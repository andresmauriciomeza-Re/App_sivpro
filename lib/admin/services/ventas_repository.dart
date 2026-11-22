import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Estados reales de una venta en el backend.
///
/// El backend escribe "Devolucion" sin tilde; [label] es el texto que se
/// muestra al usuario.
enum EstadoVenta {
  porVerificar('Por verificar', 'Por verificar'),
  enEspera('En espera', 'En espera'),
  porEntregar('Por entregar', 'Por entregar'),
  completado('Completado', 'Completado'),
  devolucion('Devolucion', 'Devolución'),
  anulado('Anulado', 'Anulado');

  const EstadoVenta(this.valorBackend, this.label);

  final String valorBackend;
  final String label;

  /// Parseo tolerante a mayúsculas, tildes y espacios. Null si no se reconoce.
  static EstadoVenta? desde(String? texto) {
    if (texto == null) return null;
    final buscado = _sinTildes(texto.trim().toLowerCase());
    for (final estado in EstadoVenta.values) {
      if (_sinTildes(estado.valorBackend.toLowerCase()) == buscado) {
        return estado;
      }
    }
    return null;
  }
}

/// Línea (producto) de una venta.
class VentaLinea {
  const VentaLinea({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subTotal,
    this.idProducto,
    this.tamano,
  });

  final int id;
  final int? idProducto;
  final String nombre;
  final double cantidad;
  final double precioUnitario;
  final double subTotal;
  final String? tamano;

  factory VentaLinea.fromJson(Map<String, dynamic> json) {
    return VentaLinea(
      id: _entero(json['id_detalle_venta']) ?? 0,
      idProducto: _entero(json['id_producto']),
      nombre: _texto(json['nombre']) ?? 'Producto',
      cantidad: _numero(json['cantidad']) ?? 0,
      precioUnitario: _numero(json['precio_unitario']) ?? 0,
      subTotal: _numero(json['sub_total']) ?? 0,
      tamano: _texto(json['tamano']),
    );
  }
}

/// Pago registrado para una venta.
class VentaPago {
  const VentaPago({
    required this.id,
    required this.tieneComprobante,
    this.tipo,
    this.fecha,
    this.cantidadPagar,
    this.depositado,
    this.faltante,
    this.estado,
    this.comprobante,
  });

  final int id;
  final String? tipo;
  final String? fecha;
  final bool tieneComprobante;
  final double? cantidadPagar;
  final double? depositado;
  final double? faltante;
  final String? estado;

  /// Solo viene en `GET /ventas/:id`. Valor tal cual lo entrega el backend.
  final Object? comprobante;

  factory VentaPago.fromJson(Map<String, dynamic> json) {
    return VentaPago(
      id: _entero(json['id_pago']) ?? 0,
      tipo: _texto(json['tipo']),
      fecha: _texto(json['fecha']),
      tieneComprobante: _booleano(json['tiene_comprobante']),
      cantidadPagar: _numero(json['cantidad_pagar']),
      depositado: _numero(json['depositado']),
      faltante: _numero(json['faltante']),
      estado: _texto(json['estado']),
      comprobante: json['comprobante'],
    );
  }
}

/// Venta (pedido) tal como la devuelve `/ventas`.
class Venta {
  const Venta({
    required this.id,
    required this.clienteNombre,
    required this.monto,
    required this.estadoTexto,
    required this.ventaLocal,
    required this.detalles,
    required this.pagos,
    this.segundosRestantesAnulacion = 0,
    this.estado,
    this.idCliente,
    this.documento,
    this.tipoDocumento,
    this.correo,
    this.telefono,
    this.fecha,
    this.horaRecogida,
    this.fechaEstado,
    this.fechaEstadoLocal,
    this.estadoOrden,
    this.estadoCliente,
    this.motivoRechazo,
    this.anuladoPor,
    this.montoReembolso,
    this.devolucionEstado,
  });

  final int id;
  final int? idCliente;

  /// `id_usuario`: documento del cliente.
  final String? documento;
  final String? tipoDocumento;
  final String clienteNombre;
  final String? correo;
  final String? telefono;

  /// 'AAAA-MM-DDTHH:MM:SS...' en hora de Colombia (sin zona).
  final String? fecha;
  final String? horaRecogida;
  final double monto;
  final String estadoTexto;
  final EstadoVenta? estado;
  final String? fechaEstado;

  /// 'AAAA-MM-DDTHH:MM:SS' en hora de Colombia, sin zona (fecha de completado).
  final String? fechaEstadoLocal;
  final bool ventaLocal;

  /// Estado de la orden de producción: Pendiente, En proceso, Completada, Cancelada.
  final String? estadoOrden;
  final String? estadoCliente;
  final String? motivoRechazo;
  final String? anuladoPor;
  final double? montoReembolso;
  final String? devolucionEstado;

  /// Segundos que quedan para anular (0 si ya no se puede). El backend
  /// valida siempre.
  final int segundosRestantesAnulacion;
  final List<VentaLinea> detalles;
  final List<VentaPago> pagos;

