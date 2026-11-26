import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/services/indicators_service.dart';
import 'package:sivpro_app/admin/widgets/module_card.dart';
import 'package:sivpro_app/admin/widgets/period_selector.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

Map<String, dynamic> _ver(String modulo, String nombre) => {
  'modulo': modulo,
  'nombre': nombre,
  'privilegios': ['Ver'],
};

const _subtitulo = 'Medición y desempeño de la gestión administrativa';
const _clientes = 'Clientes: frecuentes y mayores consumidores';
const _secciones = [
  'Devoluciones',
  'Productos más vendidos',
  'Comportamiento de las ventas',
  'Productos no conformes por semana',
];

Future<void> _montar(
  WidgetTester tester, {
  ThemeData? tema,
  double ancho = 412,
  double alto = 2600,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, alto);
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
      home: adminHomeScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Etiquetas de la barra inferior, de izquierda a derecha.
List<String> _barra(WidgetTester tester) {
  final textos = find.descendant(
    of: find.byType(ModuleBottomNav),
    matching: find.byType(Text),
  );
  final lista = tester.widgetList<Text>(textos).toList()
    ..sort(
      (a, b) => tester
          .getCenter(find.byWidget(a))
          .dx
          .compareTo(tester.getCenter(find.byWidget(b)).dx),
    );
  return [
    for (final t in lista)
      if ((t.data ?? '').length > 2) t.data!,
  ];
}

void main() {
  late BackendFalso backend;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    backend = BackendFalso();
    backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
    backend.rutas['GET /productos-no-conformes'] = (_) => respuesta(<Object>[]);
  });
  tearDown(() => AuthService.instance.logout());

  Future<void> entrar(String rol, List<Map<String, dynamic>> permisos) async {
    backend.loginComo(rol, permisos: permisos);
    backend.rutas['GET /auth/me'] = (_) =>
        respuesta(usuarioJson(rol: rol, permisos: permisos));
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
  }

  group('Empleado', () {
    testWidgets('con Indicadores: el Inicio los muestra sin las tarjetas '
        'Ventas ni Indicadores', (tester) async {
      await entrar('Empleado', [
        _ver('Ventas', 'Ventas'),
        _ver('Ventas', 'Devoluciones'),
        _ver('Producción', 'Producto No Conforme'),
      ]);
      await _montar(tester);
      expect(find.text('Inicio'), findsWidgets);
      expect(find.text(_clientes), findsNothing);
      expect(find.text(_subtitulo), findsOneWidget);
      expect(find.text('Seleccione un módulo'), findsNothing);
      expect(find.byType(SelectorPeriodo<int>), findsNWidgets(2));
      for (final seccion in _secciones) {
        expect(find.text(seccion), findsOneWidget);
      }
      expect(find.byType(ModuleCard), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(_barra(tester), ['Inicio', 'Ventas', 'Mi Perfil']);
      expect(backend.a('GET /ventas'), hasLength(1));
      expect(backend.a('GET /productos-no-conformes'), hasLength(1));
    });

    testWidgets('cambiar mes y año recalcula sin pedir de nuevo y no se '
        'duplican peticiones al volver al Inicio', (tester) async {
      await entrar('Empleado', [_ver('Ventas', 'Ventas')]);
      await _montar(tester);
      final ahora = ahoraBogota();
      final mes = nombresMes[ahora.month - 1];
      await tester.tap(find.text(mes[0].toUpperCase() + mes.substring(1)));
      await tester.pumpAndSettle();
      // El mes vecino queda visible en el menú (no hace falta desplazarlo).
      final vecino = nombresMes[ahora.month == 1 ? 1 : ahora.month - 2];
      final otro = vecino[0].toUpperCase() + vecino.substring(1);
      await tester.tap(find.text(otro).last);
      await tester.pumpAndSettle();
      expect(find.text(otro), findsOneWidget);
      await tester.tap(find.text('${ahora.year}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${ahora.year - 1}').last);
      await tester.pumpAndSettle();
      expect(find.text('${ahora.year - 1}'), findsOneWidget);
      expect(backend.a('GET /ventas'), hasLength(1));

      // Mi Perfil y de vuelta a Inicio: el Inicio sigue montado debajo.
      await tester.tap(find.text('Mi Perfil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inicio').last);
      await tester.pumpAndSettle();
      expect(find.text(_subtitulo), findsOneWidget);
      expect(backend.a('GET /ventas'), hasLength(1));
    });

    testWidgets('con otros módulos conserva sus tarjetas debajo', (
      tester,
    ) async {
      await entrar('Empleado', [
        _ver('Ventas', 'Ventas'),
        _ver('Compras', 'Insumos'),
        _ver('Producción', 'Orden de Producción'),
      ]);
      await _montar(tester);
      expect(find.text(_subtitulo), findsOneWidget);
      expect(find.byType(ModuleCard), findsNWidgets(2));
      expect(find.text('Compras'), findsWidgets);
      expect(find.text('Órdenes de producción y productos.'), findsOneWidget);
      expect(find.text('Clientes y gestión de ventas.'), findsNothing);
      expect(
        tester.getTopLeft(find.byType(ModuleCard).first).dy,
        greaterThan(tester.getTopLeft(find.text(_secciones.last)).dy),
      );
    });

    testWidgets('sin Indicadores: sin indicadores ni tarjeta Ventas', (
      tester,
    ) async {
      await entrar('Empleado', [
        _ver('Ventas', 'Clientes'),
        _ver('Compras', 'Insumos'),
      ]);
      await _montar(tester);
      expect(find.text(_subtitulo), findsNothing);
      expect(find.byType(SelectorPeriodo<int>), findsNothing);
      expect(find.text('Seleccione un módulo'), findsOneWidget);
      expect(find.byType(ModuleCard), findsOneWidget);
      expect(find.text('Compras, insumos y proveedores.'), findsOneWidget);
      expect(backend.a('GET /ventas'), isEmpty);
    });

    testWidgets('sin Indicadores ni otros módulos: estado vacío existente', (
      tester,
    ) async {
      await entrar('Empleado', [_ver('Ventas', 'Clientes')]);
      await _montar(tester);
      expect(find.byType(ModuleCard), findsNothing);
      expect(
        find.text('Tu rol no tiene módulos disponibles en la app móvil.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    for (final oscuro in [false, true]) {
      testWidgets('sin desborde a 320 dp con letra al 130 % en '
          '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
        await entrar('Empleado', [
          _ver('Ventas', 'Ventas'),
          _ver('Compras', 'Insumos'),
        ]);
        await _montar(
          tester,
          tema: oscuro ? AppTheme.oscuro : AppTheme.claro,
          ancho: 320,
          letra: 1.3,
        );
        expect(find.text(_subtitulo), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('Administrador: su Inicio y su pantalla de Indicadores siguen '
      'igual (con flecha de volver)', (tester) async {
    await entrar('Administrador', [
      _ver('Ventas', 'Ventas'),
      _ver('Ventas', 'Devoluciones'),
    ]);
    await _montar(tester);
    expect(find.text('Seleccione un módulo'), findsOneWidget);
    expect(find.text('Clientes y gestión de ventas.'), findsOneWidget);
    expect(find.text('Medición y desempeño de la gestión.'), findsOneWidget);
    expect(find.text(_subtitulo), findsNothing);
    expect(backend.a('GET /ventas'), isEmpty);

    await tester.tap(find.text('Medición y desempeño de la gestión.'));
    await tester.pumpAndSettle();
    expect(find.byType(IndicatorsScreen), findsOneWidget);
    expect(find.text('Indicadores'), findsOneWidget);
    expect(find.text(_subtitulo), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byType(SelectorPeriodo<int>), findsNWidgets(2));
    expect(find.text(_clientes), findsNothing);
    for (final seccion in _secciones) {
      expect(find.text(seccion), findsOneWidget);
    }
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Seleccione un módulo'), findsOneWidget);
  });
}
