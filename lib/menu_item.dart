class ProductSize {
  final String nombre;
  final int precio;
  const ProductSize({required this.nombre, required this.precio});
}

class ProductAddition {
  final String nombre;
  final String imagen;
  final int precio;
  const ProductAddition({
    required this.nombre,
    required this.imagen,
    required this.precio,
  });
}

class MenuItem {
  final String nombre;
  final String descripcion;
  final String imagen;
  final List<ProductSize> tamanos;
  final List<ProductAddition> adiciones;

  const MenuItem({
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.tamanos,
    this.adiciones = const [],
  });

  int get precioBase => tamanos.isNotEmpty ? tamanos.first.precio : 0;

  String get precioTexto => '\$${_formatoMiles(precioBase)}';
}

String _formatoMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}

// Adiciones de bebida compartidas por defecto en todos los productos.
const List<ProductAddition> bebidasDefault = [
  ProductAddition(
    nombre: 'Coca Cola',
    imagen: 'assets/img/Coca-Cola.png',
    precio: 3500,
  ),
  ProductAddition(
    nombre: 'Cuatro',
    imagen: 'assets/img/Quatro.png',
    precio: 3500,
  ),
  ProductAddition(
    nombre: 'Premium',
    imagen: 'assets/img/Premio.png',
    precio: 3500,
  ),
  ProductAddition(
    nombre: 'Pepsi',
    imagen: 'assets/img/Pepsi.png',
    precio: 3500,
  ),
];
