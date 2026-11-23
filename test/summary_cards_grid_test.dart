import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/widgets/summary_cards_grid.dart';

/// Las 4 tarjetas del inicio, con montos largos y títulos de 2 líneas.
List<Widget> _tarjetas(List<String> tocadas) => [
  SummaryCard(
    icon: Icons.attach_money,
    title: 'Ventas completadas hoy',
    value: r'$1.250.000',
    highlight: true,
    onTap: () => tocadas.add('ventas'),
  ),
  const SummaryCard(
    icon: Icons.local_pizza_outlined,
    title: 'Pedidos completados hoy',
    value: '128',
  ),
  const SummaryCard(
    icon: Icons.schedule_outlined,
    title: 'Ventas por verificar',
    value: '12',
  ),
  const SummaryCard(
    icon: Icons.inventory_2_outlined,
    title: 'Insumos en nivel mínimo',
    value: '7',
    warning: true,
  ),
];

Future<void> _pintar(
  WidgetTester tester, {
  required double escala,
  required List<String> tocadas,
}) async {
  // Ancho de pantalla 320 dp con el relleno lateral del inicio (18 + 18).
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(320, 900),
          textScaler: TextScaler.linear(escala),
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SummaryCardsGrid(cards: _tarjetas(tocadas)),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final escala in [1.0, 1.3]) {
    testWidgets('sin desborde a 320 dp con letra x$escala', (tester) async {
      final tocadas = <String>[];
      await _pintar(tester, escala: escala, tocadas: tocadas);
      // Un RenderFlex desbordado lanza una excepción durante el layout.
      expect(tester.takeException(), isNull);

      final altos = tester
          .widgetList<SummaryCard>(find.byType(SummaryCard))
          .map((w) => tester.getSize(find.byWidget(w)).height)
          .toSet();
      expect(altos.length, 1, reason: 'las 4 tarjetas miden lo mismo');

      await tester.tap(find.byType(SummaryCard).first);
      expect(tocadas, ['ventas']);
    });
  }
}
