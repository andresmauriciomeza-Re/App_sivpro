import 'package:flutter/foundation.dart';

/// Fuente única de verdad del stock de los productos del administrador.
///
/// El catálogo de "Gestión Producto" (nombre, precio, categoría, imagen) sigue
/// viviendo en `products.dart`, pero el stock ya no se guarda en el modelo del
/// producto: se lee y se actualiza siempre a través de este repositorio.
///
/// Así "Gestión Producto" (y sus formularios de alta/edición) y "Orden
/// Producción" comparten el mismo dato y cualquier cambio se refleja de
/// inmediato, sin tener que salir y volver a entrar a la pantalla.
class ProductsRepository extends ChangeNotifier {
  ProductsRepository._();

  static final ProductsRepository instance = ProductsRepository._();

  /// Stock inicial del catálogo. Es la única copia de estos valores: el modelo
  /// `_Product` ya no guarda stock.
  static const Map<String, int> _initialStocks = {
    'PROD-001': 50,
    'PROD-002': 40,
    'PROD-003': 30,
    'PROD-004': 25,
    'PROD-005': 20,
  };

  final Map<String, int> _stockByProductId = Map<String, int>.of(
    _initialStocks,
  );

  /// IDs de los productos con stock registrado.
  Iterable<String> get trackedProductIds => _stockByProductId.keys;

  bool isTracked(String productId) => _stockByProductId.containsKey(productId);

  /// Stock actual del producto.
  int stockOf(String productId) => _stockByProductId[productId] ?? 0;

  /// Suma total del stock de todos los productos registrados.
  int get totalStock => _stockByProductId.values.fold(0, (sum, s) => sum + s);

  /// Registra el stock con el que se acaba de crear un producto.
  void registerProduct(String productId, {required int stock}) {
    _stockByProductId[productId] = stock < 0 ? 0 : stock;
    notifyListeners();
  }

  /// Ajuste manual desde el campo "Stock disponible" de "Editar Producto".
  void setStock(String productId, int stock) {
    final value = stock < 0 ? 0 : stock;
    if (_stockByProductId[productId] == value) return;
    _stockByProductId[productId] = value;
    notifyListeners();
  }

  /// Suma automática al completar una orden de producción.
  ///
  /// Devuelve el stock resultante, o `null` si no hay nada que sumar (cantidad
  /// vacía o producto no registrado en el catálogo).
  int? addStock(String productId, int amount) {
    if (amount <= 0 || !_stockByProductId.containsKey(productId)) return null;
    final updated = _stockByProductId[productId]! + amount;
    _stockByProductId[productId] = updated;
    notifyListeners();
    return updated;
  }
}
