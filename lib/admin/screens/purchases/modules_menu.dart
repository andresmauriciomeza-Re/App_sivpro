part of '../purchases_screen.dart';

/// Pantalla de inicio por permisos (Administrador y Empleado).
///
/// Con permiso de Dashboard se abre el Dashboard; si no, este menú con los
/// módulos que el backend le permite ver. Si no tiene ninguno, muestra el
/// aviso y deja acceso a Perfil y a cerrar sesión.
Widget adminHomeScreen() {
  if (Permisos.dashboard) return const AdminDashboardScreen();
  return const ModulesMenuScreen();
}

/// Menú de módulos para quien no tiene permiso de Dashboard.
class ModulesMenuScreen extends StatelessWidget {
  const ModulesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modulos = Permisos.modulos;
    // Empleado: sin las tarjetas Ventas (ya está en la barra) e Indicadores
    // (su contenido se muestra en este mismo Inicio).
    final esEmpleado = AuthService.instance.rol == UserRole.empleado;
    final tarjetas = <Widget>[
      if (modulos.contains(ModuloMovil.compras))
        ModuleCard(
          icon: Icons.shopping_cart_outlined,
          title: 'Compras',
          description: 'Compras, insumos y proveedores.',
          onTap: () => navigateToBottomModule(context, 1),
        ),
      if (modulos.contains(ModuloMovil.produccion))
        ModuleCard(
          icon: Icons.factory_outlined,
          title: 'Producción',
          description: 'Órdenes de producción y productos.',
          onTap: () => navigateToBottomModule(context, 2),
        ),
      if (!esEmpleado && modulos.contains(ModuloMovil.ventas))
        ModuleCard(
          icon: Icons.receipt_long_outlined,
          title: 'Ventas',
          description: 'Clientes y gestión de ventas.',
          onTap: () => navigateToBottomModule(context, 3),
        ),
      if (!esEmpleado && modulos.contains(ModuloMovil.indicadores))
        ModuleCard(
          icon: Icons.insights_outlined,
          title: 'Indicadores',
          description: 'Medición y desempeño de la gestión.',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const IndicatorsScreen())),
        ),
    ];

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              initials: currentUserInitials(),
            ),
            if (esEmpleado && modulos.contains(ModuloMovil.indicadores))
              Expanded(
                child: _IndicadoresContenido(
                  titulo: 'Inicio',
                  pie: [
                    for (final tarjeta in tarjetas) ...[
                      const SizedBox(height: 24),
                      tarjeta,
                    ],
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inicio',
                        style: GoogleFonts.montserrat(
                          color: context.pal.texto(PurchasesScreen.ink),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tarjetas.isEmpty
                            ? 'Tu rol no tiene módulos disponibles en la app móvil.'
                            : 'Seleccione un módulo',
                        style: GoogleFonts.poppins(
                          color: context.pal.secundario(PurchasesScreen.muted),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (final tarjeta in tarjetas) ...[
                        tarjeta,
                        const SizedBox(height: 24),
                      ],
                      if (tarjetas.isEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => navigateToBottomModule(context, 4),
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Mi Perfil'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _confirmSignOut(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: context.pal.rojoBoton(
                                PurchasesScreen.red,
                              ),
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar sesión'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const ModuleBottomNav(selected: 0),
          ],
        ),
      ),
    );
  }
}

/// Barra inferior única para Administrador y Empleado.
///
/// "Inicio" (vuelve a la raíz) y "Mi Perfil" siempre aparecen; Compras,
/// Producción y Ventas solo si el usuario tiene ese módulo. El ícono de
/// Ventas lleva el badge de ventas "Por verificar".
class ModuleBottomNav extends StatelessWidget {
  const ModuleBottomNav({super.key, required this.selected});

  /// 0 Inicio, 1 Compras, 2 Producción, 3 Ventas, 4 Mi Perfil.
  final int selected;

  @override
  Widget build(BuildContext context) {
    return BarraNavegacionAdmin(
      items: itemsBarraAdmin(Permisos.modulos),
      seleccionado: selected,
      // Tocar el ítem activo no hace nada, salvo Inicio (vuelve a la raíz).
      alTocar: (id) {
        if (id == selected && id != 0) return;
        navigateToBottomModule(context, id);
      },
    );
  }
}
