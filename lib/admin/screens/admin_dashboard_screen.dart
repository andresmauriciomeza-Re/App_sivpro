import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';
import '../../client/screens/home_screen.dart' hide AppColors;
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../widgets/production_summary_card.dart';
import 'purchases_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const Color red = AppColors.red;
  static const Color ink = AppColors.ink;
  static const Color muted = AppColors.muted;
  static const Color page = AppColors.page;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Map<String, List<int>> _salesValues = {
    'Hoy': [40, 115, 350, 280, 145, 420, 175],
    '7 días': [180, 260, 240, 340, 310, 430, 390],
    '30 días': [350, 300, 410, 330],
  };

  static const Map<String, List<String>> _salesLabels = {
    'Hoy': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00'],
    '7 días': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
    '30 días': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'],
  };

  String _selectedPeriod = 'Hoy';

  Color get red => AdminDashboardScreen.red;
  Color get ink => AdminDashboardScreen.ink;
  Color get muted => AdminDashboardScreen.muted;
  Color get page => AdminDashboardScreen.page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido, Admin! 👋',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 29,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resumen del día — jueves 20 de agosto de 2026',
                      style: GoogleFonts.poppins(color: muted, fontSize: 15),
                    ),
                    const SizedBox(height: 34),
                    _buildSummaryGrid(),
                    const SizedBox(height: 34),
                    _buildSalesCard(),
                    const SizedBox(height: 34),
                    const ProductionSummaryCard(),
                    const SizedBox(height: 34),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actividad reciente',
                          style: GoogleFonts.poppins(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => openSalesManagement(context),
                          child: Text(
                            'Ver todos  →',
                            style: GoogleFonts.poppins(
                              color: red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._recentSales.map(_buildRecentSale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(
              color: red,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Ir a la tienda',
            onPressed: _goToStore,
            icon: Icon(Icons.storefront, color: red, size: 26),
          ),
          const SizedBox(width: 4),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(color: red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToStore() {
    AuthService.instance.startStoreSession();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SummaryCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Compras hoy',
          value: '\$842.000',
          badge: '↗ +5%',
          badgeColor: Color(0xFFE5F4E8),
        ),
        _SummaryCard(
          icon: Icons.inventory_2_outlined,
          title: 'Insumos en stock',
          value: '142',
          badge: '⚠ Bajo',
          badgeColor: Color(0xFFFFF0D8),
          badgeTextColor: Color(0xFFE47C00),
        ),
        _SummaryCard(
          icon: Icons.local_pizza_outlined,
          title: 'Pedidos hoy',
          value: '86',
          badge: '↗ +12%',
          badgeColor: Color(0xFFE5F4E8),
        ),
        _SummaryCard(
          icon: Icons.attach_money,
          title: 'Ventas hoy',
          value: '\$1.248.000',
          badge: '↗ +8%',
          badgeColor: Color(0xFFE5F4E8),
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildSalesCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 14, 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Ventas',
                style: GoogleFonts.poppins(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _periodChip(
                'Hoy',
                onTap: () => setState(() => _selectedPeriod = 'Hoy'),
                selected: _selectedPeriod == 'Hoy',
              ),
              const SizedBox(width: 8),
              _periodChip(
                '7 días',
                onTap: () => setState(() => _selectedPeriod = '7 días'),
                selected: _selectedPeriod == '7 días',
              ),
              const SizedBox(width: 8),
              _periodChip(
                '30 días',
                onTap: () => setState(() => _selectedPeriod = '30 días'),
                selected: _selectedPeriod == '30 días',
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 205,
            child: _SalesChart(
              values: _salesValues[_selectedPeriod]!,
              labels: _salesLabels[_selectedPeriod]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(
    String label, {
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? red : const Color(0xFFFFF8F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: red.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSale(_RecentSale sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sale.id,
                style: GoogleFonts.poppins(color: ink, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                sale.customer,
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Text(
            sale.amount,
            style: GoogleFonts.poppins(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
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
                  Icon(items[i].$1, color: i == 0 ? red : muted, size: 25),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 0 ? red : muted,
                      fontSize: 12,
                      fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: page,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE8DDDB)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  static const _recentSales = [
    _RecentSale('VEN-2024-0156', 'Maria González', '\$144.000'),
    _RecentSale('VEN-2024-0155', 'Carlos Martínez', '\$92.000'),
    _RecentSale('VEN-2024-0154', 'Ana Rodríguez', '\$110.000'),
    _RecentSale('VEN-2024-0153', 'Jorge Vargas', '\$156.000'),
    _RecentSale('VEN-2024-0152', 'Patricia Soto', '\$80.000'),
    _RecentSale('VEN-2024-0151', 'Luis Herrera', '\$58.000'),
  ];
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeColor,
    this.badgeTextColor,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color? badgeTextColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 12),
      decoration: BoxDecoration(
        color: AdminDashboardScreen.page,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: highlight
                      ? AdminDashboardScreen.red
                      : const Color(0xFFF2EEED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: highlight ? Colors.white : AdminDashboardScreen.red,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    color: badgeTextColor ?? const Color(0xFF27803D),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AdminDashboardScreen.muted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: highlight ? AdminDashboardScreen.red : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SalesChartPainter(values: values, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  const _SalesChartPainter({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const red = Color(0xFFB9000C);
    final gridPaint = Paint()
      ..color = const Color(0xFFD8D0CE)
      ..strokeWidth = 1;
    final barPaint = Paint()..color = red;

    const left = 50.0;
    const bottom = 178.0;
    final chartWidth = size.width - left - 4;
    final chartHeight = 148.0;

    for (var i = 0; i <= 4; i++) {
      final y = bottom - (chartHeight / 4 * i);
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      _drawText(
        canvas,
        '\$${i * 100}k',
        Offset(0, y - 7),
        const TextStyle(color: Color(0xFF6E6A68), fontSize: 11),
      );
    }
    for (var i = 0; i < labels.length; i++) {
      final x = left + chartWidth / labels.length * i;
      canvas.drawLine(
        Offset(x, bottom - chartHeight),
        Offset(x, bottom),
        gridPaint,
      );
      final barWidth = chartWidth / labels.length * 0.68;
      final barHeight = values[i] / 450 * chartHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 5, bottom - barHeight, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);
      _drawText(
        canvas,
        labels[i],
        Offset(x + 2, bottom + 10),
        const TextStyle(color: Color(0xFF6E6A68), fontSize: 11),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}

class _RecentSale {
  const _RecentSale(this.id, this.customer, this.amount);

  final String id;
  final String customer;
  final String amount;
}
