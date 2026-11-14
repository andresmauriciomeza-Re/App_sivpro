import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../config/api_config.dart';
import 'auth_service.dart';
import 'login_screen.dart';

/// Cierra la sesión tras 15 minutos sin actividad y reacciona cuando el
/// backend invalida el token.
class SessionManager with WidgetsBindingObserver {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Timer? _timer;
  DateTime? _ultimaActividad;
  bool _iniciado = false;

  void start() {
    if (_iniciado) return;
    _iniciado = true;
    AuthService.instance.onSessionExpired = _sesionExpirada;
    AuthService.instance.addListener(_alCambiarSesion);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Las pantallas raíz llaman a este método en cada toque.
  void registerActivity() {
    if (!AuthService.instance.isAuthenticated) return;
    _ultimaActividad = DateTime.now();
    _reiniciarTemporizador();
  }

  void _alCambiarSesion() {
    if (AuthService.instance.isAuthenticated) {
      _ultimaActividad = DateTime.now();
      _reiniciarTemporizador();
    } else {
      _timer?.cancel();
      _ultimaActividad = null;
    }
  }

  void _reiniciarTemporizador() {
    _timer?.cancel();
    _timer = Timer(ApiConfig.inactivityTimeout, _cerrarPorInactividad);
  }

  Future<void> _cerrarPorInactividad() async {
    if (!AuthService.instance.isAuthenticated) return;
    await AuthService.instance.logout();
    _irAlLogin('Tu sesión se cerró por inactividad. Inicia sesión nuevamente.');
  }

  void _sesionExpirada(String mensaje) {
    _timer?.cancel();
    _irAlLogin(mensaje);
  }

  void _irAlLogin(String mensaje) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = messengerKey.currentState;
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFC9151E),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(mensaje),
          ),
        );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!AuthService.instance.isAuthenticated) return;

    if (state == AppLifecycleState.resumed) {
      final ultima = _ultimaActividad;
      if (ultima != null &&
          DateTime.now().difference(ultima) >= ApiConfig.inactivityTimeout) {
        _cerrarPorInactividad();
      } else {
        _reiniciarTemporizador();
      }
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
    }
  }
}