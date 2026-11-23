import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/widgets/module_card.dart';
import 'package:sivpro_app/shared/tarjeta_modo_oscuro.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_colors.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test(
    'en claro la paleta devuelve el color de siempre; en oscuro, la oscura',
    () {
      const claro = PaletaApp.claro;
      for (final c in [
        AppColors.page,
        AppColors.ink,
        AppColors.red,
        Colors.white,
      ]) {
        expect(claro.fondo(c), c);
        expect(claro.tarjeta(c), c);
        expect(claro.texto(c), c);
        expect(claro.rojo(c), c);
        expect(claro.sombra(c), c);
        expect(claro.exitoFondo(c), c);
      }
      const oscuro = PaletaApp.modoOscuro;
      expect(oscuro.fondo(AppColors.page), PaletaApp.fondoOscuro);
      expect(oscuro.tarjeta(Colors.white), PaletaApp.tarjetaOscura);
      expect(oscuro.texto(AppColors.ink), PaletaApp.textoOscuro);
      expect(oscuro.sombra(Colors.black), Colors.transparent);
      expect(AppTheme.claro.extension<PaletaApp>(), same(PaletaApp.claro));
      expect(
        AppTheme.oscuro.extension<PaletaApp>(),
        same(PaletaApp.modoOscuro),
      );
    },
  );

  test(
    'la preferencia se guarda en el dispositivo y se vuelve a leer',
    () async {
      SharedPreferences.setMockInitialValues({
        ModoOscuroController.clave: true,
      });
      final control = ModoOscuroController.instance;
      await control.cargar();
      expect(control.oscuro.value, isTrue);

      await control.cambiar(false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ModoOscuroController.clave), isFalse);
      expect(control.oscuro.value, isFalse);
    },
  );

  testWidgets('toda la fila y el interruptor alternan el modo, sin desborde', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var oscuro = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) => TarjetaModoOscuro(
                  oscuro: oscuro,
                  onChanged: (v) => setState(() => oscuro = v),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Desactivado'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('Cambiar modo oscuro'), findsOneWidget);
    expect(
      tester.getSize(find.byType(Switch)).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('Modo oscuro'));
    await tester.pumpAndSettle();
    expect(oscuro, isTrue);
    expect(find.text('Activado'), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(oscuro, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tarjeta de módulo usa los colores de siempre en claro '
      'y la paleta en oscuro', (tester) async {
    Future<BoxDecoration> decoracion(ThemeData tema) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: ModuleCard(
                icon: Icons.inventory_2_outlined,
                title: 'Insumos',
                description: 'Existencias',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final caja = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ModuleCard),
              matching: find.byType(Container),
            )
            .first,
      );
      return caja.decoration! as BoxDecoration;
    }

    final claro = await decoracion(AppTheme.claro);
    expect(claro.color, PurchasesScreen.page);
    expect((claro.border! as Border).top.color, const Color(0xFFE8C7C4));

    final oscuro = await decoracion(AppTheme.oscuro);
    expect(oscuro.color, PaletaApp.tarjetaOscura);
    expect((oscuro.border! as Border).top.color, PaletaApp.bordeOscuro);
    expect(tester.takeException(), isNull);
  });
}
