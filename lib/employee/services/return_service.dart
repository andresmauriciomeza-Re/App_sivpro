import 'package:flutter/foundation.dart';

/// Producto dentro de una venta (o producto devuelto en un canje).
class ReturnProduct {
  final String nombre;
  final String imagen;
  final int precio;
  final int cantidad;

  const ReturnProduct({
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.cantidad,
  });

  int get subtotal => precio * cantidad;
  String get precioTexto => '\$${_formatoMiles(precio)}';
  String get subtotalTexto => '\$${_formatoMiles(precio * cantidad)}';
}

/// Devolución registrada.
///
/// `status` puede ser 'pendiente' o 'resuelta'. Cuando se resuelve se guarda el
/// tipo de resolución en `resolutionType`:
/// - 'canje': productos devueltos y nombre del producto de reemplazo.
/// - 'dinero': monto a reembolsar (`refundAmount`) y nota opcional (`refundNote`).
class ReturnRecord {
  final int index;
  final String customer;
  final String date;
  final String amount;
  final String payment;
  final String tipoVenta;
  final List<ReturnProduct> products;
  final String status;
  final List<ReturnProduct> returnedProducts;
  final String replacementProduct;
  final String resolutionType;
  final String refundAmount;
  final String refundNote;

  const ReturnRecord({
    required this.index,
    required this.customer,
    required this.date,
    required this.amount,
    required this.payment,
    required this.tipoVenta,
    required this.products,
    this.status = 'pendiente',
    this.returnedProducts = const [],
    this.replacementProduct = '',
    this.resolutionType = '',
    this.refundAmount = '',
    this.refundNote = '',
  });

  bool get isResuelta => status == 'resuelta';
  bool get isCanje => resolutionType == 'canje';
  bool get isDinero => resolutionType == 'dinero';

  /// Monto con espacio tras el símbolo: `$32.000` -> `$ 32.000`.
  String get amountTexto =>
      amount.startsWith('\$') ? '\$ ${amount.substring(1)}' : amount;

  ReturnRecord copyWith({
    String? status,
    List<ReturnProduct>? returnedProducts,
    String? replacementProduct,
    String? resolutionType,
    String? refundAmount,
    String? refundNote,
  }) {
    return ReturnRecord(
      index: index,
      customer: customer,
      date: date,
      amount: amount,
      payment: payment,
      tipoVenta: tipoVenta,
      products: products,
      status: status ?? this.status,
      returnedProducts: returnedProducts ?? this.returnedProducts,
      replacementProduct: replacementProduct ?? this.replacementProduct,
      resolutionType: resolutionType ?? this.resolutionType,
      refundAmount: refundAmount ?? this.refundAmount,
      refundNote: refundNote ?? this.refundNote,
    );
  }
}

/// Estado local (mock) de las devoluciones.
///
/// Sigue el mismo patrón de `CartService.instance` (ChangeNotifier singleton)
/// para que las pantallas se refresquen con ListenableBuilder.
class ReturnService extends ChangeNotifier {
  ReturnService._();
  static final ReturnService instance = ReturnService._();

  final List<ReturnRecord> _records = [..._registrosIniciales];

  List<ReturnRecord> get pendientes =>
      _records.where((r) => r.status == 'pendiente').toList();

  List<ReturnRecord> get resueltas =>
      _records.where((r) => r.status == 'resuelta').toList();

  /// Resuelve una devolución como "canje por producto":
  /// guarda los productos devueltos y el producto de reemplazo elegido,
  /// y la pasa de pendiente a resuelta.
  void resolveCanje(
    ReturnRecord record,
    List<ReturnProduct> returnedProducts,
    String replacementProduct,
  ) {
    final index = _records.indexWhere((r) => r.index == record.index);
    if (index == -1) return;
    _records[index] = record.copyWith(
      status: 'resuelta',
      returnedProducts: returnedProducts,
      replacementProduct: replacementProduct,
      resolutionType: 'canje',
    );
    notifyListeners();
  }

  /// Resuelve una devolución como "producto por dinero":
  /// guarda el monto a reembolsar (el de la venta) y la nota opcional,
  /// y la pasa de pendiente a resuelta.
  void resolveMoney(ReturnRecord record, String note) {
    final index = _records.indexWhere((r) => r.index == record.index);
    if (index == -1) return;
    _records[index] = record.copyWith(
      status: 'resuelta',
      resolutionType: 'dinero',
      refundAmount: record.amount,
      refundNote: note,
    );
    notifyListeners();
  }
}

const List<ReturnRecord> _registrosIniciales = [
  ReturnRecord(
    index: 6,
    customer: 'Luis Herrera',
    date: '2024-01-17',
    amount: '\$70.000',
    payment: 'Bancolombia',
    tipoVenta: 'Venta en mostrador',
    products: [
      ReturnProduct(
        nombre: 'Pizza Cañon',
        imagen: 'assets/img/pizza_cañon.png',
        precio: 16000,
        cantidad: 2,
      ),
      ReturnProduct(
        nombre: 'Pizza Pollo',
        imagen: 'assets/img/pizza_pollo.png',
        precio: 16000,
        cantidad: 2,
      ),
      ReturnProduct(
        nombre: 'Coca Cola',
        imagen: 'assets/img/Coca-Cola.png',
        precio: 3000,
        cantidad: 2,
      ),
    ],
  ),
  ReturnRecord(
    index: 7,
    customer: 'Sandra Ríos',
    date: '2024-01-18',
    amount: '\$28.000',
    payment: 'Nequi',
    tipoVenta: 'Venta en mostrador',
    products: [
      ReturnProduct(
        nombre: 'Pizza Jamón con Queso',
        imagen: 'assets/img/pizza_jamon_queso.png',
        precio: 14000,
        cantidad: 1,
      ),
      ReturnProduct(
        nombre: 'Pizza Maicitos',
        imagen: 'assets/img/pizza_maicitos.png',
        precio: 14000,
        cantidad: 1,
      ),
    ],
  ),
  ReturnRecord(
    index: 8,
    customer: 'Jorge Vargas',
    date: '2024-01-16',
    amount: '\$32.000',
    payment: 'Bancolombia',
    tipoVenta: 'Venta en mostrador',
    products: [
      ReturnProduct(
        nombre: 'Pizza Cañon',
        imagen: 'assets/img/pizza_cañon.png',
        precio: 16000,
        cantidad: 1,
      ),
      ReturnProduct(
        nombre: 'Pizza Tocineta',
        imagen: 'assets/img/pizza_tocineta.png',
        precio: 16000,
        cantidad: 1,
      ),
    ],
  ),
];

String _formatoMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}