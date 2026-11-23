import 'package:flutter/foundation.dart';

import '../../network/api_client.dart';
import '../models/producto_catalogo.dart';

/// Catálogo público del menú (`GET /productos`, sin token), con caché corta.
class CatalogoRepository {
  CatalogoRepository._();

  static final CatalogoRepository instance = CatalogoRepository._();

  static const Duration vigencia = Duration(minutes: 3);

  /// Reloj de la caché; las pruebas lo adelantan.
  @visibleForTesting
  DateTime Function() reloj = DateTime.now;

  List<ProductoCatalogo>? _productos;
  DateTime? _cargadoEn;
  Future<List<ProductoCatalogo>>? _cargando;

  /// Productos del catálogo; con [recargar] (jalar para refrescar) o caché
  /// vencida se vuelven a pedir. Los errores llegan como `ApiException`.
  Future<List<ProductoCatalogo>> productos({bool recargar = false}) {
    final guardados = _productos;
    final cargadoEn = _cargadoEn;
    if (!recargar &&
        guardados != null &&
        cargadoEn != null &&
        reloj().difference(cargadoEn) < vigencia) {
      return Future.value(guardados);
    }
    return _cargando ??= _cargar().whenComplete(() => _cargando = null);
  }

  Future<List<ProductoCatalogo>> _cargar() async {
    final data = await ApiClient.instance.get('/productos', auth: false);
    final productos = <ProductoCatalogo>[
      if (data is List)
        for (final fila in data)
          if (fila is Map<String, dynamic>) ProductoCatalogo.desdeApi(fila),
    ].where((p) => p.nombre.isNotEmpty).toList(growable: false);
    _productos = productos;
    _cargadoEn = reloj();
    return productos;
  }

  /// Se olvida al terminar la sesión.
  void limpiar() {
    _productos = null;
    _cargadoEn = null;
  }
}

/// Favoritas: el backend no las tiene. Lista fija (los productos que la
/// sección Favoritas de la móvil mostraba) resuelta contra el catálogo real
/// por nombre normalizado; las que no existan se omiten.
const List<String> favoritasMenu = [
  'Pizza Pollo',
  'Pizza Hawaiana',
  'Pizza Maicitos',
  'Pizza Peperoni',
];

/// Títulos de las secciones del menú móvil, en su orden (son también los
/// botones de filtro, junto con "Todas").
const String seccionPizzas = 'Pizzas';
const String seccionLasanas = 'Lasañas';
const String seccionFavoritas = 'Favoritas';

/// Secciones del menú móvil: Pizzas, Lasañas y Favoritas (sin Bebidas: las
/// bebidas son adiciones del detalle). Otras categorías no se muestran.
Map<String, List<ProductoCatalogo>> seccionesMenu(
  List<ProductoCatalogo> productos,
) => {
  seccionPizzas: _ordenar(
    productos.where((p) => p.seccion == SeccionMenu.pizzas),
  ),
  seccionLasanas: _ordenar(
    productos.where((p) => p.seccion == SeccionMenu.lasanas),
  ),
  seccionFavoritas: _ordenar(resolverFavoritas(productos)),
};

List<ProductoCatalogo> resolverFavoritas(List<ProductoCatalogo> productos) => [
  for (final nombre in favoritasMenu)
    ?productos
        .where(
          (p) =>
              p.seccion != SeccionMenu.bebidas &&
              normalizarNombreProducto(p.nombre) ==
                  normalizarNombreProducto(nombre),
        )
        .firstOrNull,
];

/// Bebidas del catálogo: son las adiciones del detalle de pizzas y lasañas.
List<ProductoCatalogo> bebidasDe(List<ProductoCatalogo> productos) => [
  for (final p in productos)
    if (p.seccion == SeccionMenu.bebidas) p,
];

/// Primero los que se pueden pedir y al final los "No disponible",
/// conservando el orden original dentro de cada grupo.
List<ProductoCatalogo> _ordenar(Iterable<ProductoCatalogo> productos) => [
  ...productos.where((p) => p.disponible),
  ...productos.where((p) => !p.disponible),
];
