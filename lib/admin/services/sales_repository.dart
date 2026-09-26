import 'package:flutter/material.dart';

/// Estados posibles de un pedido de venta.
enum SaleStatus {
  porVerificar('Por verificar'),
  porEntregar('Por entregar'),
  completado('Completado'),
  devolucion('Devolución');

  const SaleStatus(this.label);

  final String label;
}

/// Colores (fondo, borde y texto) del badge de cada estado.
class SaleStatusColors {
  const SaleStatusColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

/// Paleta de estados coherente con la pantalla de Compras/Ventas.
const Map<SaleStatus, SaleStatusColors> saleStatusColors = {
  SaleStatus.porVerificar: SaleStatusColors(
    background: Color(0xFFFFF1D6),
    border: Color(0xFFEFC978),
    foreground: Color(0xFFA66500),
  ),
  SaleStatus.porEntregar: SaleStatusColors(
    background: Color(0xFFE3EDFC),
    border: Color(0xFFAECBF0),
    foreground: Color(0xFF2A5FA8),
  ),
  SaleStatus.completado: SaleStatusColors(
    background: Color(0xFFD3F1D8),
    border: Color(0xFF7CC287),
    foreground: Color(0xFF1F6B29),
  ),
  SaleStatus.devolucion: SaleStatusColors(
    background: Color(0xFFECEAE9),
    border: Color(0xFFC9C3C1),
    foreground: Color(0xFF5B4643),
  ),
};

SaleStatusColors saleStatusPalette(SaleStatus status) =>
    saleStatusColors[status] ?? saleStatusColors[SaleStatus.porVerificar]!;

/// Formatea un monto en pesos con separador de miles: 56000 -> $56.000.
String formatCop(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '\$${value < 0 ? '-' : ''}$buffer';
}

/// Producto incluido en un pedido de venta.
class SaleProduct {
  const SaleProduct({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageAsset,
  });

  final String name;
  final int quantity;
  final int price;
  final String? imageAsset;

  int get total => price * quantity;
}

/// Pedido de venta.
class Sale {
  const Sale({
    required this.id,
    required this.user,
    required this.date,
    required this.pickupTime,
    required this.payment,
    required this.paymentColor,
    required this.status,
    required this.products,
    required this.total,
    this.receiptAsset,
    this.receivedAmount,
  });

  final String id;
  final String user;
  final String date;
  final String pickupTime;
  final String payment;
  final Color paymentColor;
  final SaleStatus status;
  final List<SaleProduct> products;
  final int total;

  /// Comprobante de transferencia adjunto por el cliente.
  final String? receiptAsset;

  /// Monto que el administrador confirmó al verificar el pago.
  final int? receivedAmount;

  bool get isNequi => payment == 'Nequi';

  Sale copyWith({SaleStatus? status, int? receivedAmount}) => Sale(
    id: id,
    user: user,
    date: date,
    pickupTime: pickupTime,
    payment: payment,
    paymentColor: paymentColor,
    status: status ?? this.status,
    products: products,
    total: total,
    receiptAsset: receiptAsset,
    receivedAmount: receivedAmount ?? this.receivedAmount,
  );
}

/// Fuente única de verdad de las ventas del administrador.
///
/// Sustituye la lista local hardcodeada de la pantalla de Gestión Ventas y
/// notifica a todos los listeners (badges, tarjetas y listas) cuando cambia
/// el estado de un pedido o entra uno nuevo.
class SalesRepository extends ChangeNotifier {
  SalesRepository._();

  static final SalesRepository instance = SalesRepository._();

  static const Color nequiColor = Color(0xFFEDE2FF);
  static const Color bancolombiaColor = Color(0xFFFFF2B8);

