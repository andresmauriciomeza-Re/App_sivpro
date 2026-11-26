import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/notificaciones/notificacion.dart';
import 'package:sivpro_app/admin/notificaciones/notificaciones_repository.dart';
import 'package:sivpro_app/admin/screens/notificaciones_screen.dart';
import 'package:sivpro_app/admin/screens/purchases_screen.dart';
import 'package:sivpro_app/admin/services/insumos_repository.dart';
import 'package:sivpro_app/admin/services/ventas_repository.dart';
import 'package:sivpro_app/admin/widgets/campana_notificaciones.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/home_screen.dart';
import 'package:sivpro_app/shared/pending_sales_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

Map<String, dynamic> _ver(String modulo, String nombre) => {
  'modulo': modulo,
  'nombre': nombre,
  'privilegios': ['Ver'],
};

final _ventasEInsumos = [_ver('Ventas', 'Ventas'), _ver('Compras', 'Insumos')];

Venta _venta(int id, {String estado = 'Por verificar'}) => Venta.fromJson({
  'id_venta': id,
  'cliente_nombre': 'Cliente $id',
  'monto': '56000.00',
  'estado': estado,
  'fecha': '2026-11-24T10:00:00.000000',
});

Insumo _insumo(int id, {Object actual = '10', bool activo = true}) =>
    Insumo.fromJson({
      'id_insumo': id,
      'nombre': 'Queso $id',
      'tipo': 'Insumo',
      'unidad_medida': 'kg',
      'stock_actual': actual,
      'stock_minimo': '5',
      'stock_maximo': null,
      'estado': activo,
    });

final _local = NotificacionesLocal.instance;

/// Puntos de "sin leer" de la lista.
final _sinLeer = find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == 'Sin leer',
);
final _ahora = DateTime(2026, 11, 24, 15);

