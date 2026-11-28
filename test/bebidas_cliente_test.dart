import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/models/producto_catalogo.dart';
import 'package:sivpro_app/client/screens/drinks_screen.dart';
import 'package:sivpro_app/client/screens/product_detail_screen.dart';
import 'package:sivpro_app/client/screens/profile_screen.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/tipos_bebida.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

Map<String, dynamic> _bebida(
  int id,
  String nombre, {
  String estado = 'Disponible',
  int precio = 3000,
  Object? stock = 10,
}) => filaCatalogo(id, nombre, 3, precio: precio, estado: estado, stock: stock);

/// Como el catálogo real, en otro orden y con una de cada tipo.
final _filas = [
  filaCatalogo(1, 'Pizza Pollo', 1, precio: 14000, precioGrande: 16000),
  _bebida(20, 'Agua Cristal'),
  _bebida(17, 'Gaseosa Premium', precio: 3500),
  _bebida(5, 'Gaseosa Cuatro', precio: 3000),
  _bebida(10, 'Gaseosa Pepsi', estado: 'No disponible', stock: 0),
  _bebida(13, 'Gaseosa Coca-Cola', precio: 2500, stock: 3),
  _bebida(29, 'Gatorade', precio: 4500),
  _bebida(30, 'Cerveza Águila', precio: 5000),
];

List<ProductoCatalogo> _productos(List<Map<String, dynamic>> filas) => [
  for (final f in filas) ProductoCatalogo.desdeApi(f),
];

Finder _boton(String etiqueta) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == etiqueta,
);

