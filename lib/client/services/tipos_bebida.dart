// Clasificación de las bebidas del menú. EDITA SOLO ESTE ARCHIVO para
// cambiar qué bebida va en cada filtro o cuáles salen primero.
//
// PROVISIONAL: el backend no envía el tipo de bebida (`GET /productos` solo
// trae la categoría "Bebidas"), así que se deduce de palabras del nombre.
// Cuando el backend mande ese dato, `tipoDeBebida` debe leerlo de ahí.
import '../models/producto_catalogo.dart';

/// Filtros de la pantalla "Bebidas", en el orden de los botones.
enum TipoBebida {
  gaseosas('Gaseosas'),
  agua('Agua'),
  energizantes('Energizantes'),
  cervezas('Cervezas'),
  otras('Otras');

  const TipoBebida(this.etiqueta);

  final String etiqueta;
}

/// Palabras completas, en minúscula, sin tildes ni "ñ". Se revisan en este
/// orden: la primera lista que coincida gana.
const Map<TipoBebida, List<String>> _palabras = {
  TipoBebida.cervezas: [
    'cerveza',
    'aguila',
    'poker',
    'club colombia',
    'corona',
    'heineken',
    'pilsen',
    'costena',
  ],
  TipoBebida.energizantes: [
    'energizante',
    'red bull',
    'redbull',
    'monster',
    'vive 100',
    'speed max',
  ],
  TipoBebida.agua: ['agua', 'cristal', 'brisa'],
  TipoBebida.gaseosas: [
    'gaseosa',
    'coca',
    'pepsi',
    'cuatro',
    'quatro',
    'premio',
    'premium',
    'postobon',
    'sprite',
    'fanta',
    'colombiana',
    '7up',
    'soda',
  ],
};

TipoBebida tipoDeBebida(String nombre) {
  final limpio = normalizarNombreProducto(nombre);
  for (final MapEntry(key: tipo, value: palabras) in _palabras.entries) {
    if (palabras.any(
      (p) => RegExp('\\b${RegExp.escape(p)}\\b').hasMatch(limpio),
    )) {
      return tipo;
    }
  }
  return TipoBebida.otras;
}

/// Las que se ven en el detalle de la pizza, en este orden. Cada una admite
/// los nombres con que puede venir del catálogo.
const List<List<String>> _destacadas = [
  ['gaseosa coca-cola', 'coca-cola', 'coca cola', 'gaseosa coca cola'],
  ['gaseosa pepsi', 'pepsi'],
  ['gaseosa cuatro', 'cuatro', 'gaseosa quatro', 'quatro'],
  ['gaseosa premio', 'premio', 'gaseosa premium', 'premium'],
];

/// Coca-Cola, Pepsi, Cuatro y Premio; si alguna no está en el catálogo, se
/// completa con las siguientes bebidas disponibles.
List<ProductoCatalogo> bebidasDestacadas(
  List<ProductoCatalogo> bebidas, {
  int cuantas = 4,
}) {
  final elegidas = <ProductoCatalogo>[
    for (final nombres in _destacadas)
      ?bebidas
          .where((b) => nombres.contains(normalizarNombreProducto(b.nombre)))
          .firstOrNull,
  ];
  for (final bebida in bebidas) {
    if (elegidas.length >= cuantas) break;
    if (bebida.estado == EstadoMenu.disponible && !elegidas.contains(bebida)) {
      elegidas.add(bebida);
    }
  }
  return elegidas;
}
