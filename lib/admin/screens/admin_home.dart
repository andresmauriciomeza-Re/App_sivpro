import 'package:material_ui/material_ui.dart';

import '../../auth/permisos.dart';
import 'admin_dashboard_screen.dart';
import 'purchases_screen.dart';

/// Pantalla inicial del administrador según su permiso de Dashboard.
///
/// Si no puede ver el Dashboard, entra al primer módulo que sí tenga
/// permitido en lugar de mostrar información que el backend le negaría.
Widget adminHomeScreen() {
  if (Permisos.dashboard) return const AdminDashboardScreen();
  if (Permisos.compras) return const PurchasesScreen();
  if (Permisos.produccion) return const ProductionModulesScreen();
  if (Permisos.ventasAdministracion) return const SalesScreen();
  return const ProfileScreen();
}