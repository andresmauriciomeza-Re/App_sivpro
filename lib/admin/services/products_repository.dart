import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../../shared/numeros.dart';

class ProductoGestion {
  const ProductoGestion({
    required this.idProducto,
    required this.idCategoria,
    required this.nombre,
    required this.tipo,
    required this.precioVenta,
    required this.unidadVenta,
    required this.estado,
    required this.tieneImagen,
    this.precioGrande,
    this.imagen,
    this.categoriaNombre,
    this.stock,
    this.stockPartes,
    this.disponiblesMediana,
    this.disponiblesGrande,
    this.contenido,
    this.contenidoUnidad,
    this.unidadCompra,
    this.unidadesPorEmpaque,
  });

  final int idProducto;
  final int idCategoria;
  final String nombre;
  final String tipo;
  final double precioVenta;
  final double? precioGrande;
  final String unidadVenta;
  final String? imagen;
  final bool tieneImagen;
  final String estado;
  final String? categoriaNombre;
  final int? stock;
  final int? stockPartes;
  final int? disponiblesMediana;
  final int? disponiblesGrande;
  final double? contenido;
  final String? contenidoUnidad;
  final String? unidadCompra;
  final int? unidadesPorEmpaque;

  factory ProductoGestion.fromJson(Map<String, dynamic> json) {
    return ProductoGestion(
      idProducto: _requiredInt(json, 'id_producto'),
      idCategoria: _requiredInt(json, 'id_categoria'),
      nombre: _requiredString(json, 'nombre'),
      tipo: _requiredString(json, 'tipo'),
      precioVenta: _requiredDouble(json, 'precio_venta'),
      precioGrande: _optionalDouble(json['precio_grande']),
      unidadVenta: _requiredString(json, 'unidad_venta'),
      imagen: _optionalString(json['imagen']),
      tieneImagen: json['tiene_imagen'] == true,
      estado: _requiredString(json, 'estado'),
      categoriaNombre: _optionalString(json['categoria_nombre']),
      stock: _optionalInt(json['stock']),
      stockPartes: _optionalInt(json['stock_partes']),
      disponiblesMediana: _optionalInt(json['disponibles_mediana']),
      disponiblesGrande: _optionalInt(json['disponibles_grande']),
      contenido: _optionalDouble(json['contenido']),
      contenidoUnidad: _optionalString(json['contenido_unidad']),
      unidadCompra: _optionalString(json['unidad_compra']),
      unidadesPorEmpaque: _optionalInt(json['unidades_por_empaque']),
    );
  }
}

class CategoriaProductoOpcion {
  const CategoriaProductoOpcion({
    required this.idCategoria,
    required this.nombre,
  });

  final int idCategoria;
  final String nombre;

  factory CategoriaProductoOpcion.fromJson(Map<String, dynamic> json) {
    return CategoriaProductoOpcion(
      idCategoria: _requiredInt(json, 'id_categoria'),
      nombre: _requiredString(json, 'nombre'),
    );
  }
}

class FichaProducto {
  const FichaProducto({
    required this.id,
    required this.version,
    required this.vigente,
    required this.cantidad,
    required this.medida,
    required this.insumos,
    this.fechaInicio,
    this.porciones,
    this.tiempoPreparacion,
    this.pasos = const [],
  });

  final int id;
  final int version;
  final bool vigente;
  final double cantidad;
  final String medida;
  final String? fechaInicio;
  final double? porciones;
  final double? tiempoPreparacion;
  final List<String> pasos;
  final List<FichaProductoInsumo> insumos;

