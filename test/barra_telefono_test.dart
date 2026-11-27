import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/admin/notificaciones/barra_telefono.dart';
import 'package:sivpro_app/admin/notificaciones/notificaciones_repository.dart';
import 'package:sivpro_app/admin/screens/notificaciones_screen.dart';
import 'package:sivpro_app/admin/services/insumos_repository.dart';
import 'package:sivpro_app/admin/services/ventas_repository.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/auth/session_manager.dart';
import 'package:sivpro_app/auth/splash_screen.dart';
import 'package:sivpro_app/shared/low_stock_notification_service.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';

/// Lo que llega a Android: se interceptan las llamadas del plugin, así que se
/// prueba el servicio real (textos, ids y cancelaciones).
class _Android {
  _Android() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (llamada) async {
            final datos = llamada.arguments;
            if (llamada.method == 'show') {
              mostradas.add((
                id: (datos as Map)['id'] as int,
                titulo: datos['title'] as String,
                cuerpo: datos['body'] as String,
                payload: datos['payload'] as String,
              ));
            }
            if (llamada.method == 'cancel') {
              canceladas.add((datos as Map)['id'] as int);
            }
            return switch (llamada.method) {
              'initialize' || 'requestNotificationsPermission' => true,
              _ => null,
            };
          },
        );
  }

  final mostradas =
      <({int id, String titulo, String cuerpo, String payload})>[];
  final canceladas = <int>[];

  void olvidar() {
    mostradas.clear();
    canceladas.clear();
  }
}

Venta _venta(int id) => Venta.fromJson({
  'id_venta': id,
  'cliente_nombre': 'Cliente $id',
  'monto': '1',
  'estado': 'Por verificar',
});

Insumo _insumo(int id, String nombre, [Object actual = '10']) =>
    Insumo.fromJson({
      'id_insumo': id,
      'nombre': nombre,
      'unidad_medida': 'kg',
      'stock_actual': actual,
      'stock_minimo': '5',
      'estado': true,
    });

final _local = NotificacionesLocal.instance;

/// Tres insumos bajo mínimo, como los del reporte.
final _bajos = [
  _insumo(1, 'Aceite', '1'),
  _insumo(2, 'Aguacate', '2'),
  _insumo(3, 'Aguacate 2', '3'),
  _insumo(4, 'Queso'),
];

