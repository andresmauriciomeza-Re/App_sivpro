import 'package:flutter/foundation.dart';

/// Contador en vivo de ventas con estado "Por verificar".
///
/// Fuente compartida (sin backend) entre la barra de navegación inferior,
/// la tarjeta de módulos y la lista de gestión de ventas. Hoy se sincroniza
/// desde `_SalesManagementScreenState` cada vez que cambia el estado de una
/// venta.
///
/// TODO: reemplazar este contador mock por la consulta real al backend cuando
/// exista (p. ej. escuchar un repositorio de pedidos en tiempo real y exponer
/// aquí el número de pedidos pendientes de verificar).
class PendingSalesService {
  PendingSalesService._();

  static final PendingSalesService instance = PendingSalesService._();

  final ValueNotifier<int> count = ValueNotifier<int>(0);

  void setPendingCount(int value) {
    if (count.value != value) count.value = value;
  }
}