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
import '../../shared/modo_oscuro_controller.dart';
import '../../shared/modulos_moviles.dart';
import '../../shared/pending_sales_service.dart';
import '../../shared/search.dart';
import '../../shared/validators.dart';
import '../../shared/venta_motivos.dart';
import '../../theme/app_colors.dart';
import '../../theme/paleta_app.dart';
import '../services/clients_repository.dart';
import '../services/indicators_service.dart';
import '../services/insumos_repository.dart';
import '../services/no_conformes_repository.dart';
import '../services/products_repository.dart';
import '../services/producto_edicion.dart';
import '../services/providers_repository.dart';
import '../services/production_repository.dart';
import '../services/purchases_repository.dart';
import '../../shared/formato.dart';
import '../services/ventas_repository.dart';
import '../widgets/barra_navegacion_admin.dart';
import '../widgets/module_card.dart';
import '../widgets/period_selector.dart';
import '../../shared/tarjeta_modo_oscuro.dart';
import 'admin_dashboard_screen.dart';

part 'purchases/admin_profile.dart';
part 'purchases/clients.dart';
part 'purchases/indicators.dart';
part 'purchases/production.dart';
part 'purchases/products.dart';
part 'purchases/modules_menu.dart';
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
            backgroundColor: context.pal.rojoBoton(Color(0xFFC9151E)),
          ),
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
    3 => Permisos.moduloVentas,
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
    _rutaSinTransicion(destination),
    (route) => route.isFirst,
  );
}

/// Ruta sin transición para cambiar de módulo: la pantalla cambia al instante
/// y solo se ve deslizar la píldora de la barra inferior.
Route<T> _rutaSinTransicion<T>(Widget pagina) => PageRouteBuilder<T>(
  pageBuilder: (context, animation, secondaryAnimation) => pagina,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);

/// Abre Gestión Ventas; [estado] preselecciona el filtro por estado.
void openSalesManagement(BuildContext context, {EstadoVenta? estado}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _SalesManagementScreen(estadoInicial: estado),
    ),
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
      backgroundColor: context.pal.fondo(page),
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
                        color: context.pal.texto(ink),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seleccione un módulo para administrar',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(muted),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (Permisos.comprasCompra) ...[
                      ModuleCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Compras',
                        description: 'Consultar compras',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PurchaseManagementScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (Permisos.comprasInsumos) ...[
                      ModuleCard(
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
                      ModuleCard(
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

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 1);
}
