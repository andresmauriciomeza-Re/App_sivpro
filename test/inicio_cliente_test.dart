import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/category_products_screen.dart';
import 'package:sivpro_app/client/screens/home_screen.dart';
import 'package:sivpro_app/client/screens/product_detail_screen.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/horario_local.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

/// Hora de pared de Bogotá (UTC-5) del jueves 26 de noviembre de 2026.
DateTime _bogota(int hora, int minuto, {int dia = 26}) =>
    DateTime.utc(2026, 11, dia, hora + 5, minuto);

Future<void> _montar(
  WidgetTester tester, {
  double ancho = 420,
  double alto = 1600,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, alto);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.claro,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(letra)),
        child: child!,
      ),
      home: const HomeScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

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
    HorarioLocal.reloj = () => _bogota(18, 0);
  });
  tearDown(() => HorarioLocal.reloj = DateTime.now);

  group('Abierto / Cerrado con la hora de Bogotá', () {
    for (final (hora, minuto, abierto) in [
      (15, 59, false),
      (16, 0, true),
      (21, 59, true),
      (22, 0, false),
    ]) {
      final texto =
          '${hora.toString().padLeft(2, '0')}:'
          '${minuto.toString().padLeft(2, '0')}';
      testWidgets('jueves $texto → ${abierto ? 'Abierto' : 'Cerrado'}', (
        tester,
      ) async {
        HorarioLocal.reloj = () => _bogota(hora, minuto);
        await _montar(tester);
        expect(find.text(abierto ? 'Abierto' : 'Cerrado'), findsOneWidget);
        expect(find.text(abierto ? 'Cerrado' : 'Abierto'), findsNothing);
      });
    }

    test('de lunes a miércoles está cerrado', () {
      expect(HorarioLocal.abierto(_bogota(18, 0, dia: 23)), isFalse);
      expect(HorarioLocal.abierto(_bogota(18, 0, dia: 25)), isFalse);
      expect(HorarioLocal.abierto(_bogota(18, 0, dia: 29)), isTrue);
    });
  });

  testWidgets('tarjeta del local con los datos de la web', (tester) async {
    await _montar(tester);
    expect(find.text('Jue–Dom · 4:00 p. m. – 10:00 p. m.'), findsOneWidget);
    expect(
      find.text('Cra. 45 #104-30, Laureles, Medellín, Antioquia'),
      findsOneWidget,
    );
    expect(find.text('320 882 0029'), findsOneWidget);
  });

  testWidgets('saludo con el nombre real', (tester) async {
    await _montar(tester);
    expect(find.text('Hola'), findsOneWidget);

    backend.loginComo('Cliente');
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    addTearDown(AuthService.instance.logout);
    await _montar(tester);
    expect(find.text('Hola, Ana Pérez'), findsOneWidget);
  });

  group('destacadas', () {
    testWidgets('las dos primeras Favoritas con imagen real y precio', (
      tester,
    ) async {
      await _montar(tester);
      expect(find.text('Pizza Pollo'), findsOneWidget);
      expect(find.text('Pizza Hawaiana'), findsOneWidget);
      expect(find.text('Pizza Peperoni'), findsNothing);
      expect(find.text('\$14.000'), findsNWidgets(2));

      await _tocar(tester, find.text('Pizza Pollo'));
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });

    testWidgets('"Ver todas" abre Favoritas', (tester) async {
      await _montar(tester);
      await _tocar(tester, find.text('Ver todas →').first);
      final pantalla = tester.widget<CategoryProductsScreen>(
        find.byType(CategoryProductsScreen),
      );
      expect(pantalla.categoryName, 'Favoritas');
    });

    testWidgets('si el catálogo falla, Reintentar en las destacadas', (
      tester,
    ) async {
      backend.rutas['GET /productos'] = (_) =>
          errorBackend(503, 'El servicio no está disponible en este momento.');
      await _montar(tester);
      expect(
        find.text('El servicio no está disponible en este momento.'),
        findsOneWidget,
      );
      backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
      await _tocar(tester, find.text('Reintentar'));
      expect(find.text('Pizza Pollo'), findsOneWidget);
      expect(backend.a('GET /productos'), hasLength(2));
    });
  });

  for (final seccion in ['Pizzas', 'Lasañas', 'Favoritas']) {
    testWidgets('el filtro $seccion abre la sección del catálogo', (
      tester,
    ) async {
      await _montar(tester);
      await _tocar(
        tester,
        find.descendant(
          of: find.byType(AnimatedContainer),
          matching: find.text(seccion),
        ),
      );
      final pantalla = tester.widget<CategoryProductsScreen>(
        find.byType(CategoryProductsScreen),
      );
      expect(pantalla.categoryName, seccion);
    });
  }

  for (final oscuro in [false, true]) {
    testWidgets('sin desborde con letra al 130 % y acento '
        '${oscuro ? 'de la paleta en oscuro' : 'naranja en claro'}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      addTearDown(AuthService.instance.logout);
      await ModoOscuroController.instance.cambiar(oscuro);
      addTearDown(() => ModoOscuroController.instance.cambiar(false));
      await _montar(tester, ancho: 600, letra: 1.3);
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        oscuro ? Brightness.dark : Brightness.light,
      );
      final verTodas = tester.widget<Text>(find.text('Ver todas →').first);
      expect(
        verTodas.style!.color,
        oscuro ? PaletaApp.rojoOscuro : const Color(0xFFE0472B),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