  factory FichaProducto.fromJson(Map<String, dynamic> json) {
    final insumosJson = json['insumos'];
    if (insumosJson is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    final pasosJson = json['pasos'];
    return FichaProducto(
      id: _requiredInt(json, 'id_ft'),
      version: _requiredInt(json, 'version'),
      vigente: json['vigente'] == true,
      cantidad: _requiredDouble(json, 'cantidad'),
      medida: _requiredString(json, 'medida'),
      fechaInicio: _optionalString(json['fecha_inicio']),
      porciones: _optionalDouble(json['porciones']),
      tiempoPreparacion: _optionalDouble(json['tiempo_preparacion']),
      pasos: pasosJson is List
          ? pasosJson.map((value) => value.toString()).toList(growable: false)
          : const [],
      insumos: insumosJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const ApiException('Respuesta inesperada del servidor.');
            }
            return FichaProductoInsumo.fromJson(item);
          })
          .toList(growable: false),
    );
  }
}

class FichaProductoInsumo {
  const FichaProductoInsumo({
    required this.nombre,
    required this.cantidad,
    required this.medida,
  });

  final String nombre;
  final double cantidad;
  final String medida;

  factory FichaProductoInsumo.fromJson(Map<String, dynamic> json) {
    return FichaProductoInsumo(
      nombre: _requiredString(json, 'nombre'),
      cantidad: _requiredDouble(json, 'cantidad'),
      medida: _requiredString(json, 'medida'),
    );
  }
}

class ProductsRepository {
  ProductsRepository._();

  static final ProductsRepository instance = ProductsRepository._();

  /// Un producto con datos inválidos se omite en lugar de tumbar la lista.
  Future<List<ProductoGestion>> listar() async {
    final data = await ApiClient.instance.get('/productos/gestion');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return productosGestionDesde(data);
  }

  Future<List<CategoriaProductoOpcion>> listarCategorias() async {
    final data = await ApiClient.instance.get('/categorias-productos');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return CategoriaProductoOpcion.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<ProductoGestion> actualizar(int id, Map<String, Object?> body) async {
    final data = await ApiClient.instance.put('/productos/$id', body: body);
    return _productoDeRespuesta(data);
  }

  Future<ProductoGestion> cambiarEstado(int id, String estado) async {
    final data = await ApiClient.instance.patch(
      '/productos/$id/estado',
      body: {'estado': estado},
    );
    return _productoDeRespuesta(data);
  }

  Future<List<FichaProducto>> obtenerFichas(int idProducto) async {
    final data = await ApiClient.instance.get(
      '/fichas?id_producto=$idProducto',
    );
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return FichaProducto.fromJson(item);
        })
        .toList(growable: false);
  }

  ProductoGestion _productoDeRespuesta(dynamic data) {
    final json = data is Map<String, dynamic> && data['producto'] is Map
        ? data['producto']
        : data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return ProductoGestion.fromJson(json);
  }
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = _optionalInt(json[key]);
  if (value == null) {
    throw const ApiException('Respuesta inesperada del servidor.');
  }
  return value;
}

int? _optionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.roundToDouble()) {
    return value.toInt();
  }
  if (value is String) return int.tryParse(value);
  throw const ApiException('Respuesta inesperada del servidor.');
}

double _requiredDouble(Map<String, dynamic> json, String key) {
  final value = _optionalDouble(json[key]);
  if (value == null) {
    throw const ApiException('Respuesta inesperada del servidor.');
  }
  return value;
}

double? _optionalDouble(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  final numero = numeroTolerante(value);
  if (numero != null) return numero;
  throw const ApiException('Respuesta inesperada del servidor.');
}

/// Convierte cada elemento válido; omite los que no son objetos o fallan.
List<ProductoGestion> productosGestionDesde(List<dynamic> data) {
  final productos = <ProductoGestion>[];
  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    try {
      productos.add(ProductoGestion.fromJson(item));
    } on ApiException {
      // Producto con datos incompletos o con tipos inesperados: se omite.
    }
  }
  return List.unmodifiable(productos);
}

/// Texto opcional tolerante: cualquier tipo con toString; vacío -> null.
String? _optionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw const ApiException('Respuesta inesperada del servidor.');
  }
  return value;
}
