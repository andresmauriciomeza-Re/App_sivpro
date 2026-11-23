import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../client/models/pedido.dart';
import '../client/services/pedidos_repository.dart';
import '../client/widgets/estado_pedido.dart';
import 'low_stock_notification_service.dart';

/// Avisos al cliente cuando cambia el `estado_cliente` de sus pedidos.
///
/// Sin push: consulta `GET /ventas/mias` cada [intervalo] solo con sesión de
/// Cliente, la app en primer plano y algún pedido sin terminar. Cada cambio
/// suma uno a la insignia de Pedidos (Mis pedidos la limpia) y muestra una
/// notificación local. La primera carga tras iniciar sesión solo toma la
/// línea base; al reabrir la app se compara con lo guardado de ese usuario.
class ClientNotificationService with WidgetsBindingObserver {
  ClientNotificationService._();
  static final ClientNotificationService instance =
      ClientNotificationService._();

  static const Duration intervalo = Duration(seconds: 50);
  static const int _idBase = 7200000;

  final ValueNotifier<Pedido?> lastReadyOrder = ValueNotifier<Pedido?>(null);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// Temporizador de la consulta; las pruebas lo controlan.
  @visibleForTesting
  Timer Function(Duration, void Function()) crearTemporizador =
      (duracion, accion) => Timer.periodic(duracion, (_) => accion());

  @visibleForTesting
  Future<bool> Function() pedirPermiso =
      LowStockNotificationService.instance.permitirAvisos;

  @visibleForTesting
  Future<void> Function(int id, String titulo, String cuerpo) mostrarAviso =
      LowStockNotificationService.instance.mostrarAvisoPedido;

  bool _iniciado = false;
  bool _activo = false;
  bool _listo = false;
  bool _enPrimerPlano = true;
  bool _permitido = false;
  int? _idUsuario;
  Timer? _timer;

  /// Cambia en cada inicio/parada para descartar trabajo de una sesión vieja.
  int _generacion = 0;

  /// Último `estado_cliente` conocido por pedido; null = sin línea base.
  Map<int, String>? _conocidos;

  /// Tras iniciar sesión, la primera carga solo es la línea base.
  bool _soloLineaBase = false;

  /// Se llama una vez en `main()`.
  void start() {
    if (_iniciado) return;
    _iniciado = true;
    AuthService.instance.addListener(_alCambiarSesion);
    PedidosRepository.instance.addListener(_alCambiarPedidos);
    WidgetsBinding.instance.addObserver(this);
    _alCambiarSesion();
  }

  void _alCambiarSesion() {
    final usuario = AuthService.instance.usuario;
    final cliente =
        AuthService.instance.isAuthenticated &&
        AuthService.instance.rol == UserRole.cliente &&
        usuario != null;
    if (cliente && !_activo) {
      _activo = true;
      _idUsuario = usuario.id;
      _arrancar();
    } else if (!cliente && _activo) {
      _detener();
    }
  }

  Future<void> _arrancar() async {
    final generacion = ++_generacion;
    final guardados = _soloLineaBase ? null : await _leerGuardados();
    if (generacion != _generacion || !_activo) return;
    _conocidos ??= guardados;
    _listo = true;
    unawaited(
      pedirPermiso().then((permitido) {
        if (generacion == _generacion) _permitido = permitido;
      }, onError: (_) {}),
    );
    if (PedidosRepository.instance.pedidos != null) _alCambiarPedidos();
    await _consultar();
  }

  void _detener() {
    _generacion++;
    _activo = false;
    _listo = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enPrimerPlano = true;
      _consultar();
      _programar();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _enPrimerPlano = false;
      _programar();
    }
  }

  bool get _hayPendientes =>
      PedidosRepository.instance.pedidos?.any((p) => p.activo) ?? false;

  /// Consulta periódica solo mientras haga falta; si ya corre, se conserva.
  void _programar() {
    if (_activo && _listo && _enPrimerPlano && _hayPendientes) {
      _timer ??= crearTemporizador(intervalo, _consultar);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// El repositorio nunca hace dos consultas a la vez.
  Future<void> _consultar() async {
    if (!_activo || !_listo || !_enPrimerPlano) return;
    try {
      await PedidosRepository.instance.listar(recargar: true);
    } catch (_) {
      // Sin red: se intenta en la siguiente vuelta. El 401 lo maneja el
      // cliente HTTP.
    }
  }

  void _alCambiarPedidos() {
    final pedidos = PedidosRepository.instance.pedidos;
    if (!_activo || !_listo || pedidos == null) return;
    final anteriores = _conocidos;
    final actuales = {for (final p in pedidos) p.id: p.estadoCliente};
    _conocidos = actuales;
    _soloLineaBase = false;
    unawaited(_guardar(actuales));
    if (anteriores != null) {
      for (final pedido in pedidos) {
        final antes = anteriores[pedido.id];
        if (antes != null && antes != pedido.estadoCliente) _avisar(pedido);
      }
    }
    _programar();
  }

  void _avisar(Pedido pedido) {
    unreadCount.value = unreadCount.value + 1;
    if (pedido.estadoCliente == 'Por entregar') lastReadyOrder.value = pedido;
    if (!_permitido) return;
    final estilo = EstiloEstadoPedido.de(pedido.estadoCliente);
    unawaited(
      mostrarAviso(
        _idBase + pedido.id,
        'Pedido #${pedido.id}: ${estilo.etiqueta}',
        mensajeEstadoPedido(pedido) ?? 'Tu pedido cambió de estado.',
      ).catchError((Object _) {}),
    );
  }

  String _clave(int idUsuario) => 'estados_pedidos_$idUsuario';

  Future<Map<int, String>?> _leerGuardados() async {
    final id = _idUsuario;
    if (id == null) return null;
    try {
      final texto = (await SharedPreferences.getInstance()).getString(
        _clave(id),
      );
      if (texto == null) return null;
      final datos = jsonDecode(texto);
      if (datos is! Map<String, dynamic>) return null;
      return {
        for (final MapEntry(:key, :value) in datos.entries)
          if (int.tryParse(key) != null && value is String)
            int.parse(key): value,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> _guardar(Map<int, String> estados) async {
    final id = _idUsuario;
    if (id == null) return;
    try {
      await (await SharedPreferences.getInstance()).setString(
        _clave(id),
        jsonEncode({
          for (final MapEntry(:key, :value) in estados.entries) '$key': value,
        }),
      );
    } catch (_) {
      // Sin almacenamiento solo se pierde la comparación al reabrir la app.
    }
  }

  /// Al terminar una sesión (o iniciar otra): se olvida todo lo del usuario
  /// y la siguiente carga vuelve a ser solo la línea base.
  void limpiar() {
    final id = _idUsuario;
    _detener();
    _idUsuario = null;
    _conocidos = null;
    _soloLineaBase = true;
    lastReadyOrder.value = null;
    unreadCount.value = 0;
    if (id != null) {
      unawaited(
        SharedPreferences.getInstance()
            .then((prefs) => prefs.remove(_clave(id)))
            .then<void>((_) {}, onError: (_) {}),
      );
    }
  }

  void markAllRead() {
    if (unreadCount.value != 0) unreadCount.value = 0;
  }
}
