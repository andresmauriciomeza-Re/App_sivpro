import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../../shared/numeros.dart';

/// Línea del detalle de una compra.
class CompraLinea {
  const CompraLinea({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.medida,
    required this.precioUnitario,
    required this.iva,
    required this.montoIva,
    required this.subtotal,
    required this.esNoSolicitado,
    this.idInsumo,
    this.idProducto,
    this.modoIva,
    this.baseSinIva,
    this.unidadesBase,
    this.unidadBase,
  });

  final int id;
  final int? idInsumo;
  final int? idProducto;
  final String nombre;
  final double cantidad;
  final String medida;
  final double precioUnitario;
  final double iva;
  final String? modoIva;
  final double? baseSinIva;
  final double montoIva;
  final double subtotal;
  final bool esNoSolicitado;
  final double? unidadesBase;
  final String? unidadBase;

  factory CompraLinea.fromJson(Map<String, dynamic> json) {
    return CompraLinea(
      id: _entero(json['id_dcompra']) ?? 0,
      idInsumo: _entero(json['id_insumo']),
      idProducto: _entero(json['id_producto']),
      nombre: _texto(json['nombre']) ?? 'Sin nombre',
      cantidad: _numero(json['cantidad']) ?? 0,
      medida: _texto(json['medida']) ?? '',
      precioUnitario: _numero(json['precio_unitario']) ?? 0,
      iva: _numero(json['iva']) ?? 0,
      modoIva: _texto(json['modo_iva']),
      baseSinIva: _numero(json['base_sin_iva']),
      montoIva: _numero(json['monto_iva']) ?? 0,
      subtotal: _numero(json['subtotal']) ?? 0,
      esNoSolicitado: _booleano(json['es_no_solicitado']),
      unidadesBase: _numero(json['unidades_base']),
      unidadBase: _texto(json['unidad_base']),
    );
  }
}

/// Compra realizada a un proveedor (estados "Recibido" o "Anulado").
class Compra {
  const Compra({
    required this.id,
    required this.proveedorNombre,
    required this.nFactura,
    required this.fecha,
    required this.subtotalSinIva,
    required this.totalIva,
    required this.total,
    required this.estado,
    required this.detalle,
    this.idOrdenCompra,
    this.idProveedor,
    this.proveedorNit,
    this.ivaIncluido,
    this.motivoAnulacion,
    this.fechaAnulacion,
  });

  final int id;
  final int? idOrdenCompra;
  final int? idProveedor;
  final String proveedorNombre;
  final String? proveedorNit;
  final String nFactura;
  final String fecha;
  final bool? ivaIncluido;
  final double subtotalSinIva;
  final double totalIva;
  final double total;
  final String estado;
  final String? motivoAnulacion;
  final String? fechaAnulacion;
  final List<CompraLinea> detalle;

  bool get esRecibido => estado.toLowerCase() == 'recibido';
  bool get esAnulado => estado.toLowerCase() == 'anulado';

  factory Compra.fromJson(Map<String, dynamic> json) {
    final id = _entero(json['id_compra']);
    if (id == null) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    final detalle = json['detalle'];
    return Compra(
      id: id,
      idOrdenCompra: _entero(json['id_ocompra']),
      idProveedor: _entero(json['id_proveedor']),
      proveedorNombre: _texto(json['proveedor_nombre']) ?? 'Sin proveedor',
      proveedorNit: _texto(json['proveedor_nit']),
      nFactura: _texto(json['n_factura']) ?? '',
      fecha: _fecha(json['fecha']) ?? '',
      ivaIncluido: json['iva_incluido'] is bool
          ? json['iva_incluido'] as bool
          : null,
      subtotalSinIva: _numero(json['subtotal_sin_iva']) ?? 0,
      totalIva: _numero(json['total_iva']) ?? 0,
      total: _numero(json['total']) ?? 0,
      estado: _texto(json['estado']) ?? '',
      motivoAnulacion: _texto(json['motivo_anulacion']),
      fechaAnulacion: _fecha(json['fecha_anulacion']),
      detalle: detalle is List
          ? detalle
                .whereType<Map<String, dynamic>>()
                .map(CompraLinea.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class PurchasesRepository {
  PurchasesRepository._();

  static final PurchasesRepository instance = PurchasesRepository._();

  /// Filtros opcionales: [estado] ("Recibido" | "Anulado") e [idProveedor].
  Future<List<Compra>> listar({String? estado, int? idProveedor}) async {
    final parametros = <String, String>{
      'estado': ?estado,
      'id_proveedor': ?idProveedor?.toString(),
    };
    final consulta = parametros.isEmpty
        ? ''
        : '?${Uri(queryParameters: parametros).query}';
    final data = await ApiClient.instance.get('/compras$consulta');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return Compra.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<Compra> obtener(int id) async {
    final data = await ApiClient.instance.get('/compras/$id');
    final json = data is Map<String, dynamic> && data['compra'] is Map
        ? data['compra']
        : data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Compra.fromJson(json);
  }

  /// `PATCH /compras/:id/anular`. Devuelve la compra ya actualizada (se vuelve
  /// a consultar para no depender de la forma de la respuesta del PATCH).
  Future<Compra> anular(int id, String motivo) async {
    await ApiClient.instance.patch(
      '/compras/$id/anular',
      body: {'motivo': motivo},
    );
    return obtener(id);
  }
}

int? _entero(dynamic valor) {
  if (valor is int) return valor;
  if (valor is num && valor.isFinite) return valor.toInt();
  if (valor is String) return int.tryParse(valor.trim());
  return null;
}

/// Lectura tolerante (número o texto con punto/coma; ver numeros.dart).
double? _numero(dynamic valor) => numeroTolerante(valor);

String? _texto(dynamic valor) {
  if (valor == null) return null;
  final texto = valor.toString().trim();
  return texto.isEmpty ? null : texto;
}

/// Deja la fecha como AAAA-MM-DD aunque llegue con hora.
String? _fecha(dynamic valor) {
  final texto = _texto(valor);
  if (texto == null) return null;
  final indice = texto.indexOf('T');
  return indice > 0 ? texto.substring(0, indice) : texto;
}

bool _booleano(dynamic valor) {
  if (valor is bool) return valor;
  if (valor is num) return valor != 0;
  if (valor is String) {
    final texto = valor.trim().toLowerCase();
    return texto == 'true' || texto == '1';
  }
  return false;
}
