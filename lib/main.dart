import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'auth/session_manager.dart';
import 'auth/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SessionManager.instance.start();
  runApp(const SivproApp());
}

class SivproApp extends StatelessWidget {
  const SivproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager.instance.registerActivity(),
      child: MaterialApp(
        title: 'La Sirena',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: SessionManager.instance.navigatorKey,
        scaffoldMessengerKey: SessionManager.instance.messengerKey,
        home: const SplashScreen(),
      ),
    );
  }
}