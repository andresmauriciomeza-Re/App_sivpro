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
    precio: 8000,
  ),
  ProductAddition(
    nombre: 'Cuatro',
    imagen: 'assets/img/Quatro.png',
    precio: 7000,
  ),
  ProductAddition(
    nombre: 'Premium',
    imagen: 'assets/img/Premio.png',
    precio: 7500,
  ),
  ProductAddition(
    nombre: 'Pepsi',
    imagen: 'assets/img/Pepsi.png',
    precio: 9400,
  ),
];

// Productos de cada categoría del menú, compartidos entre pantallas.
final Map<String, List<MenuItem>> categoriasMenu = {
  'Pizzas': [
    const MenuItem(
      nombre: 'Pizza Cañon',
      descripcion:
          'Salsa de tomate casera, mozzarella fresca y albahaca del jardín. La pizza que nos hizo famosos.',
      imagen: 'assets/img/pizza_cañon.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),
    const MenuItem(
      nombre: 'Pepperoni Carnes',
      descripcion: 'Nuestra masa madre con pepperoni y mozzarella.',
      imagen: 'assets/img/pizza_carnes.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),
    const MenuItem(
      nombre: 'Pizza de hawaii',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_hawaii.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza de Jamon con Queso',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_jamon_queso.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Maicitos',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_maicitos.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Peperoni',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_peperoni.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Pollo',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_pollo.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Tocineta',
      descripcion: 'El sabor del sur de Italia, con anchoas y alcaparras.',
      imagen: 'assets/img/pizza_tocineta.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),
  ],
  'Lasañas': [
    const MenuItem(
      nombre: 'Lasaña de Carne',
      descripcion:
          'Nuestra lasaña artesanal preparada con capas de pasta fresca, carne de res seleccionada, salsa boloñesa de la casa y una mezcla secreta de quesos gratinados.',
      imagen: 'assets/img/lasaña_carne.png',
      tamanos: [ProductSize(nombre: 'Normal', precio: 20000)],
      adiciones: bebidasDefault,
    ),
    const MenuItem(
      nombre: 'Lasaña Mixta',
      descripcion:
          'Capas de vegetales frescos de temporada, salsa blanca casera y quesos gratinados.',
      imagen: 'assets/img/lasaña_mixta.png',
      tamanos: [ProductSize(nombre: 'Normal', precio: 20000)],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Lasaña Mixta',
      descripcion:
          'Capas de vegetales frescos de temporada, salsa blanca casera y quesos gratinados.',
      imagen: 'assets/img/lasaña_pollo.png',
      tamanos: [ProductSize(nombre: 'Normal', precio: 20000)],
      adiciones: bebidasDefault,
    ),
  ],
  'Favoritas': [
    const MenuItem(
      nombre: 'Pizza Pollo',
      descripcion:
          'Nuestra pizza insignia. Camarones al ajillo, queso crema, mozzarella, tomate cherry y rúcula fresca.',
      imagen: 'assets/img/pizza_pollo.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),
    const MenuItem(
      nombre: 'Pizza Hawaiana',
      descripcion: 'Jamón, piña asada y mozzarella extra.',
      imagen: 'assets/img/pizza_hawaii.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Maicitos',
      descripcion: 'Jamón, piña asada y mozzarella extra.',
      imagen: 'assets/img/pizza_maicitos.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),

    const MenuItem(
      nombre: 'Pizza Peperoni',
      descripcion: 'Jamón, piña asada y mozzarella extra.',
      imagen: 'assets/img/pizza_peperoni.png',
      tamanos: [
        ProductSize(nombre: 'Mediano', precio: 14000),
        ProductSize(nombre: 'Grande', precio: 16000),
      ],
      adiciones: bebidasDefault,
    ),
  ],
};
