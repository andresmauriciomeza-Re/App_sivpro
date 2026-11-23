import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/services/pedidos_repository.dart';
import 'package:sivpro_app/shared/client_notification_service.dart';

import 'support/backend_falso.dart';
import 'support/pedidos_falsos.dart';

/// Temporizador manual: la prueba decide cuándo "pasan" los 50 s.
class _TemporizadorFalso implements Timer {
  _TemporizadorFalso(this.duracion, this._accion);

  final Duration duracion;
  final void Function() _accion;
  bool _activo = true;

  void disparar() {
    if (_activo) _accion();
  }

  @override
  void cancel() => _activo = false;

  @override
  bool get isActive => _activo;

  @override
  int get tick => 0;
}

typedef _Aviso = (int id, String titulo, String cuerpo);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final servicio = ClientNotificationService.instance;
  late BackendFalso backend;
  final temporizadores = <_TemporizadorFalso>[];
  final avisos = <_Aviso>[];
  var permisos = 0;

  _TemporizadorFalso? temporizadorActivo() =>
      temporizadores.where((t) => t.isActive).firstOrNull;

  void responder(List<Map<String, dynamic>> filas) =>
      backend.rutas['GET /ventas/mias'] = (_) => respuesta(filas);

  setUpAll(() {
    registrarLimpiezaCliente();
    servicio
      ..crearTemporizador = (duracion, accion) {
        final temporizador = _TemporizadorFalso(duracion, accion);
        temporizadores.add(temporizador);
        return temporizador;
      }
      ..pedirPermiso = () async {
        permisos++;
        return true;
      }
      ..mostrarAviso = (id, titulo, cuerpo) async {
        avisos.add((id, titulo, cuerpo));
      }
      ..start();
  });

  setUp(() {
    backend = BackendFalso();
    SharedPreferences.setMockInitialValues({});
    responder([ventaFila()]);
    temporizadores.clear();
    avisos.clear();
    permisos = 0;
  });

  tearDown(() async {
    await AuthService.instance.logout();
    await pumpEventQueue();
  });

  Future<void> entrarComoCliente() async {
    backend.loginComo('Cliente');
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await pumpEventQueue();
  }

  // Va primero: simula reabrir la app (sin un inicio de sesión previo en
  // esta ejecución) con los estados que se guardaron la vez anterior.
  test('al reabrir la app compara con lo guardado y avisa el cambio', () async {
    SharedPreferences.setMockInitialValues({
      'estados_pedidos_7': jsonEncode({'41': 'Pendiente'}),
    });
    FlutterSecureStorage.setMockInitialValues({
      'sivpro_access_token': 'token-guardado',
    });
    backend.rutas['GET /auth/me'] = (_) => respuesta(usuarioJson());
    responder([ventaFila(estado: 'En espera')]);
    expect(await AuthService.instance.restoreSession(), isTrue);
    await pumpEventQueue();
    expect(avisos, hasLength(1));
    expect(avisos.single.$2, 'Pedido #41: En espera');
    expect(avisos.single.$3, 'Falta parte del pago.');
    expect(servicio.unreadCount.value, 1);
  });

  test(
    'la primera carga tras iniciar sesión solo toma la línea base',
    () async {
      SharedPreferences.setMockInitialValues({
        'estados_pedidos_7': jsonEncode({'41': 'Aceptado'}),
      });
      await entrarComoCliente();
      expect(backend.a('GET /ventas/mias'), hasLength(1));
      expect(avisos, isEmpty);
      expect(servicio.unreadCount.value, 0);
      expect(permisos, 1);
      expect(temporizadorActivo()?.duracion, const Duration(seconds: 50));
    },
  );

  test('un cambio de estado avisa, sube la insignia y Mis pedidos la '
      'limpia', () async {
    await entrarComoCliente();
    responder([
      ventaFila(estado: 'Por entregar'),
      ventaFila(id: 40, estado: 'Completado'),
    ]);
    temporizadorActivo()!.disparar();
    await pumpEventQueue();
    expect(backend.a('GET /ventas/mias'), hasLength(2));
    expect(avisos, hasLength(1));
    final (id, titulo, cuerpo) = avisos.single;
    expect(id, 7200041);
    expect(titulo, 'Pedido #41: Por entregar');
    expect(cuerpo, 'Tu pedido está listo para recoger a las 6:30 p. m.');
    expect(servicio.unreadCount.value, 1);
    expect(servicio.lastReadyOrder.value?.id, 41);

    // Sin cambios: no se repite el aviso. Un pedido nuevo tampoco avisa.
    responder([
      ventaFila(id: 42),
      ventaFila(estado: 'Por entregar'),
      ventaFila(id: 40, estado: 'Completado'),
    ]);
    temporizadorActivo()!.disparar();
    await pumpEventQueue();
    expect(avisos, hasLength(1));

    servicio.markAllRead();
    expect(servicio.unreadCount.value, 0);

    final guardado = (await SharedPreferences.getInstance()).getString(
      'estados_pedidos_7',
    );
    expect(jsonDecode(guardado!), {
      '42': 'Pendiente',
      '41': 'Por entregar',
      '40': 'Completado',
    });
  });

  test('solo consulta mientras haya pedidos sin terminar', () async {
    responder([ventaFila(estado: 'Completado')]);
    await entrarComoCliente();
    expect(temporizadorActivo(), isNull);

    // Un pedido nuevo (p. ej. al pagar) vuelve a activar la consulta.
    responder([ventaFila(id: 42), ventaFila(estado: 'Completado')]);
    await PedidosRepository.instance.listar(recargar: true);
    expect(temporizadorActivo(), isNotNull);

    responder([
      ventaFila(id: 42, estado: 'Anulado'),
      ventaFila(estado: 'Completado'),
    ]);
    temporizadorActivo()!.disparar();
    await pumpEventQueue();
    expect(temporizadorActivo(), isNull);
  });

  test('en segundo plano no consulta; al volver consulta enseguida', () async {
    await entrarComoCliente();
    servicio.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(temporizadorActivo(), isNull);

    servicio.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(backend.a('GET /ventas/mias'), hasLength(2));
    expect(temporizadorActivo(), isNotNull);
  });

  test('nunca hay dos consultas en paralelo', () async {
    await entrarComoCliente();
    final pendiente = Completer<http.Response>();
    backend.rutas['GET /ventas/mias'] = (_) => pendiente.future;
    temporizadorActivo()!.disparar();
    temporizadorActivo()!.disparar();
    servicio.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(backend.a('GET /ventas/mias'), hasLength(2));
    pendiente.complete(respuesta([ventaFila()]));
    await pumpEventQueue();
  });

  test('el personal no consulta pedidos de cliente', () async {
    backend.loginComo('Administrador');
    backend.rutas['GET /ventas'] = (_) => respuesta(<Object>[]);
    await AuthService.instance.login('ana@correo.com', 'Clave1234');
    await pumpEventQueue();
    expect(backend.a('GET /ventas/mias'), isEmpty);
    expect(temporizadorActivo(), isNull);
    expect(permisos, 0);
  });

  test('al cerrar sesión se detiene y olvida todo', () async {
    await entrarComoCliente();
    responder([ventaFila(estado: 'En espera')]);
    temporizadorActivo()!.disparar();
    await pumpEventQueue();
    expect(servicio.unreadCount.value, 1);

    await AuthService.instance.logout();
    await pumpEventQueue();
    expect(servicio.unreadCount.value, 0);
    expect(servicio.lastReadyOrder.value, isNull);
    expect(temporizadorActivo(), isNull);
    expect(
      (await SharedPreferences.getInstance()).getString('estados_pedidos_7'),
      isNull,
    );

    // La siguiente sesión vuelve a empezar con una línea base.
    responder([ventaFila(estado: 'Aceptado')]);
    await entrarComoCliente();
    expect(avisos, hasLength(1));
    expect(servicio.unreadCount.value, 0);
  });
}
