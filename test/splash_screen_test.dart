import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/auth/splash_screen.dart';

/// Tamaños lógicos pedidos (dp) con una densidad típica de cada gama.
const _pantallas = [
  (Size(320, 568), 2.0),
  (Size(360, 640), 2.0),
  (Size(360, 780), 3.0),
  (Size(393, 851), 2.75),
  (Size(412, 915), 2.625),
  (Size(430, 932), 3.0),
];

/// La sesión nunca termina: el splash se queda en pantalla para medirlo.
Future<bool> _sesionPendiente() => Completer<bool>().future;

Future<void> _pintar(
  WidgetTester tester, {
  required Size tamano,
  required double densidad,
  double escala = 1.0,
  bool sinAnimaciones = false,
}) async {
  tester.view.physicalSize = tamano * densidad;
  tester.view.devicePixelRatio = densidad;
  // Notch arriba y barra de gestos abajo.
  tester.view.padding = FakeViewPadding(
    top: 32 * densidad,
    bottom: 24 * densidad,
  );
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(escala),
          disableAnimations: sinAnimaciones,
        ),
        child: child!,
      ),
      home: const SplashScreen(
        restaurarSesion: _sesionPendiente,
        usarSensores: false,
      ),
    ),
  );
  // Precarga (con tope de 3 s) + animación completa (2,5 s como mucho).
  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final (tamano, densidad) in _pantallas) {
    for (final escala in [1.0, 1.3]) {
      testWidgets(
        'splash completo en ${tamano.width.toInt()}x${tamano.height.toInt()} '
        'con letra x$escala',
        (tester) async {
          await _pintar(
            tester,
            tamano: tamano,
            densidad: densidad,
            escala: escala,
          );
          expect(tester.takeException(), isNull);

          final pantalla = Offset.zero & tamano;
          final texto = tester.getRect(
            find.text('Tradición  ·  Calidad  ·  Pasión'),
          );
          final boton = tester.getRect(find.text('Conectando…'));
          final titulo = tester.getRect(
            find.text('Sabores que enamoran\ndesde 1994'),
          );
          for (final r in [titulo, texto, boton]) {
            expect(pantalla.contains(r.topLeft), isTrue, reason: '$r');
            expect(pantalla.contains(r.bottomRight), isTrue, reason: '$r');
          }
          // Ni el texto pisa el botón, ni el botón entra en la barra de
          // gestos (24 dp abajo).
          expect(texto.bottom, lessThanOrEqualTo(boton.top));
          expect(boton.bottom, lessThanOrEqualTo(tamano.height - 24));
        },
      );
    }
  }

  testWidgets('gama baja (320x568 a 1.5x): animación simple sin efectos', (
    tester,
  ) async {
    await _pintar(tester, tamano: const Size(320, 568), densidad: 1.5);
    expect(tester.takeException(), isNull);
    // Sin pulso ni otros efectos: al terminar no quedan frames pendientes.
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.text('Conectando…'), findsOneWidget);
  });

  testWidgets('con "quitar animaciones" no queda ninguna animación', (
    tester,
  ) async {
    await _pintar(
      tester,
      tamano: const Size(360, 640),
      densidad: 2,
      sinAnimaciones: true,
    );
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    // La composición final se ve de inmediato.
    expect(find.text('Conectando…'), findsOneWidget);
  });

  test('nivel inicial según accesibilidad y resolución', () {
    NivelSplash nivel(Size t, double d, {bool sin = false}) =>
        nivelInicialSplash(sinAnimaciones: sin, tamano: t, densidad: d);
    expect(nivel(const Size(412, 915), 2.625, sin: true), NivelSplash.estatica);
    expect(nivel(const Size(320, 568), 1.5), NivelSplash.baja);
    expect(nivel(const Size(360, 640), 2), NivelSplash.media);
    expect(nivel(const Size(412, 915), 2.625), NivelSplash.alta);
  });
}
