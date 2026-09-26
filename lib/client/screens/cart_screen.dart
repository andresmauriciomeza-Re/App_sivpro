import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_screen.dart';
import '../services/cart_service.dart';
import 'payment_method_screen.dart';
import '../widgets/bottom_nav.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cart = CartService.instance;

        return Scaffold(
          backgroundColor: fondoClaro,
          body: SafeArea(
            child: cart.estaVacio
                ? _buildEmptyState(context)
                : _buildItemsState(context, cart),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 2),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // Estado 1: carrito vacío
  // ----------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'La Sirena',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: splashRojo.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu carrito está vacío',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega algunas pizzas deliciosas para comenzar tu pedido',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          noAnimationRoute(const MenuScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: splashRojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Ver el menú',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // Estado 2: carrito con productos
  // ----------------------------------------------------------
  Widget _buildItemsState(BuildContext context, CartService cart) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 20, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              Text(
                'Carrito',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(item: item);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '\$${formatoMiles(cart.subtotal)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${formatoMiles(cart.total)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: splashRojo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Ir a pagar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagen,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.local_pizza,
                  color: splashRojo,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Size: ${item.tamanoNombre}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
                if (item.adicionesTexto.isNotEmpty)
                  Text(
                    'Additions: ${item.adicionesTexto}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stepButton(
                      icon: Icons.remove,
                      onTap: () => CartService.instance.updateQuantity(
                        item.id,
                        item.cantidad - 1,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.cantidad}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _stepButton(
                      icon: Icons.add,
                      onTap: () => CartService.instance.updateQuantity(
                        item.id,
                        item.cantidad + 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => CartService.instance.removeItem(item.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: splashRojo,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 14),
              Text(
                '\$${formatoMiles(item.subtotal)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: splashRojo.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: splashRojo),
      ),
    );
  }
}