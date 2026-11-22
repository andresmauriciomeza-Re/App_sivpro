import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../admin/screens/purchases_screen.dart' show insumosScreen;
import '../admin/services/insumos_repository.dart';
import '../auth/auth_service.dart';
import '../auth/permisos.dart';
import '../auth/session_manager.dart';

/// Avisa con una notificación LOCAL cuando un insumo activo llega al nivel
/// mínimo (`stock_actual <= stock_minimo`).
///
/// No usa push ni segundo plano: consulta `GET /insumos` al iniciar o restaurar
/// la sesión y luego cada [intervalo] mientras la app está en primer plano.
class LowStockNotificationService with WidgetsBindingObserver {
  LowStockNotificationService._();

  static final LowStockNotificationService instance =
      LowStockNotificationService._();

  static const Duration intervalo = Duration(minutes: 5);

  static const int _idNotificacion = 7101;
  static const String _canalId = 'insumos_nivel_minimo';
  static const String _payload = 'insumos_nivel_minimo';

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

  /// Insumos que ya se avisaron y siguen bajo el mínimo (solo en memoria).
  final Set<int> _avisados = <int>{};

  bool get _plataformaSoportada =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Se llama una vez en `main()`. Reacciona a inicio y cierre de sesión.
  void start() {
    if (_iniciado) return;
    _iniciado = true;
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
    await _asegurarPermiso();
    if (generacion != _generacion || !_activo) return;
    _programarTemporizador();
    await _consultar();
  }

  void _detener() {
    _generacion++;
    _timer?.cancel();
    _timer = null;
    _avisados.clear();
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

  /// Abre Compras → Insumos si hay sesión y permiso de lectura.
  void _alTocarNotificacion(NotificationResponse respuesta) {
    if (respuesta.payload != _payload) return;
    if (!AuthService.instance.isAuthenticated || !_puedeLeerInsumos) return;
    SessionManager.instance.navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => insumosScreen()),
    );
  }

  bool get _puedeLeerInsumos => Permisos.puede('Compras', 'Insumos', 'Ver');

  Future<void> _consultar() async {
    if (_consultando || !_activo || !_permitido) return;
    if (!AuthService.instance.isAuthenticated || !_puedeLeerInsumos) return;

    final generacion = _generacion;
    _consultando = true;
    try {
      final insumos = await InsumosRepository.instance.listar(estado: true);
      if (generacion != _generacion || !_activo) return;
      await _procesar(insumos);
    } catch (_) {
      // Sin red, 401 o 403: no se avisa ni se muestra nada. El 401 de sesión
      // ya lo maneja el cliente HTTP.
    } finally {
      _consultando = false;
    }
  }

  Future<void> _procesar(List<Insumo> insumos) async {
    final bajos = insumos.where((i) => i.estado && i.bajoMinimo).toList();
    final nuevos = bajos.where((i) => !_avisados.contains(i.id)).toList();
    // Los recuperados salen del registro: si vuelven a bajar se avisa otra vez.
    _avisados
      ..clear()
      ..addAll(bajos.map((i) => i.id));
    if (nuevos.isEmpty) return;
    await _mostrar(nuevos);
  }

  Future<void> _mostrar(List<Insumo> nuevos) async {
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

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        _canalId,
        'Insumos en nivel mínimo',
        channelDescription:
            'Avisos cuando un insumo llega a su nivel mínimo de existencias',
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
      await _plugin.show(
        _idNotificacion,
        titulo,
        cuerpo,
        detalles,
        payload: _payload,
      );
    } catch (_) {
      // Una notificación fallida no debe afectar a la app.
    }
  }

  String _cantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    return valor.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }
}
