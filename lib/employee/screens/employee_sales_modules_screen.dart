import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import 'employee_clients_screen.dart';
import 'employee_returns_screen.dart';
import 'employee_sales_management_screen.dart';

class EmployeeSalesModulesScreen extends StatelessWidget {
  const EmployeeSalesModulesScreen({super.key});

  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF766B68);
  static const Color page = Color(0xFFFCF9F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Inicio',
                          style: GoogleFonts.dmSerifDisplay(
                            color: muted,
                            fontSize: 10,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.chevron_right,
                            color: muted,
                            size: 13,
                          ),
                        ),
                        Text(
                          'Ventas',
                          style: GoogleFonts.dmSerifDisplay(color: red, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ventas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Seleccione el módulo que desea gestionar.',
                      style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 11),
                    ),
                    const SizedBox(height: 18),
                    _ModuleCard(
                      icon: Icons.person,
                      title: 'Clientes',
                      description: 'Administrar base de clientes',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EmployeeClientsScreen(),
                          ),
                        );
                      },
                    ),
                    _ModuleCard(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Ventas',
                      description: 'Registro y control de pedidos',
                      selected: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const EmployeeSalesManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _ModuleCard(
                      icon: Icons.sync_alt,
                      title: 'Devoluciones',
                      description: 'Gestión de garantías y reembolsos',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EmployeeReturnsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      initials: getInitials('María González'),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home, 'Inicio'),
      (Icons.people_outline, Icons.people, 'Clientes'),
      (Icons.receipt_long_outlined, Icons.receipt_long, 'Ventas'),
      (Icons.sync_alt, Icons.sync_alt, 'Devoluciones'),
      (Icons.person_outline, Icons.person, 'Perfil'),
    ];

    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: red, width: 1),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: InkWell(
                        onTap: () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              index == 2 ? items[index].$2 : items[index].$1,
                              color: index == 2 ? red : muted,
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$3,
                              style: GoogleFonts.dmSerifDisplay(
                                color: index == 2 ? red : muted,
                                fontSize: 10,
                                height: 1,
                                fontWeight: index == 2
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
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
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF7F7) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? EmployeeSalesModulesScreen.red.withValues(alpha: 0.35)
                    : const Color(0xFFF0DAD7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? EmployeeSalesModulesScreen.red
                        : const Color(0xFFF2F1F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? Colors.white
                        : EmployeeSalesModulesScreen.red,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSerifDisplay(
                          color: EmployeeSalesModulesScreen.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.dmSerifDisplay(
                          color: EmployeeSalesModulesScreen.muted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
