import 'package:flutter/foundation.dart';
import '../client/models/order_model.dart';

/// Aviso en vivo para el cliente cuando su pedido pasa a "Listo para
/// recoger". Sin backend/push real solo funciona con la app abierta.
class ClientNotificationService {
  ClientNotificationService._();
  static final ClientNotificationService instance =
      ClientNotificationService._();

  final ValueNotifier<OrderModel?> lastReadyOrder =
      ValueNotifier<OrderModel?>(null);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void notifyReady(OrderModel order) {
    lastReadyOrder.value = order;
    unreadCount.value = unreadCount.value + 1;
  }

  void markAllRead() {
    if (unreadCount.value != 0) unreadCount.value = 0;
  }
}