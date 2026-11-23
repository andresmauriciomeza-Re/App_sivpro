import 'package:flutter/foundation.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../../shared/numeros.dart';
import '../models/pedido.dart';
import 'cart_service.dart';

/// Pedido recién creado (`POST /ventas` → 201).
class PedidoCreado {
  const PedidoCreado({
    required this.id,
    required this.monto,
    required this.horaRecogida,
  });

  final int id;

  /// Total real calculado por el servidor.
  final int monto;
  final String horaRecogida;
}

/// Tamaño que exige el backend: pizza Mediana/Grande, lasaña "Normal" y
/// bebidas (o adiciones) sin tamaño.
String? _tamanoDe(CartItem linea) => switch (linea.tamanoNombre) {
  'Mediana' || 'Grande' => linea.tamanoNombre,
  'Normal' => 'Normal',
  _ => null,
};

/// Cuerpo EXACTO de `POST /ventas`. Cada producto es una línea; cada bebida
/// adicional es una línea propia (sin tamaño) y se cobra. Las líneas con el
/// mismo producto y tamaño se consolidan (el servidor rechaza duplicados de
/// lasañas y bebidas).
Map<String, dynamic> cuerpoPedido({
  required List<CartItem> items,
  required String horaRecogida,
  required String metodoPago,
  required String comprobante,
}) {
  final cantidades = <(int, String?), int>{};
  void sumar(int? id, String? tamano, int cantidad) {
    if (id == null) {
      throw const ApiException(
        'Uno de los productos del carrito ya no está en el menú. Quítalo e '
        'inténtalo de nuevo.',
      );
    }
    if (cantidad <= 0) return;
    cantidades[(id, tamano)] = (cantidades[(id, tamano)] ?? 0) + cantidad;
  }

  for (final linea in items) {
    sumar(linea.idProducto, _tamanoDe(linea), linea.cantidad);
    for (final adicion in linea.adiciones) {
      sumar(adicion.idProducto, null, adicion.cantidad);
    }
  }
  return {
    'hora_recogida': horaRecogida,
    'productos': [
      for (final MapEntry(key: (id, tamano), value: cantidad)
          in cantidades.entries)
        {'id_producto': id, 'cantidad': cantidad, 'tamano': tamano},
    ],
    'pago': {'tipo': metodoPago, 'comprobante': comprobante},
  };
}

/// Pedidos del cliente contra el backend (`/ventas/mias`, `/ventas`).
class PedidosRepository extends ChangeNotifier {
  PedidosRepository._();

  static final PedidosRepository instance = PedidosRepository._();

  static const Duration vigencia = Duration(seconds: 30);

  /// Reloj de la caché; las pruebas lo adelantan.
  @visibleForTesting
  DateTime Function() reloj = DateTime.now;

  List<Pedido>? _pedidos;
  DateTime? _cargadoEn;
  Future<List<Pedido>>? _cargando;

  /// Última lista cargada (null si aún no se pidió).
  List<Pedido>? get pedidos => _pedidos;

  /// `GET /ventas/mias` (más recientes primero). Usa la caché corta salvo
  /// con [recargar]; nunca hay dos consultas en paralelo.
  Future<List<Pedido>> listar({bool recargar = false}) {
    final guardados = _pedidos;
    final cargadoEn = _cargadoEn;
    if (!recargar &&
        guardados != null &&
        cargadoEn != null &&
        reloj().difference(cargadoEn) < vigencia) {
      return Future.value(guardados);
    }
    return _cargando ??= _cargar().whenComplete(() => _cargando = null);
  }

  Future<List<Pedido>> _cargar() async {
    final data = await ApiClient.instance.get('/ventas/mias');
    final pedidos = <Pedido>[
      if (data is List)
        for (final fila in data)
          if (fila is Map<String, dynamic>) Pedido.desdeJson(fila),
    ];
    _pedidos = pedidos;
    _cargadoEn = reloj();
    notifyListeners();
    return pedidos;
  }

  /// `GET /ventas/mias/:id` (con la URL del comprobante de cada pago).
  Future<Pedido> obtener(int id) async {
    final data = await ApiClient.instance.get('/ventas/mias/$id');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Pedido.desdeJson(data);
  }

  /// `GET /ventas/mias/:id/pagos`.
  Future<ResumenPagos> resumenPagos(int id) async {
    final data = await ApiClient.instance.get('/ventas/mias/$id/pagos');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return ResumenPagos.desdeJson(data);
  }

  /// `POST /ventas`. No se reintenta: un error de red podría haber creado el
  /// pedido igual.
  Future<PedidoCreado> crear(Map<String, dynamic> cuerpo) async {
    final data = await ApiClient.instance.post('/ventas', body: cuerpo);
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return PedidoCreado(
      id: numeroTolerante(data['id_venta'])?.round() ?? 0,
      monto: numeroTolerante(data['monto'])?.round() ?? 0,
      horaRecogida:
          data['hora_recogida']?.toString() ??
          cuerpo['hora_recogida'].toString(),
    );
  }

  /// `PATCH /ventas/:id/cancelar` (primeros 10 minutos).
  Future<void> cancelar(int id) =>
      ApiClient.instance.patch('/ventas/$id/cancelar');

  /// `POST /ventas/:id/comprobantes` para completar el pago "En espera".
  Future<void> enviarComprobante(
    int id, {
    required String tipo,
    required String comprobante,
    required int montoDeclarado,
  }) => ApiClient.instance.post(
    '/ventas/$id/comprobantes',
    body: {
      'tipo': tipo,
      'comprobante': comprobante,
      'monto_declarado': montoDeclarado,
    },
  );

  /// Se olvida al terminar la sesión.
  void limpiar() {
    _pedidos = null;
    _cargadoEn = null;
    notifyListeners();
  }
}
