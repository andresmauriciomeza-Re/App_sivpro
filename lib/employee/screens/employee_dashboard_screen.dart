import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import 'employee_sales_management_screen.dart';
import 'employee_clients_screen.dart';
import '../../shared/page_transitions.dart';
import '../../auth/auth_service.dart';
import '../../client/screens/home_screen.dart' hide AppColors;

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
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Viernes, 18 De Septiembre De 2026',
                      style: GoogleFonts.poppins(color: muted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    _buildSalesSummary(),
                    const SizedBox(height: 26),
                    Text(
                      'ACCESOS RÁPIDOS',
                      style: GoogleFonts.poppins(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        const SizedBox(width: 14),
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
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Últimas ventas',
                          style: GoogleFonts.poppins(
                            color: ink,
                            fontSize: 22,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openSalesManagement(context),
                          child: Text(
                            'Ver todos  →',
                            style: GoogleFonts.poppins(
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
                style: GoogleFonts.montserrat(color: red, fontSize: 19),
              ),
              Text(
                'S.I.V.PRO',
                style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF1464F4),
                ),
              ),
              const Spacer(),
              _badge('+12%', const Color(0xFFE5FAF0), const Color(0xFF008C5A)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '24',
            style: GoogleFonts.poppins(color: ink, fontSize: 30),
          ),
          Text(
            'Ventas hoy',
            style: GoogleFonts.poppins(color: muted, fontSize: 13),
          ),
          Text(
            '+3 en la última hora',
            style: GoogleFonts.poppins(
              color: const Color(0xFFAAA09D),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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
                              style: GoogleFonts.poppins(
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFECE6E4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: EmployeeDashboardScreen.red, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
                  color: EmployeeDashboardScreen.muted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                sale.status,
                style: GoogleFonts.poppins(color: statusColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                sale.customer,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                sale.amount,
                style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
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
                style: GoogleFonts.poppins(
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
