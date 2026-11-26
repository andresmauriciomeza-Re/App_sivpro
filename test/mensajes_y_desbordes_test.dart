import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/widgets/barra_navegacion_admin.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/shared/mensaje_app.dart';
import 'package:sivpro_app/theme/app_colors.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

const _sinPrecio =
    'Esta bebida aún no tiene precio: registra una compra antes de ponerla '
    'disponible';

const _nombreLargo = 'Pizza de las Islas de Taikiki (Pizza Hawaina)';

Map<String, dynamic> _producto(String estado) => {
  ...filaCatalogo(
    1,
    _nombreLargo,
    1,
    precio: 0,
    precioGrande: 0,
    estado: estado,
    stockPartes: 125000,
  ),
  'categoria_nombre': 'Pizza',
};

void _vista(WidgetTester tester, {double ancho = 412, double borde = 0}) {
  tester.view.physicalSize = Size(ancho, 900);
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = FakeViewPadding(bottom: borde);
  tester.view.padding = FakeViewPadding(bottom: borde);
  addTearDown(tester.view.reset);
}

Finder get _globo => find
    .descendant(of: find.byType(SnackBar), matching: find.byType(Material))
    .first;

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    backend = BackendFalso();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => AuthService.instance.logout());

  group('componente de mensajes', () {
    const casos = [
      (
        TipoMensaje.exito,
        AppColors.bannerGreenFg,
        Icons.check_circle_outline,
        3,
      ),
      (TipoMensaje.informacion, Color(0xFF1565C0), Icons.info_outline, 3),
      (TipoMensaje.error, AppColors.red, Icons.warning_amber_rounded, 4),
    ];
    for (final (tipo, color, icono, segundos) in casos) {
      for (final oscuro in [false, true]) {
        testWidgets('${tipo.name} en ${oscuro ? 'oscuro' : 'claro'}', (
          tester,
        ) async {
          _vista(tester, ancho: 320);
          await tester.pumpWidget(
            MaterialApp(
              theme: oscuro ? AppTheme.oscuro : AppTheme.claro,
              home: const Scaffold(),
            ),
          );
          tester
              .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
              .mostrarMensaje(_sinPrecio, tipo: tipo);
          await tester.pumpAndSettle();

          final mensaje = tester.widget<SnackBar>(find.byType(SnackBar));
          expect(mensaje.behavior, SnackBarBehavior.floating);
          expect(mensaje.backgroundColor, color);
          expect(mensaje.duration, Duration(seconds: segundos));
          expect(mensaje.shape, isA<RoundedRectangleBorder>());
          expect(find.byIcon(icono), findsOneWidget);
          final texto = tester.widget<Text>(find.text(_sinPrecio));
          expect(texto.style!.color, Colors.white);
          expect(texto.style!.fontSize, greaterThanOrEqualTo(15));
          expect(texto.maxLines, isNull);
          expect(
            tester.getTopLeft(find.byIcon(icono)).dx,
            lessThan(tester.getTopLeft(find.text(_sinPrecio)).dx),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  Future<void> entrarAlPanel() async {
    backend.loginComo(
      'Empleado',
      permisos: [
        {
          'modulo': 'Producción',
          'nombre': 'Productos',
          'privilegios': ['Ver', 'Editar'],
        },
      ],
    );
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
  }

  Future<void> abrirProductos(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const ProductionModulesScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
  }

  Future<void> elegirEstado(
    WidgetTester tester,
    String actual,
    String opcion,
  ) async {
    await tester.tap(find.text(actual));
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcion).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar'));
    await tester.pumpAndSettle();
  }

  group('cambio de estado de un producto', () {
    for (final (actual, opcion) in [
      ('Disponible', 'Descontinuado'),
      ('No disponible', 'Automático'),
      ('Descontinuado', 'Automático'),
    ]) {
      for (final borde in [0.0, 34.0]) {
        testWidgets('$actual → $opcion: éxito, sin tapar la barra (borde '
            '${borde.toInt()})', (tester) async {
          _vista(tester, borde: borde);
          await entrarAlPanel();
          backend.rutas['GET /productos/gestion'] = (_) =>
              respuesta([_producto(actual)]);
          backend.rutas['PATCH /productos/1/estado'] = (_) =>
              respuesta(_producto('Disponible'));
          await abrirProductos(tester);
          await elegirEstado(tester, actual, opcion);

          expect(find.text('Producto marcado como $opcion'), findsOneWidget);
          expect(
            tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
            TipoMensaje.exito.color,
          );
          expect(
            backend.cuerpo(backend.a('PATCH /productos/1/estado').single),
            {'estado': opcion},
          );
          expect(
            tester.getRect(_globo).bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byType(BarraNavegacionAdmin)).top + 0.01,
            ),
          );
        });
      }
    }

    testWidgets('rechazo: muestra el mensaje del backend como error', (
      tester,
    ) async {
      _vista(tester);
      await entrarAlPanel();
      backend.rutas['GET /productos/gestion'] = (_) =>
          respuesta([_producto('Descontinuado')]);
      backend.rutas['PATCH /productos/1/estado'] = (_) =>
          errorBackend(409, _sinPrecio);
      await abrirProductos(tester);
      await elegirEstado(tester, 'Descontinuado', 'Automático');

      expect(find.text(_sinPrecio), findsOneWidget);
      expect(find.textContaining('Producto marcado'), findsNothing);
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
        TipoMensaje.error.color,
      );
    });
  });

  group('Editar Producto: al guardar bien avisa "Producto actualizado"', () {
    for (final desdeDetalle in [false, true]) {
      testWidgets('abierto desde ${desdeDetalle ? 'el detalle' : 'la lista'}', (
        tester,
      ) async {
        // Alta: el formulario es largo y "Guardar" queda al final.
        _vista(tester);
        tester.view.physicalSize = const Size(412, 2600);
        await entrarAlPanel();
        backend.rutas['GET /productos/gestion'] = (_) =>
            respuesta([_producto('Disponible')]);
        backend.rutas['GET /fichas'] = (_) => respuesta(<Object>[]);
        backend.rutas['GET /categorias-productos'] = (_) => respuesta([
          {'id_categoria': 1, 'nombre': 'Pizza'},
        ]);
        backend.rutas['PUT /productos/1'] = (_) =>
            respuesta(_producto('Disponible'));
        await abrirProductos(tester);
        if (desdeDetalle) {
          await tester.tap(find.byIcon(Icons.visibility_outlined));
          await tester.pumpAndSettle();
        }
        final editar = find.byIcon(Icons.edit_outlined).first;
        await tester.ensureVisible(editar);
        await tester.pumpAndSettle();
        await tester.tap(editar);
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);

        await tester.enterText(find.byType(TextField).first, 'Pizza nueva');
        final guardar = find.text('Guardar');
        await tester.ensureVisible(guardar);
        await tester.pumpAndSettle();
        await tester.tap(guardar);
        await tester.pumpAndSettle();

        expect(backend.a('PUT /productos/1'), hasLength(1));
        expect(find.text('Producto actualizado'), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          TipoMensaje.exito.color,
        );
      });
    }
  });

  testWidgets('cliente: el mensaje queda encima de su barra inferior', (
    tester,
  ) async {
    _vista(tester, borde: 34);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        home: const Scaffold(
          bottomNavigationBar: SizedBox(key: ValueKey('barra'), height: 90),
        ),
      ),
    );
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .mostrarMensaje(
          'Aviso',
          tipo: TipoMensaje.informacion,
          sobreBarraPanel: false,
        );
    await tester.pumpAndSettle();
    final barra = tester.getRect(find.byKey(const ValueKey('barra')));
    final globo = tester.getRect(_globo);
    expect(globo.bottom, lessThanOrEqualTo(barra.top));
    // Sin el levante de la barra del panel.
    expect(barra.top - globo.bottom, lessThanOrEqualTo(16));
  });

  test('ningún SnackBar nuevo sin diseño', () {
    // Los únicos con diseño propio, pendientes de decidir si se unifican.
    const conDisenoPropio = {
      'lib/auth/aviso_auth.dart',
      'lib/auth/session_manager.dart',
      'lib/client/screens/product_detail_screen.dart',
      'lib/client/widgets/bottom_nav.dart',
      'lib/shared/mensaje_app.dart',
    };
    final conSnackBar = {
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            RegExp(r'\bSnackBar\(').hasMatch(f.readAsStringSync()))
          f.path.replaceAll('\\', '/'),
    };
    expect(conSnackBar, conDisenoPropio);
  });

  testWidgets('tarjeta sin precio a 320 dp: no se desborda y el ojo y el lápiz '
      'se ven completos', (tester) async {
    _vista(tester, ancho: 320);
    await entrarAlPanel();
    backend.rutas['GET /productos/gestion'] = (_) =>
        respuesta([_producto('No disponible')]);
    await abrirProductos(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Sin precio'), findsOneWidget);
    expect(find.text('Grande sin precio'), findsOneWidget);
    for (final icono in [Icons.visibility_outlined, Icons.edit_outlined]) {
      final boton = find.widgetWithIcon(IconButton, icono);
      final caja = tester.getRect(boton);
      expect(caja.width, greaterThanOrEqualTo(48));
      expect(caja.height, greaterThanOrEqualTo(48));
      expect(caja.right, lessThanOrEqualTo(320));
    }
  });
}
