import '../services/insumos_repository.dart';

/// Barra de notificaciones del teléfono, vista desde la lista del panel.
///
/// La lista decide qué es nuevo (con su línea base guardada) y pide mostrarlo
/// o quitarlo. La implementa `LowStockNotificationService`, dueño del plugin;
/// las pruebas ponen una falsa.
abstract class BarraTelefono {
  /// Un solo aviso para los [insumos] que acaban de generar notificación.
  Future<void> avisarInsumos(int id, List<Insumo> insumos);

  /// Aviso de ventas: una venta nueva o el resumen de la primera vez.
  Future<void> avisarVenta(int id, String titulo, String cuerpo);

  Future<void> cancelar(int id);
}

/// IDs estables: repetir un aviso lo reemplaza en vez de acumularlo.
abstract final class IdsBarra {
  static const int insumos = 7101;
  static const int resumenVentas = 7102;

  /// Más el id de la venta. (Los pedidos del cliente usan 7200000.)
  static const int ventas = 7300000;
}
