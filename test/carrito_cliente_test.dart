import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/cart_screen.dart';
import 'package:sivpro_app/client/screens/product_detail_screen.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/services/validacion_carrito.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double ancho = 420,
  double alto = 1400,
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

Finder _irAPagar() => find.widgetWithText(ElevatedButton, 'Ir a pagar');

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  setUp(() {
    backend = BackendFalso();
    backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
    CatalogoRepository.instance.limpiar();
    CartService.instance.clear();
  });

  group('total', () {
    test('las adiciones no se multiplican por la cantidad del producto', () {
      final linea = lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        cantidad: 2,
        adiciones: [coca()],
      );
      // (14.000 × 2) + (8.000 × 1)
      expect(linea.subtotal, 36000);
      CartService.instance
        ..addItem(linea)
        ..addItem(
          lineaCarrito(
            idProducto: 5,
            nombre: 'Lasaña Carne',
            tamano: 'Normal',
            precio: 20000,
          ),
        );
      expect(CartService.instance.subtotal, 56000);
      expect(CartService.instance.total, 56000);
    });

    testWidgets('2 porciones + 1 bebida: el detalle y el carrito dan lo '
        'mismo', (tester) async {
      final pollo = catalogoComoProductos().firstWhere((p) => p.id == 1);
      await CatalogoRepository.instance.productos();
      await _montar(tester, ProductDetailScreen(producto: pollo));
      // Se elige la Mediana y 2 porciones, más una Coca-Cola.
      await tester.tap(find.text('Mediana'));
      await tester.pump();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Agregar Gaseosa Coca-Cola',
        ),
      );
      await tester.pump();
      final mas = find
          .descendant(
            of: find
                .ancestor(
                  of: find.text('Porciones'),
                  matching: find.byType(Row),
                )
                .first,
            matching: find.byIcon(Icons.add),
          )
          .last;
      await tester.tap(mas);
      await tester.pump();
      expect(find.text('\$36.000'), findsOneWidget);

      await tester.tap(find.text('Agregar 2 porciones al carrito'));
      await tester.pumpAndSettle();
      expect(CartService.instance.total, 36000);
    });
  });

  group('consolidación', () {
    test('mismo producto, tamaño y bebidas: una sola línea', () {
      CartService.instance
        ..addItem(
          lineaCarrito(
            idProducto: 1,
            nombre: 'Pizza Pollo',
            adiciones: [coca()],
          ),
        )
        ..addItem(
          lineaCarrito(
            idProducto: 1,
            nombre: 'Pizza Pollo',
            cantidad: 2,
            adiciones: [coca(2)],
          ),
        );
      final linea = CartService.instance.items.single;
      expect(linea.cantidad, 3);
      expect(linea.adiciones.single.cantidad, 3);
      expect(linea.subtotal, 14000 * 3 + 8000 * 3);
    });

    test(
      'otro tamaño u otras bebidas van en otra línea; respeta el máximo',
      () {
        CartService.instance
          ..addItem(lineaCarrito(idProducto: 1, nombre: 'Pizza Pollo'))
          ..addItem(
            lineaCarrito(
              idProducto: 1,
              nombre: 'Pizza Pollo',
              tamano: 'Grande',
              precio: 16000,
            ),
          )
          ..addItem(
            lineaCarrito(
              idProducto: 1,
              nombre: 'Pizza Pollo',
              adiciones: [coca()],
            ),
          );
        expect(CartService.instance.items, hasLength(3));

        CartService.instance.addItem(
          lineaCarrito(idProducto: 1, nombre: 'Pizza Pollo', cantidad: 9),
          maximo: 4,
        );
        expect(CartService.instance.items.first.cantidad, 4);
      },
    );
  });

  group('validación contra el catálogo', () {
    final catalogo = catalogoComoProductos();

    test('producto o bebida no disponible bloquea la línea', () {
      final peperoni = lineaCarrito(idProducto: 4, nombre: 'Pizza Peperoni');
      final conPepsi = lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        adiciones: [
          const CartAddition(
            idProducto: 8,
            nombre: 'Gaseosa Pepsi',
            precio: 9000,
            cantidad: 1,
          ),
        ],
      );
      final estados = validarCarrito([peperoni, conPepsi], catalogo);
      expect(estados[peperoni.id]!.noDisponible, isTrue);
      expect(
        estados[peperoni.id]!.mensaje,
        'Pizza Peperoni ya no está disponible.',
      );
      expect(estados[conPepsi.id]!.noDisponible, isTrue);
      expect(
        estados[conPepsi.id]!.mensaje,
        'Gaseosa Pepsi ya no está disponible.',
      );
    });

    test('pizza: las porciones de ambos tamaños comparten las partes', () {
      // 30 partes: 6 Medianas (18) + 3 Grandes (12) = 30; una Grande más no.
      final medianas = lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        cantidad: 6,
      );
      final grandes = lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        tamano: 'Grande',
        precio: 16000,
        cantidad: 3,
      );
      expect(
        validarCarrito([
          medianas,
          grandes,
        ], catalogo).values.any((e) => e.bloquea),
        isFalse,
      );
      grandes.cantidad = 4;
      final estado = validarCarrito([medianas, grandes], catalogo)[grandes.id]!;
      expect(estado.maximo, 3);
      expect(
        estado.mensaje,
        'Solo quedan 3 porciones de Pizza Pollo Grande disponibles',
      );
    });

    test('stock nulo = sin límite; stock numérico limita en unidades', () {
      final carne = lineaCarrito(
        idProducto: 5,
        nombre: 'Lasaña Carne',
        tamano: 'Normal',
        cantidad: 50,
      );
      final mixta = lineaCarrito(
        idProducto: 6,
        nombre: 'Lasaña Mixta',
        tamano: 'Normal',
        cantidad: 4,
      );
      final estados = validarCarrito([carne, mixta], catalogo);
      expect(estados[carne.id]!.bloquea, isFalse);
      expect(estados[carne.id]!.maximo, isNull);
      expect(
        estados[mixta.id]!.mensaje,
        'Solo quedan 3 unidades de Lasaña Mixta',
      );
    });

    test('una bebida pedida en varias líneas suma su demanda', () {
      final a = lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        adiciones: [coca(3)],
      );
      final b = lineaCarrito(
        idProducto: 2,
        nombre: 'Pizza Hawaiana',
        adiciones: [coca(3)],
      );
      final estados = validarCarrito([a, b], catalogo);
      expect(
        estados[a.id]!.mensaje,
        'Solo quedan 5 unidades de Gaseosa Coca-Cola',
      );
      expect(
        estados[b.id]!.mensaje,
        'Solo quedan 5 unidades de Gaseosa Coca-Cola',
      );
    });
  });

  group('pantalla del carrito', () {
    testWidgets('línea no disponible o excedida: marcada y sin pagar', (
      tester,
    ) async {
      CartService.instance
        ..addItem(lineaCarrito(idProducto: 4, nombre: 'Pizza Peperoni'))
        ..addItem(
          lineaCarrito(
            idProducto: 6,
            nombre: 'Lasaña Mixta',
            tamano: 'Normal',
            precio: 21000,
            cantidad: 4,
          ),
        );
      await _montar(tester, const CartScreen());
      expect(
        find.text('Pizza Peperoni ya no está disponible.'),
        findsOneWidget,
      );
      expect(
        find.text('Solo quedan 3 unidades de Lasaña Mixta'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Algunos productos se agotaron o ya no tienen stock suficiente. '
          'Revisa tu carrito.',
        ),
        findsOneWidget,
      );
      expect(tester.widget<ElevatedButton>(_irAPagar()).onPressed, isNull);
      // La no disponible no se puede aumentar.
      final mas = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Agregar uno de Pizza Peperoni',
      );
      expect(tester.widget<Semantics>(mas).properties.enabled, isFalse);

      // Al bajar la cantidad y quitar la no disponible, se puede pagar.
      CartService.instance.removeItem(CartService.instance.items.first.id);
      await tester.pump();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Quitar uno de Lasaña Mixta',
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(_irAPagar()).onPressed, isNotNull);
    });

    testWidgets('si el catálogo no carga avisa, deja reintentar y no '
        'bloquea', (tester) async {
      backend.rutas['GET /productos'] = (_) =>
          errorBackend(503, 'No se pudo conectar con la base de datos.');
      CartService.instance.addItem(
        lineaCarrito(idProducto: 1, nombre: 'Pizza Pollo'),
      );
      await _montar(tester, const CartScreen());
      expect(
        find.textContaining('No pudimos revisar la disponibilidad.'),
        findsOneWidget,
      );
      expect(tester.widget<ElevatedButton>(_irAPagar()).onPressed, isNotNull);

      backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No pudimos revisar la disponibilidad.'),
        findsNothing,
      );
    });

    testWidgets('muestra textos en español y precios con formato', (
      tester,
    ) async {
      CartService.instance.addItem(
        lineaCarrito(
          idProducto: 1,
          nombre: 'Pizza Pollo',
          cantidad: 2,
          adiciones: [coca()],
        ),
      );
      await _montar(tester, const CartScreen());
      expect(find.text('Tamaño: Mediana · 2 porciones'), findsOneWidget);
      expect(find.text('Adiciones: Gaseosa Coca-Cola'), findsOneWidget);
      expect(find.text('\$36.000'), findsNWidgets(3));
    });

    for (final oscuro in [false, true]) {
      testWidgets('sin desborde con letra al 130 % en '
          '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
        SharedPreferences.setMockInitialValues({});
        backend.loginComo('Cliente');
        await AuthService.instance.login('ana@correo.com', 'Clave1234');
        addTearDown(AuthService.instance.logout);
        await ModoOscuroController.instance.cambiar(oscuro);
        addTearDown(() => ModoOscuroController.instance.cambiar(false));
        CartService.instance
          ..addItem(
            lineaCarrito(
              idProducto: 1,
              nombre: 'Pizza Pollo',
              cantidad: 2,
              adiciones: [coca()],
            ),
          )
          ..addItem(lineaCarrito(idProducto: 4, nombre: 'Pizza Peperoni'));
        await _montar(tester, const CartScreen(), ancho: 600, letra: 1.3);
        expect(
          Theme.of(tester.element(find.byType(Scaffold))).brightness,
          oscuro ? Brightness.dark : Brightness.light,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  test('el carrito se vacía al cerrar sesión', () async {
    backend.loginComo('Cliente');
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    CartService.instance.addItem(
      lineaCarrito(idProducto: 1, nombre: 'Pizza Pollo'),
    );
    await AuthService.instance.logout();
    expect(CartService.instance.items, isEmpty);
  });
}
