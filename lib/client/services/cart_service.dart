import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class CartAddition {
  final String nombre;
  final int precio;
  final int cantidad;

  /// `id_producto` real de la bebida (null en datos fijos).
  final int? idProducto;
  const CartAddition({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.idProducto,
  });
}

class CartItem {
  final String id;
  final String nombre;
  final String imagen;
  final String tamanoNombre;
  final int precioBase;
  List<CartAddition> adiciones;
  int cantidad;

  /// `id_producto` real (null cuando el producto viene del catálogo fijo).
  final int? idProducto;

  CartItem({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.tamanoNombre,
    required this.precioBase,
    required this.adiciones,
    this.cantidad = 1,
    this.idProducto,
  });

  int get precioAdiciones =>
      adiciones.fold(0, (s, a) => s + a.precio * a.cantidad);

  /// Igual que el detalle y que el backend (cada adición es su propia línea):
  /// las adiciones NO se multiplican por la cantidad del producto.
  int get subtotal => precioBase * cantidad + precioAdiciones;

  String get adicionesTexto => adiciones
      .where((a) => a.cantidad > 0)
      .map((a) => a.cantidad > 1 ? '${a.nombre} ×${a.cantidad}' : a.nombre)
      .join(', ');

  String get _claveProducto => '${idProducto ?? nombre}|$tamanoNombre';

  Set<String> get _clavesAdiciones => {
    for (final a in adiciones) '${a.idProducto ?? a.nombre}',
  };

  /// Mismo producto, tamaño y bebidas: se consolida en una sola línea.
  bool _mismaCombinacion(CartItem otra) =>
      _claveProducto == otra._claveProducto &&
      setEquals(_clavesAdiciones, otra._clavesAdiciones);
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

  /// Agrega la línea o, si ya hay una igual, suma sus cantidades (y las de
  /// sus adiciones). [maximo] limita la cantidad del producto al consolidar.
  void addItem(CartItem item, {int? maximo}) {
    final i = _items.indexWhere((l) => l._mismaCombinacion(item));
    if (i < 0) {
      _items.add(item);
    } else {
      final linea = _items[i];
      final suma = linea.cantidad + item.cantidad;
      linea.cantidad = maximo == null
          ? suma
          : math.min(suma, math.max(maximo, linea.cantidad));
      linea.adiciones = [
        for (final a in linea.adiciones)
          CartAddition(
            nombre: a.nombre,
            precio: a.precio,
            idProducto: a.idProducto,
            cantidad:
                a.cantidad +
                item.adiciones
                    .where(
                      (n) =>
                          '${n.idProducto ?? n.nombre}' ==
                          '${a.idProducto ?? a.nombre}',
                    )
                    .fold(0, (s, n) => s + n.cantidad),
          ),
      ];
    }
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
