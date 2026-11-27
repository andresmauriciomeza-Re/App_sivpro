import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart' as panel;
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/profile_screen.dart' as cliente;
import 'package:sivpro_app/shared/gama_dispositivo.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

final _control = ModoOscuroController.instance;

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await _control.cambiar(false);
    backend = BackendFalso();
    GamaDispositivo.simulada = false;
  });
  tearDown(() async {
    await AuthService.instance.logout();
    await _control.cambiar(false);
    GamaDispositivo.simulada = null;
  });

  Future<void> entrar(String rol) async {
    backend.loginComo(rol);
    backend.rutas['GET /auth/me'] = (_) =>
        respuesta({'usuario': usuarioJson(rol: rol)});
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
  }

  for (final (rol, perfil) in [
    ('Empleado', () => const panel.ProfileScreen() as Widget),
    ('Cliente', () => const cliente.ProfileScreen() as Widget),
  ]) {
    testWidgets('perfil de $rol: el interruptor cambia al instante, guarda y '
        'el tema llega justo después', (tester) async {
      tester.view.physicalSize = const Size(412, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await entrar(rol);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.claro, home: perfil()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pump(); // un solo cuadro
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Activado'), findsOneWidget);
      expect(_control.oscuro.value, isFalse, reason: 'el tema aún no cambia');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ModoOscuroController.clave), isTrue);

      await tester.pump(ModoOscuroController.retardoTema);
      expect(_control.oscuro.value, isTrue);
      await tester.pumpAndSettle();
    });
  }

  test('dos toques seguidos: manda el último', () async {
    final primero = _control.alternar(true);
    final segundo = _control.alternar(false);
    await Future.wait([primero, segundo]);
    expect(_control.interruptor.value, isFalse);
    expect(_control.oscuro.value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ModoOscuroController.clave), isFalse);
  });

  for (final (nombre, baja, duracion) in [
    ('media y alta: transición corta', false, 150),
    ('baja: cambio directo', true, 0),
  ]) {
    testWidgets('gama $nombre en las pantallas del cliente', (tester) async {
      GamaDispositivo.simulada = baja;
      await entrar('Cliente');
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.claro, home: const cliente.ProfileScreen()),
      );
      await tester.pumpAndSettle();
      final tema = tester.widget<AnimatedTheme>(
        find
            .descendant(
              of: find.byType(cliente.ProfileScreen),
              matching: find.byType(AnimatedTheme),
            )
            .first,
      );
      expect(tema.duration, Duration(milliseconds: duracion));
    });
  }
}
