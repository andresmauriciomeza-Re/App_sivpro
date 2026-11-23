import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/widgets/barra_navegacion_admin.dart';
import 'package:sivpro_app/admin/widgets/sales_pending_badge.dart';
import 'package:sivpro_app/auth/models/usuario.dart';
import 'package:sivpro_app/shared/modulos_moviles.dart';
import 'package:sivpro_app/shared/pending_sales_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';
import 'package:sivpro_app/theme/paleta_app.dart';

const Color _pildoraClara = Color(0xE6C32828);

Usuario _usuario({bool superAdmin = false, List<Permiso> permisos = const []}) {
  return Usuario(
    id: 1,
    nombre: 'Prueba',
    correo: 'prueba@lasirena.com',
    numeroDocumento: '123',
    tipoDocumento: 'CC',
    telefono: '3000000000',
    rol: 'Empleado',
    esSuperAdmin: superAdmin,
    permisos: permisos,
    roles: const [],
  );
}

Permiso _ver(String modulo, String nombre) =>
    Permiso(modulo: modulo, nombre: nombre, privilegios: const ['Ver']);

/// Pantalla con la barra abajo, como en el panel.
Widget _pantalla(Widget barra) => Scaffold(
  body: Column(
    children: [
      const Expanded(child: SizedBox.expand()),
      barra,
    ],
  ),
);

Future<void> _montar(
  WidgetTester tester,
  Widget home, {
  ThemeData? tema,
  double ancho = 360,
  double letra = 1,
  bool sinAnimaciones = false,
}) async {
  tester.view.physicalSize = Size(ancho, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: tema ?? AppTheme.claro,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(letra),
          disableAnimations: sinAnimaciones,
        ),
        child: child!,
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

BarraNavegacionAdmin _barra(
  List<ModuloMovil> modulos,
  int seleccionado, {
  ValueChanged<int>? alTocar,
}) => BarraNavegacionAdmin(
  items: itemsBarraAdmin(modulos),
  seleccionado: seleccionado,
  alTocar: alTocar ?? (_) {},
);

Finder _pildora(Color color) => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.decoration is BoxDecoration &&
      (w.decoration as BoxDecoration).color == color,
);

