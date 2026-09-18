import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_service.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';

// ============================================================
// Barra de navegación inferior ÚNICA para toda la app.
// Se usa en Inicio, Menú, Carrito, Mis pedidos, Detalle de
// pedido y Perfil, para que siempre se vea exactamente igual:
// mismos íconos, mismo orden, mismo tamaño y mismo estilo.
// ============================================================

const Color kSplashRojo = Color(0xE6C32828);

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  /// 0 = Inicio, 1 = Menú, 2 = Carrito, 3 = Mis pedidos, 4 = Perfil
  final int currentIndex;

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
    ),
    _NavItemData(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: 'Menú',
    ),
    _NavItemData(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Carrito',
    ),
    _NavItemData(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Pedidos',
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, noAnimationRoute(const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, noAnimationRoute(const MenuScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, noAnimationRoute(const CartScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          noAnimationRoute(const MyOrdersScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          noAnimationRoute(const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, _) {
              return Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _buildNavItem(context, i),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final _NavItemData item = _items[index];
    final bool isActive = index == currentIndex;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => _onTap(context, index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isActive ? kSplashRojo : Colors.transparent,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(item, isActive, index),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_NavItemData item, bool isActive, int index) {
    final IconData icon = isActive ? item.activeIcon : item.icon;
    final Widget icono = Icon(
      icon,
      size: 22,
      color: isActive ? Colors.white : Colors.black38,
    );

    if (index != 2) return icono;

    final int total = CartService.instance.totalArticulos;
    if (total <= 0) return icono;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icono,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : kSplashRojo,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              total > 99 ? '99+' : '$total',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? kSplashRojo : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ============================================================
// Ruta sin animación: para que el cambio Inicio <-> Menú
// se sienta instantáneo, como el cambio de tab de un bottom nav.
// Pública para que cualquier pantalla la reutilice.
// ============================================================
Route<T> noAnimationRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
