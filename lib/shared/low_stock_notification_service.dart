import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../admin/notificaciones/barra_telefono.dart';
import '../admin/notificaciones/notificaciones_repository.dart';
import '../admin/screens/notificaciones_screen.dart';
import '../admin/services/insumos_repository.dart';
import '../auth/auth_service.dart';
import '../auth/permisos.dart';
import '../auth/session_manager.dart';

/// Notificaciones LOCALES del teléfono (dueño del plugin).
///
/// Consulta `GET /insumos` al iniciar o restaurar la sesión y luego cada
/// [intervalo] en primer plano (sin push ni segundo plano) y entrega la lista
/// a [NotificacionesLocal]. Es esa lista, con su línea base guardada, la que
/// decide qué es nuevo y pide mostrarlo en la barra ([BarraTelefono]).
class LowStockNotificationService
    with WidgetsBindingObserver
    implements BarraTelefono {
  LowStockNotificationService._();

  static final LowStockNotificationService instance =
      LowStockNotificationService._();

  static const Duration intervalo = Duration(minutes: 5);

  static const String _canalId = 'insumos_nivel_minimo';
  static const String _canalVentasId = 'ventas_por_verificar';
  static const String _payload = 'notificaciones_panel';

  /// El de los avisos que dejó en la barra la versión anterior.
  static const String _payloadAnterior = 'insumos_nivel_minimo';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  bool _iniciado = false;
  bool _activo = false;
  bool _consultando = false;
  bool _pluginListo = false;
  bool _permisoSolicitado = false;
  bool _permitido = false;

  /// Cambia en cada inicio/parada para descartar consultas de una sesión vieja.
  int _generacion = 0;

  /// Petición de permiso en curso: los avisos esperan a que termine.
  Future<void>? _permiso;
  Future<void> _permisoListo() => _permiso ??= _asegurarPermiso();

  /// La app se abrió tocando un aviso del panel y falta llevar a la pantalla.
  Future<void>? _lanzamiento;
  bool _abrirAlEntrar = false;

  bool get _plataformaSoportada =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Se llama una vez en `main()`. Reacciona a inicio y cierre de sesión.
  void start() {
    if (_iniciado) return;
    _iniciado = true;
    NotificacionesLocal.barra = this;
    if (_plataformaSoportada) _lanzamiento = _revisarLanzamiento();
    AuthService.instance.addListener(_alCambiarSesion);
    WidgetsBinding.instance.addObserver(this);
    _alCambiarSesion();
  }

  void _alCambiarSesion() {
    final autenticado = AuthService.instance.isAuthenticated;
    if (autenticado && !_activo) {
      _activo = true;
      _arrancar();
    } else if (!autenticado && _activo) {
      _activo = false;
      _detener();
    }
  }

  Future<void> _arrancar() async {
    if (!_plataformaSoportada) return;
    final generacion = ++_generacion;
    await _permisoListo();
    if (generacion != _generacion || !_activo) return;
    _programarTemporizador();
    await _consultar();
  }

  void _detener() {
    _generacion++;
    _timer?.cancel();
    _timer = null;
  }

  void _programarTemporizador() {
    _timer?.cancel();
    _timer = Timer.periodic(intervalo, (_) => _consultar());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_activo || !_plataformaSoportada) return;
    if (state == AppLifecycleState.resumed) {
      _programarTemporizador();
      _consultar();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Para los avisos de pedidos del cliente (mismo plugin): inicializa y
  /// pide el permiso (Android 13+ / iOS) una sola vez por ejecución.
  Future<bool> permitirAvisos() async {
    if (!_plataformaSoportada) return false;
    await _asegurarPermiso();
    return _permitido;
  }

  /// Muestra el aviso de un cambio de estado de un pedido del cliente.
  Future<void> mostrarAvisoPedido(int id, String titulo, String cuerpo) async {
    if (!_plataformaSoportada || !_pluginListo) return;
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        'pedidos_cliente',
        'Mis pedidos',
        channelDescription: 'Avisos cuando cambia el estado de tus pedidos',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    try {
      await _plugin.show(id, titulo, cuerpo, detalles);
    } catch (_) {
      // Una notificación fallida no debe afectar a la app.
    }
  }

  /// Inicializa el plugin y pide el permiso una sola vez por ejecución.
  Future<void> _asegurarPermiso() async {
    try {
      await _inicializarPlugin();
      if (_permisoSolicitado) return;
      _permisoSolicitado = true;

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        _permitido = await android.requestNotificationsPermission() ?? false;
      } else if (ios != null) {
        _permitido =
            await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (_) {
      _permitido = false;
    }
  }

  Future<void> _inicializarPlugin() async {
    if (_pluginListo) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // El permiso se pide después de iniciar sesión, no al inicializar.
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _alTocarNotificacion,
    );
    _pluginListo = true;
  }

  Future<void> _revisarLanzamiento() async {
    try {
      final datos = await _plugin.getNotificationAppLaunchDetails();
      if (datos?.didNotificationLaunchApp ?? false) {
        _abrirAlEntrar = _esDelPanel(datos!.notificationResponse?.payload);
      }
    } catch (_) {
      // Sin plugin: la app abre normalmente.
    }
  }

  bool _esDelPanel(String? payload) =>
      payload == _payload || payload == _payloadAnterior;

  void _alTocarNotificacion(NotificationResponse respuesta) =>
      alTocar(respuesta.payload);

  /// Aviso tocado con la app abierta.
  @visibleForTesting
  void alTocar(String? payload) {
    if (_esDelPanel(payload)) _abrirNotificaciones();
  }

  /// Simula que la app se abrió tocando un aviso.
  @visibleForTesting
  set abiertaDesdeAviso(String? payload) =>
      _abrirAlEntrar = _esDelPanel(payload);

  /// Lo llama el splash cuando ya puso la pantalla de inicio de la sesión
  /// restaurada: si se entró tocando un aviso, abre Notificaciones encima.
  Future<void> abrirPendiente() async {
    await _lanzamiento;
    if (!_abrirAlEntrar) return;
    _abrirAlEntrar = false;
    _abrirNotificaciones();
  }

  /// Sin sesión al abrir: la app sigue su camino normal.
  void descartarPendiente() {
    _lanzamiento = null;
    _abrirAlEntrar = false;
  }

  bool get _esPersonal {
    final rol = AuthService.instance.rol;
    return AuthService.instance.isAuthenticated &&
        (rol == UserRole.admin || rol == UserRole.empleado);
  }

  /// Notificaciones del panel sobre la pantalla de inicio, solo con sesión de
  /// Administrador o Empleado.
  void _abrirNotificaciones() {
    if (!_esPersonal) return;
    final navigator = SessionManager.instance.navigatorKey.currentState;
    if (navigator == null) return;
    navigator
      ..popUntil((route) => route.isFirst)
      ..push(
        MaterialPageRoute<void>(builder: (_) => const NotificacionesScreen()),
      );
  }

  /// Solo personal (Administrador o Empleado) con Compras › Insumos › Ver.
  bool get _puedeLeerInsumos {
    final rol = AuthService.instance.rol;
    final esPersonal = rol == UserRole.admin || rol == UserRole.empleado;
    return esPersonal && Permisos.puede('Compras', 'Insumos', 'Ver');
  }

  Future<void> _consultar() async {
    if (_consultando || !_activo || !_permitido) return;
    if (!AuthService.instance.isAuthenticated || !_puedeLeerInsumos) return;

    final generacion = _generacion;
    _consultando = true;
    try {
      final insumos = await InsumosRepository.instance.listar(estado: true);
      if (generacion != _generacion || !_activo) return;
      await NotificacionesLocal.instance.desdeInsumos(insumos);
    } catch (_) {
      // Sin red, 401 o 403: no se avisa ni se muestra nada. El 401 de sesión
      // ya lo maneja el cliente HTTP.
    } finally {
      _consultando = false;
    }
  }

  @override
  Future<void> avisarInsumos(int id, List<Insumo> nuevos) async {
    final String titulo;
    final String cuerpo;
    if (nuevos.length == 1) {
      final insumo = nuevos.first;
      titulo = 'Insumo en nivel mínimo';
      cuerpo =
          '${insumo.nombre} llegó al nivel mínimo '
          '(${_cantidad(insumo.stockActual)} ${insumo.unidadMedida}).';
    } else {
      titulo = '${nuevos.length} insumos llegaron al nivel mínimo';
      final nombres = nuevos.take(3).map((i) => i.nombre).join(', ');
      final restantes = nuevos.length - 3;
      cuerpo = restantes > 0 ? '$nombres y $restantes más.' : '$nombres.';
    }

    await _mostrarDelPanel(
      id,
      titulo,
      cuerpo,
      const AndroidNotificationDetails(
        _canalId,
        'Insumos en nivel mínimo',
        channelDescription:
            'Avisos cuando un insumo llega a su nivel mínimo de existencias',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  @override
  Future<void> avisarVenta(int id, String titulo, String cuerpo) =>
      _mostrarDelPanel(
        id,
        titulo,
        cuerpo,
        const AndroidNotificationDetails(
          _canalVentasId,
          'Ventas por verificar',
          channelDescription: 'Avisos de ventas nuevas por verificar',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  Future<void> _mostrarDelPanel(
    int id,
    String titulo,
    String cuerpo,
    AndroidNotificationDetails android,
  ) async {
    if (!_plataformaSoportada) return;
    await _permisoListo();
    // Si la sesión se cerró mientras tanto, no se muestra nada.
    if (!_permitido || !_esPersonal) return;
    try {
      await _plugin.show(
        id,
        titulo,
        cuerpo,
        NotificationDetails(
          android: android,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: _payload,
      );
    } catch (_) {
      // Una notificación fallida no debe afectar a la app.
    }
  }

  @override
  Future<void> cancelar(int id) async {
    if (!_plataformaSoportada) return;
    try {
      await _inicializarPlugin();
      await _plugin.cancel(id);
    } catch (_) {
      // Si no se puede quitar, se queda en la barra.
    }
  }

  String _cantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    return valor.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }
}
