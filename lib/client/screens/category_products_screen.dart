import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/catalogo_repository.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/imagen_producto.dart';
import 'product_detail_screen.dart';
import '../widgets/bottom_nav.dart';

class CategoryProductsScreen extends StatelessWidget {
  /// Una sección del catálogo real (Pizzas, Lasañas o Favoritas).
  const CategoryProductsScreen.catalogo({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  Widget build(BuildContext context) =>
      TemaCliente(child: _Categoria(categoryName: categoryName));
}

/// Cuerpo de la sección, bajo [TemaCliente] para que `context.pal` vea su
/// tema.
class _Categoria extends StatefulWidget {
  const _Categoria({required this.categoryName});

  final String categoryName;

  @override
  State<_Categoria> createState() => _CategoriaState();
}

class _CategoriaState extends State<_Categoria> {
  static const Color fondoClaro = Color(0xFFFCF7F5);
  static const Color splashRojo = Color(0xE6C32828);

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)
  List<ProductoCatalogo>? _productos;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool recargar = false}) async {
    try {
      final productos = await CatalogoRepository.instance.productos(
        recargar: recargar,
      );
      if (!mounted) return;
      setState(() {
        _productos = seccionesMenu(productos)[widget.categoryName] ?? const [];
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (_productos != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
      setState(() => _error = error.message);
    }
  }

  void _reintentar() {
    setState(() => _error = null);
    _cargar(recargar: true);
  }

  String get _descripcion {
    switch (widget.categoryName) {
      case 'Pizzas':
        return 'Nuestras recetas tradicionales, preparadas con ingredientes '
            'frescos y la auténtica masa artesanal de La Sirena. El sabor '
            'de siempre, como nunca antes.';
      case 'Lasañas':
        return 'Capas de pasta fresca, salsas caseras y quesos gratinados. '
            'Nuestra receta italiana con el toque artesanal de La Sirena.';
      case 'Favoritas':
        return 'Las creaciones más pedidas por nuestros clientes. '
            'Combinaciones únicas que se ganaron un lugar especial en el '
            'menú.';
      default:
        return 'Descubre todos los productos de esta categoría.';
    }
  }

  void _abrirDetalle(ProductoCatalogo item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(producto: item)),
    );
  }

  Widget _buildContenido() {
    final pal = context.pal;
    final productos = _productos;
    final error = _error;
    if (productos == null && error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: pal.secundario(Colors.black54)),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _reintentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: pal.rojoBoton(splashRojo),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }
    if (productos == null) {
      return Center(
        child: CircularProgressIndicator(color: pal.rojo(splashRojo)),
      );
    }
    if (productos.isEmpty) {
      return Center(
        child: Text(
          'Todavía no hay productos en esta categoría.',
          style: GoogleFonts.poppins(color: pal.atenuado(Colors.black45)),
        ),
      );
    }
    // Con letra del sistema más grande, la tarjeta crece en alto para que el
    // texto no se desborde; con letra normal conserva su proporción.
    final escala = MediaQuery.textScalerOf(context).scale(1);
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: productos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: escala <= 1 ? 0.60 : 0.60 / (1 + (escala - 1) * 0.3),
      ),
      itemBuilder: (context, index) {
        final item = productos[index];
        return _ProductGridCard(item: item, onTap: () => _abrirDetalle(item));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final contenido = _buildContenido();
    return Scaffold(
      backgroundColor: pal.fondo(fondoClaro),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  Text(
                    'Volver al menú',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _descripcion,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: pal.texto(Colors.black87),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: pal.rojo(splashRojo),
                onRefresh: () => _cargar(recargar: true),
                child: contenido,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.item, required this.onTap});

  final ProductoCatalogo item;
  final VoidCallback onTap;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final descripcion = item.descripcion;
    final imagen = AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: pal.campo(Colors.grey.shade100),
        child: ImagenProducto(
          producto: item,
          fit: BoxFit.cover,
          respaldo: (context) => Container(
            color: pal.campo(Colors.grey.shade200),
            child: Icon(
              Icons.local_pizza,
              color: pal.rojo(splashRojo),
              size: 32,
            ),
          ),
        ),
      ),
    );
    return Material(
      color: pal.tarjeta(Colors.white),
      // En oscuro, borde fino en lugar de sombra.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pal.oscuro
            ? const BorderSide(color: PaletaApp.bordeOscuro)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: pal.sombra(Colors.black.withValues(alpha: 0.05)),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                // Solo se marca lo que no se puede pedir; la foto se atenúa
                // si está "No disponible".
                child: switch (item.estado) {
                  EstadoMenu.disponible => imagen,
                  final estado => Stack(
                    children: [
                      estado == EstadoMenu.noDisponible
                          ? Opacity(opacity: 0.5, child: imagen)
                          : imagen,
                      Positioned(
                        top: 8,
                        right: 8,
                        child: EtiquetaEstado(estado: estado),
                      ),
                    ],
                  ),
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descripcion ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: formatCop(item.precioBase),
                                children: [
                                  // Las pizzas se venden por porción.
                                  if (item.esPizza)
                                    TextSpan(
                                      text: ' / porción',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: pal.secundario(Colors.black54),
                                      ),
                                    ),
                                ],
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: pal.texto(Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: pal.rojoBoton(splashRojo),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