/// Cantidad que muestra el contador de una bebida (por su accesibilidad).
Finder _cantidad(String nombre, String precio, int cantidad) =>
    _boton('$nombre, $precio, cantidad $cantidad');

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    backend = BackendFalso();
    SharedPreferences.setMockInitialValues({});
    CatalogoRepository.instance.limpiar();
    CartService.instance.clear();
  });
  tearDown(() async {
    await ModoOscuroController.instance.cambiar(false);
    await AuthService.instance.logout();
  });

  Future<void> montar(
    WidgetTester tester,
    Widget pantalla, {
    double ancho = 412,
    double alto = 2400,
    double letra = 1,
  }) async {
    tester.view.physicalSize = Size(ancho, alto);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(letra)),
          child: child!,
        ),
        home: pantalla,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> abrirDetalle(
    WidgetTester tester, {
    double ancho = 412,
    double letra = 1,
  }) async {
    backend.rutas['GET /productos'] = (_) => respuesta(_filas);
    await montar(
      tester,
      ProductDetailScreen(producto: _productos(_filas).first),
      ancho: ancho,
      letra: letra,
    );
  }

  Future<void> tocar(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  group('clasificación por nombre', () {
    test('cada bebida cae en su filtro', () {
      for (final (nombre, tipo) in [
        ('Gaseosa Coca-Cola', TipoBebida.gaseosas),
        ('postobon de manzana', TipoBebida.gaseosas),
        ('Agua Cristal', TipoBebida.agua),
        ('Red Bull', TipoBebida.energizantes),
        ('Cerveza Águila', TipoBebida.cervezas),
        ('Club Colombia', TipoBebida.cervezas),
        ('Colombiana', TipoBebida.gaseosas),
        ('Gatorade', TipoBebida.otras),
        ('Aguardiente', TipoBebida.otras),
      ]) {
        expect(tipoDeBebida(nombre), tipo, reason: nombre);
      }
    });

    test('destacadas en orden; si falta una, completa con disponibles', () {
      List<String> nombres(List<Map<String, dynamic>> filas) => [
        for (final b in bebidasDestacadas(_productos(filas))) b.nombre,
      ];
      expect(nombres(_filas.sublist(1)), [
        'Gaseosa Coca-Cola',
        'Gaseosa Pepsi',
        'Gaseosa Cuatro',
        'Gaseosa Premium',
      ]);
      expect(
        nombres([
          _bebida(40, 'Gaseosa Rara', estado: 'No disponible'),
          _bebida(20, 'Agua Cristal'),
          _bebida(13, 'Coca Cola'),
          _bebida(18, 'Premio'),
          _bebida(29, 'Gatorade'),
        ]),
        ['Coca Cola', 'Premio', 'Agua Cristal', 'Gatorade'],
      );
    });
  });

  testWidgets('el detalle muestra las 4 en orden y "Ver más bebidas"', (
    tester,
  ) async {
    await abrirDetalle(tester);
    final nombres = [
      'Gaseosa Coca-Cola',
      'Gaseosa Pepsi',
      'Gaseosa Cuatro',
      'Gaseosa Premium',
    ];
    final alturas = [
      for (final n in nombres) tester.getTopLeft(find.text(n)).dy,
    ];
    expect(alturas, [...alturas]..sort());
    expect(find.text('Agua Cristal'), findsNothing);
    expect(find.text('Gatorade'), findsNothing);
    expect(find.text('No disponible'), findsOneWidget);
    expect(find.text('Ver más bebidas'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Ver más bebidas')).dy,
      greaterThan(alturas.last),
    );
  });

  testWidgets('"Bebidas" filtra con los botones que tienen alguna bebida', (
    tester,
  ) async {
    await abrirDetalle(tester);
    await tocar(tester, find.text('Ver más bebidas'));
    expect(find.byType(BebidasScreen), findsOneWidget);
    Finder chip(String e) => find.widgetWithText(ChoiceChip, e);
    for (final e in ['Todas', 'Gaseosas', 'Agua', 'Cervezas', 'Otras']) {
      expect(chip(e), findsOneWidget, reason: e);
    }
    expect(chip('Energizantes'), findsNothing);

    await tocar(tester, chip('Agua'));
    expect(find.text('Agua Cristal'), findsOneWidget);
    expect(find.text('Gaseosa Coca-Cola'), findsNothing);
    await tocar(tester, chip('Gaseosas'));
    expect(find.text('Gaseosa Coca-Cola'), findsOneWidget);
    expect(find.text('Agua Cristal'), findsNothing);
    await tocar(tester, chip('Otras'));
    expect(find.text('Gatorade'), findsOneWidget);
    await tocar(tester, chip('Todas'));
    expect(find.text('Agua Cristal'), findsOneWidget);
    expect(find.text('Cerveza Águila'), findsOneWidget);
  });

  testWidgets('las cantidades son las mismas en las dos pantallas, con sus '
      'límites, y llegan al carrito', (tester) async {
    await abrirDetalle(tester);
    await tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
    await tocar(tester, find.text('Ver más bebidas'));
    // Ya viene la que se agregó en el detalle.
    expect(_cantidad('Gaseosa Coca-Cola', r'$2.500', 1), findsOneWidget);

    await tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
    await tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
    await tocar(tester, _boton('Agregar Gaseosa Coca-Cola')); // stock 3
    expect(find.textContaining('Máximo disponible: 3.'), findsOneWidget);
    expect(_cantidad('Gaseosa Coca-Cola', r'$2.500', 3), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(_boton('Agregar Gaseosa Pepsi'))
          .properties
          .enabled,
      isFalse,
    );
    await tocar(tester, _boton('Agregar Agua Cristal'));

    await tocar(tester, find.byTooltip('Volver'));
    expect(find.byType(BebidasScreen), findsNothing);
    expect(_cantidad('Gaseosa Coca-Cola', r'$2.500', 3), findsOneWidget);
    // Grande (16.000) + 3 × 2.500 + agua 3.000.
    expect(find.text(r'$26.500'), findsOneWidget);

    await tocar(tester, _boton('Quitar Gaseosa Coca-Cola'));
    expect(find.text(r'$24.000'), findsOneWidget);
    await tocar(tester, find.text('Ver más bebidas'));
    expect(_cantidad('Gaseosa Coca-Cola', r'$2.500', 2), findsOneWidget);
    await tocar(tester, find.byTooltip('Volver'));

    await tocar(tester, find.text('Agregar 1 porción al carrito'));
    expect([
      for (final a in CartService.instance.items.single.adiciones)
        (a.nombre, a.cantidad),
    ], unorderedEquals([('Agua Cristal', 1), ('Gaseosa Coca-Cola', 2)]));
  });

  for (final ancho in [320.0, 360.0]) {
    for (final oscuro in [false, true]) {
      testWidgets('sin desbordes a ${ancho.toInt()} dp y letra 130 % en '
          '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
        backend.loginComo('Cliente');
        await AuthService.instance.login('ana@correo.com', 'Clave1234');
        await ModoOscuroController.instance.cambiar(oscuro);
        await abrirDetalle(tester, ancho: ancho, letra: 1.3);
        expect(tester.takeException(), isNull);
        await tocar(tester, find.text('Ver más bebidas'));
        expect(tester.takeException(), isNull);
        expect(
          Theme.of(tester.element(find.byType(ChoiceChip).first)).brightness,
          oscuro ? Brightness.dark : Brightness.light,
        );
        expect(
          tester.getRect(_boton('Agregar Agua Cristal')).right,
          lessThanOrEqualTo(ancho),
        );
      });
    }
  }

  testWidgets('Mi Perfil: sin contadores, con el mismo límite', (tester) async {
    backend.loginComo('Cliente');
    backend.rutas['GET /auth/me'] = (_) =>
        respuesta({'usuario': usuarioJson()});
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await montar(tester, const ProfileScreen());
    expect(find.textContaining(RegExp(r'^\d+/(60|15)$')), findsNothing);
    final campos = tester.widgetList<TextField>(find.byType(TextField));
    expect([for (final c in campos) c.maxLength], [60, 15]);

    await tester.tap(find.text('Editar'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), 'a' * 80);
    await tester.enterText(find.byType(TextField).at(1), '9' * 30);
    await tester.pump();
    final textos = [
      for (final c in tester.widgetList<TextField>(find.byType(TextField)))
        c.controller!.text.length,
    ];
    expect(textos, [60, 15]);
    expect(find.textContaining(RegExp(r'^\d+/(60|15)$')), findsNothing);
  });
}
