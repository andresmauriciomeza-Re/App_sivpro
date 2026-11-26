/// Tipos de notificación del panel (Administrador y Empleado).
enum TipoNotificacion {
  ventaPorVerificar,
  insumoBajoMinimo,
  insumoAgotado,
  resumenVentasPorVerificar,
  resumenInsumosBajoMinimo,
}

/// Módulo al que lleva una notificación al tocarla.
enum DestinoNotificacion { ventas, insumos }

/// Notificación del panel. Los nombres de [toJson] son los que usará la
/// fuente del backend (fase 2).
class Notificacion {
  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.destino,
    this.leida = false,
    this.referencia,
  });

  /// Estable: "venta:12", "insumo:4:agotado", "resumen:ventas"…
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;

  /// Hora de pared de Bogotá (como el resto del panel).
  final DateTime fecha;
  final bool leida;
  final DestinoNotificacion destino;

  /// Id de la venta o del insumo, si aplica.
  final String? referencia;

  Notificacion copyWith({bool? leida, DateTime? fecha}) => Notificacion(
    id: id,
    tipo: tipo,
    titulo: titulo,
    mensaje: mensaje,
    fecha: fecha ?? this.fecha,
    destino: destino,
    leida: leida ?? this.leida,
    referencia: referencia,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo': tipo.name,
    'titulo': titulo,
    'mensaje': mensaje,
    'fecha': fecha.toIso8601String(),
    'leida': leida,
    'destino': destino.name,
    'referencia': referencia,
  };

  /// null si el JSON no es válido (se descarta sin romper la lista).
  static Notificacion? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final tipo = TipoNotificacion.values
        .where((t) => t.name == json['tipo'])
        .firstOrNull;
    final destino = DestinoNotificacion.values
        .where((d) => d.name == json['destino'])
        .firstOrNull;
    final fecha = DateTime.tryParse('${json['fecha']}');
    if (id is! String || tipo == null || destino == null || fecha == null) {
      return null;
    }
    final referencia = json['referencia'];
    return Notificacion(
      id: id,
      tipo: tipo,
      titulo: '${json['titulo'] ?? ''}',
      mensaje: '${json['mensaje'] ?? ''}',
      fecha: fecha,
      destino: destino,
      leida: json['leida'] == true,
      referencia: referencia == null ? null : '$referencia',
    );
  }
}
