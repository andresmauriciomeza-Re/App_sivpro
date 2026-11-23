import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/models/producto_catalogo.dart';
import 'package:sivpro_app/client/screens/category_products_screen.dart';
import 'package:sivpro_app/client/screens/menu_screen.dart';
import 'package:sivpro_app/client/screens/product_detail_screen.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/widgets/imagen_producto.dart';
import 'package:sivpro_app/config/api_config.dart';
import 'package:sivpro_app/network/api_client.dart';
import 'package:sivpro_app/network/api_exception.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

/// Fila de `GET /productos` como la entrega PostgreSQL (números como texto).
Map<String, dynamic> _fila(
  int id,
  String nombre,
  int categoria, {
  String categoriaNombre = '',
  Object? precio = '14000.00',
  Object? precioGrande,
  String estado = 'Disponible',
  Object? stock,
  Object? mediana,
  Object? grande,
  bool tieneImagen = false,
  List<String> imagenes = const [],
}) => {
  'id_producto': id,
  'id_categoria': categoria,
  'nombre': nombre,
  'tipo': 'Elaborado',
  'precio_venta': precio,
  'unidad_venta': 'Unidad',
  'imagen': null,
  'estado': estado,
  'tiene_imagen': tieneImagen,
  'imagenes': imagenes,
  'categoria_nombre': categoriaNombre,
  'categoria_descripcion': null,
  'categoria_emoji': null,
  'stock': stock,
  'stock_partes': null,
  'disponibles_mediana': mediana,
  'disponibles_grande': grande,
  'precio_grande': precioGrande,
};

final List<Map<String, dynamic>> _catalogo = [
  _fila(1, 'Pizza Pollo', 1, precioGrande: '16000.00', mediana: '5', grande: 0),
  _fila(2, 'Pizza Hawaiana', 1, estado: 'No disponible', precioGrande: 16000),
  _fila(3, 'Pizza Paisa', 1), // sin Grande ni stock: sin límite
  _fila(4, 'Pizza Peperoni', 1, precioGrande: 16000, mediana: 0, grande: 0),
  _fila(5, 'Lasaña Carne', 2, precio: '20000.00'), // stock nulo = sin límite
  _fila(6, 'Lasaña Mixta', 2, precio: 21000, stock: '3'),
  _fila(7, 'Gaseosa Coca-Cola', 3, precio: '8000.00', stock: 2),
  _fila(8, 'Gaseosa Pepsi', 3, precio: 9000, estado: 'No disponible'),
  _fila(9, 'Gaseosa Cuatro', 3, precio: 7000, stock: 0),
  _fila(10, 'Combo Familiar', 4, categoriaNombre: 'Combos', precio: 50000),
];

/// Catálogo con [bebidas] gaseosas (en lugar de las 3 del catálogo base).
List<Map<String, dynamic>> _catalogoConBebidas(int bebidas) => [
  for (final f in _catalogo)
    if (f['id_categoria'] != 3) f,
  for (var i = 1; i <= bebidas; i++)
    _fila(100 + i, 'Gaseosa $i', 3, precio: 5000, stock: 10),
];

List<ProductoCatalogo> get _productos => [
  for (final f in _catalogo) ProductoCatalogo.desdeApi(f),
];

ProductoCatalogo _p(String nombre) =>
    _productos.firstWhere((p) => p.nombre == nombre);

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double ancho = 900,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, 2400);
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

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

/// Botón "+" de la fila (cantidad o adición) que contiene [texto].
Finder _mas(String texto) => find
    .descendant(
      of: find.ancestor(of: find.text(texto), matching: find.byType(Row)).first,
      matching: find.byIcon(Icons.add),
    )
    .last;