  /// Código visible: VEN-001.
  String get codigo => 'VEN-${id.toString().padLeft(3, '0')}';

  String get estadoLabel => estado?.label ?? estadoTexto;

  factory Venta.fromJson(Map<String, dynamic> json) {
    final id = _entero(json['id_venta']);
    if (id == null) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    final estadoTexto = _texto(json['estado']) ?? '';
    final detalles = json['detalles'];
    final pagos = json['pagos'];
    return Venta(
      id: id,
      idCliente: _entero(json['id_cliente']),
      documento: _texto(json['id_usuario']),
      tipoDocumento: _texto(json['tipo_documento']),
      clienteNombre: _texto(json['cliente_nombre']) ?? 'Sin nombre',
      correo: _texto(json['correo']),
      telefono: _texto(json['telefono']),
      fecha: _texto(json['fecha']),
      horaRecogida: _texto(json['hora_recogida']),
      monto: _numero(json['monto']) ?? 0,
      estadoTexto: estadoTexto,
      estado: EstadoVenta.desde(estadoTexto),
      fechaEstado: _texto(json['fecha_estado']),
      fechaEstadoLocal: _texto(json['fecha_estado_local']),
      ventaLocal: _booleano(json['venta_local']),
      estadoOrden: _texto(json['estado_orden']),
      estadoCliente: _texto(json['estado_cliente']),
      motivoRechazo: _texto(json['motivo_rechazo']),
      anuladoPor: _texto(json['anulado_por']),
      montoReembolso: _numero(json['monto_reembolso']),
      devolucionEstado: _texto(json['devolucion_estado']),
      segundosRestantesAnulacion:
          _entero(json['segundos_restantes_anulacion']) ?? 0,
      detalles: detalles is List
          ? detalles
                .whereType<Map<String, dynamic>>()
                .map(VentaLinea.fromJson)
                .toList(growable: false)
          : const [],
      pagos: pagos is List
          ? pagos
                .whereType<Map<String, dynamic>>()
                .map(VentaPago.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

/// Pago dentro del resumen de pagos (`GET /ventas/:id/pagos`).
class PagoResumen {
  const PagoResumen({
    required this.id,
    this.tipo,
    this.fecha,
    this.estado,
    this.montoDeclarado,
    this.montoConfirmado,
  });

  final int id;
  final String? tipo;
  final String? fecha;
  final String? estado;
  final double? montoDeclarado;
  final double? montoConfirmado;

  bool get rechazado => (estado ?? '').toLowerCase().contains('rechaz');
  bool get confirmado => montoConfirmado != null;

  /// Se puede confirmar si no está rechazado ni ya confirmado.
  bool get pendienteDeConfirmar => !rechazado && !confirmado;

  factory PagoResumen.fromJson(Map<String, dynamic> json) {
    return PagoResumen(
      id: _entero(json['id_pago']) ?? 0,
      tipo: _texto(json['tipo']),
      fecha: _texto(json['fecha']),
      estado: _texto(json['estado']),
      montoDeclarado: _numero(json['monto_declarado']),
      montoConfirmado: _numero(json['monto_confirmado']),
    );
  }
}

/// Resumen de pagos de una venta.
class ResumenPagos {
  const ResumenPagos({
    required this.total,
    required this.recibido,
    required this.enRevision,
    required this.falta,
    required this.saldoAFavor,
    required this.pagos,
  });

  final double total;
  final double recibido;
  final double enRevision;
  final double falta;
  final double saldoAFavor;
  final List<PagoResumen> pagos;

  factory ResumenPagos.fromJson(Map<String, dynamic> json) {
    final pagos = json['pagos'];
    return ResumenPagos(
      total: _numero(json['total']) ?? 0,
      recibido: _numero(json['recibido']) ?? 0,
      enRevision: _numero(json['en_revision']) ?? 0,
      falta: _numero(json['falta']) ?? 0,
      saldoAFavor: _numero(json['saldo_a_favor']) ?? 0,
      pagos: pagos is List
          ? pagos
                .whereType<Map<String, dynamic>>()
                .map(PagoResumen.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

/// Insumo o producto que falta para aceptar una venta (409 de stock).
class FaltanteStock {
  const FaltanteStock({
    required this.nombre,
    this.requerido,
    this.stock,
    this.falta,
    this.unidad,
    this.motivo,
  });

  final String nombre;
  final double? requerido;
  final double? stock;
  final double? falta;
  final String? unidad;
  final String? motivo;

  /// Extrae `faltantes` del cuerpo de error de [error]; vacío si no hay.
  static List<FaltanteStock> desde(ApiException error) {
    final crudo = error.data?['faltantes'];
    if (crudo is! List) return const [];
    return crudo
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => FaltanteStock(
            nombre: _texto(item['nombre']) ?? 'Sin nombre',
            requerido: _numero(item['requerido']),
            stock: _numero(item['stock']),
            falta: _numero(item['falta']),
            unidad: _texto(item['unidad']),
            motivo: _texto(item['motivo']),
          ),
        )
        .toList(growable: false);
  }
}

class VentasRepository {
  VentasRepository._();

  static final VentasRepository instance = VentasRepository._();

  /// `GET /ventas` (permiso Ventas > Ventas > Ver), más recientes primero.
  Future<List<Venta>> listar() async {
    final data = await ApiClient.instance.get('/ventas');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return Venta.fromJson(item);
        })
        .toList(growable: false);
  }

  /// `GET /ventas/:id/pagos` (requiere Ventas > Ventas > Editar).
  Future<ResumenPagos> resumenPagos(int id) async {
    final data = await ApiClient.instance.get('/ventas/$id/pagos');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return ResumenPagos.fromJson(data);
  }

  /// `PATCH /ventas/:id/pagos/:idPago/confirmacion`. Devuelve el resumen
  /// actualizado.
  Future<ResumenPagos> confirmarPago(
    int idVenta,
    int idPago,
    int montoConfirmado,
  ) async {
    final data = await ApiClient.instance.patch(
      '/ventas/$idVenta/pagos/$idPago/confirmacion',
      body: {'monto_confirmado': montoConfirmado},
    );
    if (data is Map<String, dynamic>) return ResumenPagos.fromJson(data);
    return resumenPagos(idVenta);
  }

  /// `PATCH /ventas/:id/verificacion` con `accion: aceptar`.
  Future<void> aceptar(int id) => _verificar(id, {'accion': 'aceptar'});

  /// `PATCH /ventas/:id/verificacion` con `accion: monto_faltante`
  /// (el cliente recibe un correo).
  Future<void> pedirMontoFaltante(int id) =>
      _verificar(id, {'accion': 'monto_faltante'});

  /// `PATCH /ventas/:id/verificacion` con `accion: rechazar`.
  Future<void> rechazar(int id, String motivoRechazo) =>
      _verificar(id, {'accion': 'rechazar', 'motivo_rechazo': motivoRechazo});

  Future<void> _verificar(int id, Map<String, Object?> cuerpo) async {
    await ApiClient.instance.patch('/ventas/$id/verificacion', body: cuerpo);
  }

  /// `POST /ventas/:id/listo` (solo ventas "Por entregar").
  Future<void> marcarListo(int id) async {
    await ApiClient.instance.post('/ventas/$id/listo');
  }

  /// `PATCH /ventas/:id/anular` (primeros 10 minutos desde la creación).
  Future<void> anular(int id, String motivo) async {
    await ApiClient.instance.patch('/ventas/$id/anular', body: {'motivo': motivo});
  }

  /// `GET /ventas/:id`: incluye el comprobante de cada pago.
  Future<Venta> obtener(int id) async {
    final data = await ApiClient.instance.get('/ventas/$id');
    final json = data is Map<String, dynamic> && data['venta'] is Map
        ? data['venta']
        : data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Venta.fromJson(json);
  }
}

const List<String> _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "2026-11-20T15:45:00.000000" -> "20 nov 2026, 3:45 p. m.".
/// No convierte zonas horarias: el backend ya entrega hora de Colombia.
String formatFechaHoraVenta(String? raw) {
  if (raw == null) return '—';
  final coincide = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2}))?',
  ).firstMatch(raw.trim());
  if (coincide == null) return raw;
  final mes = int.tryParse(coincide.group(2)!) ?? 0;
  final nombreMes = mes >= 1 && mes <= 12 ? _meses[mes - 1] : coincide.group(2);
  final fecha = '${int.parse(coincide.group(3)!)} $nombreMes ${coincide.group(1)}';
  final hora = coincide.group(4);
  final minuto = coincide.group(5);
  if (hora == null || minuto == null) return fecha;
  return '$fecha, ${_hora12(int.parse(hora), minuto)}';
}

/// "16:30:00" -> "4:30 p. m.".
String formatHoraVenta(String? raw) {
  if (raw == null) return '—';
  final coincide = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw.trim());
  if (coincide == null) return raw;
  return _hora12(int.parse(coincide.group(1)!), coincide.group(2)!);
}

String _hora12(int hora24, String minuto) {
  final sufijo = hora24 >= 12 ? 'p. m.' : 'a. m.';
  final hora = hora24 % 12 == 0 ? 12 : hora24 % 12;
  return '$hora:$minuto $sufijo';
}

String _sinTildes(String valor) {
  const conTilde = 'áéíóúüñ';
  const sinTilde = 'aeiouun';
  final buffer = StringBuffer();
  for (final rune in valor.runes) {
    final caracter = String.fromCharCode(rune);
    final indice = conTilde.indexOf(caracter);
    buffer.write(indice >= 0 ? sinTilde[indice] : caracter);
  }
  return buffer.toString();
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
    return texto == 'true' || texto == '1';
  }
  return false;
}
