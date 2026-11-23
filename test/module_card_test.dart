import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/widgets/module_card.dart';

const _produccion = [
  (
    'Órdenes de producción',
    'Consultar, actualizar y cambiar estado de órdenes.',
  ),
  ('Productos', 'Consultar y actualizar productos.'),
  ('Categorías de producto', 'Consultar y actualizar categorías.'),
  ('Productos no conformes', 'Consultar y completar registros.'),
  ('Empleados', 'Consultar y actualizar empleados.'),
];

/// Simula el hub: lista desplazable (relleno 24) y barra inferior debajo.
Future<void> _pintarHub(WidgetTester tester, double escala) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(320, 640),
          textScaler: TextScaler.linear(escala),
        ),
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    for (final (titulo, descripcion) in _produccion) ...[
                      ModuleCard(
                        icon: Icons.inventory_2_outlined,
                        title: titulo,
                        description: descripcion,
                        onTap: () {},
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
              const SizedBox(key: Key('barra'), height: 80),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('con texto que cabe mide 288, igual que antes (Compras)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              ModuleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Compras',
                description: 'Consultar compras',
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(ModuleCard)).height,
      ModuleCard.altoMinimo,
    );
  });

  for (final escala in [1.0, 1.3]) {
    testWidgets('hub de Producción a 320 dp con letra x$escala', (
      tester,
    ) async {
      await _pintarHub(tester, escala);
      expect(tester.takeException(), isNull);

      // La lista se desplaza y la última tarjeta queda visible por encima
      // de la barra inferior.
      final ultima = find.text('Empleados');
      await tester.scrollUntilVisible(
        ultima,
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final barraArriba = tester.getTopLeft(find.byKey(const Key('barra'))).dy;
      expect(tester.getBottomLeft(ultima).dy, lessThanOrEqualTo(barraArriba));
    });
  }
}