/// Botón "Agregar …" / "Quitar …" de una tarjeta del carrusel de adiciones,
/// por su etiqueta de accesibilidad.
Finder _boton(String etiqueta) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == etiqueta,
);

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  setUp(() {
    backend = BackendFalso();
    backend.rutas['GET /productos'] = (_) => respuesta(_catalogo);
    CatalogoRepository.instance
      ..limpiar()
      ..reloj = DateTime.now;
    CartService.instance.clear();
  });

  group('modelo del catálogo', () {
    test('lee números como texto y campos nulos', () {
      final pollo = _p('Pizza Pollo');
      expect(pollo.id, 1);
      expect(pollo.seccion, SeccionMenu.pizzas);
      expect(
        [for (final t in pollo.tamanos) (t.nombre, t.precio)],
        [('Mediana', 14000), ('Grande', 16000)],
      );
      expect(pollo.tamanos.first.disponibles, 5);
      expect(pollo.tamanos.last.agotado, isTrue);
      expect(pollo.estado, EstadoMenu.disponible);

      final paisa = _p('Pizza Paisa');
      expect([for (final t in paisa.tamanos) t.nombre], ['Mediana']);
      expect(paisa.limite, isNull);
      expect(paisa.estado, EstadoMenu.disponible);

      final lasana = _p('Lasaña Carne');
      expect(
        [for (final t in lasana.tamanos) (t.nombre, t.precio)],
        [('Normal', 20000)],
      );
      expect(lasana.stock, isNull, reason: 'stock nulo = sin límite');
      expect(lasana.estado, EstadoMenu.disponible);
      expect(_p('Lasaña Mixta').stock, 3);

      expect(_p('Pizza Peperoni').estado, EstadoMenu.agotado);
      expect(_p('Pizza Hawaiana').estado, EstadoMenu.noDisponible);
      expect(_p('Combo Familiar').seccion, SeccionMenu.otra);
    });

    test('una sola etiqueta: "No disponible" manda sobre "Agotado"', () {
      final agotadaYNoDisponible = ProductoCatalogo.desdeApi(
        _fila(20, 'Pizza X', 1, estado: 'No disponible', mediana: 0, grande: 0),
      );
      expect(agotadaYNoDisponible.estado, EstadoMenu.noDisponible);
    });

    test('nombre normalizado sin tildes ni prefijo "pizza "', () {
      expect(normalizarNombreProducto('  Pizza  Cañón '), 'canon');
      expect(normalizarNombreProducto('Lasaña Pollo'), 'lasana pollo');
    });

    test('descripciones: primero las de la móvil y si no, las de la web', () {
      expect(_p('Pizza Pollo').descripcion, contains('anchoas'));
      expect(
        _p('Pizza Paisa').descripcion,
        'Carne molida, trozos de carne y peperoni sobre queso derretido.',
      );
      expect(
        _p('Lasaña Carne').descripcion,
        'Capas de pasta con carne molida y queso gratinado.',
      );
      expect(_p('Combo Familiar').descripcion, isNull);
    });

    test(
      'secciones: solo Pizzas, Lasañas y Favoritas, disponibles primero',
      () {
        final secciones = seccionesMenu(_productos);
        expect(secciones.keys, ['Pizzas', 'Lasañas', 'Favoritas']);
        expect(
          [for (final p in secciones['Pizzas']!) p.nombre],
          ['Pizza Pollo', 'Pizza Paisa', 'Pizza Peperoni', 'Pizza Hawaiana'],
        );
        expect(
          [for (final p in secciones['Lasañas']!) p.nombre],
          ['Lasaña Carne', 'Lasaña Mixta'],
        );
        // Favoritas fijas de la móvil resueltas por nombre; Maicitos no existe.
        expect(favoritasMenu, [
          'Pizza Pollo',
          'Pizza Hawaiana',
          'Pizza Maicitos',
          'Pizza Peperoni',
        ]);
        expect(
          [for (final p in secciones['Favoritas']!) p.nombre],
          ['Pizza Pollo', 'Pizza Peperoni', 'Pizza Hawaiana'],
        );
        final enMenu = [for (final s in secciones.values) ...s];
        expect(enMenu.where((p) => p.seccion == SeccionMenu.bebidas), isEmpty);
        expect(enMenu.where((p) => p.nombre == 'Combo Familiar'), isEmpty);
      },
    );

    test('favoritas por nombre normalizado (tildes y mayúsculas)', () {
      final catalogo = [
        ProductoCatalogo.desdeApi(_fila(30, 'PIZZA  PEPERÓNI', 1)),
        ProductoCatalogo.desdeApi(_fila(31, 'Lasaña Pollo', 2)),
      ];
      expect([for (final p in resolverFavoritas(catalogo)) p.id], [30]);
    });

    test('adiciones = bebidas reales con su id_producto, precio y stock', () {
      final bebidas = bebidasDe(_productos);
      expect(
        [for (final b in bebidas) (b.id, b.precioBase, b.stock)],
        [(7, 8000, 2), (8, 9000, null), (9, 7000, 0)],
      );
    });

    test('imagen: backend, galería, foto local y por último el respaldo', () {
      final conTodo = ProductoCatalogo.desdeApi(
        _fila(
          1,
          'Pizza Pollo',
          1,
          tieneImagen: true,
          imagenes: ['https://cdn.ejemplo.com/pollo.jpg', 'otra.jpg'],
        ),
      );
      expect(fuentesImagen(conTodo), [
        '${ApiConfig.baseUrl}/productos/1/imagen',
        'https://cdn.ejemplo.com/pollo.jpg',
        'assets/img/pizza_pollo.png',
      ]);
      final sinNada = ProductoCatalogo.desdeApi(
        _fila(40, 'Pizza Nueva', 1, imagenes: ['sin-url.jpg']),
      );
      expect(fuentesImagen(sinNada), isEmpty);
    });
  });

  group('repositorio', () {
    test('usa la caché, recarga al pedirlo y al vencer', () async {
      var ahora = DateTime(2026, 11, 23, 10);
      CatalogoRepository.instance.reloj = () => ahora;
      await CatalogoRepository.instance.productos();
      await CatalogoRepository.instance.productos();
      expect(backend.a('GET /productos'), hasLength(1));

      await CatalogoRepository.instance.productos(recargar: true);
      expect(backend.a('GET /productos'), hasLength(2));

      ahora = ahora.add(CatalogoRepository.vigencia);
      await CatalogoRepository.instance.productos();
      expect(backend.a('GET /productos'), hasLength(3));
      expect(backend.a('GET /productos').last.headers['Authorization'], isNull);
    });

    test('se olvida al terminar la sesión', () async {
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      await CatalogoRepository.instance.productos();
      await AuthService.instance.logout();
      await CatalogoRepository.instance.productos();
      expect(backend.a('GET /productos'), hasLength(2));
    });

    test('503 y sin red llegan como ApiException', () async {
      backend.rutas['GET /productos'] = (_) =>
          errorBackend(503, 'No se pudo conectar con la base de datos.');
      await expectLater(
        CatalogoRepository.instance.productos(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'No se pudo conectar con la base de datos.',
          ),
        ),
      );
      ApiClient.instance.clienteHttp = MockClient(
        (_) async => throw const SocketException('sin red'),
      );
      await expectLater(
        CatalogoRepository.instance.productos(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('Nuestro Menú', () {
    testWidgets('exactamente 4 filtros, sin Bebidas, con la tarjeta destacada '
        'de cada sección', (tester) async {
      await _montar(tester, const MenuScreen());
      for (final filtro in ['Todas', 'Pizzas', 'Lasañas', 'Favoritas']) {
        expect(
          find.descendant(
            of: find.byType(ListView).at(1),
            matching: find.text(filtro),
          ),
          findsOneWidget,
          reason: filtro,
        );
      }
      expect(
        find.descendant(
          of: find.byType(ListView).at(1),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(4),
      );
      expect(find.textContaining('Bebida'), findsNothing);
      expect(find.text('Gaseosa Coca-Cola'), findsNothing);
      expect(find.text('Combo Familiar'), findsNothing);
      // Pizzas y Favoritas abren con Pizza Pollo; Lasañas con Lasaña Carne.
      expect(find.text('Pizza Pollo'), findsNWidgets(2));
      expect(find.text('Lasaña Carne'), findsOneWidget);
      expect(find.text('Disponible'), findsNWidgets(3));
    });

    testWidgets('lista vacía', (tester) async {
      backend.rutas['GET /productos'] = (_) => respuesta(<Object>[]);
      await _montar(tester, const MenuScreen());
      expect(find.text('No hay productos disponibles.'), findsOneWidget);
    });

    testWidgets('error 503 con "Reintentar" que vuelve a cargar', (
      tester,
    ) async {
      backend.rutas['GET /productos'] = (_) =>
          errorBackend(503, 'No se pudo conectar con la base de datos.');
      await _montar(tester, const MenuScreen());
      expect(
        find.text('No se pudo conectar con la base de datos.'),
        findsOneWidget,
      );
      backend.rutas['GET /productos'] = (_) => respuesta(_catalogo);
      await _tocar(tester, find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Lasaña Carne'), findsOneWidget);
    });

    testWidgets('jalar para refrescar vuelve a pedir el catálogo', (
      tester,
    ) async {
      await _montar(tester, const MenuScreen());
      expect(backend.a('GET /productos'), hasLength(1));
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
      await tester.pumpAndSettle();
      expect(backend.a('GET /productos'), hasLength(2));
    });
  });

  group('productos de una sección', () {
    testWidgets('todas las pizzas con precio por porción y una sola '
        'etiqueta en las que no se pueden pedir', (tester) async {
      await _montar(
        tester,
        const CategoryProductsScreen.catalogo(categoryName: 'Pizzas'),
      );
      for (final nombre in [
        'Pizza Pollo',
        'Pizza Paisa',
        'Pizza Peperoni',
        'Pizza Hawaiana',
      ]) {
        expect(find.text(nombre), findsOneWidget);
      }
      expect(find.text('Agotado'), findsOneWidget);
      expect(find.text('No disponible'), findsOneWidget);
      expect(find.text('Disponible'), findsNothing);
      expect(
        find.textContaining(' / porción', findRichText: true),
        findsNWidgets(4),
      );
    });

    testWidgets('el detalle abre desde la sección con las bebidas reales y '
        'la barra fija', (tester) async {
      await _montar(
        tester,
        const CategoryProductsScreen.catalogo(categoryName: 'Pizzas'),
      );
      await _tocar(tester, find.text('Pizza Paisa'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailScreen), findsOneWidget);
      expect(find.text('Mediana'), findsOneWidget);
      // Las adiciones son las bebidas reales, en el carrusel horizontal.
      expect(find.text('Gaseosa Coca-Cola'), findsOneWidget);
      expect(find.text('Coca Cola'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is ListView && w.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
      // Total y botón en la barra fija de la pantalla.
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(ProductDetailScreen),
                matching: find.byType(Scaffold),
              ),
            )
            .bottomNavigationBar,
        isNotNull,
      );
      expect(
        find.ancestor(
          of: find.text('Total a pagar'),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });
  });

  group('detalle', () {
    Future<void> abrir(WidgetTester tester, String nombre) async {
      await CatalogoRepository.instance.productos();
      await _montar(tester, ProductDetailScreen(producto: _p(nombre)));
    }

    testWidgets('pizza: tamaños por porción, Grande agotada, límites y total', (
      tester,
    ) async {
      await abrir(tester, 'Pizza Pollo');
      expect(find.text('Elige el tamaño'), findsOneWidget);
      expect(find.text('\$14.000 / porción'), findsOneWidget);
      expect(find.text('\$16.000 / porción'), findsOneWidget);
      expect(find.text('Quedan 5 porciones'), findsOneWidget);
      expect(find.text('Agotado'), findsWidgets);
      expect(find.text('Porciones'), findsOneWidget);
      // La Grande está agotada: se propone la Mediana.
      expect(find.text('Agregar 1 porción al carrito'), findsOneWidget);
      await _tocar(tester, find.text('Grande'));
      expect(find.text('Quedan 5 porciones'), findsOneWidget);

      for (var i = 0; i < 4; i++) {
        await _tocar(tester, _mas('Porciones'));
      }
      expect(find.text('Agregar 5 porciones al carrito'), findsOneWidget);
      await _tocar(tester, _mas('Porciones'));
      expect(
        find.text('Solo quedan 5 porciones de Pizza Pollo Mediana disponibles'),
        findsOneWidget,
      );
      expect(find.text('Agregar 5 porciones al carrito'), findsOneWidget);

      // Adiciones reales: Coca-Cola con stock 2; Pepsi y Cuatro no se suman.
      expect(find.text('Adiciones (Bebidas)'), findsOneWidget);
      expect(find.text('\$8.000'), findsOneWidget);
      expect(find.text('No disponible'), findsOneWidget);
      await _tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
      await _tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
      await _tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
      expect(
        find.text(
          'Máximo disponible: 2. No hay más unidades de Gaseosa Coca-Cola',
        ),
        findsOneWidget,
      );
      await _tocar(tester, _boton('Agregar Gaseosa Pepsi'));
      await _tocar(tester, _boton('Agregar Gaseosa Cuatro'));
      // (14.000 × 5) + (8.000 × 2)
      expect(find.text('\$86.000'), findsOneWidget);

      await _tocar(tester, find.text('Agregar 5 porciones al carrito'));
      final linea = CartService.instance.items.single;
      expect(linea.idProducto, 1);
      expect(linea.tamanoNombre, 'Mediana');
      expect(linea.precioBase, 14000);
      expect(linea.cantidad, 5);
      expect(
        [
          for (final a in linea.adiciones)
            (a.idProducto, a.nombre, a.precio, a.cantidad),
        ],
        [(7, 'Gaseosa Coca-Cola', 8000, 2)],
      );
      await tester.pumpAndSettle();
    });

    testWidgets('"No disponible" se muestra pero no se puede agregar', (
      tester,
    ) async {
      await abrir(tester, 'Pizza Hawaiana');
      final boton = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('No disponible por ahora'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(boton.onPressed, isNull);
    });

    testWidgets('pizza agotada: tamaños deshabilitados y botón "Agotado"', (
      tester,
    ) async {
      await abrir(tester, 'Pizza Peperoni');
      // Mediana, Grande, el botón y la bebida agotada (Gaseosa Cuatro).
      expect(find.text('Agotado'), findsNWidgets(4));
      final boton = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Agotado').last,
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(boton.onPressed, isNull);
      expect(CartService.instance.items, isEmpty);
    });

    testWidgets('lasaña: una presentación "Normal" y "Cantidad"', (
      tester,
    ) async {
      await abrir(tester, 'Lasaña Mixta');
      expect(find.text('Presentación'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('\$21.000'), findsWidgets);
      expect(find.text('Quedan 3'), findsOneWidget);
      expect(find.text('Cantidad'), findsOneWidget);
      expect(find.text('Agregar al carrito'), findsOneWidget);
      expect(find.textContaining('porción'), findsNothing);
    });
  });

  group('detalle: carrusel de adiciones y barra fija', () {
    Finder carrusel() => find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.horizontal,
    );

    Future<void> abrirEnCelular(
      WidgetTester tester,
      String nombre, {
      int? bebidas,
      double ancho = 360,
      double letra = 1,
      double margenInferior = 0,
    }) async {
      if (bebidas != null) {
        backend.rutas['GET /productos'] = (_) =>
            respuesta(_catalogoConBebidas(bebidas));
      }
      await CatalogoRepository.instance.productos(recargar: true);
      tester.view.physicalSize = Size(ancho, 780);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = FakeViewPadding(bottom: margenInferior);
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
          home: ProductDetailScreen(producto: _p(nombre)),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('el carrusel es horizontal y no crece con 4 ni con 30 '
        'bebidas', (tester) async {
      await abrirEnCelular(tester, 'Lasaña Mixta', bebidas: 4);
      expect(carrusel(), findsOneWidget);
      final altoCon4 = tester.getSize(carrusel()).height;

      await abrirEnCelular(tester, 'Lasaña Mixta', bebidas: 30);
      expect(tester.getSize(carrusel()).height, altoCon4);
      expect(find.text('Adiciones (Bebidas)'), findsOneWidget);
    });

    testWidgets('con 30 bebidas el total y el botón se ven sin desplazar', (
      tester,
    ) async {
      await abrirEnCelular(tester, 'Pizza Pollo', bebidas: 30);
      for (final texto in ['Total a pagar', 'Agregar 1 porción al carrito']) {
        final caja = tester.getRect(find.text(texto));
        expect(caja.top, greaterThanOrEqualTo(0), reason: texto);
        expect(caja.bottom, lessThanOrEqualTo(780), reason: texto);
        // No están dentro del contenido que se desplaza.
        expect(
          find.ancestor(
            of: find.text(texto),
            matching: find.byType(SingleChildScrollView),
          ),
          findsNothing,
          reason: texto,
        );
      }
    });

    testWidgets('a 360 dp se ven 2 tarjetas completas y asoma la tercera', (
      tester,
    ) async {
      await abrirEnCelular(tester, 'Lasaña Mixta', bebidas: 30);
      final tarjetas = [
        for (var i = 1; i <= 3; i++)
          tester.getRect(
            find
                .ancestor(
                  of: find.text('Gaseosa $i'),
                  matching: find.byType(Container),
                )
                .first,
          ),
      ];
      expect(tarjetas[0].left, 20); // mismo margen que el contenido
      expect(tarjetas[0].width, 120);
      expect(tarjetas[1].right, lessThanOrEqualTo(360));
      expect(tarjetas[2].left, lessThan(360));
      expect(tarjetas[2].right, greaterThan(360));
    });

    testWidgets('sumar y restar en una tarjeta cambia el total; las no '
        'disponibles no suman', (tester) async {
      await abrirEnCelular(tester, 'Lasaña Mixta');
      // Se sube el contenido (la barra fija tapa lo de abajo) y se tocan las
      // tarjetas sin desplazar el carrusel.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      Future<void> tocar(String etiqueta) async {
        await tester.tap(_boton(etiqueta));
        await tester.pump();
      }

      expect(find.text('\$21.000'), findsWidgets);
      await tocar('Agregar Gaseosa Coca-Cola');
      await tocar('Agregar Gaseosa Coca-Cola');
      expect(find.text('\$37.000'), findsOneWidget);
      await tocar('Quitar Gaseosa Coca-Cola');
      expect(find.text('\$29.000'), findsOneWidget);
      await tocar('Agregar Gaseosa Pepsi');
      // "No disponible" y sin stock: su "Agregar" está deshabilitado.
      for (final nombre in ['Gaseosa Pepsi', 'Gaseosa Cuatro']) {
        expect(
          tester
              .widget<Semantics>(_boton('Agregar $nombre'))
              .properties
              .enabled,
          isFalse,
          reason: nombre,
        );
      }
      expect(find.text('\$29.000'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Gaseosa Coca-Cola, \$8.000, cantidad 1',
        ),
        findsOneWidget,
      );
    });

    testWidgets('el aviso de límite se ve por encima de la barra fija', (
      tester,
    ) async {
      await abrirEnCelular(tester, 'Lasaña Mixta');
      for (var i = 0; i < 3; i++) {
        await _tocar(tester, _boton('Agregar Gaseosa Coca-Cola'));
      }
      await tester.pump(const Duration(milliseconds: 300));
      final aviso = tester.getRect(
        find.text(
          'Máximo disponible: 2. No hay más unidades de Gaseosa Coca-Cola',
        ),
      );
      final total = tester.getRect(find.text('Total a pagar'));
      expect(aviso.bottom, lessThanOrEqualTo(total.top));
    });

    testWidgets('respeta la barra de gestos (SafeArea) sin teclado', (
      tester,
    ) async {
      await abrirEnCelular(tester, 'Lasaña Mixta', margenInferior: 34);
      final boton = tester.getRect(
        find.byWidgetPredicate((w) => w is ButtonStyleButton).last,
      );
      expect(boton.bottom, 780 - 34 - 12);
    });

    for (final oscuro in [false, true]) {
      for (final nombre in ['Pizza Pollo', 'Lasaña Mixta']) {
        testWidgets('$nombre a 320 dp con letra al 130 % en '
            '${oscuro ? 'oscuro' : 'claro'} sin desborde', (tester) async {
          SharedPreferences.setMockInitialValues({});
          backend.loginComo('Cliente');
          await AuthService.instance.login('ana@correo.com', 'Clave1234');
          addTearDown(AuthService.instance.logout);
          await ModoOscuroController.instance.cambiar(oscuro);
          addTearDown(() => ModoOscuroController.instance.cambiar(false));
          await abrirEnCelular(tester, nombre, ancho: 320, letra: 1.3);
          expect(
            Theme.of(tester.element(find.byType(Scaffold))).brightness,
            oscuro ? Brightness.dark : Brightness.light,
          );
          expect(carrusel(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('la imagen cae del backend a la foto local y al respaldo', (
    tester,
  ) async {
    final conImagen = ProductoCatalogo.desdeApi(
      _fila(1, 'Pizza Pollo', 1, tieneImagen: true),
    );
    final sinImagen = ProductoCatalogo.desdeApi(_fila(41, 'Pizza Rara', 1));
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            for (final p in [conImagen, sinImagen])
              SizedBox(
                width: 80,
                height: 80,
                child: ImagenProducto(
                  producto: p,
                  respaldo: (_) => const Icon(Icons.local_pizza),
                ),
              ),
          ],
        ),
      ),
    );
    final red = tester.widget<Image>(find.byType(Image).first);
    expect(
      (red.image as NetworkImage).url,
      '${ApiConfig.baseUrl}/productos/1/imagen',
    );
    // Si la del backend falla, la siguiente es la foto local...
    final contexto = tester.element(find.byType(Image).first);
    final local = red.errorBuilder!(contexto, Exception('404'), null) as Image;
    expect((local.image as AssetImage).assetName, 'assets/img/pizza_pollo.png');
    // ...y si esa también falla, el respaldo.
    final respaldo = local.errorBuilder!(contexto, Exception('sin foto'), null);
    expect(respaldo, isA<Icon>());
    expect(find.byIcon(Icons.local_pizza), findsOneWidget);
  });

  group('modo oscuro del menú', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
    });
    tearDown(() async {
      await ModoOscuroController.instance.cambiar(false);
      await AuthService.instance.logout();
    });

    for (final oscuro in [false, true]) {
      for (final (nombre, pantalla) in [
        ('Nuestro Menú', const MenuScreen() as Widget),
        (
          'una sección',
          const CategoryProductsScreen.catalogo(categoryName: 'Pizzas')
              as Widget,
        ),
        ('el detalle', ProductDetailScreen(producto: _p('Pizza Pollo'))),
      ]) {
        testWidgets('$nombre en ${oscuro ? 'oscuro' : 'claro'} sin desborde '
            'con letra al 130 %', (tester) async {
          await ModoOscuroController.instance.cambiar(oscuro);
          // Fuente de pruebas (1 em por letra): ancho amplio; los 320 dp se
          // midieron aparte con Poppins y Montserrat reales.
          await _montar(tester, pantalla, ancho: 600, letra: 1.3);
          expect(
            Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
            oscuro ? Brightness.dark : Brightness.light,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
