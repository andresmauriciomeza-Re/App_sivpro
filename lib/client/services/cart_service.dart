import 'package:flutter/foundation.dart';

class CartAddition {
  final String nombre;
  final int precio;
  final int cantidad;
  const CartAddition({
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });
}

class CartItem {
  final String id;
  final String nombre;
  final String imagen;
  final String tamanoNombre;
  final int precioBase;
  final List<CartAddition> adiciones;
  int cantidad;

  CartItem({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.tamanoNombre,
    required this.precioBase,
    required this.adiciones,
    this.cantidad = 1,
  });

  int get precioAdiciones =>
      adiciones.fold(0, (s, a) => s + a.precio * a.cantidad);
  int get precioUnitario => precioBase + precioAdiciones;
  int get subtotal => precioUnitario * cantidad;

  String get adicionesTexto =>
      adiciones.where((a) => a.cantidad > 0).map((a) => a.nombre).join(', ');
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  int get totalArticulos => _items.fold(0, (s, i) => s + i.cantidad);
  int get subtotal => _items.fold(0, (s, i) => s + i.subtotal);
  int get total => subtotal;
  bool get estaVacio => _items.isEmpty;

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateQuantity(String id, int cantidad) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    if (cantidad <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].cantidad = cantidad;
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

String formatoMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}