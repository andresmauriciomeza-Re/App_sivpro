import '../../shared/numeros.dart';

int _entero(dynamic valor) => numeroTolerante(valor)?.round() ?? 0;

int? _enteroONulo(dynamic valor) => numeroTolerante(valor)?.round();

String? _texto(dynamic valor) {
  final texto = valor?.toString().trim();
  return texto == null || texto.isEmpty ? null : texto;
}

/// Fechas del backend "YYYY-MM-DDTHH:mm:ss.SSSSSS" sin zona: ya son hora de
/// Bogotá, así que se leen como hora de pared (sin convertir).
DateTime? _fecha(dynamic valor) {
  final texto = _texto(valor);
  if (texto == null) return null;
  return DateTime.tryParse(
    texto.replaceFirst(RegExp(r'(Z|[+-]\d\d:?\d\d)$'), ''),
  );
}

/// Línea de un pedido (`detalles` de `GET /ventas/mias`).
class LineaPedido {
  const LineaPedido({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.tamano,
  });

  factory LineaPedido.desdeJson(Map<String, dynamic> json) => LineaPedido(
    idProducto: _entero(json['id_producto']),
    nombre: _texto(json['nombre']) ?? 'Producto',
    cantidad: _entero(json['cantidad']),
    precioUnitario: _entero(json['precio_unitario']),
    subtotal: _entero(json['sub_total']),
    tamano: _texto(json['tamano']),
  );

  final int idProducto;
  final String nombre;
  final int cantidad;
  final int precioUnitario;
  final int subtotal;

  /// "Mediana"/"Grande" (pizza, cantidad en porciones), "Normal" o null.
  final String? tamano;

  bool get esPizza => tamano == 'Mediana' || tamano == 'Grande';
}

/// Pago registrado en un pedido.
class PagoPedido {
  const PagoPedido({
    required this.id,
    required this.tipo,
    required this.estado,
    this.comprobante,
    this.tieneComprobante = false,
  });

  factory PagoPedido.desdeJson(Map<String, dynamic> json) => PagoPedido(
    id: _entero(json['id_pago']),
    tipo: _texto(json['tipo']) ?? '',
    estado: _texto(json['estado']) ?? '',
    comprobante: _texto(json['comprobante']),
    tieneComprobante:
        json['tiene_comprobante'] == true ||
        _texto(json['comprobante']) != null,
  );

  final int id;
  final String tipo;
  final String estado;

  /// URL del comprobante (solo en `GET /ventas/mias/:id`).
  final String? comprobante;
  final bool tieneComprobante;
}

/// Pedido del cliente (`GET /ventas/mias`).
class Pedido {
  const Pedido({
    required this.id,
    required this.estado,
    required this.estadoCliente,
    required this.monto,
    this.fecha,
    this.fechaEstado,
    this.horaRecogida,
    this.motivoRechazo,
    this.anuladoPor,
    this.montoReembolso,
    this.comprobanteAnulacion,
    this.segundosRestantesAnulacion = 0,
    this.direccionRecogida,
    this.ventaLocal = false,
    this.detalles = const [],
    this.pagos = const [],
    this.devolucionEstado,
    this.devolucionTipo,
    this.devolucionMonto,
    this.devolucionNota,
    this.metodoReembolso,
    this.idVentaReemplazo,
  });

  factory Pedido.desdeJson(Map<String, dynamic> json) {
    final detalles = json['detalles'];
    final pagos = json['pagos'];
    final estado = _texto(json['estado']) ?? '';
    return Pedido(
      id: _entero(json['id_venta']),
      estado: estado,
      estadoCliente: _texto(json['estado_cliente']) ?? estado,
      monto: _entero(json['monto']),
      fecha: _fecha(json['fecha']),
      fechaEstado: _fecha(json['fecha_estado']),
      horaRecogida: _texto(json['hora_recogida']),
      motivoRechazo: _texto(json['motivo_rechazo']),
      anuladoPor: _texto(json['anulado_por']),
      montoReembolso: _enteroONulo(json['monto_reembolso']),
      comprobanteAnulacion: _texto(json['comprobante_anulacion']),
      segundosRestantesAnulacion: _entero(json['segundos_restantes_anulacion']),
      direccionRecogida: _texto(json['direccion_recogida']),
      ventaLocal: json['venta_local'] == true,
      detalles: detalles is List
          ? [
              for (final d in detalles)
                if (d is Map<String, dynamic>) LineaPedido.desdeJson(d),
            ]
          : const [],
      pagos: pagos is List
          ? [
              for (final p in pagos)
                if (p is Map<String, dynamic>) PagoPedido.desdeJson(p),
            ]
          : const [],
      devolucionEstado: _texto(json['devolucion_estado']),
      devolucionTipo: _texto(json['devolucion_tipo']),
      devolucionMonto: _enteroONulo(json['devolucion_monto']),
      devolucionNota: _texto(json['devolucion_nota']),
      metodoReembolso: _texto(json['metodo_reembolso']),
      idVentaReemplazo: _enteroONulo(json['id_venta_reemplazo']),
    );
  }

