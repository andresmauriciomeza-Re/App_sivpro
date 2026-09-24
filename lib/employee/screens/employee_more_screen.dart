import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../theme/app_colors.dart';
import '../services/employee_profile_service.dart';
import 'employee_profile_screen.dart';
import '../../shared/page_transitions.dart';

/// Pantalla "Más" del rol Empleado (réplica de la del Administrador, sin
/// "Reportes e Informes" y con los datos del empleado en sesión).
class EmployeeMoreScreen extends StatelessWidget {
  const EmployeeMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = EmployeeProfileService.instance.profile;
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, profile),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _optionsCard(context, profile),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'La Sirena Pizza – S.I.V.PRO',
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Versión 2.1.4',
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.muted,
                          fontSize: 11,
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
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: profile.initials,
    );
  }

  Widget _optionsCard(BuildContext context, EmployeeProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.page,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.initials,
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Empleado',
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.profileChipBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'S.I.V.PRO',
                          style: GoogleFonts.dmSerifDisplay(
                            color: AppColors.muted,
                            fontSize: 11,
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
              MaterialPageRoute(
                settings: const RouteSettings(
                  name: kEmployeeProfileDetailRoute,
                ),
                builder: (_) => const EmployeeProfileScreen(),
              ),
            ),
          ),
          InkWell(
            onTap: () => confirmEmployeeSignOut(context),
            child: Container(
              height: 52,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: AppColors.red, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.dmSerifDisplay(
                      color: AppColors.red,
                      fontSize: 15,
                    ),
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
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.muted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSerifDisplay(
                  color: AppColors.ink,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.people_outline, 'Clientes'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.sync_alt, 'Devoluciones'),
      (Icons.person_outline, 'Perfil'),
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
                  top: BorderSide(color: AppColors.red, width: 1),
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
                              items[index].$1,
                              color: index == 4
                                  ? AppColors.red
                                  : AppColors.muted,
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.dmSerifDisplay(
                                color: index == 4
                                    ? AppColors.red
                                    : AppColors.muted,
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