void main() {
  late BackendFalso backend;
  late _Android android;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    _local.start();
    NotificacionesLocal.barra = LowStockNotificationService.instance;
  });
  setUp(() {
    backend = BackendFalso();
    android = _Android();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    await AuthService.instance.logout();
    await pumpEventQueue();
    LowStockNotificationService.instance.descartarPendiente();
  });

  Future<void> entrar([String rol = 'Empleado']) async {
    backend.loginComo(
      rol,
      permisos: [
        {
          'modulo': 'Ventas',
          'nombre': 'Ventas',
          'privilegios': ['Ver'],
        },
        {
          'modulo': 'Compras',
          'nombre': 'Insumos',
          'privilegios': ['Ver'],
        },
      ],
    );
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await _local.listar();
  }

  /// Una consulta automática completa.
  Future<void> consultar(List<Venta> ventas, List<Insumo> insumos) async {
    await _local.desdeVentas(ventas);
    await _local.desdeInsumos(insumos);
    await pumpEventQueue();
  }

  test('primera vez: como máximo un resumen en la barra', () async {
    await entrar();
    await consultar([_venta(1), _venta(2)], _bajos);
    expect(await _local.listar(), hasLength(2)); // la lista, como siempre
    expect(android.mostradas, hasLength(1));
    expect(android.mostradas.single.id, IdsBarra.resumenVentas);
    expect(android.mostradas.single.titulo, 'Tienes 2 ventas por verificar');
    expect(android.mostradas.single.cuerpo, 'Revísalas en Ventas.');
  });

  test('primera vez solo con insumos: el texto de siempre', () async {
    await entrar();
    await consultar(const [], _bajos);
    expect(android.mostradas.single.id, IdsBarra.insumos);
    expect(
      android.mostradas.single.titulo,
      '3 insumos llegaron al nivel mínimo',
    );
    expect(android.mostradas.single.cuerpo, 'Aceite, Aguacate, Aguacate 2.');
  });

  test('reabrir la app sin cambios no notifica nada', () async {
    await entrar();
    await consultar([_venta(1)], _bajos);
    android.olvidar();

    // Misma sesión restaurada: se relee lo guardado.
    await _local.refrescar();
    await consultar([_venta(1)], _bajos);
    expect(android.mostradas, isEmpty);
    expect(android.canceladas, isEmpty);

    // Y al cerrar sesión y volver a entrar.
    await AuthService.instance.logout();
    await entrar();
    await consultar([_venta(1)], _bajos);
    expect(android.mostradas, isEmpty);
  });

  test('un insumo nuevo bajo mínimo sí notifica, y solo él', () async {
    await entrar();
    await consultar(const [], _bajos);
    android.olvidar();

    final conQueso = [..._bajos.take(3), _insumo(4, 'Queso', '4')];
    await consultar(const [], conQueso);
    await consultar(const [], conQueso);
    expect(android.mostradas, hasLength(1));
    expect(android.mostradas.single.id, IdsBarra.insumos);
    expect(android.mostradas.single.titulo, 'Insumo en nivel mínimo');
    expect(
      android.mostradas.single.cuerpo,
      'Queso llegó al nivel mínimo (4 kg).',
    );

    // Empeora a agotado: avisa de nuevo con el mismo id.
    await consultar(const [], [..._bajos.take(3), _insumo(4, 'Queso', '0')]);
    expect(android.mostradas.map((n) => n.id), [
      IdsBarra.insumos,
      IdsBarra.insumos,
    ]);
  });

  test('una venta nueva por verificar notifica con su propio id', () async {
    await entrar();
    await consultar([_venta(1)], const []);
    android.olvidar();

    await consultar([_venta(1), _venta(2)], const []);
    await consultar([_venta(1), _venta(2)], const []);
    expect(android.mostradas, hasLength(1));
    expect(android.mostradas.single.id, IdsBarra.ventas + 2);
    expect(android.mostradas.single.titulo, 'Nueva venta por verificar');
    expect(android.mostradas.single.cuerpo, 'VEN-002 · Cliente 2');
  });

  group('lo que se hace en la lista se refleja en la barra', () {
    Future<void> conDosAvisos() async {
      await entrar();
      await consultar([_venta(1)], [_insumo(4, 'Queso')]);
      await consultar([_venta(1), _venta(2)], [_insumo(4, 'Queso', '4')]);
      android.olvidar();
    }

    test('eliminar uno cancela solo el suyo, incluso tras reabrir', () async {
      await conDosAvisos();
      await _local.refrescar();
      await _local.eliminar('venta:2');
      expect(android.canceladas, [IdsBarra.ventas + 2]);

      await _local.eliminar('insumo:4:bajo');
      expect(android.canceladas, [IdsBarra.ventas + 2, IdsBarra.insumos]);

      // El resumen de la primera vez sigue puesto hasta eliminarlo.
      await _local.eliminar('resumen:ventas');
      expect(android.canceladas.last, IdsBarra.resumenVentas);
    });

    for (final (nombre, accion) in [
      ('eliminar todas', _local.eliminarTodas),
      ('marcar todas como leídas', _local.marcarTodasLeidas),
    ]) {
      test('$nombre quita todo de la barra', () async {
        await conDosAvisos();
        await accion();
        expect(android.canceladas.toSet(), {
          IdsBarra.ventas + 2,
          IdsBarra.insumos,
          IdsBarra.resumenVentas,
        });
      });
    }

    test('cerrar sesión quita todo de la barra', () async {
      await conDosAvisos();
      await AuthService.instance.logout();
      await pumpEventQueue();
      expect(
        android.canceladas.toSet(),
        containsAll([
          IdsBarra.ventas + 2,
          IdsBarra.insumos,
          IdsBarra.resumenVentas,
        ]),
      );
    });
  });

  group('tocar el aviso de la barra', () {
    Future<void> montar(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.claro,
        navigatorKey: SessionManager.instance.navigatorKey,
        home: const Scaffold(body: Text('inicio')),
      ),
    );

    for (final rol in ['Administrador', 'Empleado']) {
      testWidgets('$rol: abre Notificaciones', (tester) async {
        await entrar(rol);
        await montar(tester);
        final payload = 'notificaciones_panel';
        LowStockNotificationService.instance.alTocar(payload);
        await tester.pumpAndSettle();
        expect(find.byType(NotificacionesScreen), findsOneWidget);
      });
    }

    testWidgets('sin sesión de personal no hace nada', (tester) async {
      await montar(tester);
      LowStockNotificationService.instance.alTocar('notificaciones_panel');
      await tester.pumpAndSettle();
      expect(find.byType(NotificacionesScreen), findsNothing);

      await entrar('Cliente');
      LowStockNotificationService.instance.alTocar('notificaciones_panel');
      await tester.pumpAndSettle();
      expect(find.byType(NotificacionesScreen), findsNothing);
    });

    testWidgets('con la app cerrada: tras restaurar la sesión abre '
        'Notificaciones encima del inicio', (tester) async {
      await entrar();
      backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
      backend.rutas['GET /productos-no-conformes'] = (_) =>
          respuesta(<Object>[]);
      LowStockNotificationService.instance.abiertaDesdeAviso =
          'notificaciones_panel';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.claro,
          navigatorKey: SessionManager.instance.navigatorKey,
          home: SplashScreen(
            restaurarSesion: () async => true,
            usarSensores: false,
          ),
        ),
      );
      // El splash completa su animación antes de navegar.
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.byType(NotificacionesScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
