import 'dart:async';

import 'package:flutter/widgets.dart';

import '../admin/notificaciones/notificaciones_repository.dart';
import '../admin/services/ventas_repository.dart';
import '../auth/auth_service.dart';
import '../auth/permisos.dart';

/// Contador en vivo de ventas con estado "Por verificar".
///
/// Se alimenta de `GET /ventas`: al iniciar o restaurar la sesión, al volver
/// la app a primer plano, cada [intervalo] mientras está en primer plano y
/// cuando una pantalla de ventas carga su lista ([actualizarDesde]). Solo
/// consulta con sesión y permiso Ventas > Ventas > Ver; al cerrar sesión se
/// detiene y vuelve a 0. Los errores 401, 403 o de red se ignoran.
class PendingSalesService with WidgetsBindingObserver {
  PendingSalesService._();

  static final PendingSalesService instance = PendingSalesService._();

  static const Duration intervalo = Duration(minutes: 2);

  final ValueNotifier<int> count = ValueNotifier<int>(0);

  Timer? _timer;
  bool _iniciado = false;
  bool _activo = false;
  bool _consultando = false;

  /// Cambia en cada inicio/parada para descartar consultas de una sesión vieja.
  int _generacion = 0;

  bool get _puedeLeerVentas => Permisos.puede('Ventas', 'Ventas', 'Ver');

  /// Se llama una vez en `main()`. Reacciona a inicio y cierre de sesión.
  void start() {
    if (_iniciado) return;
    _iniciado = true;
    AuthService.instance.addListener(_alCambiarSesion);
    WidgetsBinding.instance.addObserver(this);
    _alCambiarSesion();
  }

  void _alCambiarSesion() {
    // Solo personal: con sesión de Cliente no se consulta ni se programa nada.
    final personal =
        AuthService.instance.isAuthenticated &&
        AuthService.instance.rol != UserRole.cliente;
    if (personal && !_activo) {
      _activo = true;
      _generacion++;
      _programarTemporizador();
      refrescar();
    } else if (!personal && _activo) {
      _activo = false;
      _generacion++;
      _timer?.cancel();
      _timer = null;
      count.value = 0;
    }
  }

  void _programarTemporizador() {
    _timer?.cancel();
    _timer = Timer.periodic(intervalo, (_) => refrescar());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_activo) return;
    if (state == AppLifecycleState.resumed) {
      _programarTemporizador();
      refrescar();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Consulta `GET /ventas` y actualiza el contador. Salta si ya hay una en curso.
  Future<void> refrescar() async {
    if (_consultando || !_activo) return;
    if (!AuthService.instance.isAuthenticated || !_puedeLeerVentas) return;

    final generacion = _generacion;
    _consultando = true;
    try {
      final ventas = await VentasRepository.instance.listar();
      if (generacion != _generacion || !_activo) return;
      actualizarDesde(ventas);
    } catch (_) {
      // Sin red, 401 o 403: se conserva el último valor sin mostrar errores.
    } finally {
      _consultando = false;
    }
  }

  /// Reutiliza una lista ya cargada por una pantalla para no repetir la llamada.
  /// También alimenta las notificaciones del panel.
  void actualizarDesde(List<Venta> ventas) {
    unawaited(NotificacionesLocal.instance.desdeVentas(ventas));
    final pendientes = ventas
        .where((venta) => venta.estado == EstadoVenta.porVerificar)
        .length;
    if (count.value != pendientes) count.value = pendientes;
  }
}
