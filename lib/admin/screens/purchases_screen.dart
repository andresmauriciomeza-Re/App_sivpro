import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_screen.dart';
import '../../auth/permisos.dart';
import '../../config/api_config.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/pending_sales_service.dart';
import '../../shared/search.dart';
import '../../shared/validators.dart';
import '../../theme/app_colors.dart';
import '../services/clients_repository.dart';
import '../services/indicators_service.dart';
import '../services/insumos_repository.dart';
import '../services/no_conformes_repository.dart';
import '../services/products_repository.dart';
import '../services/providers_repository.dart';
import '../services/production_repository.dart';
import '../services/purchases_repository.dart';
import '../services/sales_repository.dart';
import '../services/ventas_repository.dart';
import '../widgets/sales_pending_badge.dart';

part 'purchases/admin_profile.dart';
part 'purchases/clients.dart';
part 'purchases/indicators.dart';
part 'purchases/production.dart';
part 'purchases/products.dart';
part 'purchases/more_options.dart';
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
          style: FilledButton.styleFrom(backgroundColor: Color(0xFFC9151E)),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await AuthService.instance.logout();
    if (!context.mounted) return;
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

  final permitido = switch (index) {
    1 => Permisos.compras,
    2 => Permisos.produccion,
    3 => Permisos.ventasAdministracion,
    _ => true,
  };
  if (!permitido) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No tienes permiso para acceder a este módulo.'),
      ),
    );
    return;
  }

  final Widget destination = switch (index) {
    1 => const PurchasesScreen(),
    2 => const ProductionModulesScreen(),
    3 => const SalesScreen(),
    4 => const ProfileScreen(),
    _ => const PurchasesScreen(),
  };

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => route.isFirst,
  );
}

void openSalesManagement(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _SalesManagementScreen()));
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compras',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seleccione un módulo para administrar',
                      style: GoogleFonts.poppins(color: muted, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    if (Permisos.comprasCompra) ...[
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
                    ],
                    if (Permisos.comprasInsumos) ...[
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
                    ],
                    if (Permisos.comprasProveedores)
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
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final items = <(IconData, String, int)>[
      if (Permisos.dashboard) (Icons.home_outlined, 'Inicio', 0),
      if (Permisos.compras) (Icons.shopping_cart_outlined, 'Compras', 1),
      if (Permisos.produccion) (Icons.factory_outlined, 'Producción', 2),
      if (Permisos.ventasAdministracion)
        (Icons.receipt_long_outlined, 'Ventas', 3),
      (Icons.person_outline, 'Mi Perfil', 4),
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
          for (final item in items)
            GestureDetector(
              onTap: () => navigateToBottomModule(context, item.$3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminBottomNavIcon(
                    icon: item.$1,
                    color: item.$3 == 1 ? red : muted,
                    size: 27,
                    showPendingBadge: item.$3 == adminSalesNavIndex,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    style: GoogleFonts.poppins(
                      color: item.$3 == 1 ? red : muted,
                      fontSize: 12,
                      fontWeight: item.$3 == 1
                          ? FontWeight.w700
                          : FontWeight.w400,
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
        padding: const EdgeInsets.fromLTRB(25, 25, 18, 20),
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
                  child: Icon(icon, color: Colors.black87, size: 38),
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
