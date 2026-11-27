import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'auth/auth_service.dart';
import 'auth/session_manager.dart';
import 'admin/notificaciones/notificaciones_repository.dart';
import 'auth/splash_screen.dart';
import 'client/services/limpieza_sesion_cliente.dart';
import 'shared/client_notification_service.dart';
import 'shared/gama_dispositivo.dart';
import 'shared/low_stock_notification_service.dart';
import 'shared/modo_oscuro_controller.dart';
import 'shared/pending_sales_service.dart';
import 'theme/app_theme.dart';
import 'theme/tema_panel.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SessionManager.instance.start();
  LowStockNotificationService.instance.start();
  PendingSalesService.instance.start();
  ClientNotificationService.instance.start();
  NotificacionesLocal.instance.start();
  ModoOscuroController.instance.cargar();
  GamaDispositivo.cargar();
  AppTheme.precargar();
  registrarLimpiezaCliente();
  runApp(const SivproApp());
}

/// Modo oscuro del panel de personal (Administrador y Empleado) con la
/// preferencia encendida; splash, login y cliente siguen en claro.
bool get _oscuroPanel => temaOscuroActivo(
  preferencia: ModoOscuroController.instance.oscuro.value,
  rol: AuthService.instance.rol,
);

class SivproApp extends StatefulWidget {
  const SivproApp({super.key});

  @override
  State<SivproApp> createState() => _SivproAppState();
}

class _SivproAppState extends State<SivproApp> {
  final Listenable _cambios = Listenable.merge([
    ModoOscuroController.instance.oscuro,
    AuthService.instance,
  ]);
  final GlobalKey _claveNavegador = GlobalKey();
  bool _oscuro = _oscuroPanel;

  @override
  void initState() {
    super.initState();
    _cambios.addListener(_alCambiar);
  }

  @override
  void dispose() {
    _cambios.removeListener(_alCambiar);
    super.dispose();
  }

  void _alCambiar() {
    final oscuro = _oscuroPanel;
    if (oscuro == _oscuro) return;
    if (!oscuro) SystemChrome.setSystemUIOverlayStyle(barraEstadoClaraIos);
    setState(() => _oscuro = oscuro);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager.instance.registerActivity(),
      child: MaterialApp(
        title: 'La Sirena',
        debugShowCheckedModeBanner: false,
        theme: _oscuro ? AppTheme.oscuro : AppTheme.claro,
        // Corta y suave; en gama baja, cambio directo.
        themeAnimationStyle: GamaDispositivo.baja
            ? AnimationStyle.noAnimation
            : AnimationStyle(
                duration: GamaDispositivo.duracionTema,
                curve: Curves.easeInOut,
              ),
        navigatorKey: SessionManager.instance.navigatorKey,
        scaffoldMessengerKey: SessionManager.instance.messengerKey,
        builder: (context, child) {
          // La clave conserva la pila de pantallas al cambiar de modo.
          final navegador = KeyedSubtree(key: _claveNavegador, child: child!);
          return _oscuro
              ? AnnotatedRegion<SystemUiOverlayStyle>(
                  value: barraEstadoOscura,
                  child: navegador,
                )
              : navegador;
        },
        home: const SplashScreen(),
      ),
    );
  }
}