Future<List<Notificacion>> _lista() => _local.listar();

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    NotificacionesLocal.reloj = () => _ahora;
    _local.start();
  });
  setUp(() {
    backend = BackendFalso();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    await AuthService.instance.logout();
  });

  Future<void> entrar(
    String rol,
    List<Map<String, dynamic>> permisos, {
    int id = 7,
  }) async {
    backend.rutas['POST /auth/login'] = (_) => respuesta({
      'token': 'token-de-prueba',
      'usuario': {...usuarioJson(rol: rol, permisos: permisos), 'id': id},
    });
    backend.rutas['GET /auth/me'] = (_) =>
        respuesta({...usuarioJson(rol: rol, permisos: permisos), 'id': id});
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await _local.listar();
  }

  group('alimentación', () {
    test('primera vez: solo dos resúmenes y sin duplicar después', () async {
      await entrar('Empleado', _ventasEInsumos);
      final ventas = [_venta(1), _venta(2), _venta(3, estado: 'Completado')];
      final insumos = [
        _insumo(1),
        _insumo(2, actual: '3'),
        _insumo(3, actual: '0'),
        _insumo(4, actual: '0', activo: false),
      ];
      await _local.desdeVentas(ventas);
      await _local.desdeInsumos(insumos);
      var lista = await _lista();
      expect(lista.map((n) => n.titulo), {
        'Tienes 2 ventas por verificar',
        '2 insumos en nivel mínimo',
      });
      expect(lista.every((n) => !n.leida), isTrue);
      expect(_local.conteoNoLeidas.value, 2);

      await _local.desdeVentas(ventas);
      await _local.desdeInsumos(insumos);
      lista = await _lista();
      expect(lista, hasLength(2));
    });

    test('sin elementos no crea resúmenes', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas([_venta(1, estado: 'Completado')]);
      await _local.desdeInsumos([_insumo(1)]);
      expect(await _lista(), isEmpty);
    });

    test('una venta nueva por verificar avisa una sola vez', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas([_venta(1)]);
      await _local.desdeVentas([_venta(1), _venta(2)]);
      await _local.desdeVentas([_venta(1), _venta(2)]);
      final ventas = (await _lista())
          .where((n) => n.tipo == TipoNotificacion.ventaPorVerificar)
          .toList();
      expect(ventas, hasLength(1));
      expect(ventas.single.id, 'venta:2');
      expect(ventas.single.referencia, '2');
      expect(ventas.single.destino, DestinoNotificacion.ventas);
      expect(ventas.single.mensaje, 'VEN-002 · Cliente 2');
      expect(ventas.single.fecha, _ahora);
    });

    test('sin permiso de Ventas no recibe avisos de ventas', () async {
      await entrar('Empleado', [_ver('Compras', 'Insumos')]);
      await _local.desdeVentas([_venta(1)]);
      await _local.desdeVentas([_venta(1), _venta(2)]);
      expect(await _lista(), isEmpty);
    });

    test('insumo: OK → bajo mínimo → agotado, un aviso por cambio', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeInsumos([_insumo(1)]);
      await _local.desdeInsumos([_insumo(1, actual: '3')]);
      await _local.desdeInsumos([_insumo(1, actual: '2')]);
      await _local.desdeInsumos([_insumo(1, actual: '0')]);
      await _local.desdeInsumos([_insumo(1, actual: '0')]);
      final lista = await _lista();
      expect(lista.map((n) => n.id), {'insumo:1:agotado', 'insumo:1:bajo'});
      expect(
        lista.firstWhere((n) => n.id == 'insumo:1:bajo').mensaje,
        'Queso 1: 3 kg (mínimo 5 kg).',
      );
      expect(
        lista.firstWhere((n) => n.id == 'insumo:1:agotado').titulo,
        'Insumo agotado',
      );
    });

    test('sin permiso de Insumos no recibe avisos de insumos', () async {
      await entrar('Empleado', [_ver('Ventas', 'Ventas')]);
      await _local.desdeInsumos([_insumo(1, actual: '0')]);
      await _local.desdeInsumos([_insumo(1), _insumo(2, actual: '0')]);
      expect(await _lista(), isEmpty);
    });

    test('PendingSalesService sigue contando y alimenta las '
        'notificaciones', () async {
      await entrar('Administrador', _ventasEInsumos);
      PendingSalesService.instance.actualizarDesde([_venta(1), _venta(2)]);
      expect(PendingSalesService.instance.count.value, 2);
      await pumpEventQueue();
      expect(_local.conteoNoLeidas.value, 1);
      PendingSalesService.instance.count.value = 0;
    });

    test('el Cliente no genera notificaciones del panel', () async {
      await entrar('Cliente', const []);
      await _local.desdeVentas([_venta(1)]);
      expect(await _lista(), isEmpty);
    });
  });

  group('almacenamiento', () {
    test('por usuario, sin mezclar cuentas', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas([_venta(1)]);
      expect(await _lista(), hasLength(1));

      await AuthService.instance.logout();
      await entrar('Empleado', _ventasEInsumos, id: 8);
      expect(await _lista(), isEmpty);
      expect(_local.conteoNoLeidas.value, 0);

      await AuthService.instance.logout();
      await entrar('Empleado', _ventasEInsumos);
      expect(await _lista(), hasLength(1));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notificaciones_panel_7'), isNotNull);
      expect(
        prefs.getString('notificaciones_panel_7'),
        contains('resumen:ventas'),
      );
      expect(prefs.getString('notificaciones_panel_8'), isNull);
    });

    test('máximo 50, primero salen las leídas más viejas, sin duplicar '
        'ids', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas(const []); // línea base vacía
      var reloj = DateTime(2026, 11, 1);
      for (var i = 1; i <= 50; i++) {
        NotificacionesLocal.reloj = () => reloj;
        reloj = reloj.add(const Duration(minutes: 1));
        await _local.desdeVentas([_venta(i)]);
      }
      // La más vieja queda sin leer; la segunda más vieja, leída.
      await _local.marcarLeida('venta:2');
      NotificacionesLocal.reloj = () => reloj;
      await _local.desdeVentas([_venta(51)]);
      NotificacionesLocal.reloj = () => _ahora;
      final lista = await _lista();
      expect(lista, hasLength(50));
      expect(lista.map((n) => n.id).toSet(), hasLength(50));
      expect(lista.any((n) => n.id == 'venta:2'), isFalse);
      expect(lista.any((n) => n.id == 'venta:1'), isTrue);
      expect(lista.first.id, 'venta:51');

      final guardado = jsonDecode(
        (await SharedPreferences.getInstance()).getString(
          'notificaciones_panel_7',
        )!,
      );
      expect(guardado, hasLength(50));
    });

    test('marcar leída baja el contador; marcar todas lo deja en 0; cerrar '
        'sesión vacía la memoria', () async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas(const []);
      await _local.desdeVentas([_venta(1), _venta(2), _venta(3)]);
      expect(_local.conteoNoLeidas.value, 3);
      await _local.marcarLeida('venta:2');
      expect(_local.conteoNoLeidas.value, 2);
      await _local.marcarTodasLeidas();
      expect(_local.conteoNoLeidas.value, 0);
      await _local.desdeVentas([_venta(4)]);
      expect(_local.conteoNoLeidas.value, 1);

      await AuthService.instance.logout();
      expect(_local.conteoNoLeidas.value, 0);
      expect(await _lista(), isEmpty);
    });
  });

  test('fecha relativa corta', () {
    final ahora = DateTime(2026, 11, 24, 15);
    expect(fechaRelativa(ahora, ahora), 'Ahora');
    expect(
      fechaRelativa(ahora.subtract(const Duration(minutes: 5)), ahora),
      'Hace 5 min',
    );
    expect(
      fechaRelativa(ahora.subtract(const Duration(hours: 3)), ahora),
      'Hace 3 h',
    );
    expect(fechaRelativa(DateTime(2026, 11, 23, 22), ahora), 'Ayer');
    expect(fechaRelativa(DateTime(2026, 11, 20, 9), ahora), '20 nov 2026');
  });

  group('pantallas', () {
    Future<void> montar(
      WidgetTester tester,
      Widget home, {
      ThemeData? tema,
      double ancho = 412,
      double letra = 1,
    }) async {
      tester.view.physicalSize = Size(ancho, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          theme: tema ?? AppTheme.claro,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(letra)),
            child: child!,
          ),
          home: home,
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      backend.rutas['GET /insumos'] = (_) => respuesta(<Object>[]);
      backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
      backend.rutas['GET /productos-no-conformes'] = (_) =>
          respuesta(<Object>[]);
      backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
    });

    for (final rol in ['Administrador', 'Empleado']) {
      testWidgets('$rol: campana en Inicio y en pantallas secundarias, a la '
          'izquierda de las iniciales', (tester) async {
        await entrar(rol, _ventasEInsumos);
        await montar(tester, adminHomeScreen());
        expect(find.byType(CampanaNotificaciones), findsOneWidget);
        expect(
          tester.getCenter(find.byType(CampanaNotificaciones)).dx,
          lessThan(tester.getCenter(find.text('AP')).dx),
        );
        await montar(tester, insumosScreen());
        expect(find.byType(CampanaNotificaciones), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    }

    testWidgets('Dashboard: también lleva la campana', (tester) async {
      await entrar('Administrador', [
        _ver('Dashboard', 'Dashboard'),
        ..._ventasEInsumos,
      ]);
      // Vista ancha: la fuente de pruebas mide 1 em por letra y el resto del
      // Dashboard ya desborda a 412 dp con ella (también sin la campana).
      await montar(tester, adminHomeScreen(), ancho: 1000);
      expect(find.byType(CampanaNotificaciones), findsOneWidget);
    });

    testWidgets('el Cliente no tiene campana', (tester) async {
      await entrar('Cliente', const []);
      await montar(tester, const HomeScreen());
      expect(find.byType(CampanaNotificaciones), findsNothing);
    });

    testWidgets('insignia: oculta en 0, número y 9+; Semantics', (
      tester,
    ) async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas(const []);
      await montar(tester, insumosScreen());
      final campana = find.byType(CampanaNotificaciones);
      expect(
        find.descendant(of: campana, matching: find.byType(Text)),
        findsNothing,
      );
      expect(find.bySemanticsLabel('Notificaciones'), findsOneWidget);

      await _local.desdeVentas([_venta(1), _venta(2), _venta(3)]);
      await tester.pump();
      expect(
        find.descendant(of: campana, matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Notificaciones, 3 sin leer'),
        findsOneWidget,
      );

      await _local.desdeVentas([for (var i = 1; i <= 12; i++) _venta(i)]);
      await tester.pump();
      expect(
        find.descendant(of: campana, matching: find.text('9+')),
        findsOneWidget,
      );
    });

    testWidgets('pantalla: vacía, lista, marcar todas, abrir sin marcar '
        'todo', (tester) async {
      await entrar('Empleado', _ventasEInsumos);
      await montar(tester, insumosScreen());
      await tester.tap(find.byType(CampanaNotificaciones));
      await tester.pumpAndSettle();
      expect(find.byType(NotificacionesScreen), findsOneWidget);
      expect(find.text('No tienes notificaciones.'), findsOneWidget);
      expect(find.byType(CampanaNotificaciones), findsNothing);
      final marcar = find.widgetWithText(
        TextButton,
        'Marcar todas como leídas',
      );
      expect(tester.widget<TextButton>(marcar).onPressed, isNull);

      await _local.desdeVentas(const []);
      NotificacionesLocal.reloj = () => DateTime(2026, 11, 20, 9);
      await _local.desdeVentas([_venta(1)]);
      NotificacionesLocal.reloj = () => _ahora;
      await _local.desdeVentas([_venta(1), _venta(2)]);
      await tester.pumpAndSettle();
      final titulos = tester
          .widgetList<Text>(find.text('Nueva venta por verificar'))
          .toList();
      expect(titulos, hasLength(2));
      expect(
        tester.getTopLeft(find.text('VEN-002 · Cliente 2')).dy,
        lessThan(tester.getTopLeft(find.text('VEN-001 · Cliente 1')).dy),
      );
      expect(find.text('20 nov 2026'), findsOneWidget);
      expect(_sinLeer, findsNWidgets(2));
      expect(_local.conteoNoLeidas.value, 2);

      await tester.tap(marcar);
      await tester.pumpAndSettle();
      expect(_local.conteoNoLeidas.value, 0);
      expect(_sinLeer, findsNothing);
    });

    testWidgets('tocar: marca leída y va a Ventas con permiso', (tester) async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas(const []);
      await _local.desdeVentas([_venta(1)]);
      await montar(tester, const NotificacionesScreen());
      await tester.tap(find.text('Nueva venta por verificar'));
      await tester.pumpAndSettle();
      expect(_local.conteoNoLeidas.value, 0);
      expect(find.byType(SalesScreen), findsOneWidget);
    });

    testWidgets('tocar: va a Insumos con permiso', (tester) async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeInsumos([_insumo(1)]);
      await _local.desdeInsumos([_insumo(1, actual: '0')]);
      await montar(tester, const NotificacionesScreen());
      await tester.tap(find.text('Insumo agotado'));
      await tester.pumpAndSettle();
      expect(find.text('Insumos'), findsWidgets);
      expect(
        find.textContaining('Total insumos', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('tocar sin permiso: solo la marca leída y avisa', (
      tester,
    ) async {
      await entrar('Empleado', _ventasEInsumos);
      await _local.desdeVentas(const []);
      await _local.desdeVentas([_venta(1)]);
      // El rol perdió Ventas: se refresca el perfil sin ese permiso.
      backend.rutas['GET /auth/me'] = (_) => respuesta({
        ...usuarioJson(rol: 'Empleado', permisos: [_ver('Compras', 'Insumos')]),
        'id': 7,
      });
      await AuthService.instance.refrescarPerfil();
      await montar(tester, const NotificacionesScreen());
      await tester.tap(find.text('Nueva venta por verificar'));
      await tester.pumpAndSettle();
      expect(_local.conteoNoLeidas.value, 0);
      expect(find.text('No tienes acceso a ese módulo.'), findsOneWidget);
      expect(find.byType(NotificacionesScreen), findsOneWidget);
    });

    for (final oscuro in [false, true]) {
      testWidgets('sin desborde a 320 dp con letra al 130 % en '
          '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
        await entrar('Empleado', _ventasEInsumos);
        await _local.desdeVentas(const []);
        await _local.desdeVentas([for (var i = 1; i <= 12; i++) _venta(i)]);
        final tema = oscuro ? AppTheme.oscuro : AppTheme.claro;
        await montar(
          tester,
          insumosScreen(),
          tema: tema,
          ancho: 320,
          letra: 1.3,
        );
        expect(tester.takeException(), isNull);
        await montar(
          tester,
          const NotificacionesScreen(),
          tema: tema,
          ancho: 320,
          letra: 1.3,
        );
        expect(tester.takeException(), isNull);
        await montar(
          tester,
          adminHomeScreen(),
          tema: tema,
          ancho: 320,
          letra: 1.3,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
