import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/login_screen.dart';
import 'package:sivpro_app/auth/splash_screen.dart';
import 'package:sivpro_app/network/api_exception.dart';
import 'package:sivpro_app/shared/gama_dispositivo.dart';

Future<void> _montar(
  WidgetTester tester,
  Future<bool> Function() restaurar, {
  bool sinAnimaciones = false,
}) async {
  tester.view.physicalSize = const Size(412, 915) * 2.625;
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: sinAnimaciones),
        child: child!,
      ),
      home: SplashScreen(restaurarSesion: restaurar, usarSensores: false),
    ),
  );
}

/// Avanza en pasos cortos [total], como lo haría el reloj de verdad.
Future<void> _avanzar(WidgetTester tester, Duration total) async {
  const paso = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < total; t += paso) {
    await tester.pump(paso);
  }
}

/// Avanza hasta que aparezca [algo] y devuelve los milisegundos que tardó.
Future<int> _hasta(WidgetTester tester, Finder algo) async {
  var ms = 0;
  while (algo.evaluate().isEmpty && ms < 15000) {
    await tester.pump(const Duration(milliseconds: 100));
    ms += 100;
  }
  expect(algo, findsOneWidget);
  return ms;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GamaDispositivo.simulada = false;
  });
  tearDown(() => GamaDispositivo.simulada = null);

  for (final (nombre, baja, duracion) in [
    ('media y alta', false, 2500),
    ('baja', true, 1800),
  ]) {
    testWidgets('gama $nombre: no navega antes de terminar la animación y sin '
        'sesión va a Login', (tester) async {
      GamaDispositivo.simulada = baja;
      var consultas = 0;
      await _montar(tester, () async {
        consultas++;
        return false; // la respuesta llega de inmediato
      });
      expect(consultas, 1, reason: 'en paralelo con la animación');

      // Cuánto tarda en salir. (En pruebas la animación empieza cuando vence
      // el tope de 3 s de la precarga de imágenes.)
      var ms = 0;
      while (find.byType(LoginScreen).evaluate().isEmpty && ms < 15000) {
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('Conectando…'), findsNothing);
        await tester.pump(const Duration(milliseconds: 100));
        ms += 100;
      }
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(ms, greaterThanOrEqualTo(duracion + 300), reason: 'completa');
      expect(ms, lessThanOrEqualTo(duracion + 3700));
    });
  }

  testWidgets('servidor lento: termina la animación, muestra "Conectando…" y '
      'navega al responder', (tester) async {
    final respuesta = Completer<bool>();
    await _montar(tester, () => respuesta.future);
    // Solo cuando la animación ya terminó.
    final ms = await _hasta(tester, find.text('Conectando…'));
    expect(ms, greaterThanOrEqualTo(2500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Mientras tanto el botón no saca del splash.
    await tester.tap(find.text('Conectando…'));
    await _avanzar(tester, const Duration(seconds: 1));
    expect(find.byType(LoginScreen), findsNothing);

    respuesta.complete(false);
    await _avanzar(tester, const Duration(seconds: 2));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('error de red: el aviso "Sin conexión" sale después de la '
      'animación', (tester) async {
    await _montar(
      tester,
      () async => throw const ApiException('No se pudo conectar.'),
    );
    final ms = await _hasta(tester, find.text('Sin conexión'));
    expect(ms, greaterThanOrEqualTo(2500 + 300));
    await _avanzar(tester, const Duration(milliseconds: 500));
    await tester.tap(find.text('Ir a iniciar sesión'));
    await _avanzar(tester, const Duration(seconds: 1));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('con "quitar animaciones" va a Login sin animar', (tester) async {
    await _montar(tester, () async => false, sinAnimaciones: true);
    // Solo el tope de la precarga (3 s en pruebas) y la pausa final.
    await _avanzar(tester, const Duration(seconds: 4));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('gama baja: hasta 3 GB de RAM o Android 8.1', () {
    bool baja(int ram, int sdk) => GamaDispositivo.esBaja(ramMb: ram, sdk: sdk);
    expect(baja(1900, 34), isTrue);
    expect(baja(2850, 33), isTrue); // "3 GB"
    expect(baja(3700, 33), isFalse); // "4 GB"
    expect(baja(7600, 27), isTrue); // Android 8.1
    expect(baja(7600, 28), isFalse);
    expect(baja(0, 0), isFalse); // sin datos
  });
}
