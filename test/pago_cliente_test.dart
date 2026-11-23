import 'dart:async';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/client/screens/payment_method_screen.dart';
import 'package:sivpro_app/client/screens/receipt_sent_screen.dart';
import 'package:sivpro_app/client/services/cart_service.dart';
import 'package:sivpro_app/client/services/catalogo_repository.dart';
import 'package:sivpro_app/client/services/comprobantes.dart';
import 'package:sivpro_app/client/services/horario_local.dart';
import 'package:sivpro_app/client/services/limpieza_sesion_cliente.dart';
import 'package:sivpro_app/client/services/pedidos_repository.dart';
import 'package:sivpro_app/network/api_exception.dart';
import 'package:sivpro_app/shared/modo_oscuro_controller.dart';
import 'package:sivpro_app/theme/app_theme.dart';

import 'support/backend_falso.dart';
import 'support/catalogo_falso.dart';

const _urlComprobante = 'https://res.cloudinary.com/demo/comprobantes/c1.png';

/// 3:00 p. m. en Bogotá (UTC-5) de un jueves.
final _tresDeLaTarde = DateTime.utc(2026, 11, 26, 20);

Uint8List _png([int relleno = 3]) => Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  for (var i = 0; i < relleno; i++) i % 256,
]);

Uint8List _conFirma(String firma, [int relleno = 3]) =>
    Uint8List.fromList([...firma.codeUnits, ...List.filled(relleno, 0)]);

void _llenarCarrito() {
  CartService.instance
    ..addItem(
      lineaCarrito(
        idProducto: 1,
        nombre: 'Pizza Pollo',
        cantidad: 2,
        adiciones: [coca()],
      ),
    )
    ..addItem(
      lineaCarrito(
        idProducto: 5,
        nombre: 'Lasaña Carne',
        tamano: 'Normal',
        precio: 20000,
      ),
    );
}

Future<void> _montar(
  WidgetTester tester, {
  double ancho = 420,
  double alto = 1800,
  double letra = 1,
}) async {
  tester.view.physicalSize = Size(ancho, alto);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.claro,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(letra)),
        child: child!,
      ),
      home: const PaymentMethodScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _elegirHora(WidgetTester tester, String hora) async {
  await _tocar(tester, find.byType(DropdownButtonFormField<int>));
  await tester.tap(find.text(hora).last);
  await tester.pumpAndSettle();
}

Future<void> _subirComprobante(WidgetTester tester) =>
    _tocar(tester, find.text('Toca para adjuntar tu comprobante de pago'));

Finder _confirmar() => find.widgetWithText(ElevatedButton, 'Confirmar pedido');

/// Abre Nequi, elige las 4:30 p. m. y sube un PNG.
Future<void> _prepararPedido(WidgetTester tester) async {
  await _montar(tester);
  await _tocar(tester, find.text('Nequi'));
  await _elegirHora(tester, '4:30 p. m.');
  await _subirComprobante(tester);
  expect(find.text('comprobante.png'), findsOneWidget);
}

http.Response _ventaCreada({int id = 123, String monto = '56000.00'}) =>
    respuesta({
      'id_venta': id,
      'id_cliente': 7,
      'fecha': '2026-11-26T15:00:00.000',
      'hora_recogida': '16:30:00',
      'monto': monto,
      'estado': 'Por verificar',
      'fecha_estado': '2026-11-26T15:00:00.000',
      'venta_local': false,
      'hora_completado_local': null,
      'pagos': [
        {
          'id_pago': 9,
          'tipo': 'Nequi',
          'comprobante': _urlComprobante,
          'depositado': false,
          'monto_declarado': null,
        },
      ],
    }, 201);

