import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/menu_item.dart';
import 'product_detail_screen.dart';
import '../widgets/bottom_nav.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.items,
  });

  final String categoryName;
  final List<MenuItem> items;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  static const Color fondoClaro = Color(0xFFFCF7F5);
  // ignore: unused_field
  static const Color descripcionColor = Color(0xFF2F6FED);

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)

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

  void _abrirDetalle(MenuItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoClaro,
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
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Text(
                    'Volver al menú',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.black87,
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
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.items.isEmpty
                  ? Center(
                      child: Text(
                        'Todavía no hay productos en esta categoría.',
                        style: GoogleFonts.poppins(color: Colors.black45),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: widget.items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.60,
                          ),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return _ProductGridCard(
                          item: item,
                          onTap: () => _abrirDetalle(item),
                        );
                      },
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

  final MenuItem item;
  final VoidCallback onTap;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Image.asset(
                      item.imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.local_pizza,
                          color: splashRojo,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.precioTexto,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: splashRojo,
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