  final int id;

  /// Estado de la venta en el backend (Por verificar, En espera, …).
  final String estado;

  /// Lo que se muestra al cliente (Pendiente, Aceptado, En proceso, …).
  final String estadoCliente;
  final int monto;
  final DateTime? fecha;
  final DateTime? fechaEstado;

  /// "HH:mm:ss" (hora de Bogotá).
  final String? horaRecogida;
  final String? motivoRechazo;
  final String? anuladoPor;
  final int? montoReembolso;
  final String? comprobanteAnulacion;

  /// Segundos que quedan de los 10 minutos para cancelar (0 si ya pasaron).
  final int segundosRestantesAnulacion;
  final String? direccionRecogida;
  final bool ventaLocal;
  final List<LineaPedido> detalles;
  final List<PagoPedido> pagos;
  final String? devolucionEstado;
  final String? devolucionTipo;
  final int? devolucionMonto;
  final String? devolucionNota;
  final String? metodoReembolso;
  final int? idVentaReemplazo;

  /// 'Pendiente' mientras se gestiona; 'Resuelta' cuando ya se cerró.
  bool get devolucionResuelta => devolucionEstado == 'Resuelta';

  /// Método del primer pago (Nequi o Bancolombia).
  String? get metodoPago => pagos.isEmpty ? null : pagos.first.tipo;

  /// URL del primer comprobante (solo en el detalle).
  String? get comprobantePago {
    for (final pago in pagos) {
      if (pago.comprobante != null) return pago.comprobante;
    }
    return null;
  }

  /// Lo que se devuelve si el cliente cancela (80 %, como la web).
  int get valorADevolver => (monto * 0.8).round();

  int get articulos => detalles.fold(0, (s, d) => s + d.cantidad);

  /// Estados finales: ya no cambian (no se siguen consultando).
  static const Set<String> estadosFinales = {
    'Completado',
    'Anulado',
    'Rechazado',
    'Devolución',
  };

  bool get activo => !estadosFinales.contains(estadoCliente);

  /// Estados que el backend deja cancelar al cliente (como la web).
  bool get estadoCancelable =>
      estado == 'Por verificar' ||
      estado == 'En espera' ||
      estado == 'Por entregar' ||
      (ventaLocal && estado == 'Completado');
}

/// Pago dentro del resumen `GET /ventas/mias/:id/pagos`.
class PagoResumen {
  const PagoResumen({
    required this.estado,
    this.comprobante,
    this.montoDeclarado,
    this.montoConfirmado,
  });

  factory PagoResumen.desdeJson(Map<String, dynamic> json) => PagoResumen(
    estado: _texto(json['estado']) ?? '',
    comprobante: _texto(json['comprobante']),
    montoDeclarado: _enteroONulo(json['monto_declarado']),
    montoConfirmado: _enteroONulo(json['monto_confirmado']),
  );

  final String estado;
  final String? comprobante;
  final int? montoDeclarado;
  final int? montoConfirmado;
}

/// Resumen de pagos de un pedido (`GET /ventas/mias/:id/pagos`).
class ResumenPagos {
  const ResumenPagos({
    required this.total,
    required this.recibido,
    required this.enRevision,
    required this.falta,
    this.pagos = const [],
  });

  factory ResumenPagos.desdeJson(Map<String, dynamic> json) {
    final pagos = json['pagos'];
    return ResumenPagos(
      total: _entero(json['total']),
      recibido: _entero(json['recibido']),
      enRevision: _entero(json['en_revision']),
      falta: _entero(json['falta']),
      pagos: pagos is List
          ? [
              for (final p in pagos)
                if (p is Map<String, dynamic>) PagoResumen.desdeJson(p),
            ]
          : const [],
    );
  }

  final int total;
  final int recibido;
  final int enRevision;
  final int falta;
  final List<PagoResumen> pagos;

  /// Igual que la web: un pago pendiente sin confirmar, con comprobante o
  /// con monto declarado, está en revisión.
  bool get hayComprobanteEnRevision => pagos.any(
    (p) =>
        p.estado == 'Pendiente' &&
        p.montoConfirmado == null &&
        (p.comprobante != null || p.montoDeclarado != null),
  );
}
