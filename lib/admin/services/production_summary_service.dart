import 'indicators_service.dart';
import 'production_repository.dart';

/// Resumen de órdenes de producción para la tarjeta "Resumen de Hoy".
class ProductionSummary {
  const ProductionSummary({
    required this.ordenesActivas,
    required this.completadasHoy,
  });

  /// Órdenes en estado "Pendiente" o "En proceso".
  final int ordenesActivas;

  /// Órdenes cuya `fecha_completada` es hoy (hora de Bogotá).
  final int completadasHoy;

  /// Función pura: calcula el resumen a partir de la lista de órdenes.
  factory ProductionSummary.desde(
    List<OrdenProduccion> ordenes, {
    DateTime? ahora,
  }) {
    final hoy = ahoraBogota(ahora);
    final hoyTexto =
        '${hoy.year.toString().padLeft(4, '0')}-'
        '${hoy.month.toString().padLeft(2, '0')}-'
        '${hoy.day.toString().padLeft(2, '0')}';
    var activas = 0;
    var completadas = 0;
    for (final orden in ordenes) {
      if (orden.estado == 'Pendiente' || orden.estado == 'En proceso') {
        activas++;
      } else if (orden.estado == 'Completada' &&
          diaDeTexto(orden.fechaCompletada) == hoyTexto) {
        completadas++;
      }
    }
    return ProductionSummary(
      ordenesActivas: activas,
      completadasHoy: completadas,
    );
  }
}

class ProductionSummaryService {
  ProductionSummaryService._();

  static final ProductionSummaryService instance = ProductionSummaryService._();

  /// `GET /ordenes-produccion` (Producción > Orden de Producción > Ver).
  Future<ProductionSummary> cargar() async {
    final ordenes = await ProductionRepository.instance.listar();
    return ProductionSummary.desde(ordenes);
  }
}
