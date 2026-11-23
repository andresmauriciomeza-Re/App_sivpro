import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/auth/login_screen.dart';
import 'package:sivpro_app/auth/session_manager.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/services/pedidos_repository.dart';
import 'package:sivpro_app/config/api_config.dart';
import 'package:sivpro_app/network/api_exception.dart';
import 'package:sivpro_app/shared/client_notification_service.dart';
import 'package:sivpro_app/shared/pending_sales_service.dart';
import 'package:sivpro_app/shared/validators.dart';

import 'support/backend_falso.dart';
import 'support/pedidos_falsos.dart';

const _verVentas = {
  'modulo': 'Ventas',
  'nombre': 'Ventas',
  'privilegios': ['Ver'],
};

const _reenvioOk =
    'Si tu cuenta está pendiente, te enviamos un nuevo correo de confirmación.';

Future<void> _llenarEstadoCliente(BackendFalso backend) async {
  CartService.instance.addItem(
    CartItem(
      id: 'p1',
      nombre: 'Pizza Cañon',
      imagen: '',
      tamanoNombre: 'Mediana',
      precioBase: 30000,
      adiciones: const [],
    ),
  );
  backend.rutas['GET /ventas/mias'] = (_) =>
      respuesta([ventaFila(estado: 'Por entregar')]);
  final [pedido] = await PedidosRepository.instance.listar(recargar: true);
  ClientNotificationService.instance
    ..lastReadyOrder.value = pedido
    ..unreadCount.value = 1;
}

void _esperarEstadoClienteVacio() {
  expect(CartService.instance.items, isEmpty);
  expect(PedidosRepository.instance.pedidos, isNull);
  expect(ClientNotificationService.instance.unreadCount.value, 0);
  expect(ClientNotificationService.instance.lastReadyOrder.value, isNull);
}

Future<void> _montarLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
}

/// Los SnackBar se encolan: se cierran antes de esperar el siguiente.
Future<void> _cerrarAvisos(WidgetTester tester) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .clearSnackBars();
  await tester.pumpAndSettle();
}

