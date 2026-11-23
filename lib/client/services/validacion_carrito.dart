import 'dart:math' as math;

import '../models/producto_catalogo.dart';
import 'cart_service.dart';

/// Resultado de revisar una línea del carrito contra el catálogo.
class EstadoLinea {
  const EstadoLinea({this.noDisponible = false, this.mensaje, this.maximo});

  static const EstadoLinea correcta = EstadoLinea();

  /// El producto (o una de sus bebidas) ya no se puede pedir: la línea no se
  /// puede aumentar y el pago queda bloqueado hasta quitarla.
  final bool noDisponible;

  /// Texto en rojo de la línea (no disponible o por encima del stock).
  final String? mensaje;

  /// Cantidad máxima del producto en esta línea; null = sin límite.
  final int? maximo;

  bool get bloquea => noDisponible || mensaje != null;
}

/// Partes de pizza que consume una porción (igual que el backend).
int? partesPorPorcion(String tamano) => switch (tamano) {
  'Mediana' => 3,
  'Grande' => 4,
  _ => null,
};

String _sinStock(ProductoCatalogo producto, String tamano, int maximo) {
  if (producto.esPizza) {
    if (maximo == 0) {
      return 'No quedan porciones de ${producto.nombre} $tamano disponibles';
    }
    return maximo == 1
        ? 'Solo queda 1 porción de ${producto.nombre} $tamano disponible'
        : 'Solo quedan $maximo porciones de ${producto.nombre} $tamano '
              'disponibles';
  }
  return _sinUnidades(producto.nombre, maximo);
}

String _sinUnidades(String nombre, int maximo) {
  if (maximo == 0) return 'No quedan unidades de $nombre';
  return maximo == 1
      ? 'Solo queda 1 unidad de $nombre'
      : 'Solo quedan $maximo unidades de $nombre';
}

/// Máximo de la línea [i] descontando lo que ya ocupan las demás (como la
/// web: la propia no se cuenta dos veces). null = sin límite.
int? _maximoDe(int i, List<CartItem> items, ProductoCatalogo producto) {
  final linea = items[i];
  final otras = [
    for (var j = 0; j < items.length; j++)
      if (j != i && items[j].idProducto == producto.id) items[j],
  ];
  if (producto.esPizza) {
    final factor = partesPorPorcion(linea.tamanoNombre);
    final partes = producto.stockPartes;
    if (factor != null && partes != null) {
      final consumidas = otras.fold(
        0,
        (s, l) => s + l.cantidad * (partesPorPorcion(l.tamanoNombre) ?? 0),
      );
      return math.max(0, (partes - consumidas) ~/ factor);
    }
    final tamano = producto.tamanos
        .where((t) => t.nombre == linea.tamanoNombre)
        .firstOrNull;
    final disponibles = tamano?.disponibles;
    if (disponibles == null) return null;
    final enOtras = otras
        .where((l) => l.tamanoNombre == linea.tamanoNombre)
        .fold(0, (s, l) => s + l.cantidad);
    return math.max(0, disponibles - enOtras);
  }
  final stock = producto.stock;
  if (stock == null) return null;
  return math.max(0, stock - otras.fold(0, (s, l) => s + l.cantidad));
}

/// Revisa cada línea (por su `id`) contra el catálogo recién cargado:
/// productos o bebidas que ya no se pueden pedir y cantidades por encima del
/// stock. El carrito nunca se corrige solo: solo se marca.
Map<String, EstadoLinea> validarCarrito(
  List<CartItem> items,
  List<ProductoCatalogo> catalogo,
) {
  final porId = {for (final p in catalogo) p.id: p};

  // Las bebidas adicionales se cobran como líneas propias: su demanda total
  // es la suma de todas las líneas que las llevan.
  final demandaBebidas = <int, int>{};
  for (final linea in items) {
    for (final a in linea.adiciones) {
      final id = a.idProducto;
      if (id != null && a.cantidad > 0) {
        demandaBebidas[id] = (demandaBebidas[id] ?? 0) + a.cantidad;
      }
    }
  }

  final estados = <String, EstadoLinea>{};
  for (var i = 0; i < items.length; i++) {
    final linea = items[i];
    final producto = porId[linea.idProducto];
    final pedible =
        producto != null &&
        producto.disponible &&
        producto.seccion != SeccionMenu.otra;
    if (!pedible) {
      estados[linea.id] = EstadoLinea(
        noDisponible: true,
        mensaje: '${linea.nombre} ya no está disponible.',
      );
      continue;
    }
    String? mensaje;
    var noDisponible = false;
    for (final a in linea.adiciones.where((a) => a.cantidad > 0)) {
      final bebida = porId[a.idProducto];
      if (bebida == null || !bebida.disponible) {
        noDisponible = true;
        mensaje = '${a.nombre} ya no está disponible.';
        break;
      }
      final stock = bebida.stock;
      final demanda = demandaBebidas[bebida.id] ?? 0;
      if (stock != null && demanda > stock) {
        mensaje = _sinUnidades(bebida.nombre, stock);
      }
    }
    final maximo = _maximoDe(i, items, producto);
    if (!noDisponible && maximo != null && linea.cantidad > maximo) {
      mensaje = _sinStock(producto, linea.tamanoNombre, maximo);
    }
    estados[linea.id] = EstadoLinea(
      noDisponible: noDisponible,
      mensaje: mensaje,
      maximo: maximo,
    );
  }
  return estados;
}