void main() {
  late BackendFalso backend;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registrarLimpiezaCliente();
  });
  setUp(() {
    backend = BackendFalso();
    backend.rutas['GET /productos'] = (_) => respuesta(catalogoPedidos);
    backend.rutas['GET /ventas/mias'] = (_) => respuesta([]);
    backend.rutas['POST /uploads'] = (_) =>
        respuesta({'url': _urlComprobante, 'publicId': 'comprobantes/c1'}, 201);
    CatalogoRepository.instance.limpiar();
    PedidosRepository.instance.limpiar();
    CartService.instance.clear();
    HorarioLocal.reloj = () => _tresDeLaTarde;
    Comprobantes.elegir = () async =>
        ArchivoComprobante(nombre: 'comprobante.png', bytes: _png());
  });
  tearDown(() => HorarioLocal.reloj = DateTime.now);

  group('cuerpo de POST /ventas', () {
    test('adiciones como líneas propias sin tamaño y duplicados '
        'consolidados', () {
      final items = [
        lineaCarrito(
          idProducto: 1,
          nombre: 'Pizza Pollo',
          cantidad: 2,
          adiciones: [coca()],
        ),
        lineaCarrito(idProducto: 1, nombre: 'Pizza Pollo'),
        lineaCarrito(
          idProducto: 1,
          nombre: 'Pizza Pollo',
          tamano: 'Grande',
          precio: 16000,
        ),
        lineaCarrito(
          idProducto: 5,
          nombre: 'Lasaña Carne',
          tamano: 'Normal',
          precio: 20000,
          adiciones: [coca(2)],
        ),
        lineaCarrito(
          idProducto: 7,
          nombre: 'Gaseosa Coca-Cola',
          tamano: '',
          precio: 8000,
        ),
      ];
      expect(
        cuerpoPedido(
          items: items,
          horaRecogida: '18:30',
          metodoPago: 'Bancolombia',
          comprobante: _urlComprobante,
        ),
        {
          'hora_recogida': '18:30',
          'productos': [
            {'id_producto': 1, 'cantidad': 3, 'tamano': 'Mediana'},
            {'id_producto': 7, 'cantidad': 4, 'tamano': null},
            {'id_producto': 1, 'cantidad': 1, 'tamano': 'Grande'},
            {'id_producto': 5, 'cantidad': 1, 'tamano': 'Normal'},
          ],
          'pago': {'tipo': 'Bancolombia', 'comprobante': _urlComprobante},
        },
      );
    });

    test('un producto sin id no se envía', () {
      expect(
        () => cuerpoPedido(
          items: [
            CartItem(
              id: 'x',
              nombre: 'Pizza vieja',
              imagen: '',
              tamanoNombre: 'Mediana',
              precioBase: 14000,
              adiciones: [],
            ),
          ],
          horaRecogida: '18:30',
          metodoPago: 'Nequi',
          comprobante: _urlComprobante,
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('hora de recogida', () {
    test('cada 15 minutos de 4:00 a 9:45 p. m., solo las futuras', () {
      final todas = HorarioLocal.horariosRecogida(_tresDeLaTarde);
      expect(todas.length, 24);
      expect(HorarioLocal.texto(todas.first), '4:00 p. m.');
      expect(HorarioLocal.texto(todas.last), '9:45 p. m.');
      expect(HorarioLocal.paraEnviar(todas.first), '16:00');
      expect(HorarioLocal.paraEnviar(todas.last), '21:45');

      // 6:07 p. m. en Bogotá: la siguiente es 6:15 p. m.
      final tarde = HorarioLocal.horariosRecogida(
        DateTime.utc(2026, 11, 26, 23, 7),
      );
      expect(HorarioLocal.paraEnviar(tarde.first), '18:15');
      // Exactamente a la hora: esa ya no sirve.
      expect(
        HorarioLocal.horariosRecogida(DateTime.utc(2026, 11, 26, 23, 15)).first,
        18 * 60 + 30,
      );
      // 9:45 p. m.: no queda ninguna.
      expect(
        HorarioLocal.horariosRecogida(DateTime.utc(2026, 11, 27, 2, 45)),
        isEmpty,
      );
    });

    test('la hora de Bogotá no depende de la zona del celular', () {
      final utc = DateTime.utc(2026, 11, 26, 21, 30);
      expect(HorarioLocal.minutosBogota(utc), 16 * 60 + 30);
      expect(HorarioLocal.minutosBogota(utc.toLocal()), 16 * 60 + 30);
      expect(HorarioLocal.textoDeHora('18:30:00'), '6:30 p. m.');
    });
  });

  group('comprobante', () {
    test('JPG, PNG, WEBP o PDF hasta 5 MB', () {
      ArchivoComprobante archivo(Uint8List bytes) =>
          ArchivoComprobante(nombre: 'a', bytes: bytes);
      expect(Comprobantes.tipoDe(_png()), 'image/png');
      expect(
        Comprobantes.tipoDe(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])),
        'image/jpeg',
      );
      expect(
        Comprobantes.tipoDe(_conFirma('RIFF\x00\x00\x00\x00WEBP')),
        'image/webp',
      );
      expect(Comprobantes.tipoDe(_conFirma('%PDF-1.7')), 'application/pdf');
      expect(Comprobantes.validar(archivo(_png())), isNull);
      expect(
        Comprobantes.validar(archivo(_conFirma('GIF89a'))),
        'Usa una imagen JPG, PNG o WEBP, o un PDF.',
      );
      expect(
        Comprobantes.validar(archivo(_png(Comprobantes.maximoBytes))),
        'El archivo supera el máximo de 5 MB.',
      );
      expect(
        Comprobantes.validar(archivo(_png(Comprobantes.maximoBytes - 8))),
        isNull,
      );
    });

    test(
      'se sube por multipart con carpeta, campo "archivo" y tipo real',
      () async {
        final subido = await Comprobantes.subir(
          ArchivoComprobante(nombre: 'mi recibo (1).png', bytes: _png(10)),
        );
        expect(subido.url, _urlComprobante);
        final [peticion] = backend.a('POST /uploads');
        expect(
          peticion.headers['Content-Type'],
          startsWith('multipart/form-data; boundary='),
        );
        final partes = partesMultipart(peticion);
        expect(partes['carpeta']!.texto, 'comprobantes');
        expect(partes['archivo']!.archivo, 'mi_recibo__1_.png');
        expect(partes['archivo']!.tipo, 'image/png');
        expect(partes['archivo']!.bytes, _png(10));
      },
    );

    test('los errores de subida muestran el mensaje del backend', () async {
      backend.rutas['POST /uploads'] = (_) => errorBackend(
        415,
        'El contenido de la imagen no coincide con su tipo.',
      );
      await expectLater(
        Comprobantes.subir(ArchivoComprobante(nombre: 'a.png', bytes: _png())),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'El contenido de la imagen no coincide con su tipo.',
          ),
        ),
      );
    });
  });

  group('pantalla de pago', () {
    testWidgets('confirma el pedido con el cuerpo exacto y muestra los datos '
        'reales', (tester) async {
      _llenarCarrito();
      backend.rutas['POST /ventas'] = (_) => _ventaCreada();
      await _prepararPedido(tester);
      await _tocar(tester, _confirmar());

      final [peticion] = backend.a('POST /ventas');
      expect(backend.cuerpo(peticion), {
        'hora_recogida': '16:30',
        'productos': [
          {'id_producto': 1, 'cantidad': 2, 'tamano': 'Mediana'},
          {'id_producto': 7, 'cantidad': 1, 'tamano': null},
          {'id_producto': 5, 'cantidad': 1, 'tamano': 'Normal'},
        ],
        'pago': {'tipo': 'Nequi', 'comprobante': _urlComprobante},
      });
      expect(find.byType(ReceiptSentScreen), findsOneWidget);
      expect(find.text('#123'), findsOneWidget);
      expect(find.text('\$56.000'), findsOneWidget);
      expect(find.text('4:30 p. m.'), findsOneWidget);
      expect(CartService.instance.items, isEmpty);
      expect(backend.a('GET /ventas/mias'), isNotEmpty);

      // Sin redirección automática.
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(ReceiptSentScreen), findsOneWidget);
    });

    testWidgets('sin comprobante o sin hora no se envía', (tester) async {
      _llenarCarrito();
      await _montar(tester);
      await _tocar(tester, find.text('Nequi'));
      await _tocar(tester, _confirmar());
      expect(find.text('Sube el comprobante de pago.'), findsOneWidget);
      await _subirComprobante(tester);
      await _tocar(tester, _confirmar());
      expect(find.text('Selecciona la hora de recogida.'), findsOneWidget);
      expect(backend.a('POST /ventas'), isEmpty);
    });

    testWidgets('una hora que ya pasó se limpia y no se envía', (tester) async {
      _llenarCarrito();
      await _prepararPedido(tester);
      HorarioLocal.reloj = () => DateTime.utc(2026, 11, 26, 21, 35);
      await _tocar(tester, _confirmar());
      expect(
        find.text('Esta hora no está disponible porque ya pasó.'),
        findsOneWidget,
      );
      expect(find.text('4:30 p. m.'), findsNothing);
      expect(backend.a('POST /ventas'), isEmpty);
    });

    testWidgets('sin horarios para hoy lo avisa', (tester) async {
      _llenarCarrito();
      HorarioLocal.reloj = () => DateTime.utc(2026, 11, 27, 2, 50);
      await _montar(tester);
      await _tocar(tester, find.text('Bancolombia'));
      expect(find.byType(DropdownButtonFormField<int>), findsNothing);
      expect(find.text('Ya no hay horarios disponibles para hoy.'), findsOne);
      await _subirComprobante(tester);
      await _tocar(tester, _confirmar());
      expect(
        find.text('Ya no hay horarios disponibles para hoy.'),
        findsNWidgets(2),
      );
      expect(backend.a('POST /ventas'), isEmpty);
    });

    testWidgets('un archivo inválido no se sube', (tester) async {
      _llenarCarrito();
      Comprobantes.elegir = () async =>
          ArchivoComprobante(nombre: 'foto.gif', bytes: _conFirma('GIF89a'));
      await _montar(tester);
      await _tocar(tester, find.text('Nequi'));
      await _subirComprobante(tester);
      expect(
        find.text('Usa una imagen JPG, PNG o WEBP, o un PDF.'),
        findsOneWidget,
      );
      expect(backend.a('POST /uploads'), isEmpty);
    });

    testWidgets('el comprobante se puede quitar', (tester) async {
      _llenarCarrito();
      await _prepararPedido(tester);
      await _tocar(tester, find.text('Quitar comprobante'));
      expect(find.text('comprobante.png'), findsNothing);
      expect(
        find.text('Toca para adjuntar tu comprobante de pago'),
        findsOneWidget,
      );
    });

    testWidgets('al cambiar de método se descarta el comprobante', (
      tester,
    ) async {
      _llenarCarrito();
      await _prepararPedido(tester);
      await _tocar(tester, find.text('Volver al carrito'));
      await _tocar(tester, find.text('Nequi'));
      expect(find.text('comprobante.png'), findsOneWidget);
      await _tocar(tester, find.text('Volver al carrito'));
      await _tocar(tester, find.text('Bancolombia'));
      expect(
        find.text(
          'Cambiaste el método de pago. Quitamos el comprobante anterior. '
          'Sube el del nuevo método.',
        ),
        findsOneWidget,
      );
      expect(find.text('comprobante.png'), findsNothing);
      expect(find.text('4:30 p. m.'), findsOneWidget);
    });

    for (final (estado, mensaje) in [
      (400, 'Selecciona Mediana o Grande para Pizza Pollo.'),
      (409, 'Solo quedan 2 unidades de «Lasaña Carne»'),
      (429, 'Demasiadas solicitudes. Intenta de nuevo en un momento.'),
      (503, 'El servicio no está disponible en este momento.'),
    ]) {
      testWidgets('$estado: muestra el mensaje y conserva carrito y '
          'comprobante', (tester) async {
        _llenarCarrito();
        backend.rutas['POST /ventas'] = (_) => errorBackend(estado, mensaje);
        await _prepararPedido(tester);
        await _tocar(tester, _confirmar());
        expect(find.text(mensaje), findsOneWidget);
        expect(find.byType(ReceiptSentScreen), findsNothing);
        expect(CartService.instance.items, hasLength(2));
        expect(find.text('comprobante.png'), findsOneWidget);
        expect(backend.a('POST /ventas'), hasLength(1));
      });
    }

    testWidgets('error de red: no reintenta y pide revisar Mis pedidos', (
      tester,
    ) async {
      _llenarCarrito();
      backend.rutas['POST /ventas'] = (_) =>
          throw http.ClientException('Conexión perdida');
      await _prepararPedido(tester);
      await _tocar(tester, _confirmar());
      expect(
        find.text(
          'No pudimos confirmar si tu pedido se registró. Revisa Mis '
          'pedidos antes de intentarlo otra vez.',
        ),
        findsOneWidget,
      );
      expect(backend.a('POST /ventas'), hasLength(1));
      expect(backend.a('GET /ventas/mias'), hasLength(1));
      expect(CartService.instance.items, hasLength(2));
    });

    testWidgets('doble toque en Confirmar pedido envía una sola vez', (
      tester,
    ) async {
      _llenarCarrito();
      final pendiente = Completer<http.Response>();
      backend.rutas['POST /ventas'] = (_) => pendiente.future;
      await _prepararPedido(tester);
      await tester.ensureVisible(_confirmar());
      await tester.pumpAndSettle();
      await tester.tap(_confirmar());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_confirmar(), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      expect(backend.a('POST /ventas'), hasLength(1));
      pendiente.complete(_ventaCreada());
      await tester.pumpAndSettle();
      expect(backend.a('POST /ventas'), hasLength(1));
      expect(find.byType(ReceiptSentScreen), findsOneWidget);
    });

    testWidgets('si el catálogo cambió y algo se agotó no se envía', (
      tester,
    ) async {
      _llenarCarrito();
      await _prepararPedido(tester);
      backend.rutas['GET /productos'] = (_) => respuesta([
        for (final fila in catalogoPedidos)
          if (fila['id_producto'] == 5)
            {...fila, 'estado': 'No disponible'}
          else
            fila,
      ]);
      await _tocar(tester, _confirmar());
      expect(
        find.text(
          'Algunos productos se agotaron o ya no tienen stock suficiente. '
          'Revisa tu carrito.',
        ),
        findsOneWidget,
      );
      expect(backend.a('POST /ventas'), isEmpty);
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
        _llenarCarrito();
        await _montar(tester, ancho: 600, letra: 1.3);
        await _tocar(tester, find.text('Nequi'));
        await _elegirHora(tester, '4:30 p. m.');
        await _subirComprobante(tester);
        expect(
          Theme.of(tester.element(find.text('Confirmar pedido'))).brightness,
          oscuro ? Brightness.dark : Brightness.light,
        );
        // El QR siempre sobre blanco en oscuro.
        final qr = tester.widget<Container>(
          find
              .ancestor(
                of: find.byType(Image),
                matching: find.byType(Container),
              )
              .first,
        );
        final fondo = (qr.decoration! as BoxDecoration).color;
        expect(fondo, oscuro ? Colors.white : const Color(0xFFFCF7F5));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
