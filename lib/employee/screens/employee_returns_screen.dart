import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import 'employee_exchange_screen.dart';
import 'employee_refund_screen.dart';
import '../../shared/page_transitions.dart';
import '../services/return_service.dart';

class EmployeeReturnsScreen extends StatelessWidget {
  const EmployeeReturnsScreen({super.key});

  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF211616);
  static const muted = Color(0xFF766B68);
  static const page = Color(0xFFFCF9F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _bottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: ReturnService.instance,
          builder: (context, _) {
            final pendientes = ReturnService.instance.pendientes;
            final resueltas = ReturnService.instance.resueltas;
            return Column(
              children: [
                _header(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _breadcrumb(),
                        const SizedBox(height: 28),
                        Text(
                          'Devoluciones',
                          style: GoogleFonts.dmSerifDisplay(
                            color: ink,
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSerifDisplay(fontSize: 20),
                            children: [
                              TextSpan(
                                text: '${pendientes.length} pendientes',
                                style: const TextStyle(
                                  color: Color(0xFFB44A00),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '  ·  ${resueltas.length} resueltas',
                                style: const TextStyle(color: muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 38),
                        _sectionTitle(
                          'PENDIENTES DE RESOLUCIÓN',
                          badge: '${pendientes.length} en cola',
                        ),
                        const SizedBox(height: 18),
                        ...pendientes.map(
                          (item) => _ReturnCard(
                            item: item,
                            onManage: () => _showManageDialog(context, item),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('RESUELTAS'),
                        const SizedBox(height: 18),
                        if (resueltas.isNotEmpty)
                          ...resueltas.map(
                            (item) => _ResolvedCard(item: item),
                          ),
                        const SizedBox(height: 22),
                        _resolutionInfo(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 30),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 36),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LA SIRENA PIZZA',
                style: GoogleFonts.dmSerifDisplay(
                  color: red,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'S.I.V.PRO Mobile',
                style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: red,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFCACA), width: 4),
            ),
            child: Text(
              getInitials('María González'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, color: Color(0xFFA49A97), size: 20),
        const SizedBox(width: 6),
        Text('Inicio', style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 15)),
        const Icon(Icons.chevron_right, color: Color(0xFFA49A97), size: 22),
        Text(
          'devoluciones',
          style: GoogleFonts.dmSerifDisplay(color: ink, fontSize: 15),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, {String? badge}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFFA49A97),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: .4,
          ),
        ),
        const Spacer(),
        if (badge != null) _queueBadge(badge),
      ],
    );
  }

  Widget _queueBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        border: Border.all(color: const Color(0xFFFFD55A)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSerifDisplay(
          color: const Color(0xFF9B4610),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _resolutionInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '?',
              style: TextStyle(color: muted, fontSize: 18),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolución de devoluciones',
                  style: GoogleFonts.dmSerifDisplay(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Las devoluciones aprobadas se sincronizarán directamente con el módulo de caja y se notificará al cliente vía WhatsApp.',
                  style: GoogleFonts.dmSerifDisplay(
                    color: muted,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.people_outline, 'Clientes'),
      (Icons.receipt_long, 'Ventas'),
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
                  top: BorderSide(color: Color(0xFFEDE6E4)),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => handleEmployeeBottomNav(context, i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].$1,
                              color: i == 3 ? red : const Color(0xFFA49A97),
                              size: 22,
                            ),
                            Text(
                              items[i].$2,
                              style: GoogleFonts.dmSerifDisplay(
                                color: i == 3 ? red : const Color(0xFFA49A97),
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

  Future<void> _showManageDialog(BuildContext context, ReturnRecord item) async {
    final resolved = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => _ReturnManagementScreen(item: item),
      ),
    );
    if (resolved == 'canje' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devolución realizada correctamente.')),
      );
    } else if (resolved == 'dinero' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reembolso registrado correctamente.')),
      );
    }
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.item, required this.onManage});

  final ReturnRecord item;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final isNequi = item.payment == 'Nequi';
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(26, 27, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECD7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync, color: Color(0xFFE84A08), size: 34),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${item.index}  ${item.customer}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.date,
                  style: GoogleFonts.dmSerifDisplay(color: const Color(0xFFA49A97)),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.amount,
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PaymentBadge(payment: item.payment, isNequi: isNequi),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onManage,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7A2B0C),
              side: const BorderSide(color: Color(0xFFFFC51C)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Gestionar'),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.payment, required this.isNequi});

  final String payment;
  final bool isNequi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: isNequi ? const Color(0xFFF0E3FF) : const Color(0xFFFFF3C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isNequi ? '💜 Nequi' : '▤  Bancolombia',
        style: GoogleFonts.dmSerifDisplay(
          color: isNequi ? const Color(0xFF6E1DCB) : const Color(0xFF8B3F11),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ResolvedCard extends StatelessWidget {
  const _ResolvedCard({required this.item});

  final ReturnRecord item;

  String get _resolutionText {
    if (item.isCanje) return 'Canje: ${item.replacementProduct}';
    final base = 'Reembolso: ${item.amountTexto}';
    return item.refundNote.isEmpty ? base : '$base — ${item.refundNote}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(26, 27, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9BD5B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF19733B),
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${item.index}  ${item.customer}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.date,
                  style: GoogleFonts.dmSerifDisplay(color: const Color(0xFFA49A97)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ResolutionBadge(label: item.isCanje ? 'Canje' : 'Dinero'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _resolutionText,
                        style: GoogleFonts.dmSerifDisplay(
                          color: const Color(0xFF19733B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      item.amount,
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF19733B),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Resuelta',
                      style: GoogleFonts.dmSerifDisplay(
                        color: const Color(0xFF19733B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolutionBadge extends StatelessWidget {
  const _ResolutionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSerifDisplay(
          color: const Color(0xFF19733B),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReturnManagementScreen extends StatefulWidget {
  const _ReturnManagementScreen({required this.item});

  final ReturnRecord item;

  @override
  State<_ReturnManagementScreen> createState() =>
      _ReturnManagementScreenState();
}

class _ReturnManagementScreenState extends State<_ReturnManagementScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  String _resolution = 'money';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _bottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breadcrumb(),
                    const SizedBox(height: 22),
                    _returnSummary(),
                    const SizedBox(height: 22),
                    Text(
                      '¿Cómo se resuelve esta devolución?',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _resolutionCard(
                      value: 'product',
                      title: 'Producto por producto',
                      description:
                          'El cliente devuelve el pedido y recibe un producto de reemplazo.',
                      color: const Color(0xFFB8D2FF),
                      iconColor: const Color(0xFFD9E7FF),
                    ),
                    const SizedBox(height: 20),
                    _resolutionCard(
                      value: 'money',
                      title: 'Producto por dinero',
                      description:
                          'El cliente devuelve el pedido y se le reembolsa el valor pagado.',
                      color: const Color(0xFF15B98A),
                      iconColor: const Color(0xFFC9F7E5),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _confirmResolution(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: red,
                          minimumSize: const Size.fromHeight(68),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Confirmar y procesar resolución',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  Widget _header() {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LA SIRENA PIZZA',
                style: GoogleFonts.dmSerifDisplay(
                  color: red,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'S.I.V.PRO Mobile',
                style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              getInitials('María González'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text('Inicio', style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 16)),
        const SizedBox(width: 36),
        Text(
          'devoluciones',
          style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 16),
        ),
        const SizedBox(width: 36),
        Text(
          'gestionar',
          style: GoogleFonts.dmSerifDisplay(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _returnSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF5CC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${widget.item.index}  ${widget.item.customer} · ${widget.item.date}',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.amount,
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _paymentBadge(),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted,
                  side: const BorderSide(color: Color(0xFFE0E4E9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 22),
            child: Divider(color: Color(0xFFF1EBD6)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '¿Cómo se resuelve esta devolución?',
              style: GoogleFonts.dmSerifDisplay(
                color: ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge() {
    final isNequi = widget.item.payment == 'Nequi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: isNequi ? const Color(0xFFF0E3FF) : const Color(0xFFFFF3C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isNequi ? '💜 Nequi' : '🏦 Bancolombia',
        style: GoogleFonts.dmSerifDisplay(
          color: isNequi ? const Color(0xFF6E1DCB) : const Color(0xFF8B3F11),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _resolutionCard({
    required String value,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    final selected = _resolution == value;
    return InkWell(
      onTap: () => setState(() => _resolution = value),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 26, 22, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: .65),
            width: selected ? 3 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? color : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: GoogleFonts.dmSerifDisplay(
                color: ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.dmSerifDisplay(
                color: muted,
                fontSize: 16,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.people_outline, 'Clientes'),
      (Icons.receipt_long, 'Ventas'),
      (Icons.sync_alt, 'Devoluciones'),
      (Icons.person_outline, 'Perfil'),
    ];
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => handleEmployeeBottomNav(context, i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].$1,
                              color: i == 3 ? red : const Color(0xFFA4AAB5),
                              size: 21,
                            ),
                            Text(
                              items[i].$2,
                              style: GoogleFonts.dmSerifDisplay(
                                color: i == 3 ? red : const Color(0xFFA4AAB5),
                                fontSize: 10,
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

  Future<void> _confirmResolution(BuildContext context) async {
    if (_resolution == 'product') {
      final resolved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => EmployeeExchangeScreen(record: widget.item),
        ),
      );
      if (resolved == true && context.mounted) {
        Navigator.of(context).pop('canje');
      }
      return;
    }

    final resolved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EmployeeRefundScreen(record: widget.item),
      ),
    );
    if (resolved == true && context.mounted) {
      Navigator.of(context).pop('dinero');
    }
  }
}