Future<void> _intentarLogin(WidgetTester tester, String correo) async {
  await _cerrarAvisos(tester);
  await tester.enterText(find.byType(TextFormField).at(0), correo);
  await tester.enterText(find.byType(TextFormField).at(1), 'Clave1234');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pump();
  await tester.pump();
}

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  setUp(() => backend = BackendFalso());
  tearDown(() async => AuthService.instance.logout());

  group('validación del login', () {
    test('acepta hasta 255 caracteres y conserva los mensajes', () {
      expect(loginEmailValidator(''), 'Ingresa tu correo');
      expect(loginPasswordValidator(''), 'Ingresa tu contraseña');
      expect(loginEmailValidator('a' * 255), isNull);
      expect(loginPasswordValidator('a' * 255), isNull);
      expect(loginEmailValidator('a' * 256), isNotNull);
      expect(loginPasswordValidator('a' * 256), isNotNull);
    });
  });

  group('reenviar correo de confirmación desde el login', () {
    testWidgets('aparece solo tras un 403 y desaparece al editar el correo', (
      tester,
    ) async {
      backend.rutas['POST /auth/login'] = (_) =>
          errorBackend(401, 'Correo o contraseña incorrectos.');
      await _montarLogin(tester);
      await _intentarLogin(tester, 'ana@correo.com');
      expect(find.text('Reenviar correo de confirmación'), findsNothing);

      backend.rutas['POST /auth/login'] = (_) => errorBackend(
        403,
        'Tu cuenta aún no está activada. Revisa tu correo.',
      );
      await _intentarLogin(tester, 'ana@correo.com');
      expect(
        find.text('Tu cuenta aún no está activada. Revisa tu correo.'),
        findsOneWidget,
      );
      expect(find.text('Reenviar correo de confirmación'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'otra@correo.com',
      );
      await tester.pump();
      expect(find.text('Reenviar correo de confirmación'), findsNothing);
    });

    testWidgets('envía el correo escrito, muestra el mensaje y espera 60 s', (
      tester,
    ) async {
      backend.rutas['POST /auth/login'] = (_) => errorBackend(
        403,
        'Tu cuenta aún no está activada. Revisa tu correo.',
      );
      backend.rutas['POST /auth/verificacion/reenviar'] = (_) =>
          respuesta({'mensaje': _reenvioOk});
      await _montarLogin(tester);
      await _intentarLogin(tester, 'ana@correo.com');

      await _cerrarAvisos(tester);
      await tester.tap(find.text('Reenviar correo de confirmación'));
      await tester.pump();
      await tester.pump();
      final envios = backend.a('POST /auth/verificacion/reenviar');
      expect(envios, hasLength(1));
      expect(backend.cuerpo(envios.single), {'correo': 'ana@correo.com'});
      expect(find.text(_reenvioOk), findsOneWidget);
      expect(find.text('Reenviar en 60 s'), findsOneWidget);

      // Deshabilitado durante la espera: otro toque no envía nada.
      await tester.tap(find.text('Reenviar en 60 s'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Reenviar en 59 s'), findsOneWidget);
      expect(backend.a('POST /auth/verificacion/reenviar'), hasLength(1));

      await tester.pump(const Duration(seconds: 59));
      expect(find.text('Reenviar correo de confirmación'), findsOneWidget);
    });

    testWidgets('un 429 muestra el mensaje del backend y también espera', (
      tester,
    ) async {
      const limite =
          'Espera un momento antes de pedir otro correo de confirmación.';
      backend.rutas['POST /auth/login'] = (_) => errorBackend(
        403,
        'Tu cuenta aún no está activada. Revisa tu correo.',
      );
      backend.rutas['POST /auth/verificacion/reenviar'] = (_) =>
          errorBackend(429, limite);
      await _montarLogin(tester);
      await _intentarLogin(tester, 'ana@correo.com');

      await _cerrarAvisos(tester);
      await tester.tap(find.text('Reenviar correo de confirmación'));
      await tester.pump();
      await tester.pump();
      expect(find.text(limite), findsOneWidget);
      expect(find.text('Reenviar en 60 s'), findsOneWidget);
      await tester.pump(const Duration(seconds: 60));
    });
  });

  group('el estado del cliente se limpia al terminar la sesión', () {
    test('al cerrar sesión', () async {
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      await _llenarEstadoCliente(backend);
      await AuthService.instance.logout();
      _esperarEstadoClienteVacio();
    });

    for (final codigo in ApiException.sessionCodes) {
      test('al invalidarse la sesión ($codigo)', () async {
        backend.loginComo('Cliente');
        await AuthService.instance.login('ana@correo.com', 'Clave1234');
        await _llenarEstadoCliente(backend);
        backend.rutas['GET /auth/me'] = (_) =>
            errorBackend(401, 'Sesión no válida.', code: codigo);
        await expectLater(
          AuthService.instance.refrescarPerfil(),
          throwsA(isA<ApiException>()),
        );
        expect(AuthService.instance.isAuthenticated, isFalse);
        _esperarEstadoClienteVacio();
      });
    }

    test('al iniciar otra sesión', () async {
      await _llenarEstadoCliente(backend);
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      _esperarEstadoClienteVacio();
    });
  });

  group('servicios compartidos según el rol', () {
    Future<void> iniciar(
      WidgetTester tester,
      String rol, {
      List<Map<String, dynamic>> permisos = const [],
    }) async {
      SessionManager.instance.start();
      PendingSalesService.instance.start();
      backend.loginComo(rol, permisos: permisos);
      backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      await tester.pump();
    }

    testWidgets('Cliente: sin cierre por inactividad ni consulta de ventas', (
      tester,
    ) async {
      await iniciar(tester, 'Cliente');
      await _llenarEstadoCliente(backend);
      await tester.pump(
        ApiConfig.inactivityTimeout + const Duration(minutes: 5),
      );
      expect(AuthService.instance.isAuthenticated, isTrue);
      expect(backend.a('GET /ventas'), isEmpty);
      expect(CartService.instance.items, isNotEmpty);
      await AuthService.instance.logout();
    });

    for (final rol in ['Administrador', 'Empleado']) {
      testWidgets('$rol: consulta ventas y se cierra por inactividad', (
        tester,
      ) async {
        await iniciar(tester, rol, permisos: const [_verVentas]);
        expect(backend.a('GET /ventas'), isNotEmpty);
        await _llenarEstadoCliente(backend);
        await tester.pump(ApiConfig.inactivityTimeout);
        await tester.pump();
        expect(AuthService.instance.isAuthenticated, isFalse);
        _esperarEstadoClienteVacio();
      });
    }
  });
}
