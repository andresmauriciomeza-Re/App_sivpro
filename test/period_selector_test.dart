import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/widgets/period_selector.dart';

const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', //
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// Réplica de la fila de Indicadores (Mes flex 3, Año flex 2) a 320 dp.
class _Periodo extends StatefulWidget {
  const _Periodo({required this.alCambiar});

  final void Function(int mes, int anio) alCambiar;

  @override
  State<_Periodo> createState() => _PeriodoState();
}

class _PeriodoState extends State<_Periodo> {
  int _mes = 11;
  int _anio = 2026;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SelectorPeriodo<int>(
              key: const Key('mes'),
              valor: _mes,
              opciones: [for (var m = 1; m <= 12; m++) m],
              etiqueta: (m) => _meses[m - 1],
              alturaMaxima: 320,
              onSelected: (v) {
                setState(() => _mes = v);
                widget.alCambiar(_mes, _anio);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SelectorPeriodo<int>(
              key: const Key('anio'),
              valor: _anio,
              opciones: const [2026, 2025, 2024, 2023, 2022],
              etiqueta: (y) => '$y',
              onSelected: (v) {
                setState(() => _anio = v);
                widget.alCambiar(_mes, _anio);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<(int, int)>> _pintar(WidgetTester tester) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final cambios = <(int, int)>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: _Periodo(alCambiar: (m, a) => cambios.add((m, a)))),
    ),
  );
  return cambios;
}

/// Material del menú abierto (el que tiene la forma redondeada).
Finder _menu() => find.byWidgetPredicate(
  (w) =>
      w is Material &&
      w.shape is RoundedRectangleBorder &&
      (w.shape as RoundedRectangleBorder).borderRadius ==
          BorderRadius.circular(16),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('elegir otro año llama al callback y el menú mide lo mismo '
      'que el campo', (tester) async {
    final cambios = await _pintar(tester);
    final campo = tester.getRect(find.byKey(const Key('anio')));

    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final menu = tester.getRect(_menu());
    expect(menu.width, closeTo(campo.width, 0.5));
    expect(menu.left, closeTo(campo.left, 0.5));
    expect(menu.top, greaterThan(campo.bottom)); // debajo, con margen
    // Solo la opción elegida lleva el check.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();
    expect(cambios, [(11, 2024)]);
    expect(find.text('2024'), findsOneWidget); // campo actualizado
    expect(_menu(), findsNothing);
  });

  testWidgets('el menú de Mes no pasa de 320 y se desplaza', (tester) async {
    final cambios = await _pintar(tester);
    final campo = tester.getRect(find.byKey(const Key('mes')));

    await tester.tap(find.text('Noviembre'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final menu = tester.getRect(_menu());
    expect(menu.height, lessThanOrEqualTo(320));
    expect(menu.width, closeTo(campo.width, 0.5));

    await tester.scrollUntilVisible(
      find.text('Enero'),
      -100,
      scrollable: find.descendant(
        of: _menu(),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Enero'));
    await tester.pumpAndSettle();
    expect(cambios, [(1, 2026)]);
  });

  testWidgets('menú de estado de producto: ancho propio bajo la píldora', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final elegidos = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topLeft,
              child: MenuApp<String>(
                opciones: const ['Automático', 'Descontinuado'],
                etiqueta: (e) => e,
                valor: 'Automático',
                ancho: 200,
                onSelected: elegidos.add,
                child: const Text('Disponible', key: Key('pildora')),
              ),
            ),
          ),
        ),
      ),
    );
    final pildora = tester.getRect(find.byKey(const Key('pildora')));

    await tester.tap(find.byKey(const Key('pildora')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final menu = tester.getRect(_menu());
    expect(menu.width, closeTo(200, 0.5));
    expect(menu.left, closeTo(pildora.left, 0.5));
    expect(menu.top, greaterThan(pildora.bottom));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Descontinuado'));
    await tester.pumpAndSettle();
    expect(elegidos, ['Descontinuado']);
  });
}
