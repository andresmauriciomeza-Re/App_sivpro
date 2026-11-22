import '../../network/api_client.dart';
import '../../network/api_exception.dart';

class OrdenProduccionLinea {
  const OrdenProduccionLinea({
    required this.idDetalle,
    required this.nombre,
    required this.unidad,
    required this.cantidadEstimada,
    this.idProducto,
    this.idInsumo,
    this.idFicha,
    this.tamano,
    this.cantidadDebida,
    this.cantidadReal,
    this.merma,
  });

  final int idDetalle;
  final int? idProducto;
  final int? idInsumo;
  final int? idFicha;
  final String nombre;
  final String unidad;
  final String? tamano;
  final double cantidadEstimada;
  final double? cantidadDebida;
  final double? cantidadReal;
  final double? merma;

  factory OrdenProduccionLinea.fromJson(Map<String, dynamic> json) {
    return OrdenProduccionLinea(
      idDetalle: _requiredInt(json, 'id_detalle_op'),
      idProducto: _optionalInt(json['id_producto']),
      idInsumo: _optionalInt(json['id_insumo']),
      idFicha: _optionalInt(json['id_ft']),
      nombre: _requiredString(json, 'nombre'),
      unidad: _requiredString(json, 'unidad'),
      tamano: _optionalString(json['tamano']),
      cantidadEstimada: _requiredDouble(json, 'cantidad_estimada'),
      cantidadDebida: _optionalDouble(json['cantidad_debida']),
      cantidadReal: _optionalDouble(json['cantidad_real']),
      merma: _optionalDouble(json['merma']),
    );
  }
}

class OrdenProduccion {
  const OrdenProduccion({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.fechaSolicitada,
    required this.lineas,
    this.fechaEntregaEstimada,
    this.horaSolicitada,
    this.ventaNumero,
    this.cliente,
    this.observacion,
    this.descripcionPreparacion,
    this.fechaEnProceso,
    this.fechaCompletada,
    this.fechaCancelada,
    this.tiempoPreparacionMin,
  });

  final int id;
  final String tipo;
  final String estado;
  final String fechaSolicitada;
  final String? fechaEntregaEstimada;
  final String? horaSolicitada;
  final String? ventaNumero;
  final String? cliente;
  final String? observacion;
  final String? descripcionPreparacion;
  final String? fechaEnProceso;
  final String? fechaCompletada;
  final String? fechaCancelada;

  /// Tiempo de preparación en minutos (si el backend lo entrega).
  final int? tiempoPreparacionMin;
  final List<OrdenProduccionLinea> lineas;

  String get tipoLabel => tipo == 'Preparacion' ? 'Preparación' : tipo;

  factory OrdenProduccion.fromJson(Map<String, dynamic> json) {
    final lineasJson = json['lineas'];
    if (lineasJson is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    final tipo = _requiredString(json, 'tipo');
    final estado = _requiredString(json, 'estado');
    // Un tipo o estado desconocido NO invalida la lista: la orden se conserva
    // con el texto crudo (sin acciones disponibles, porque estas comparan
    // contra los valores conocidos).
    return OrdenProduccion(
      id: _requiredInt(json, 'id_orden_produccion'),
      tipo: tipo,
      estado: estado,
      fechaSolicitada: _requiredString(json, 'fecha_solicitada'),
      fechaEntregaEstimada: _optionalString(json['fecha_entrega_estimada']),
      horaSolicitada: _optionalString(json['hora_solicitada']),
      ventaNumero: _optionalString(json['venta_numero']),
      cliente: _optionalString(json['cliente']),
      observacion: _optionalString(json['observacion']),
      descripcionPreparacion: _optionalString(json['descripcion_preparacion']),
      fechaEnProceso: _optionalString(json['fecha_en_proceso']),
      fechaCompletada: _optionalString(json['fecha_completada']),
      fechaCancelada: _optionalString(json['fecha_cancelada']),
      tiempoPreparacionMin: _optionalInt(json['tiempo_preparacion_min']),
      lineas: lineasJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const ApiException('Respuesta inesperada del servidor.');
            }
            return OrdenProduccionLinea.fromJson(item);
          })
          .toList(growable: false),
    );
  }
}

