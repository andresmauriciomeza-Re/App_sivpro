import 'package:sivpro_app/client/models/producto_catalogo.dart';
import 'package:sivpro_app/client/services/cart_service.dart';

/// Fila de `GET /productos` como la entrega PostgreSQL (números como texto).
Map<String, dynamic> filaCatalogo(
  int id,
  String nombre,
  int categoria, {
  Object? precio = '14000.00',
  Object? precioGrande,
  String estado = 'Disponible',
  Object? stock,
  Object? stockPartes,
  Object? mediana,
  Object? grande,
}) => {
  'id_producto': id,
  'id_categoria': categoria,
  'nombre': nombre,
  'tipo': categoria == 3 ? 'Reventa' : 'Elaborado',
  'precio_venta': precio,
  'unidad_venta': 'Unidad',
  'imagen': null,
  'estado': estado,
  'tiene_imagen': false,
  'imagenes': <String>[],
  'categoria_nombre': '',
  'categoria_descripcion': null,
  'categoria_emoji': null,
  'stock': stock,
  'stock_partes': stockPartes,
  'disponibles_mediana': mediana,
  'disponibles_grande': grande,
  'precio_grande': precioGrande,
};

/// Catálogo base de las pruebas de carrito, pago e inicio.
final List<Map<String, dynamic>> catalogoPedidos = [
  filaCatalogo(
    1,
    'Pizza Pollo',
    1,
    precioGrande: '16000.00',
    stockPartes: '30',
    mediana: 10,
    grande: 7,
  ),
  filaCatalogo(2, 'Pizza Hawaiana', 1, precioGrande: 16000),
  filaCatalogo(
    4,
    'Pizza Peperoni',
    1,
    precioGrande: 16000,
    estado: 'No disponible',
  ),
  filaCatalogo(5, 'Lasaña Carne', 2, precio: '20000.00'),
  filaCatalogo(6, 'Lasaña Mixta', 2, precio: 21000, stock: '3'),
  filaCatalogo(7, 'Gaseosa Coca-Cola', 3, precio: '8000.00', stock: 5),
  filaCatalogo(8, 'Gaseosa Pepsi', 3, precio: 9000, estado: 'No disponible'),
];

List<ProductoCatalogo> catalogoComoProductos([
  List<Map<String, dynamic>>? filas,
]) => [for (final f in filas ?? catalogoPedidos) ProductoCatalogo.desdeApi(f)];

int _siguiente = 0;

/// Línea de carrito como la arma el detalle del producto.
CartItem lineaCarrito({
  required int idProducto,
  required String nombre,
  String tamano = 'Mediana',
  int precio = 14000,
  int cantidad = 1,
  List<CartAddition> adiciones = const [],
}) => CartItem(
  id: 'linea-${_siguiente++}',
  idProducto: idProducto,
  nombre: nombre,
  imagen: '',
  tamanoNombre: tamano,
  precioBase: precio,
  adiciones: [...adiciones],
  cantidad: cantidad,
);

CartAddition coca([int cantidad = 1]) => CartAddition(
  idProducto: 7,
  nombre: 'Gaseosa Coca-Cola',
  precio: 8000,
  cantidad: cantidad,
);
