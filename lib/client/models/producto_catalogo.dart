import '../../shared/numeros.dart';

/// Sección del menú móvil a la que pertenece un producto del catálogo.
enum SeccionMenu { pizzas, lasanas, bebidas, otra }

/// Una sola etiqueta de estado por producto (como la web): "No disponible"
/// manda sobre todo; si está disponible pero sin stock, "Agotado".
enum EstadoMenu { disponible, agotado, noDisponible }

const String _conTilde = 'áéíóúüñ';
const String _sinTilde = 'aeiouun';

/// Nombre comparable: minúsculas, sin tildes, espacios simples y sin el
/// prefijo "pizza " (como la web al resolver favoritas e imágenes).
String normalizarNombreProducto(String nombre) {
  final buffer = StringBuffer();
  for (final rune in nombre.trim().toLowerCase().runes) {
    final caracter = String.fromCharCode(rune);
    final i = _conTilde.indexOf(caracter);
    buffer.write(i >= 0 ? _sinTilde[i] : caracter);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceFirst(RegExp(r'^pizza '), '');
}

/// Descripciones que la móvil ya mostraba (catálogo fijo), por nombre
/// normalizado. Tienen prioridad sobre las de la web.
const Map<String, String> _descripcionesMovil = {
  'canon':
      'Salsa de tomate casera, mozzarella fresca y albahaca del jardín. La '
      'pizza que nos hizo famosos.',
  'pepperoni carnes': 'Nuestra masa madre con pepperoni y mozzarella.',
  'de hawaii': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'de jamon con queso': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'maicitos': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'peperoni': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'pollo': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'tocineta': 'El sabor del sur de Italia, con anchoas y alcaparras.',
  'hawaiana': 'Jamón, piña asada y mozzarella extra.',
  'lasana de carne':
      'Nuestra lasaña artesanal preparada con capas de pasta fresca, carne '
      'de res seleccionada, salsa boloñesa de la casa y una mezcla secreta de '
      'quesos gratinados.',
  'lasana mixta':
      'Capas de vegetales frescos de temporada, salsa blanca casera y quesos '
      'gratinados.',
  'lasana pollo':
      'Capas de vegetales frescos de temporada, salsa blanca casera y quesos '
      'gratinados.',
};

/// Descripciones de la web (el backend no las trae), por nombre normalizado.
const Map<String, String> _descripcionesWeb = {
  'peperoni': 'Rodajas de peperoni sobre queso derretido.',
  'jamon': 'Peperoni y hierbas sobre queso derretido.',
  'hawaiana': 'Jamón y trozos de piña sobre queso derretido.',
  'pollo': 'Tiras de pollo y queso derretido con hierbas.',
  'canon': 'Trozos de jamón sobre queso derretido.',
  'maicitos': 'Granos de maíz sobre queso derretido con hierbas.',
  'paisa': 'Carne molida, trozos de carne y peperoni sobre queso derretido.',
  'tocineta': 'Trozos de tocineta sobre queso derretido.',
  'lasana carne': 'Capas de pasta con carne molida y queso gratinado.',
  'lasana pollo':
      'Lasaña de pollo con capas de pasta, salsa y queso gratinado.',
  'lasana mixta': 'Lasaña mixta con capas de pasta, salsa y queso gratinado.',
};

/// Fotos locales de la app por nombre normalizado (respaldo de la imagen).
const Map<String, String> _assetsLocales = {
  'canon': 'assets/img/pizza_cañon.png',
  'hawaiana': 'assets/img/pizza_hawaii.png',
  'de hawaii': 'assets/img/pizza_hawaii.png',
  'jamon': 'assets/img/pizza_jamon_queso.png',
  'de jamon con queso': 'assets/img/pizza_jamon_queso.png',
  'maicitos': 'assets/img/pizza_maicitos.png',
  'peperoni': 'assets/img/pizza_peperoni.png',
  'pollo': 'assets/img/pizza_pollo.png',
  'tocineta': 'assets/img/pizza_tocineta.png',
  'paisa': 'assets/img/pizza_carnes.png',
  'pepperoni carnes': 'assets/img/pizza_carnes.png',
  'lasana carne': 'assets/img/lasaña_carne.png',
  'lasana de carne': 'assets/img/lasaña_carne.png',
  'lasana mixta': 'assets/img/lasaña_mixta.png',
  'lasana pollo': 'assets/img/lasaña_pollo.png',
  'gaseosa coca-cola': 'assets/img/Coca-Cola.png',
  'coca cola': 'assets/img/Coca-Cola.png',
  'gaseosa cuatro': 'assets/img/Quatro.png',
  'cuatro': 'assets/img/Quatro.png',
  'gaseosa premium': 'assets/img/Premio.png',
  'premium': 'assets/img/Premio.png',
  'gaseosa pepsi': 'assets/img/Pepsi.png',
  'pepsi': 'assets/img/Pepsi.png',
};

/// Tamaño o presentación con su precio. En pizzas, el precio y las
/// unidades son por porción.
class TamanoProducto {
  const TamanoProducto({
    required this.nombre,
    required this.precio,
    this.disponibles,
  });

  final String nombre;
  final int precio;

  /// Unidades que se pueden pedir; null = sin límite (el backend no lo envía).
  final int? disponibles;

  bool get agotado => disponibles == 0;
}

/// Producto del menú del cliente, del catálogo real (`GET /productos`).
class ProductoCatalogo {
  const ProductoCatalogo({
    this.id,
    required this.nombre,
    required this.seccion,
    this.descripcion,
    this.tamanos = const [],
    required this.precioBase,
    this.disponible = true,
    this.stock,
    this.stockPartes,
    this.tieneImagen = false,
    this.galeria = const [],
    this.assetLocal,
  });

  /// `id_producto` real; null en los productos fijos de Inicio.
  final int? id;
  final String nombre;
  final SeccionMenu seccion;
  final String? descripcion;
  final List<TamanoProducto> tamanos;
  final int precioBase;

  /// `estado == 'Disponible'`; "No disponible" se muestra pero no se pide.
  final bool disponible;

  /// Stock general; null = sin límite (lasañas y elaborados pueden no tenerlo).
  final int? stock;

  /// Pizzas: partes preparadas (3 por porción Mediana, 4 por Grande), que
  /// comparten ambos tamaños; null = sin dato.
  final int? stockPartes;
  final bool tieneImagen;
  final List<String> galeria;
  final String? assetLocal;

  factory ProductoCatalogo.desdeApi(Map<String, dynamic> json) {
    final nombre = (json['nombre'] ?? '').toString().trim();
    final clave = normalizarNombreProducto(nombre);
    final seccion = _seccionDe(
      numeroTolerante(json['id_categoria'])?.toInt(),
      (json['categoria_nombre'] ?? '').toString(),
    );
    final precio = numeroTolerante(json['precio_venta'])?.round() ?? 0;
    final precioGrande = numeroTolerante(json['precio_grande'])?.round();
    final stock = _unidades(json['stock']);
    final imagenes = json['imagenes'];
    return ProductoCatalogo(
      id: numeroTolerante(json['id_producto'])?.toInt(),
      nombre: nombre,
      seccion: seccion,
      descripcion: _descripcionesMovil[clave] ?? _descripcionesWeb[clave],
      tamanos: switch (seccion) {
        SeccionMenu.pizzas => [
          TamanoProducto(
            nombre: 'Mediana',
            precio: precio,
            disponibles: _unidades(json['disponibles_mediana']),
          ),
          if (precioGrande != null)
            TamanoProducto(
              nombre: 'Grande',
              precio: precioGrande,
              disponibles: _unidades(json['disponibles_grande']),
            ),
        ],
        SeccionMenu.lasanas => [
          TamanoProducto(nombre: 'Normal', precio: precio, disponibles: stock),
        ],
        _ => const [],
      },
      precioBase: precio,
      disponible:
          (json['estado'] ?? '').toString().trim().toLowerCase() ==
          'disponible',
      stock: stock,
      stockPartes: _unidades(json['stock_partes']),
      tieneImagen: json['tiene_imagen'] == true,
      galeria: imagenes is List
          ? [
              for (final url in imagenes)
                if (url is String && url.trim().isNotEmpty) url.trim(),
            ]
          : const [],
      assetLocal: _assetsLocales[clave],
    );
  }

  bool get esPizza => seccion == SeccionMenu.pizzas;

  /// Lleva "Adiciones (Bebidas)" en el detalle (pizzas y lasañas, como hoy).
  bool get conAdiciones =>
      seccion == SeccionMenu.pizzas || seccion == SeccionMenu.lasanas;

  /// Límite del producto sin tamaño (como la web): en pizza con ambos
  /// tamaños informados, el de la Mediana; si no, el stock general.
  int? get limite {
    if (esPizza && tamanos.length == 2) {
      final mediana = tamanos.first.disponibles;
      if (mediana != null && tamanos.last.disponibles != null) return mediana;
    }
    return stock;
  }

  bool get agotado => limite == 0;

  EstadoMenu get estado => !disponible
      ? EstadoMenu.noDisponible
      : agotado
      ? EstadoMenu.agotado
      : EstadoMenu.disponible;

  /// Máximo a pedir con el tamaño elegido (pizza: porciones de ese tamaño).
  int? limiteDe(TamanoProducto? tamano) =>
      esPizza ? tamano?.disponibles : stock;
}

SeccionMenu _seccionDe(int? idCategoria, String categoria) {
  switch (idCategoria) {
    case 1:
      return SeccionMenu.pizzas;
    case 2:
      return SeccionMenu.lasanas;
    case 3:
      return SeccionMenu.bebidas;
  }
  final nombre = normalizarNombreProducto(categoria);
  if (nombre.contains('pizza')) return SeccionMenu.pizzas;
  if (nombre.contains('lasana')) return SeccionMenu.lasanas;
  if (nombre.contains('bebida')) return SeccionMenu.bebidas;
  return SeccionMenu.otra;
}

/// Unidades enteras no negativas; null (o negativo) = sin límite.
int? _unidades(dynamic valor) {
  final numero = numeroTolerante(valor);
  if (numero == null || numero < 0) return null;
  return numero.floor();
}
