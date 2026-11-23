import '../admin/services/ventas_repository.dart';

/// Reglas de negocio de ventas compartidas por toda la app móvil.
///
/// Los textos deben coincidir EXACTAMENTE con los que valida el backend.

/// Motivos de `PATCH /ventas/:id/verificacion` con `accion: rechazar`.
const List<String> motivosRechazoVenta = [
  'Comprobante falso',
  'La imagen no corresponde a un comprobante',
  'Comprobante borroso',
];

/// Motivos de `PATCH /ventas/:id/anular`.
const List<String> motivosAnulacionVenta = [
  'Cliente canceló el pedido',
  'Error al registrar el pedido',
  'Producto no disponible',
];

/// Opción libre: se envía como `Otro: detalle` (detalle obligatorio).
const String motivoOtroVenta = 'Otro';

/// Longitud máxima del detalle de "Otro".
const int maxDetalleMotivoVenta = 80;

/// Arma el motivo a enviar: `Otro: detalle` o la opción elegida tal cual.
String motivoVentaParaEnviar(String opcion, String detalle) =>
    opcion == motivoOtroVenta ? '$motivoOtroVenta: ${detalle.trim()}' : opcion;

/// Estados desde los que el backend permite anular (primeros 10 minutos).
const Set<EstadoVenta> estadosAnulablesVenta = {
  EstadoVenta.porVerificar,
  EstadoVenta.enEspera,
  EstadoVenta.porEntregar,
};

/// `true` si una venta en [estado] con [segundosRestantes] se puede anular.
bool ventaAnulable(EstadoVenta? estado, int segundosRestantes) =>
    segundosRestantes > 0 && estadosAnulablesVenta.contains(estado);
