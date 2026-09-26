import 'package:flutter/foundation.dart';
import '../client/models/order_model.dart';
import 'client_notification_service.dart';

/// Repositorio compartido de pedidos creados desde la app cliente.
/// Única fuente de verdad entre "Mis pedidos" (cliente) y "Gestión de
/// ventas" (admin): ambos leen/escriben sobre `mockOrders` y escuchan
/// este ChangeNotifier para refrescarse solos sin backend.
class OrdersRepository extends ChangeNotifier {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  List<OrderModel> get orders => mockOrders;

  void add(OrderModel order) {
    mockOrders.insert(0, order);
    notifyListeners();
  }

  OrderModel? byNumero(String numero) {
    for (final order in mockOrders) {
      if (order.numero == numero) return order;
    }
    return null;
  }

  void updateStatus(String numero, OrderStatus status) {
    final index = mockOrders.indexWhere((o) => o.numero == numero);
    if (index < 0) return;
    final anterior = mockOrders[index];
    if (anterior.estado == status) return;

    final actualizado = anterior.copyWith(estado: status);
    mockOrders[index] = actualizado;
    notifyListeners();

    if (status == OrderStatus.listoParaRecoger) {
      ClientNotificationService.instance.notifyReady(actualizado);
    }
  }
}