import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';

import 'support/backend_falso.dart';

Map<String, dynamic> _insumo(
  int id,
  String nombre, {
  String tipo = 'Insumo',
  Object actual = '12.9',
  Object minimo = '4',
  Object? maximo,
  bool estado = true,
}) => {
  'id_insumo': id,
  'nombre': nombre,
  'tipo': tipo,
  'categoria_nombre': 'Lácteos',
  'unidad_medida': 'lt',
  'stock_actual': actual,
  'stock_minimo': minimo,
  'stock_maximo': maximo,
  'estado': estado,
};

final _insumos = [
  _insumo(1, 'Leche'),
  _insumo(2, 'Queso', actual: '0', minimo: '5', estado: false),
  _insumo(3, 'Salsa base', tipo: 'Producto insumo', minimo: '5', maximo: 20),
];

final _leyenda = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_StockBarLegend',
);

Finder _enLeyenda(String texto) =>
    find.descendant(of: _leyenda, matching: find.text(texto));

const _textosLeyenda = [
  'Stock mínimo',
  'Sobre el mínimo',
  'Bajo el mínimo',
  'Agotado',
];

Future<void> _montar(
  WidgetTester tester, {
  ThemeData? tema,
  double ancho = 412,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: tema ?? AppTheme.claro,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(letra)),
        child: child!,
      ),
      home: insumosScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Raya del mínimo dentro de la tarjeta de [nombre]: (left, ancho de barra).
(double, double) _raya(WidgetTester tester, String nombre) {
  final tarjeta = find.ancestor(
    of: find.text(nombre),
    matching: find.byType(InkWell),
  );
  final raya = find.descendant(
    of: tarjeta.first,
    matching: find.byWidgetPredicate(
      (w) =>
          w is Positioned && w.child.runtimeType.toString() == '_MinimumMark',
    ),
  );
  final barra = find.ancestor(of: raya, matching: find.byType(Stack)).first;
  return (tester.widget<Positioned>(raya).left!, tester.getSize(barra).width);
}

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() async {
    backend = BackendFalso();
    backend.loginComo('Administrador');
    backend.rutas['GET /insumos'] = (_) => respuesta(_insumos);
    await AuthService.instance.login('admin@correo.com', 'Clave1234');
  });
  tearDown(() => AuthService.instance.logout());

  testWidgets('la leyenda aparece una sola vez con cada filtro', (
    tester,
  ) async {
    await _montar(tester);
    for (final tipo in ['Insumo', 'Producto insumo', 'Todos los tipos']) {
      for (final estado in ['Activos', 'Inactivos', 'Todos']) {
        await tester.tap(find.text(tipo));
        await tester.tap(find.text(estado));
        await tester.pumpAndSettle();
        expect(_leyenda, findsOneWidget, reason: '$tipo/$estado');
        for (final texto in _textosLeyenda) {
          expect(_enLeyenda(texto), findsOneWidget, reason: '$tipo/$estado');
        }
      }
    }
    // Debajo de los filtros y encima de la primera tarjeta.
    expect(
      tester.getTopLeft(_leyenda).dy,
      greaterThan(tester.getTopLeft(find.text('Inactivos')).dy),
    );
    expect(
      tester.getTopLeft(_leyenda).dy,
      lessThan(tester.getTopLeft(find.text('Leche')).dy),
    );
  });

  testWidgets('la raya del mínimo queda en la misma posición', (tester) async {
    await _montar(tester);
    // Sin máximo: escala = mayor entre stock, mínimo y 1.
    var (left, ancho) = _raya(tester, 'Leche');
    expect(left, closeTo(ancho * 4 / 12.9 - 1, 0.01));
    (left, ancho) = _raya(tester, 'Queso');
    expect(left, closeTo(ancho - 2, 0.01));
    // Con máximo 20: escala = máximo.
    (left, ancho) = _raya(tester, 'Salsa base');
    expect(left, closeTo(ancho * 5 / 20 - 1, 0.01));
    // La fila de stock no cambia (el máximo sin definir sigue como 0).
    expect(find.textContaining('Mín.: 4   Máx.: 0'), findsOneWidget);
  });

  testWidgets('la barra describe stock actual y mínimo', (tester) async {
    await _montar(tester);
    expect(
      find.bySemanticsLabel('Stock actual 12.9 lt, mínimo 4 lt'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Stock actual 0 lt, mínimo 5 lt'),
      findsOneWidget,
    );
  });

  testWidgets('el detalle usa la misma barra con su leyenda', (tester) async {
    backend.rutas['GET /insumos/1'] = (_) => respuesta(_insumos.first);
    await _montar(tester);
    await tester.tap(find.text('Leche'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);
    expect(_leyenda, findsOneWidget);
    for (final texto in _textosLeyenda) {
      expect(_enLeyenda(texto), findsOneWidget);
    }
    expect(
      find.bySemanticsLabel('Stock actual 12.9 lt, mínimo 4 lt'),
      findsOneWidget,
    );
  });

  for (final oscuro in [false, true]) {
    testWidgets('sin desborde a 320 dp con letra al 130 % en '
        '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
      await _montar(
        tester,
        tema: oscuro ? AppTheme.oscuro : AppTheme.claro,
        ancho: 320,
        letra: 1.3,
      );
      expect(tester.takeException(), isNull);
      final raya = tester.widget<Container>(
        find
            .descendant(
              of: find.byWidgetPredicate(
                (w) => w.runtimeType.toString() == '_MinimumMark',
              ),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        raya.color,
        oscuro ? PaletaApp.textoOscuro : const Color(0xFF261B1A),
      );
    });
  }
}
