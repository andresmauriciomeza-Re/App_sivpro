import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/login_screen.dart';
import '../../shared/initials.dart';
import '../../shared/pending_sales_badge.dart';
import '../../shared/pending_sales_service.dart';
import '../../shared/orders_repository.dart';
import '../../client/models/order_model.dart' as client_order;
import '../../auth/auth_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/production_summary_card.dart';

part 'purchases/admin_profile.dart';
part 'purchases/clients.dart';
part 'purchases/more_options.dart';
part 'purchases/production.dart';
part 'purchases/products.dart';
part 'purchases/providers.dart';
part 'purchases/purchase_management.dart';
part 'purchases/sales.dart';
part 'purchases/supplies.dart';

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Está seguro de que desea cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Color(0xFFC9151E),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

void navigateToBottomModule(BuildContext context, int index) {
  if (index == 0) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  final Widget destination = switch (index) {
    1 => const PurchasesScreen(),
    2 => const _ProductionScreen(),
    3 => const SalesScreen(),
    4 => const MoreOptionsScreen(),
    _ => const PurchasesScreen(),
  };

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => route.isFirst,
  );
}

void openSalesManagement(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const _SalesManagementScreen()),
  );
}

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  static const Color red = Color(0xFFC62828);
  static const Color ink = Color(0xFF261B1A);
  static const Color muted = Color(0xFF6E5A58);
  static const Color page = Color(0xFFFFFBFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compras',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seleccione un módulo para administrar',
                      style: GoogleFonts.poppins(
                        color: muted,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _ModuleCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Compras',
                      description:
                          'Registrar y consultar órdenes de compra a proveedores.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PurchaseManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ModuleCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Insumos',
                      description:
                          'Control de inventario, stock bajo y actualización de unidades.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _SupplyManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ModuleCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Proveedores',
                      description:
                          'Directorio de contactos, estados e historial de distribuidores.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProviderManagementScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 28),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.red,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.person_outline, 'Mi Perfil'),
    ];
    return Container(
      padding: const EdgeInsets.only(top: 9, bottom: 8),
      decoration: const BoxDecoration(
        color: page,
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => navigateToBottomModule(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].$1,
                    color: i == 1 ? red : muted,
                    size: 27,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1 ? red : muted,
                      fontSize: 12,
                      fontWeight: i == 1 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 288,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 36, 26, 28),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8C7C4), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -72,
            right: -58,
            child: Container(
              width: 164,
              height: 164,
              decoration: const BoxDecoration(
                color: Color(0xFFF2C9CA),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9E8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: Colors.black87,
                  size: 38,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: PurchasesScreen.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.poppins(
                  color: PurchasesScreen.muted,
                  fontSize: 19,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