class LineaVerificacionProduccion {
  const LineaVerificacionProduccion({
    required this.idDetalle,
    required this.cantidadDebida,
  });

  final int idDetalle;
  final int cantidadDebida;

  factory LineaVerificacionProduccion.fromJson(Map<String, dynamic> json) {
    return LineaVerificacionProduccion(
      idDetalle: _requiredInt(json, 'id_detalle_op'),
      cantidadDebida: _requiredInt(json, 'cantidad_debida'),
    );
  }
}

class ProductionRepository {
  ProductionRepository._();

  static final ProductionRepository instance = ProductionRepository._();

  Future<List<OrdenProduccion>> listar() async {
    final data = await ApiClient.instance.get('/ordenes-produccion');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return OrdenProduccion.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<OrdenProduccion> obtener(int id) async {
    final data = await ApiClient.instance.get('/ordenes-produccion/$id');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return OrdenProduccion.fromJson(data);
  }

  Future<List<LineaVerificacionProduccion>> obtenerVerificacion(int id) async {
    final data = await ApiClient.instance.get(
      '/ordenes-produccion/$id/verificacion',
    );
    if (data is! Map<String, dynamic> || data['lineas'] is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return (data['lineas'] as List)
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return LineaVerificacionProduccion.fromJson(item);
        })
        .toList(growable: false);
  }

  /// `PUT /ordenes-produccion/:id`. Nunca mezcla claves de ambos tipos:
  /// - Pedido Pendiente: solo `observacion` y `tiempo_preparacion_min`.
  /// - Pedido En proceso: solo `tiempo_preparacion_min`.
  /// - Preparación: solo `observacion`, `fecha_solicitada`, `hora_solicitada`.
  /// Cualquier otra clave de [cambios] se descarta antes de enviar. El
  /// llamador vuelve a consultar la orden con [obtener].
  Future<void> actualizar(
    int id,
    Map<String, Object?> cambios, {
    required String tipo,
    required String estado,
  }) async {
    final Set<String> permitidas;
    if (tipo == 'Pedido') {
      permitidas = estado == 'Pendiente'
          ? const {'observacion', 'tiempo_preparacion_min'}
          : const {'tiempo_preparacion_min'};
    } else {
      permitidas = const {'observacion', 'fecha_solicitada', 'hora_solicitada'};
    }
    final cuerpo = <String, Object?>{
      for (final entrada in cambios.entries)
        if (permitidas.contains(entrada.key)) entrada.key: entrada.value,
    };
    if (cuerpo.isEmpty) {
      throw const ApiException('No hay cambios válidos para esta orden.');
    }
    await ApiClient.instance.put('/ordenes-produccion/$id', body: cuerpo);
  }

  Future<OrdenProduccion> iniciar(int id) async {
    final data = await ApiClient.instance.post(
      '/ordenes-produccion/$id/iniciar',
    );
    return _ordenDeRespuesta(data);
  }

  Future<OrdenProduccion> completar(
    int id, {
    Map<String, Object?>? body,
  }) async {
    final data = await ApiClient.instance.post(
      '/ordenes-produccion/$id/completar',
      body: body,
    );
    return _ordenDeRespuesta(data);
  }

  Future<OrdenProduccion> darBaja(
    int id, {
    required String motivo,
    required String descripcion,
  }) async {
    final data = await ApiClient.instance.post(
      '/ordenes-produccion/$id/dar-baja',
      body: {'motivo': motivo, 'descripcion': descripcion},
    );
    return _ordenDeRespuesta(data);
  }

  OrdenProduccion _ordenDeRespuesta(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return OrdenProduccion.fromJson(data);
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
  if (value is num && value.isFinite) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed.isFinite) return parsed;
  }
  throw const ApiException('Respuesta inesperada del servidor.');
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw const ApiException('Respuesta inesperada del servidor.');
  }
  return value;
}

/// Texto opcional tolerante: acepta cualquier tipo y devuelve null si vacío.
String? _optionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}