  final List<Sale> _sales = List<Sale>.of(const [
    Sale(
      id: 'VEN-001',
      user: 'María González',
      date: '2024-01-15',
      pickupTime: '4:30 PM',
      payment: 'Nequi',
      paymentColor: nequiColor,
      status: SaleStatus.porEntregar,
      products: [SaleProduct(name: 'Margarita', quantity: 2, price: 28000)],
      total: 56000,
      receiptAsset: 'assets/img/Nequi.png',
    ),
    Sale(
      id: 'VEN-002',
      user: 'Carlos Martínez',
      date: '2024-01-15',
      pickupTime: '5:00 PM',
      payment: 'Bancolombia',
      paymentColor: bancolombiaColor,
      status: SaleStatus.completado,
      products: [
        SaleProduct(name: 'Lasaña de Carne', quantity: 1, price: 35000),
        SaleProduct(name: 'Quatro', quantity: 2, price: 8000),
      ],
      total: 51000,
      receiptAsset: 'assets/img/Bancolombia.png',
    ),
    Sale(
      id: 'VEN-003',
      user: 'Ana Rodríguez',
      date: '2024-01-16',
      pickupTime: '4:45 PM',
      payment: 'Nequi',
      paymentColor: nequiColor,
      status: SaleStatus.porVerificar,
      products: [
        SaleProduct(name: 'Pizza Pepperoni', quantity: 1, price: 32000),
        SaleProduct(name: 'Pepsi', quantity: 1, price: 7000),
      ],
      total: 39000,
      receiptAsset: 'assets/img/Nequi.png',
    ),
    Sale(
      id: 'VEN-004',
      user: 'Jorge Vargas',
      date: '2024-01-16',
      pickupTime: '6:15 PM',
      payment: 'Bancolombia',
      paymentColor: bancolombiaColor,
      status: SaleStatus.devolucion,
      products: [SaleProduct(name: 'Pizza Hawái', quantity: 1, price: 30000)],
      total: 30000,
      receiptAsset: 'assets/img/Bancolombia.png',
    ),
    Sale(
      id: 'VEN-005',
      user: 'Patricia Soto',
      date: '2024-01-17',
      pickupTime: '4:00 PM',
      payment: 'Nequi',
      paymentColor: nequiColor,
      status: SaleStatus.porVerificar,
      products: [
        SaleProduct(name: 'Pizza Jamón y Queso', quantity: 2, price: 29000),
        SaleProduct(name: 'Coca-Cola', quantity: 2, price: 7000),
      ],
      total: 72000,
      receiptAsset: 'assets/img/Nequi.png',
    ),
    Sale(
      id: 'VEN-006',
      user: 'Luis Pérez',
      date: '2024-01-17',
      pickupTime: '7:00 PM',
      payment: 'Bancolombia',
      paymentColor: bancolombiaColor,
      status: SaleStatus.completado,
      products: [SaleProduct(name: 'Lasaña Mixta', quantity: 1, price: 36000)],
      total: 36000,
      receiptAsset: 'assets/img/Bancolombia.png',
    ),
    Sale(
      id: 'VEN-007',
      user: 'Camila Torres',
      date: '2024-01-18',
      pickupTime: '5:30 PM',
      payment: 'Nequi',
      paymentColor: nequiColor,
      status: SaleStatus.porVerificar,
      products: [
        SaleProduct(name: 'Pizza de Pollo', quantity: 1, price: 31000),
        SaleProduct(name: 'Premio', quantity: 1, price: 6000),
      ],
      total: 37000,
      receiptAsset: 'assets/img/Nequi.png',
    ),
    Sale(
      id: 'VEN-008',
      user: 'Diego Ramírez',
      date: '2024-01-18',
      pickupTime: '6:45 PM',
      payment: 'Bancolombia',
      paymentColor: bancolombiaColor,
      status: SaleStatus.porEntregar,
      products: [
        SaleProduct(name: 'Pizza Tocineta', quantity: 2, price: 33000),
      ],
      total: 66000,
      receiptAsset: 'assets/img/Bancolombia.png',
    ),
  ]);

  List<Sale> get sales => List<Sale>.unmodifiable(_sales);

  /// Ventas que aún esperan verificación de pago.
  List<Sale> get pendingVerificationSales => _sales
      .where((sale) => sale.status == SaleStatus.porVerificar)
      .toList(growable: false);

  /// Conteo de pedidos "Por verificar" (usado por badges, alertas y avisos).
  int get pendingVerificationCount => pendingVerificationSales.length;

  /// Texto del badge con tope de 99 (ej. 3 -> "3", 120 -> "99+").
  String get pendingVerificationLabel {
    final count = pendingVerificationCount;
    return count > 99 ? '99+' : '$count';
  }

  Sale? saleById(String id) {
    for (final sale in _sales) {
      if (sale.id == id) return sale;
    }
    return null;
  }

  /// Cambia el estado de un pedido y notifica a toda la app.
  void updateStatus(String saleId, SaleStatus status, {int? receivedAmount}) {
    final index = _sales.indexWhere((sale) => sale.id == saleId);
    if (index < 0) return;
    _sales[index] = _sales[index].copyWith(
      status: status,
      receivedAmount: receivedAmount,
    );
    notifyListeners();
  }

  /// Registra un pedido nuevo (por ejemplo, uno enviado desde la app cliente).
  void addSale(Sale sale) {
    _sales.insert(0, sale);
    notifyListeners();
  }
}
