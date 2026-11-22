import 'dart:async';

import 'package:material_ui/material_ui.dart';
import '../auth/auth_service.dart';

/// Refresco por sondeo mientras la pantalla está visible.
///
/// No es tiempo real: no hay push, WebSocket ni SSE. Cada consulta se hace
/// cada [intervaloRefresco] y solo si la ruta sigue activa, la app está en
/// primer plano y la sesión sigue abierta. Las pantallas deben ignorar
/// llamadas solapadas (por ejemplo con su propio indicador de recarga).
mixin PeriodicRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _appActiva = true;

  Duration get intervaloRefresco => const Duration(seconds: 45);

  Future<void> refrescarPeriodico();

  void iniciarRefrescoPeriodico() {
    detenerRefrescoPeriodico();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _appActiva = state == AppLifecycleState.resumed;
      },
    );
    AuthService.instance.addListener(_alCambiarSesion);
    _timer = Timer.periodic(intervaloRefresco, (_) => _tick());
  }

  void detenerRefrescoPeriodico() {
    _timer?.cancel();
    _timer = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    AuthService.instance.removeListener(_alCambiarSesion);
  }

  void _alCambiarSesion() {
    if (!AuthService.instance.isAuthenticated) detenerRefrescoPeriodico();
  }

  void _tick() {
    if (!mounted || !_appActiva) return;
    if (!AuthService.instance.isAuthenticated) {
      detenerRefrescoPeriodico();
      return;
    }
    if (ModalRoute.of(context)?.isCurrent != true) return;
    refrescarPeriodico();
  }

  @override
  void dispose() {
    detenerRefrescoPeriodico();
    super.dispose();
  }
}
