import 'dart:async';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/models/pedido.dart';
import 'package:sivpro_app/client/screens/home_screen.dart';
import 'package:sivpro_app/client/screens/my_orders_screen.dart';
import 'package:sivpro_app/client/screens/order_detail_screen.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/comprobantes.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/services/pedidos_repository.dart';
import 'package:sivpro_app/client/widgets/estado_pedido.dart';
import 'package:sivpro_app/shared/client_notification_service.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';
import 'support/pedidos_falsos.dart';

const _url = 'https://res.cloudinary.com/demo/comprobantes/c2.png';

Future<void> _montar(
  WidgetTester tester,
  Widget pantalla, {
  double ancho = 420,
  double alto = 2000,
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
      home: pantalla,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Pedido _pedido(Map<String, dynamic> fila) => Pedido.desdeJson(fila);

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  setUp(() {
    backend = BackendFalso();
    backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
    backend.rutas['GET /ventas/mias'] = (_) => respuesta([ventaFila()]);
    backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(ventaFila());
    backend.rutas['GET /ventas/mias/41/pagos'] = (_) =>
        respuesta(resumenPagosJson(enRevision: 56000));
    CatalogoRepository.instance.limpiar();
    PedidosRepository.instance.limpiar();
    ClientNotificationService.instance.limpiar();
    OrderDetailScreen.geocodificar = (_) async => null;
  });

  group('modelo', () {
    test('lee la fila de /ventas/mias con montos de texto', () {
      final pedido = _pedido(
        ventaFila(comprobante: _url, horaRecogida: '18:30:00'),
      );
      expect(pedido.id, 41);
      expect(pedido.monto, 56000);
      expect(pedido.estadoCliente, 'Pendiente');
      expect(pedido.articulos, 4);
      expect(pedido.detalles.first.esPizza, isTrue);
      expect(pedido.detalles.first.precioUnitario, 14000);
      expect(pedido.detalles.last.esPizza, isFalse);
      expect(pedido.metodoPago, 'Nequi');
      expect(pedido.comprobantePago, _url);
      expect(pedido.valorADevolver, 44800);
      expect(pedido.fecha, DateTime(2026, 11, 26, 15, 2));
    });

    test('comprobante en revisión (igual que la web)', () {
      ResumenPagos resumen(Map<String, dynamic> pago) =>
          ResumenPagos.desdeJson(resumenPagosJson(falta: 20000, pagos: [pago]));
      expect(
        resumen({
          'estado': 'Pendiente',
          'comprobante': _url,
          'monto_declarado': null,
          'monto_confirmado': null,
        }).hayComprobanteEnRevision,
        isTrue,
      );
      expect(
        resumen({
          'estado': 'Pendiente',
          'comprobante': null,
          'monto_declarado': '20000.00',
          'monto_confirmado': null,
        }).hayComprobanteEnRevision,
        isTrue,
      );
      expect(
        resumen({
          'estado': 'Pendiente',
          'comprobante': _url,
          'monto_declarado': null,
          'monto_confirmado': '36000.00',
        }).hayComprobanteEnRevision,
        isFalse,
      );
      expect(
        resumen({
          'estado': 'Aceptado',
          'comprobante': _url,
          'monto_declarado': null,
          'monto_confirmado': null,
        }).hayComprobanteEnRevision,
        isFalse,
      );
    });

    test('etiquetas de estado como la web y estados desconocidos neutros', () {
      expect(EstiloEstadoPedido.de('En proceso').etiqueta, 'En preparación');
      expect(
        EstiloEstadoPedido.de('Pendiente').mensaje,
        'Estamos verificando tu pago.',
      );
      expect(
        EstiloEstadoPedido.de('En espera').mensaje,
        'Falta parte del pago.',
      );
      final raro = EstiloEstadoPedido.de('Pausado');
      expect(raro.etiqueta, 'Pausado');
      expect(raro.color, const Color(0xFF757575));
      expect(raro.mensaje, isNull);
      expect(
        mensajeEstadoPedido(_pedido(ventaFila(estado: 'Por entregar'))),
        'Tu pedido está listo para recoger a las 6:30 p. m.',
      );
      expect(ProgresoPedido.pasoDe('En espera'), 0);
      expect(ProgresoPedido.pasoDe('Por entregar'), 3);
      expect(ProgresoPedido.pasoDe('Rechazado'), -1);
    });
  });

  group('Mis pedidos', () {
    testWidgets('lista real con estado, fecha, artículos y total', (
      tester,
    ) async {
      ClientNotificationService.instance.unreadCount.value = 3;
      await _montar(tester, const MyOrdersScreen());
      expect(find.text('Pedido #41'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('26/11/2026, 3:02 p. m.'), findsOneWidget);
      expect(find.text('4 artículos'), findsOneWidget);
      expect(find.text('\$56.000'), findsOneWidget);
      expect(ClientNotificationService.instance.unreadCount.value, 0);
    });

    testWidgets('la insignia de Pedidos se ve en otra pestaña y se limpia '
        'al abrir Mis pedidos', (tester) async {
      ClientNotificationService.instance.unreadCount.value = 2;
      await _montar(tester, const HomeScreen());
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(find.byType(MyOrdersScreen), findsOneWidget);
      expect(find.text('2'), findsNothing);
      expect(ClientNotificationService.instance.unreadCount.value, 0);
    });

    testWidgets('sin pedidos muestra el estado vacío', (tester) async {
      backend.rutas['GET /ventas/mias'] = (_) => respuesta([]);
      await _montar(tester, const MyOrdersScreen());
      expect(find.text('Aún no tienes pedidos'), findsOneWidget);
      expect(find.text('Ir al menú'), findsOneWidget);
    });

    testWidgets('error con Reintentar', (tester) async {
      backend.rutas['GET /ventas/mias'] = (_) =>
          errorBackend(503, 'El servicio no está disponible en este momento.');
      await _montar(tester, const MyOrdersScreen());
      expect(
        find.text('El servicio no está disponible en este momento.'),
        findsOneWidget,
      );
      backend.rutas['GET /ventas/mias'] = (_) => respuesta([ventaFila()]);
      await _tocar(tester, find.text('Reintentar'));
      expect(find.text('Pedido #41'), findsOneWidget);
    });

    testWidgets('mientras carga muestra el indicador', (tester) async {
      final pendiente = Completer<http.Response>();
      backend.rutas['GET /ventas/mias'] = (_) => pendiente.future;
      await _montar(tester, const MyOrdersScreen());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pendiente.complete(respuesta([ventaFila()]));
      await tester.pump();
      await tester.pump();
      expect(find.text('Pedido #41'), findsOneWidget);
    });

    testWidgets('tirar hacia abajo recarga', (tester) async {
      await _montar(tester, const MyOrdersScreen());
      expect(backend.a('GET /ventas/mias'), hasLength(1));
      await tester.fling(find.byType(ListView), const Offset(0, 900), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(backend.a('GET /ventas/mias'), hasLength(2));
    });

    testWidgets('estado desconocido se muestra tal cual', (tester) async {
      backend.rutas['GET /ventas/mias'] = (_) =>
          respuesta([ventaFila(estadoCliente: 'Pausado')]);
      await _montar(tester, const MyOrdersScreen());
      expect(find.text('Pausado'), findsOneWidget);
    });
  });

  group('detalle', () {
    testWidgets('productos, porciones, precios, total, hora y pagos', (
      tester,
    ) async {
      await _montar(tester, OrderDetailScreen(pedido: _pedido(ventaFila())));
      expect(find.text('Pedido #41'), findsOneWidget);
      expect(find.text('Estamos verificando tu pago.'), findsOneWidget);
      expect(find.text('2 porciones — Mediana'), findsOneWidget);
      expect(find.text('Precio por porción: \$14.000'), findsOneWidget);
      expect(find.text('\$28.000'), findsOneWidget);
      expect(find.text('1 × \$8.000'), findsOneWidget);
      expect(find.text('\$56.000'), findsOneWidget);
      expect(find.text('Hora de recogida: 6:30 p. m.'), findsOneWidget);
      expect(find.text('Transferencia · Nequi'), findsOneWidget);
      expect(
        find.text('Recibido: \$0 · En revisión: \$56.000 · Falta: \$0'),
        findsOneWidget,
      );
      expect(find.textContaining('Cra. 45 #104-30, Laureles'), findsOneWidget);
      // Sin horas inventadas en los pasos.
      expect(find.byType(ProgresoPedido), findsOneWidget);
      expect(find.textContaining('p. m.'), findsNWidgets(2));
    });

    testWidgets('comprobante: imagen o PDF', (tester) async {
      backend.rutas['GET /ventas/mias/41'] = (_) =>
          respuesta(ventaFila(comprobante: _url));
      await _montar(tester, OrderDetailScreen(pedido: _pedido(ventaFila())));
      expect(find.text('Comprobante de pago'), findsOneWidget);
      expect(find.bySemanticsLabel('Comprobante de pago'), findsOneWidget);

      backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(
        ventaFila(comprobante: 'https://res.cloudinary.com/demo/c.pdf'),
      );
      await _montar(tester, OrderDetailScreen(pedido: _pedido(ventaFila())));
      expect(find.text('Abrir comprobante (PDF)'), findsOneWidget);
    });

    testWidgets('listo para recoger: hora y dirección de recogida', (
      tester,
    ) async {
      final fila = ventaFila(
        estado: 'Por entregar',
        direccionRecogida: 'Cra. 45 #104-30, Laureles, Medellín, Antioquia',
      );
      backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
      await _montar(tester, OrderDetailScreen(pedido: _pedido(fila)));
      expect(
        find.text('Tu pedido está listo para recoger a las 6:30 p. m.'),
        findsOneWidget,
      );
      expect(
        find.text('Cra. 45 #104-30, Laureles, Medellín, Antioquia'),
        findsOneWidget,
      );
    });

    group('cancelar', () {
      Map<String, dynamic> cancelable([int segundos = 120]) =>
          ventaFila(segundos: segundos);

      testWidgets('visible con cuenta regresiva y textos de la web', (
        tester,
      ) async {
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(cancelable());
        backend.rutas['PATCH /ventas/41/cancelar'] = (_) =>
            respuesta({'id_venta': 41, 'estado': 'Anulado'});
        await _montar(tester, OrderDetailScreen(pedido: _pedido(cancelable())));
        expect(find.text('¿Te arrepentiste del pedido?'), findsOneWidget);
        expect(
          find.text(
            'Puedes cancelarlo dentro de los primeros 10 minutos. Te '
            'devolvemos el 80 % del valor (\$44.800).',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancelar pedido (120 s)'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Cancelar pedido (119 s)'), findsOneWidget);

        await _tocar(tester, find.text('Cancelar pedido (119 s)'));
        expect(find.text('Cancelar pedido #41'), findsOneWidget);
        expect(
          find.text(
            'El pedido quedará cancelado y te devolvemos el 80 % del valor '
            'pagado. Esta acción no se puede deshacer.',
          ),
          findsOneWidget,
        );
        expect(find.text('Total del pedido'), findsOneWidget);
        expect(find.text('Valor a devolver (80 %)'), findsOneWidget);
        await _tocar(tester, find.text('Volver'));
        expect(backend.a('PATCH /ventas/41/cancelar'), isEmpty);

        await _tocar(tester, find.textContaining('Cancelar pedido ('));
        backend.rutas['GET /ventas/mias/41'] = (_) =>
            respuesta(ventaFila(estado: 'Anulado', montoReembolso: '44800.00'));
        await _tocar(tester, find.text('Sí, cancelar pedido'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(backend.a('PATCH /ventas/41/cancelar'), hasLength(1));
        expect(
          find.text('Pedido #41 cancelado. Te devolvemos el 80 % del valor.'),
          findsOneWidget,
        );
        expect(find.text('¿Te arrepentiste del pedido?'), findsNothing);
        expect(find.text('Valor a devolver: \$44.800'), findsOneWidget);
      });

      testWidgets('se oculta al terminar la cuenta', (tester) async {
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(cancelable(2));
        await _montar(
          tester,
          OrderDetailScreen(pedido: _pedido(cancelable(2))),
        );
        expect(find.text('Cancelar pedido (2 s)'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('¿Te arrepentiste del pedido?'), findsNothing);
      });

      testWidgets('no se ofrece si el estado no lo permite', (tester) async {
        final fila = ventaFila(estado: 'Completado', segundos: 300);
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
        await _montar(tester, OrderDetailScreen(pedido: _pedido(fila)));
        expect(find.text('¿Te arrepentiste del pedido?'), findsNothing);
      });

      testWidgets('409: muestra el mensaje del backend y envía una vez', (
        tester,
      ) async {
        final pendiente = Completer<http.Response>();
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(cancelable());
        backend.rutas['PATCH /ventas/41/cancelar'] = (_) => pendiente.future;
        await _montar(tester, OrderDetailScreen(pedido: _pedido(cancelable())));
        await _tocar(tester, find.textContaining('Cancelar pedido ('));
        await _tocar(tester, find.text('Sí, cancelar pedido'));
        expect(find.text('Cancelando…'), findsOneWidget);
        await tester.tap(find.text('Cancelando…'), warnIfMissed: false);
        await tester.pump();
        expect(find.text('Cancelar pedido #41'), findsNothing);
        pendiente.complete(
          errorBackend(
            409,
            'Solo puedes cancelar el pedido en los primeros 10 minutos.',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.text(
            'Solo puedes cancelar el pedido en los primeros 10 minutos.',
          ),
          findsOneWidget,
        );
        expect(backend.a('PATCH /ventas/41/cancelar'), hasLength(1));
      });
    });

    group('completar pago', () {
      final enEspera = ventaFila(estado: 'En espera');

      testWidgets('envía el faltante con monto declarado', (tester) async {
        Comprobantes.elegir = () async => ArchivoComprobante(
          nombre: 'faltante.png',
          bytes: Uint8List.fromList([
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, //
          ]),
        );
        backend.rutas['POST /uploads'] = (_) =>
            respuesta({'url': _url, 'publicId': 'c2'}, 201);
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(enEspera);
        backend.rutas['GET /ventas/mias/41/pagos'] = (_) =>
            respuesta(resumenPagosJson(recibido: 36000, falta: 20000));
        backend.rutas['POST /ventas/41/comprobantes'] = (_) =>
            respuesta({'id_pago': 10}, 201);
        await _montar(tester, OrderDetailScreen(pedido: _pedido(enEspera)));
        expect(find.text('Falta parte del pago.'), findsOneWidget);

        await _tocar(tester, find.text('Enviar dinero faltante'));
        expect(find.text('Completar pago'), findsOneWidget);
        expect(find.text('\$20.000'), findsWidgets);
        final enviar = find.widgetWithText(
          ElevatedButton,
          'Enviar comprobante',
        );
        expect(tester.widget<ElevatedButton>(enviar).onPressed, isNull);

        await _tocar(tester, find.text('Nequi'));
        await _tocar(
          tester,
          find.text('Toca para adjuntar tu comprobante de pago'),
        );
        expect(find.text('faltante.png'), findsOneWidget);
        await tester.enterText(find.byType(TextField), '25000');
        await tester.pump();
        expect(find.text('Estás enviando más de lo que falta'), findsOneWidget);
        await tester.enterText(find.byType(TextField), '20.000');
        await tester.pump();
        expect(
          find.text('Ingresa un monto en pesos mayor que 0, solo con números.'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), '25000');
        await tester.pump();

        backend.rutas['GET /ventas/mias/41'] = (_) =>
            respuesta(ventaFila(estado: 'Por verificar'));
        await _tocar(tester, enviar);
        final [peticion] = backend.a('POST /ventas/41/comprobantes');
        expect(backend.cuerpo(peticion), {
          'tipo': 'Nequi',
          'comprobante': _url,
          'monto_declarado': 25000,
        });
        expect(
          find.text('Recibimos tu comprobante, lo estamos verificando'),
          findsOneWidget,
        );
      });

      testWidgets('con un comprobante en revisión no se ofrece', (
        tester,
      ) async {
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(enEspera);
        backend.rutas['GET /ventas/mias/41/pagos'] = (_) => respuesta(
          resumenPagosJson(
            recibido: 36000,
            falta: 20000,
            pagos: [
              {
                'id_pago': 10,
                'estado': 'Pendiente',
                'comprobante': _url,
                'monto_declarado': '20000.00',
                'monto_confirmado': null,
              },
            ],
          ),
        );
        await _montar(tester, OrderDetailScreen(pedido: _pedido(enEspera)));
        expect(find.text('Enviar dinero faltante'), findsNothing);
        expect(
          find.text('Estamos revisando tu último comprobante'),
          findsOneWidget,
        );
      });
    });

    for (final (motivo, reembolso, mensaje) in [
      (
        'Dinero faltante',
        '36000.00',
        'Rechazado: el valor recibido no cubría el total y el dinero fue '
            'devuelto.',
      ),
      (
        'Comprobante falso',
        null,
        'Rechazado: el comprobante de pago no fue válido.',
      ),
      (
        'Local cerrado',
        '56000.00',
        'Pedido anulado por la pizzería: Local cerrado.',
      ),
      (
        'Comprobante borroso',
        null,
        'Rechazado por la pizzería: Comprobante borroso.',
      ),
      (null, null, 'Rechazado: el pedido fue anulado por el administrador.'),
    ]) {
      testWidgets('anulado: $mensaje', (tester) async {
        final fila = ventaFila(
          estado: 'Anulado',
          motivoRechazo: motivo,
          montoReembolso: reembolso,
          comprobanteAnulacion: reembolso == null
              ? null
              : 'https://res.cloudinary.com/demo/devolucion.pdf',
        );
        backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
        await _montar(tester, OrderDetailScreen(pedido: _pedido(fila)));
        expect(find.text(mensaje), findsOneWidget);
        if (reembolso != null) {
          expect(find.textContaining('Valor a devolver: \$'), findsOneWidget);
          expect(
            find.text('Ver comprobante de devolución (PDF)'),
            findsOneWidget,
          );
        } else {
          expect(find.textContaining('Valor a devolver'), findsNothing);
        }
        expect(find.byType(ProgresoPedido), findsNothing);
      });
    }

    testWidgets('devolución en gestión y resuelta', (tester) async {
      var fila = ventaFila(estado: 'Devolucion', devolucionEstado: 'Pendiente');
      backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
      await _montar(tester, OrderDetailScreen(pedido: _pedido(fila)));
      expect(find.text('Devolución en gestión'), findsOneWidget);

      fila = ventaFila(
        estado: 'Devolucion',
        devolucionEstado: 'Resuelta',
        devolucionTipo: 'Producto',
        devolucionNota: 'Se cambió la pizza.',
        idVentaReemplazo: 52,
      );
      backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
      await _montar(tester, OrderDetailScreen(pedido: _pedido(fila)));
      expect(
        find.text('Cambio de producto · nuevo pedido #52'),
        findsOneWidget,
      );
      expect(find.text('Se cambió la pizza.'), findsOneWidget);
    });
  });

  for (final oscuro in [false, true]) {
    testWidgets('sin desborde con letra al 130 % en '
        '${oscuro ? 'oscuro' : 'claro'}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      backend.loginComo('Cliente');
      await AuthService.instance.login('ana@correo.com', 'Clave1234');
      addTearDown(AuthService.instance.logout);
      await ModoOscuroController.instance.cambiar(oscuro);
      addTearDown(() => ModoOscuroController.instance.cambiar(false));
      final fila = ventaFila(
        estado: 'En espera',
        segundos: 300,
        comprobante: _url,
      );
      backend.rutas['GET /ventas/mias'] = (_) => respuesta([
        fila,
        ventaFila(id: 42, estado: 'Anulado', motivoRechazo: 'Dinero faltante'),
      ]);
      backend.rutas['GET /ventas/mias/41'] = (_) => respuesta(fila);
      backend.rutas['GET /ventas/mias/41/pagos'] = (_) =>
          respuesta(resumenPagosJson(recibido: 36000, falta: 20000));
      await _montar(tester, const MyOrdersScreen(), ancho: 600, letra: 1.3);
      expect(
        Theme.of(tester.element(find.byType(Scaffold))).brightness,
        oscuro ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull);

      await _montar(
        tester,
        OrderDetailScreen(pedido: _pedido(fila)),
        ancho: 600,
        letra: 1.3,
      );
      expect(
        Theme.of(tester.element(find.byType(Scaffold))).brightness,
        oscuro ? Brightness.dark : Brightness.light,
      );
      await _tocar(tester, find.text('Enviar dinero faltante'));
      await _tocar(tester, find.text('Bancolombia'));
      expect(tester.takeException(), isNull);
    });
  }
}
