import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/cart_screen.dart';
import 'package:sivpro_app/client/screens/home_screen.dart';
import 'package:sivpro_app/client/screens/menu_screen.dart';
import 'package:sivpro_app/client/screens/my_orders_screen.dart';
import 'package:sivpro_app/client/screens/profile_screen.dart';
import 'package:sivpro_app/client/widgets/bottom_nav.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/shared/tarjeta_modo_oscuro.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';

import 'support/backend_falso.dart';

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double ancho = 420,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      // Tema de la app para el cliente: claro (ver temaOscuroActivo).
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

Brightness _brillo(WidgetTester tester, Type pantalla) => Theme.of(
  tester.element(
    find.descendant(of: find.byType(pantalla), matching: find.byType(Scaffold)),
  ),
).brightness;

/// Fondo de la cápsula de la barra inferior del cliente.
Color? _fondoBarra(WidgetTester tester) =>
    (tester
                .widgetList<Container>(
                  find.descendant(
                    of: find.byType(AppBottomNav),
                    matching: find.byType(Container),
                  ),
                )
                .first
                .decoration!
            as BoxDecoration)
        .color;

Future<void> _guardar(
  WidgetTester tester, {
  required String correo,
  required String telefono,
}) async {
  await tester.tap(find.text('Editar'));
  await tester.pump();
  await tester.enterText(find.byType(TextField).at(0), correo);
  await tester.enterText(find.byType(TextField).at(1), telefono);
  await tester.tap(find.text('Guardar'));
  await tester.pump();
  await tester.pump();
}

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ModoOscuroController.instance.cambiar(false);
    backend = BackendFalso()..loginComo('Cliente');
    backend.rutas['GET /auth/me'] = (_) =>
        respuesta({'usuario': usuarioJson()});
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
  });
  tearDown(() async {
    await AuthService.instance.logout();
    await ModoOscuroController.instance.cambiar(false);
  });

  testWidgets('la tarjeta "Modo oscuro" alterna y guarda la preferencia; el '
      'perfil y su barra pasan a oscuro', (tester) async {
    await _montar(tester, const ProfileScreen());
    expect(find.byType(TarjetaModoOscuro), findsOneWidget);
    expect(find.text('Desactivado'), findsOneWidget);
    expect(_brillo(tester, ProfileScreen), Brightness.light);
    expect(_fondoBarra(tester), Colors.white);

    await tester.tap(find.text('Modo oscuro'));
    await tester.pumpAndSettle();
    expect(ModoOscuroController.instance.oscuro.value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ModoOscuroController.clave), isTrue);
    expect(find.text('Activado'), findsOneWidget);
    expect(_brillo(tester, ProfileScreen), Brightness.dark);
    expect(
      tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(ProfileScreen),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor,
      PaletaApp.fondoOscuro,
    );
    expect(_fondoBarra(tester), PaletaApp.tarjetaOscura);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(prefs.getBool(ModoOscuroController.clave), isFalse);
    expect(_brillo(tester, ProfileScreen), Brightness.light);
  });

  // Con la preferencia activa, todas las pestañas del cliente (y su barra)
  // pasan a oscuro.
  for (final (nombre, pantalla, tipo) in [
    ('Inicio', const HomeScreen() as Widget, HomeScreen),
    ('Menú', const MenuScreen() as Widget, MenuScreen),
    ('Carrito', const CartScreen() as Widget, CartScreen),
    ('Mis pedidos', const MyOrdersScreen() as Widget, MyOrdersScreen),
  ]) {
    testWidgets('$nombre pasa a oscuro (con su barra) con la preferencia '
        'activa', (tester) async {
      await ModoOscuroController.instance.cambiar(true);
      // Ancho amplio: la fuente de pruebas mide 1 em por letra.
      await _montar(tester, pantalla, ancho: 1000);
      expect(_brillo(tester, tipo), Brightness.dark);
      expect(_fondoBarra(tester), PaletaApp.tarjetaOscura);
    });
  }

  // La fuente de pruebas mide 1 em por letra (más ancha que Poppins): el
  // ancho de 320 dp se midió aparte con Poppins real.
  for (final oscuro in [false, true]) {
    testWidgets('perfil ${oscuro ? 'oscuro' : 'claro'} sin desborde con letra '
        'al 130 %', (tester) async {
      await ModoOscuroController.instance.cambiar(oscuro);
      await _montar(tester, const ProfileScreen(), ancho: 412, letra: 1.3);
      expect(
        _brillo(tester, ProfileScreen),
        oscuro ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);
    });
  }

  group('validación frente a PUT /auth/perfil', () {
    for (final (correo, telefono, mensaje) in [
      ('ana@correo', '3001234567', 'Ingresa un correo válido y sin espacios.'),
      (
        '.ana@correo.com',
        '3001234567',
        'Ingresa un correo válido y sin espacios.',
      ),
      (
        'ana@correo.com',
        '123456',
        'El teléfono debe tener solo números, entre 7 y 15 dígitos.',
      ),
      ('', '3001234567', 'El correo es obligatorio'),
    ]) {
      testWidgets('rechaza "$correo" / "$telefono" sin llamar', (tester) async {
        await _montar(tester, const ProfileScreen());
        await _guardar(tester, correo: correo, telefono: telefono);
        expect(find.text(mensaje), findsOneWidget);
        expect(backend.a('PUT /auth/perfil'), isEmpty);
      });
    }

    testWidgets('envía solo correo (en minúsculas) y teléfono', (tester) async {
      backend.rutas['PUT /auth/perfil'] = (_) =>
          respuesta({'usuario': usuarioJson()});
      await _montar(tester, const ProfileScreen());
      await _guardar(
        tester,
        correo: 'Ana.Nueva+1@Correo.CO',
        telefono: '3001234567',
      );
      expect(backend.cuerpo(backend.a('PUT /auth/perfil').single), {
        'correo': 'ana.nueva+1@correo.co',
        'telefono': '3001234567',
      });
    });

    for (final (estado, mensaje) in [
      (400, 'Ingresa un correo válido y sin espacios.'),
      (409, 'Este correo ya está registrado.'),
      (
        429,
        'Demasiadas actualizaciones de perfil. Intenta de nuevo más tarde.',
      ),
    ]) {
      testWidgets('$estado muestra el mensaje del backend', (tester) async {
        backend.rutas['PUT /auth/perfil'] = (_) =>
            errorBackend(estado, mensaje);
        await _montar(tester, const ProfileScreen());
        await _guardar(
          tester,
          correo: 'otra@correo.com',
          telefono: '3001234567',
        );
        expect(find.text(mensaje), findsOneWidget);
        expect(find.text('Guardar'), findsOneWidget); // sigue editando
      });
    }
  });
}