/// Etiquetas visibles, de izquierda a derecha.
List<String> _etiquetas(WidgetTester tester) {
  final textos = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(BarraNavegacionAdmin),
          matching: find.byType(Text),
        ),
      )
      .where((t) => t.data != null && int.tryParse(t.data!) == null)
      .toList();
  textos.sort(
    (a, b) => tester
        .getCenter(find.byWidget(a))
        .dx
        .compareTo(tester.getCenter(find.byWidget(b)).dx),
  );
  return [for (final t in textos) t.data!];
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => PendingSalesService.instance.count.value = 0);

  group('ítems según permisos', () {
    final casos = <String, (Usuario, List<String>)>{
      'super administrador': (
        _usuario(superAdmin: true),
        ['Inicio', 'Compras', 'Producción', 'Ventas', 'Mi Perfil'],
      ),
      'empleado solo con Ventas': (
        _usuario(permisos: [_ver('Ventas', 'Ventas')]),
        ['Inicio', 'Ventas', 'Mi Perfil'],
      ),
      'empleado con Insumos y Orden de Producción': (
        _usuario(
          permisos: [
            _ver('Compras', 'Insumos'),
            _ver('Producción', 'Orden de Producción'),
          ],
        ),
        ['Inicio', 'Compras', 'Producción', 'Mi Perfil'],
      ),
      'sin permisos': (_usuario(), ['Inicio', 'Mi Perfil']),
    };
    for (final MapEntry(key: nombre, value: (usuario, esperadas))
        in casos.entries) {
      for (final oscuro in [false, true]) {
        testWidgets('$nombre en modo ${oscuro ? 'oscuro' : 'claro'}', (
          tester,
        ) async {
          await _montar(
            tester,
            _pantalla(_barra(modulosMoviles(usuario), 0)),
            tema: oscuro ? AppTheme.oscuro : AppTheme.claro,
          );
          expect(_etiquetas(tester), esperadas);
          final pildora = _pildora(
            oscuro ? PaletaApp.rojoBotonOscuro : _pildoraClara,
          );
          expect(pildora, findsOneWidget);
          // La píldora se reparte entre los ítems que haya.
          final ancho = tester.getSize(pildora).width;
          final ranura = (360 - 32 - 12) / esperadas.length;
          expect(ancho, closeTo(ranura - 4, 0.01));
          expect(tester.getSize(pildora).height, 52);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('claro: fondo blanco con sombra; oscuro: #1C1819 con borde', (
    tester,
  ) async {
    BoxDecoration caja() =>
        tester
                .widgetList<Container>(
                  find.descendant(
                    of: find.byType(BarraNavegacionAdmin),
                    matching: find.byType(Container),
                  ),
                )
                .first
                .decoration!
            as BoxDecoration;
    Decoration? frente() => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(BarraNavegacionAdmin),
            matching: find.byType(Container),
          ),
        )
        .first
        .foregroundDecoration;

    await _montar(tester, _pantalla(_barra(ModuloMovil.values, 0)));
    expect(caja().color, Colors.white);
    expect(caja().boxShadow!.single.color, Colors.black.withValues(alpha: .08));
    expect(frente(), isNull);
    expect(
      tester.getSize(find.byType(BarraNavegacionAdmin)).height,
      64 + 16 + 12,
    );

    await _montar(
      tester,
      _pantalla(_barra(ModuloMovil.values, 0)),
      tema: AppTheme.oscuro,
    );
    expect(caja().color, PaletaApp.tarjetaOscura);
    expect(caja().boxShadow!.single.color, Colors.transparent);
    expect(
      ((frente()! as BoxDecoration).border! as Border).top.color,
      PaletaApp.bordeOscuro,
    );
  });

  testWidgets('activo con icono relleno y blanco; inactivo outline y gris', (
    tester,
  ) async {
    await _montar(tester, _pantalla(_barra(ModuloMovil.values, 2)));
    expect(find.byIcon(Icons.factory), findsOneWidget);
    expect(find.byIcon(Icons.factory_outlined), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(Icons.factory)).color, Colors.white);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.home_outlined)).color,
      Colors.black38,
    );
  });

  for (final ancho in [320.0, 360.0]) {
    testWidgets('sin desborde en $ancho dp con letra al 130 %', (tester) async {
      await _montar(
        tester,
        _pantalla(_barra(ModuloMovil.values, 2)),
        ancho: ancho,
        letra: 1.3,
      );
      expect(tester.takeException(), isNull);
      final ranura = (ancho - 32 - 12) / 5 - 4;
      for (final etiqueta in ['Inicio', 'Compras', 'Producción', 'Ventas']) {
        final caja = find.ancestor(
          of: find.text(etiqueta),
          matching: find.byType(FittedBox),
        );
        expect(tester.getSize(caja).width, lessThanOrEqualTo(ranura + 0.01));
      }
      expect(find.text('Mi Perfil'), findsOneWidget);
    });
  }

  group('badge de Ventas', () {
    testWidgets('aparece con contador mayor que 0 y no con 0', (tester) async {
      await _montar(tester, _pantalla(_barra(ModuloMovil.values, 0)));
      expect(find.byType(SalesPendingBadge), findsNothing);

      PendingSalesService.instance.count.value = 7;
      await tester.pump();
      expect(find.byType(SalesPendingBadge), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      PendingSalesService.instance.count.value = 0;
      await tester.pump();
      expect(find.byType(SalesPendingBadge), findsNothing);
    });

    testWidgets('sobre la píldora activa invierte sus colores', (tester) async {
      PendingSalesService.instance.count.value = 3;
      BoxDecoration fondo() =>
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(SalesPendingBadge),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;

      await _montar(tester, _pantalla(_barra(ModuloMovil.values, 0)));
      expect(fondo().color, const Color(0xFFC9151E));

      await _montar(
        tester,
        _pantalla(_barra(ModuloMovil.values, adminSalesNavIndex)),
      );
      expect(fondo().color, Colors.white);
      expect(
        tester.widget<Text>(find.text('3')).style!.color,
        const Color(0xFFC62828),
      );
    });
  });

  testWidgets('tocar un ítem entrega su ID', (tester) async {
    final tocados = <int>[];
    await _montar(
      tester,
      _pantalla(_barra(ModuloMovil.values, 0, alTocar: tocados.add)),
    );
    for (final etiqueta in ['Compras', 'Producción', 'Ventas', 'Mi Perfil']) {
      await tester.tap(find.text(etiqueta));
    }
    expect(tocados, [1, 2, 3, 4]);
  });

  group('ModuleBottomNav usa la navegación existente', () {
    testWidgets('Inicio vuelve a la raíz aunque ya esté activo', (
      tester,
    ) async {
      await _montar(tester, const Scaffold(body: Text('raíz')));
      final navegador = tester.state<NavigatorState>(find.byType(Navigator));
      navegador.push(
        MaterialPageRoute<void>(
          builder: (_) => _pantalla(const ModuleBottomNav(selected: 0)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('raíz'), findsNothing);

      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      expect(find.text('raíz'), findsOneWidget);
    });

    testWidgets('tocar el ítem activo (no Inicio) no navega', (tester) async {
      await _montar(tester, const Scaffold(body: Text('raíz')));
      final navegador = tester.state<NavigatorState>(find.byType(Navigator));
      navegador.push(
        MaterialPageRoute<void>(
          builder: (_) => _pantalla(const ModuleBottomNav(selected: 4)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mi Perfil'));
      await tester.pumpAndSettle();
      expect(find.byType(ModuleBottomNav), findsOneWidget);
      expect(navegador.canPop(), isTrue);
    });
  });

  group('animación de la píldora', () {
    Future<void> abrir(WidgetTester tester, int seleccionado) {
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            PageRouteBuilder<void>(
              pageBuilder: (_, _, _) =>
                  _pantalla(_barra(ModuloMovil.values, seleccionado)),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
      return tester.pump();
    }

    double izquierda(WidgetTester tester) =>
        tester.getTopLeft(_pildora(_pildoraClara).last).dx;

    testWidgets('se desliza del ítem anterior al nuevo y al volver a Inicio', (
      tester,
    ) async {
      await _montar(tester, _pantalla(_barra(ModuloMovil.values, 0)));
      final enInicio = izquierda(tester);

      await abrir(tester, 4);
      await tester.pump(const Duration(milliseconds: 100));
      final aMitad = izquierda(tester);
      await tester.pumpAndSettle();
      final enPerfil = izquierda(tester);
      expect(aMitad, greaterThan(enInicio));
      expect(aMitad, lessThan(enPerfil));

      // Volver a la raíz (como Inicio): la barra de abajo anima de 4 a 0.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final volviendo = izquierda(tester);
      expect(volviendo, greaterThan(enInicio));
      expect(volviendo, lessThan(enPerfil));
      await tester.pumpAndSettle();
      expect(izquierda(tester), enInicio);
    });

    testWidgets('la primera barra no anima y con "quitar animaciones" '
        'el cambio es instantáneo', (tester) async {
      await _montar(
        tester,
        _pantalla(_barra(ModuloMovil.values, 3)),
        sinAnimaciones: true,
      );
      final enVentas = izquierda(tester);

      await abrir(tester, 1);
      final enCompras = izquierda(tester);
      expect(enCompras, lessThan(enVentas));
      await tester.pump(const Duration(milliseconds: 100));
      expect(izquierda(tester), enCompras);
    });

    testWidgets('si el ítem anterior no existe por permisos, no anima', (
      tester,
    ) async {
      await _montar(tester, _pantalla(_barra(ModuloMovil.values, 2)));
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            PageRouteBuilder<void>(
              pageBuilder: (_, _, _) =>
                  _pantalla(_barra(const [ModuloMovil.ventas], 3)),
              transitionDuration: Duration.zero,
            ),
          );
      await tester.pump();
      final inicial = izquierda(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(izquierda(tester), inicial);
    });
  });
}
