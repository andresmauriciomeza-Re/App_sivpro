import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Insumo tal como lo devuelve `/insumos` (solo lectura en el móvil).
class Insumo {
  const Insumo({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockMaximo,
    required this.estado,
    this.idCategoria,
    this.categoriaNombre,
    this.pesoMedida,
    this.costoUnitario,
    this.costoMaximo,
    this.iva,
    this.descripcion,
    this.tiempoPreparacion,
    this.fichaVigente,
  });

  final int id;
  final int? idCategoria;
  final String? categoriaNombre;
  final String nombre;

  /// "Insumo" o "Producto insumo".
  final String tipo;
  final String unidadMedida;
  final double? pesoMedida;
  final double stockActual;
  final double stockMinimo;
  final double stockMaximo;
  final double? costoUnitario;
  final double? costoMaximo;
  final double? iva;
  final String? descripcion;
  final double? tiempoPreparacion;
  final bool estado;

  /// Solo en "Producto insumo". Estructura libre del backend.
  final Object? fichaVigente;

  bool get esProductoInsumo => tipo.toLowerCase().contains('producto');

  /// Código visible: INS-004.
  String get codigo => 'INS-${id.toString().padLeft(3, '0')}';

  bool get agotado => stockActual <= 0;

  /// Stock en o por debajo del mínimo.
  bool get bajoMinimo => stockActual <= stockMinimo;

  bool get sobreMaximo => stockMaximo > 0 && stockActual > stockMaximo;

  factory Insumo.fromJson(Map<String, dynamic> json) {
    final id = _entero(json['id_insumo']);
    final nombre = _texto(json['nombre']);
    if (id == null || nombre == null) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Insumo(
      id: id,
      idCategoria: _entero(json['id_categoria_insumo']),
      categoriaNombre: _texto(json['categoria_nombre']),
      nombre: nombre,
      tipo: _texto(json['tipo']) ?? 'Insumo',
      unidadMedida: _texto(json['unidad_medida']) ?? '',
      pesoMedida: _numero(json['peso_medida']),
      stockActual: _numero(json['stock_actual']) ?? 0,
      stockMinimo: _numero(json['stock_minimo']) ?? 0,
      stockMaximo: _numero(json['stock_maximo']) ?? 0,
      costoUnitario: _numero(json['costo_unitario']),
      costoMaximo: _numero(json['costo_maximo']),
      iva: _numero(json['iva']),
      descripcion: _texto(json['descripcion']),
      tiempoPreparacion: _numero(json['tiempo_preparacion']),
      estado: _booleano(json['estado']),
      fichaVigente: json['ficha_vigente'],
    );
  }
}

class InsumosRepository {
  InsumosRepository._();

  static final InsumosRepository instance = InsumosRepository._();

  /// Filtros opcionales: [tipo] ("Insumo" | "Producto insumo") y [estado].
  Future<List<Insumo>> listar({String? tipo, bool? estado}) async {
    final parametros = <String, String>{
      'tipo': ?tipo,
      'estado': ?estado?.toString(),
    };
    final consulta = parametros.isEmpty
        ? ''
        : '?${Uri(queryParameters: parametros).query}';
    final data = await ApiClient.instance.get('/insumos$consulta');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return Insumo.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<Insumo> obtener(int id) async {
    final data = await ApiClient.instance.get('/insumos/$id');
    final json = data is Map<String, dynamic> && data['insumo'] is Map
        ? data['insumo']
        : data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Insumo.fromJson(json);
  }
}

int? _entero(dynamic valor) {
  if (valor is int) return valor;
  if (valor is num && valor.isFinite) return valor.toInt();
  if (valor is String) return int.tryParse(valor.trim());
  return null;
}

/// Acepta número o texto ("12.5", "12,5").
double? _numero(dynamic valor) {
  if (valor is num) return valor.isFinite ? valor.toDouble() : null;
  if (valor is String) {
    final parsed = double.tryParse(valor.trim().replaceAll(',', '.'));
    if (parsed != null && parsed.isFinite) return parsed;
  }
  return null;
}

String? _texto(dynamic valor) {
  if (valor == null) return null;
  final texto = valor.toString().trim();
  return texto.isEmpty ? null : texto;
}

bool _booleano(dynamic valor) {
  if (valor is bool) return valor;
  if (valor is num) return valor != 0;
  if (valor is String) {
    final texto = valor.trim().toLowerCase();
    return texto == 'true' || texto == '1' || texto == 'activo';
  }
  return false;
}
