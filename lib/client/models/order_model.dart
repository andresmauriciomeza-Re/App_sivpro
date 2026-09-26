import 'package:flutter/material.dart';

enum OrderStatus { pagoPendiente, enPreparacion, listoParaRecoger, cancelada }

extension OrderStatusInfo on OrderStatus {
  String get texto {
    switch (this) {
      case OrderStatus.pagoPendiente:
        return 'Pago en aprobación';
      case OrderStatus.enPreparacion:
        return 'En preparación';
      case OrderStatus.listoParaRecoger:
        return 'Listo para recoger';
      case OrderStatus.cancelada:
        return 'Cancelada';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pagoPendiente:
        return const Color(0xFFE6A400);
      case OrderStatus.enPreparacion:
        return const Color(0xFFE68A00);
      case OrderStatus.listoParaRecoger:
        return const Color(0xFF34A853);
      case OrderStatus.cancelada:
        return const Color(0xFFE0472B);
    }
  }

  IconData get icono {
    switch (this) {
      case OrderStatus.pagoPendiente:
        return Icons.hourglass_top;
      case OrderStatus.enPreparacion:
        return Icons.local_fire_department;
      case OrderStatus.listoParaRecoger:
        return Icons.check_circle;
      case OrderStatus.cancelada:
        return Icons.cancel;
    }
  }
}

class OrderProductItem {
  final String nombre;
  final String imagen;
  final int cantidad;
  final int precioUnitario;

  const OrderProductItem({
    required this.nombre,
    required this.imagen,
    required this.cantidad,
    required this.precioUnitario,
  });

  int get subtotal => cantidad * precioUnitario;
}

class OrderModel {
  final String numero;
  final DateTime fecha;
  final int articulos;
  final int total;
  final OrderStatus estado;
  final List<String> imagenes;
  final List<String> nombresProductos;
  final String metodoPago;
  final List<OrderProductItem> productos;

  const OrderModel({
    required this.numero,
    required this.fecha,
    required this.articulos,
    required this.total,
    required this.estado,
    required this.imagenes,
    required this.nombresProductos,
    this.metodoPago = 'Nequi',
    this.productos = const [],
  });

  OrderModel copyWith({OrderStatus? estado}) {
    return OrderModel(
      numero: numero,
      fecha: fecha,
      articulos: articulos,
      total: total,
      estado: estado ?? this.estado,
      imagenes: imagenes,
      nombresProductos: nombresProductos,
      metodoPago: metodoPago,
      productos: productos,
    );
  }
}

// Pedidos reales creados por el cliente desde el flujo de pago.
final List<OrderModel> mockOrders = [];
