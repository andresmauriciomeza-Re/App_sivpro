import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import 'employee_sales_management_screen.dart';
import 'employee_clients_screen.dart';
import '../../shared/page_transitions.dart';
import '../../auth/auth_service.dart';
import '../../client/screens/home_screen.dart' hide AppColors;
import '../services/return_service.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF8C8583);
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
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Buenos días, María! 👋',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Viernes, 18 De Septiembre De 2026',
                      style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    _buildSalesSummary(),
                    const SizedBox(height: 16),
                    Text(
                      'ACCESOS RÁPIDOS',
                      style: GoogleFonts.dmSerifDisplay(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.point_of_sale_outlined,
                            label: 'Ventas',
                            subtitle: 'Cobrar orden',
                            onTap: () => _openSalesManagement(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.people_outline,
                            label: 'Clientes',
                            subtitle: 'Directorio',
                            onTap: () => _openClients(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Últimas ventas',
                          style: GoogleFonts.dmSerifDisplay(
                            color: ink,
                            fontSize: 22,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openSalesManagement(context),
                          child: Text(
                            'Ver todos  →',
                            style: GoogleFonts.dmSerifDisplay(
                              color: red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._sales.map((sale) => _SaleCard(sale: sale)),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La Sirena',
                style: GoogleFonts.dmSerifDisplay(color: red, fontSize: 19),
              ),
              Text(
                'S.I.V.PRO',
                style: GoogleFonts.dmSerifDisplay(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _goToStore(context),
            tooltip: 'Ir a la tienda',
            color: red,
            icon: const Icon(Icons.storefront, size: 26),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: Text(
              getInitials('María González'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToStore(BuildContext context) {
    AuthService.instance.startStoreSession();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget _buildSalesSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CompactStatCard(
            icon: Icons.shopping_bag_outlined,
            iconBg: AppColors.salesIconBg,
            iconColor: AppColors.salesIconFg,
            value: '24',
            label: 'Ventas hoy',
            subtext: '+3 en la última hora',
            badge: '+12%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CompactStatCard(
            icon: Icons.assignment_return_outlined,
            iconBg: AppColors.returnIconBg,
            iconColor: AppColors.returnIconFg,
            value: '$_devolucionesHoy',
            label: 'Devoluciones',
            subtext: 'pendientes por atender',
          ),
        ),
      ],
    );
  }

  static int get _devolucionesHoy =>
      ReturnService.instance.pendientes.length +
      ReturnService.instance.resueltas.length;

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
                        onTap: index == 0
                            ? null
                            : () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              index == 0 ? items[index].$2 : items[index].$1,
                              color: index == 0
                                  ? red
                                  : const Color(0xFF756D6A),
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$3,
                              style: GoogleFonts.dmSerifDisplay(
                                color: index == 0
                                    ? red
                                    : const Color(0xFF756D6A),
                                fontSize: 10,
                                height: 1,
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

  void _openSalesManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: kVentasModulesRoute),
        builder: (_) => const EmployeeSalesManagementScreen(),
      ),
    );
  }

  void _openClients(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: kClientesRoute),
        builder: (_) => const EmployeeClientsScreen(),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFECE6E4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: EmployeeDashboardScreen.red, size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: EmployeeDashboardScreen.ink,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSerifDisplay(
                color: EmployeeDashboardScreen.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subtext,
    this.badge,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String? subtext;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFECE6E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.dmSerifDisplay(
                      color: AppColors.badgeGreenFg,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.dmSerifDisplay(
                color: EmployeeDashboardScreen.ink,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              color: EmployeeDashboardScreen.muted,
              fontSize: 13,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.cardSubtext,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sale {
  const _Sale(
    this.id,
    this.customer,
    this.payment,
    this.time,
    this.amount,
    this.status,
  );

  final String id;
  final String customer;
  final String payment;
  final String time;
  final String amount;
  final String status;
}

const _sales = [
  _Sale(
    'VEN-2024-0156',
    'María González',
    'Nequi',
    '18:30',
    '\$144.000',
    'En preparación',
  ),
  _Sale(
    'VEN-2024-0155',
    'Carlos Martínez',
    'Efectivo',
    '18:15',
    '\$92.000',
    'Listo',
  ),
  _Sale(
    'VEN-2024-0154',
    'Ana Rodríguez',
    'Daviplata',
    '17:45',
    '\$110.000',
    'Entregado',
  ),
  _Sale(
    'VEN-2024-0153',
    'Jorge Vargas',
    'Bancolombia',
    '17:20',
    '\$156.000',
    'Listo',
  ),
  _Sale(
    'VEN-2024-0152',
    'Patricia Soto',
    'Nequi',
    '16:50',
    '\$80.000',
    'Entregado',
  ),
];

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final _Sale sale;

  @override
  Widget build(BuildContext context) {
    final statusColor = sale.status == 'En preparación'
        ? const Color(0xFF2F6FE0)
        : sale.status == 'Listo'
        ? const Color(0xFF008C5A)
        : EmployeeDashboardScreen.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE6E4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                sale.id,
                style: GoogleFonts.dmSerifDisplay(
                  color: EmployeeDashboardScreen.muted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                sale.status,
                style: GoogleFonts.dmSerifDisplay(color: statusColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                sale.customer,
                style: GoogleFonts.dmSerifDisplay(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                sale.amount,
                style: GoogleFonts.dmSerifDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                color: EmployeeDashboardScreen.muted,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                sale.payment,
                style: GoogleFonts.dmSerifDisplay(
                  color: EmployeeDashboardScreen.muted,
                  fontSize: 12,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('·', style: TextStyle(color: Color(0xFFBDB5B3))),
              ),
              Icon(
                Icons.access_time,
                color: EmployeeDashboardScreen.muted,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                sale.time,
                style: GoogleFonts.dmSerifDisplay(
                  color: EmployeeDashboardScreen.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
