import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/widgets/bottom_nav.dart';
import 'package:sivpro_app/shared/client_notification_service.dart';
import 'package:sivpro_app/shared/pending_sales_badge.dart';

import 'support/backend_falso.dart';

Widget _pantalla(int indice) =>
    Scaffold(bottomNavigationBar: AppBottomNav(currentIndex: indice));

Future<void> _montar(
  WidgetTester tester,
  int indice, {
  double ancho = 400,
  double letra = 1,
  bool sinAnimaciones = false,
}) async {
  tester.view.physicalSize = Size(ancho, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(letra),
          disableAnimations: sinAnimaciones,
        ),
        child: child!,
      ),
      home: _pantalla(indice),
    ),
  );
  await tester.pumpAndSettle();
}

/// Igual que la barra: pantalla nueva sin transición sobre la actual.
Future<void> _reemplazar(WidgetTester tester, int indice) async {
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => _pantalla(indice),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
  await tester.pump();
}

Finder get _pildora => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.decoration is BoxDecoration &&
      (w.decoration as BoxDecoration).color == kSplashRojo,
);

double _izquierda(WidgetTester tester) => tester.getTopLeft(_pildora.last).dx;

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  tearDown(() {
    CartService.instance.clear();
    ClientNotificationService.instance.limpiar();
  });

  testWidgets('la píldora se desliza entre cualquier par de pestañas', (
    tester,
  ) async {
    await _montar(tester, 0);
    final posiciones = <int, double>{0: _izquierda(tester)};
    for (var i = 1; i < 5; i++) {
      await _reemplazar(tester, i);
      await tester.pumpAndSettle();
      posiciones[i] = _izquierda(tester);
    }
    for (final (desde, hasta) in [(4, 0), (0, 3), (3, 1), (1, 4), (2, 2)]) {
      await _reemplazar(tester, desde);
      await tester.pumpAndSettle();
      await _reemplazar(tester, hasta);
      await tester.pump(const Duration(milliseconds: 100));
      final aMitad = _izquierda(tester);
      if (desde == hasta) {
        expect(aMitad, posiciones[hasta]);
      } else {
        final (menor, mayor) = posiciones[desde]! < posiciones[hasta]!
            ? (posiciones[desde]!, posiciones[hasta]!)
            : (posiciones[hasta]!, posiciones[desde]!);
        expect(aMitad, greaterThan(menor), reason: '$desde → $hasta');
        expect(aMitad, lessThan(mayor), reason: '$desde → $hasta');
      }
      await tester.pumpAndSettle();
      expect(_izquierda(tester), posiciones[hasta]);
    }
  });

  testWidgets('desde una pantalla abierta con push (detalle de pedido) '
      'también anima, y al volver atrás', (tester) async {
    await _montar(tester, 3);
    final enPedidos = _izquierda(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => _pantalla(3)));
    await tester.pumpAndSettle();
    expect(_izquierda(tester), enPedidos);

    await _reemplazar(tester, 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_izquierda(tester), lessThan(enPedidos));
    await tester.pumpAndSettle();
    final enInicio = _izquierda(tester);

    // Atrás vuelve a Mis pedidos, que estaba debajo: también se desliza.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final volviendo = _izquierda(tester);
    expect(volviendo, greaterThan(enInicio));
    expect(volviendo, lessThan(enPedidos));
    await tester.pumpAndSettle();
    expect(_izquierda(tester), enPedidos);
  });

  testWidgets('el ítem activo usa icono relleno, blanco y escala hasta 1', (
    tester,
  ) async {
    await _montar(tester, 0);
    await _reemplazar(tester, 1);
    await tester.pump(const Duration(milliseconds: 60));
    final escala = tester
        .widget<Transform>(
          find.byWidgetPredicate(
            (w) =>
                w is Transform &&
                w.child is Icon &&
                (w.child! as Icon).icon == Icons.restaurant_menu,
          ),
        )
        .transform
        .entry(0, 0);
    expect(escala, inExclusiveRange(0.9, 1.0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Icon>(find.byIcon(Icons.restaurant_menu)).color,
      Colors.white,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.home_outlined)).color,
      Colors.black38,
    );
  });

  testWidgets('no anima la primera vez ni con "quitar animaciones"', (
    tester,
  ) async {
    await _montar(tester, 3, sinAnimaciones: true);
    final enPedidos = _izquierda(tester);
    await _reemplazar(tester, 0);
    final enInicio = _izquierda(tester);
    expect(enInicio, lessThan(enPedidos));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_izquierda(tester), enInicio);
  });

  testWidgets('al cerrar sesión se olvida la última pestaña', (tester) async {
    final backend = BackendFalso()..loginComo('Cliente');
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await _montar(tester, 4);
    await AuthService.instance.logout();
    expect(backend.peticiones, isNotEmpty);

    await _reemplazar(tester, 0);
    final inicial = _izquierda(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_izquierda(tester), inicial);
  });

  testWidgets('badges: aparecen con contador mayor que 0 y no con 0; el del '
      'carrito invierte colores cuando está activo', (tester) async {
    await _montar(tester, 0);
    expect(find.text('1'), findsNothing);
    expect(find.byType(PendingSalesBadge), findsOneWidget);
    expect(find.text('2'), findsNothing);

    CartService.instance.addItem(
      CartItem(
        id: 'p1',
        nombre: 'Pizza',
        imagen: '',
        tamanoNombre: 'Mediana',
        precioBase: 14000,
        adiciones: const [],
      ),
    );
    ClientNotificationService.instance.unreadCount.value = 2;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(tester.widget<Text>(find.text('1')).style!.color, Colors.white);

    await _reemplazar(tester, 2);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text('1')).style!.color, kSplashRojo);
  });

  for (final ancho in [320.0, 360.0]) {
    testWidgets('sin desborde en $ancho dp con letra al 130 %', (tester) async {
      ClientNotificationService.instance.unreadCount.value = 120;
      await _montar(tester, 3, ancho: ancho, letra: 1.3);
      expect(tester.takeException(), isNull);
      expect(find.text('99+'), findsOneWidget);
    });
  }
}
