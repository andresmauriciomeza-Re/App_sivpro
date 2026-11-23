import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'auth/auth_service.dart';
import 'auth/session_manager.dart';
import 'auth/splash_screen.dart';
import 'shared/low_stock_notification_service.dart';
import 'shared/modo_oscuro_controller.dart';
import 'shared/pending_sales_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SessionManager.instance.start();
  LowStockNotificationService.instance.start();
  PendingSalesService.instance.start();
  ModoOscuroController.instance.cargar();
  runApp(const SivproApp());
}

/// Modo oscuro activo: solo con la preferencia encendida y sesión de
/// Administrador (login, splash, empleado y cliente siguen en claro).
bool get _oscuroAdmin =>
    ModoOscuroController.instance.oscuro.value &&
    AuthService.instance.rol == UserRole.admin;

/// Barra de estado del modo oscuro (iconos claros). Al salir se restaura el
/// estilo claro en iOS; en Android no se fija nada en modo claro.
const SystemUiOverlayStyle _barraOscura = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);
const SystemUiOverlayStyle _barraClaraIos = SystemUiOverlayStyle(
  statusBarBrightness: Brightness.light,
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
  bool _oscuro = _oscuroAdmin;

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
    final oscuro = _oscuroAdmin;
    if (oscuro == _oscuro) return;
    if (!oscuro) SystemChrome.setSystemUIOverlayStyle(_barraClaraIos);
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
        navigatorKey: SessionManager.instance.navigatorKey,
        scaffoldMessengerKey: SessionManager.instance.messengerKey,
        builder: (context, child) {
          // La clave conserva la pila de pantallas al cambiar de modo.
          final navegador = KeyedSubtree(key: _claveNavegador, child: child!);
          return _oscuro
              ? AnnotatedRegion<SystemUiOverlayStyle>(
                  value: _barraOscura,
                  child: navegador,
                )
              : navegador;
        },
        home: const SplashScreen(),
      ),
    );
  }
}
