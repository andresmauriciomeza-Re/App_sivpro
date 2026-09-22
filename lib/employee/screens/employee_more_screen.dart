import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/employee_profile_service.dart';
import 'employee_profile_screen.dart';
import '../../shared/page_transitions.dart';

/// Pantalla "Más" del rol Empleado (réplica de la del Administrador, sin
/// "Reportes e Informes" y con los datos del empleado en sesión).
class EmployeeMoreScreen extends StatelessWidget {
  const EmployeeMoreScreen({super.key});

  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF6E5A58);
  static const Color page = Color(0xFFFFFBFA);

  @override
  Widget build(BuildContext context) {
    final profile = EmployeeProfileService.instance.profile;
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, profile),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Más opciones',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 38),
                    _optionsCard(context, profile),
                    const SizedBox(height: 48),
                    Center(
                      child: Text(
                        'La Sirena Pizza – S.I.V.PRO',
                        style: GoogleFonts.poppins(color: muted, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Versión 2.1.4',
                        style: GoogleFonts.robotoMono(
                          color: muted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, EmployeeProfile profile) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: muted, size: 29),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: red,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              profile.initials,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionsCard(BuildContext context, EmployeeProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: page,
        border: Border.all(color: const Color(0xFFE5BDB9)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 38, 24, 34),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: GoogleFonts.poppins(
                          color: ink,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Empleado',
                        style: GoogleFonts.poppins(
                          color: muted,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E2E1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'S.I.V.PRO',
                          style: GoogleFonts.poppins(
                            color: muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _optionTile(
            icon: Icons.person_outline,
            title: 'Perfil',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmployeeProfileScreen()),
            ),
          ),
          InkWell(
            onTap: () => confirmEmployeeSignOut(context),
            child: Container(
              height: 84,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: red, size: 31),
                  const SizedBox(width: 25),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.poppins(color: red, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
        ),
        child: Row(
          children: [
            Icon(icon, color: muted, size: 29),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: ink, fontSize: 20),
              ),
            ),
            const Icon(Icons.chevron_right, color: muted, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.more_horiz, 'Más'),
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
                        onTap: index == 4
                            ? null
                            : () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              index == 4 ? Icons.more_horiz : items[index].$1,
                              color: index == 4 ? red : muted,
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.poppins(
                                color: index == 4 ? red : muted,
                                fontSize: 10,
                                height: 1,
                                fontWeight: index == 4
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