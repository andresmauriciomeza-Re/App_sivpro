import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

const _iconos = {
  'Iniciar': Icons.play_arrow,
  'Completar': Icons.check,
  'Dar de baja': Icons.block,
  'Editar': Icons.edit_outlined,
  'Detalle': Icons.visibility_outlined,
};

Map<String, dynamic> _orden(String estado) => {
  'id_orden_produccion': 1,
  'tipo': 'Pedido',
  'estado': estado,
  'fecha_solicitada': '2026-11-26',
  'lineas': <Object>[],
};

/// El botón (círculo) de una acción, localizado por su tooltip.
Finder _boton(String nombre) => find.descendant(
  of: find.byTooltip(nombre),
  matching: find.byType(OutlinedButton),
);

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    backend = BackendFalso();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => AuthService.instance.logout());

  Future<void> abrirOrdenes(
    WidgetTester tester,
    String estado, {
    double ancho = 412,
    double letra = 1,
    bool oscuro = false,
  }) async {
    tester.view.physicalSize = Size(ancho, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    backend.loginComo(
      'Administrador',
      permisos: [
        {
          'modulo': 'Producción',
          'nombre': 'Orden de Producción',
          'privilegios': ['Ver', 'Editar'],
        },
      ],
    );
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    backend.rutas['GET /ordenes-produccion'] = (_) =>
        respuesta([_orden(estado)]);
    backend.rutas['GET /ordenes-produccion/1'] = (_) =>
        respuesta(_orden(estado));
    await tester.pumpWidget(
      MaterialApp(
        theme: oscuro ? AppTheme.oscuro : AppTheme.claro,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(letra)),
          child: child!,
        ),
        home: const ProductionModulesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Órdenes de producción'));
    await tester.pumpAndSettle();
  }

  const casos = {
    'Pendiente': ['Iniciar', 'Dar de baja', 'Editar', 'Detalle'],
    'En proceso': ['Completar', 'Dar de baja', 'Editar', 'Detalle'],
    'Completada': ['Detalle'],
    'Cancelada': ['Detalle'],
  };

  for (final MapEntry(key: estado, value: visibles) in casos.entries) {
    for (final ancho in [320.0, 360.0]) {
      for (final oscuro in [false, true]) {
        testWidgets('$estado a ${ancho.toInt()} dp, letra 130 %, '
            '${oscuro ? 'oscuro' : 'claro'}: solo íconos en una fila', (
          tester,
        ) async {
          await abrirOrdenes(
            tester,
            estado,
            ancho: ancho,
            letra: 1.3,
            oscuro: oscuro,
          );
          expect(tester.takeException(), isNull);

          for (final nombre in _iconos.keys) {
            expect(find.text(nombre), findsNothing);
            expect(
              find.byTooltip(nombre),
              visibles.contains(nombre) ? findsOneWidget : findsNothing,
              reason: nombre,
            );
          }
          final cajas = [for (final n in visibles) tester.getRect(_boton(n))];
          for (final (i, caja) in cajas.indexed) {
            final nombre = visibles[i];
            expect(caja.width, greaterThanOrEqualTo(48), reason: nombre);
            expect(caja.height, greaterThanOrEqualTo(48), reason: nombre);
            expect(caja.right, lessThanOrEqualTo(ancho), reason: nombre);
            expect(caja.top, cajas.first.top, reason: 'misma fila');
            if (i > 0) {
              expect(caja.left - cajas[i - 1].right, greaterThanOrEqualTo(12));
            }
            final icono = find.descendant(
              of: _boton(nombre),
              matching: find.byIcon(_iconos[nombre]!),
            );
            expect(tester.widget<Icon>(icono).semanticLabel, nombre);
          }
          // Alineados a la izquierda de la tarjeta.
          expect(
            cajas.first.left,
            closeTo(tester.getRect(find.text('Orden 1')).left, 1),
          );
        });
      }
    }
  }

  testWidgets('cada ícono hace lo mismo y el detalle conserva el texto', (
    tester,
  ) async {
    await abrirOrdenes(tester, 'Pendiente');
    await tester.longPress(_boton('Dar de baja'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Dar de baja'), findsOneWidget); // el tooltip
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(_boton('Detalle'));
    await tester.pumpAndSettle();
    for (final nombre in ['Iniciar', 'Dar de baja', 'Editar']) {
      expect(find.widgetWithText(OutlinedButton, nombre), findsOneWidget);
    }
  });

  testWidgets('en el detalle, Completar sigue con su texto', (tester) async {
    await abrirOrdenes(tester, 'En proceso');
    await tester.tap(_boton('Detalle'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Completar'), findsOneWidget);
  });
}
