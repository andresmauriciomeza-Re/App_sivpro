import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/services/indicators_service.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

Map<String, dynamic> _ver(String modulo, String nombre) => {
  'modulo': modulo,
  'nombre': nombre,
  'privilegios': ['Ver'],
};

final _hoy = ahoraBogota();
final String _mes = _hoy.month.toString().padLeft(2, '0');
final _mesTexto = '${nombresMes[_hoy.month - 1]} de ${_hoy.year}';
const _abreviados = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', //
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Venta de `GET /ventas`; los números llegan como texto, como el backend.
Map<String, dynamic> _venta(
  int id, {
  Object? idDevolucion,
  int? dia,
  String? cliente = 'Ana Pérez',
  List<Map<String, dynamic>>? detalles,
}) => {
  'id_venta': id,
  'cliente_nombre': cliente,
  'monto': '56000.00',
  'estado': idDevolucion == null ? 'Completado' : 'Devolucion',
  'fecha': '${_hoy.year}-$_mes-01T10:00:00.000000',
  'fecha_estado_local': null,
  'id_devolucion': idDevolucion,
  'devolucion_fecha': dia == null
      ? null
      : '${_hoy.year}-$_mes-${dia.toString().padLeft(2, '0')}'
            'T12:00:00.000000',
  'devolucion_monto': '40000.00',
  'detalles':
      detalles ??
      [
        {'nombre': 'Pizza Pollo', 'cantidad': '2', 'tamano': 'Mediana'},
        {'nombre': 'Gaseosa', 'cantidad': 1, 'tamano': null},
      ],
  'pagos': null,
};

Future<void> _montar(
  WidgetTester tester, {
  ThemeData? tema,
  double ancho = 412,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, 3200);
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
      home: const IndicatorsScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tarjeta "Devoluciones" (el contenedor de la sección).
Finder _tarjeta() => find
    .ancestor(of: find.text('Devoluciones'), matching: find.byType(Container))
    .first;

Finder _enTarjeta(Finder finder) =>
    find.descendant(of: _tarjeta(), matching: finder);

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() async {
    backend = BackendFalso();
    backend.rutas['GET /productos-no-conformes'] = (_) => respuesta(<Object>[]);
    backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
  });
  tearDown(() => AuthService.instance.logout());

  Future<void> entrar(List<Map<String, dynamic>> permisos) async {
    backend.loginComo('Administrador', permisos: permisos);
    await AuthService.instance.login('admin@correo.com', 'Clave1234');
  }

  final conDevoluciones = [
    _ver('Ventas', 'Ventas'),
    _ver('Ventas', 'Devoluciones'),
  ];

  testWidgets('reemplaza a la tarjeta de clientes y va primera', (
    tester,
  ) async {
    await entrar(conDevoluciones);
    await _montar(tester);
    expect(
      find.text('Clientes: frecuentes y mayores consumidores'),
      findsNothing,
    );
    expect(find.text('Devoluciones'), findsOneWidget);
    expect(find.text('Devoluciones registradas en $_mesTexto'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Devoluciones')).dy,
      lessThan(tester.getTopLeft(find.text('Productos más vendidos')).dy),
    );
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('cuenta y lista las del mes: máximo 10, más recientes '
      'primero, productos como la web y sin dinero', (tester) async {
    await entrar(conDevoluciones);
    backend.rutas['GET /ventas'] = (_) => respuesta([
      _venta(1), // sin devolución
      for (var i = 0; i < 12; i++)
        _venta(10 + i, idDevolucion: '${100 + i}', dia: i + 1),
      // Sin fecha de devolución: cae a la de la venta (día 1); sin nombre.
      _venta(30, idDevolucion: 200, cliente: null, detalles: []),
    ]);
    await _montar(tester);

    expect(_enTarjeta(find.text('13')), findsOneWidget);
    expect(_enTarjeta(find.text('Productos: 3')), findsNWidgets(10));
    expect(_enTarjeta(find.text('Y 3 más este mes')), findsOneWidget);
    final abreviado = _abreviados[_hoy.month - 1];
    final fechas = tester
        .widgetList<Text>(
          _enTarjeta(find.textContaining(' $abreviado ${_hoy.year}')),
        )
        .map((t) => t.data)
        .toList();
    expect(fechas.first, '12 $abreviado ${_hoy.year}');
    expect(fechas.last, '3 $abreviado ${_hoy.year}');
    expect(fechas, hasLength(10));
    expect(_enTarjeta(find.textContaining(r'$')), findsNothing);
    expect(_enTarjeta(find.byType(Divider)), findsNWidgets(9));
  });

  testWidgets('nombre de respaldo y productos 0 si faltan datos', (
    tester,
  ) async {
    await entrar(conDevoluciones);
    backend.rutas['GET /ventas'] = (_) =>
        respuesta([_venta(30, idDevolucion: 200, cliente: null, detalles: [])]);
    await _montar(tester);
    expect(_enTarjeta(find.text('1')), findsOneWidget);
    expect(_enTarjeta(find.text('Sin nombre')), findsOneWidget);
    expect(_enTarjeta(find.text('Productos: 0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin devoluciones: 0 y el texto de la web; cambiar de mes '
      'recalcula sin pedir de nuevo', (tester) async {
    await entrar(conDevoluciones);
    backend.rutas['GET /ventas'] = (_) =>
        respuesta([_venta(10, idDevolucion: 100, dia: 2)]);
    await _montar(tester);
    expect(_enTarjeta(find.text('1')), findsOneWidget);

    final vecino = nombresMes[_hoy.month == 1 ? 1 : _hoy.month - 2];
    final actual = nombresMes[_hoy.month - 1];
    await tester.tap(find.text(actual[0].toUpperCase() + actual.substring(1)));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(vecino[0].toUpperCase() + vecino.substring(1)).last,
    );
    await tester.pumpAndSettle();
    expect(_enTarjeta(find.text('0')), findsOneWidget);
    expect(
      _enTarjeta(find.text('No hay devoluciones registradas')),
      findsOneWidget,
    );
    expect(backend.a('GET /ventas'), hasLength(1));
  });

  testWidgets('mientras carga no muestra cifras', (tester) async {
    await entrar(conDevoluciones);
    tester.view.physicalSize = const Size(412, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const IndicatorsScreen()),
    );
    expect(_enTarjeta(find.byType(CircularProgressIndicator)), findsOneWidget);
    expect(_enTarjeta(find.text('0')), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('sin permiso de Devoluciones no aparece ni deja hueco', (
    tester,
  ) async {
    await entrar([_ver('Ventas', 'Ventas')]);
    await _montar(tester);
    expect(find.text('Devoluciones'), findsNothing);
    final selectores = tester.getBottomLeft(find.text('${_hoy.year}')).dy;
    final productos = tester.getTopLeft(find.text('Productos más vendidos')).dy;
    expect(productos - selectores, lessThan(80));
  });

  for (final oscuro in [false, true]) {
    testWidgets('sin desborde a 320 dp con letra al 130 % en '
        '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
      await entrar(conDevoluciones);
      backend.rutas['GET /ventas'] = (_) => respuesta([
        _venta(
          10,
          idDevolucion: 100,
          dia: 2,
          cliente:
              'María Fernanda de los Ángeles Restrepo Villegas de Castañeda',
        ),
      ]);
      await _montar(
        tester,
        tema: oscuro ? AppTheme.oscuro : AppTheme.claro,
        ancho: 320,
        letra: 1.3,
      );
      expect(_enTarjeta(find.text('1')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
