import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';

class EmployeeSaleDetailScreen extends StatelessWidget {
  const EmployeeSaleDetailScreen({
    required this.index,
    required this.customer,
    required this.date,
    required this.payment,
    required this.amount,
    required this.returned,
    super.key,
  });

  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final int index;
  final String customer;
  final String date;
  final String payment;
  final String amount;
  final bool returned;

  @override
  Widget build(BuildContext context) {
    final status = returned ? 'Devolución' : 'Por entregar';
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _bottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: getInitials('María González'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Venta $index',
                          style: GoogleFonts.dmSerifDisplay(
                            color: ink,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Detalle de venta  —  ID $index',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _card('INFORMACIÓN', _information()),
                    const SizedBox(height: 28),
                    _card('PRODUCTOS DEL PEDIDO', _products()),
                    const SizedBox(height: 28),
                    _card('COMPROBANTE DE TRANSFERENCIA', _receipt()),
                    const SizedBox(height: 28),
                    _card('HISTORIAL DE ESTADOS', _history(status)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE6E8EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17243A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSerifDisplay(
              color: muted,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          child,
        ],
      ),
    );
  }

  Widget _information() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _value('ID Venta', '$index')),
            Expanded(child: _value('Cliente', customer)),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(child: _value('Fecha', date)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Método de pago',
                    style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _paymentChip(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _value(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSerifDisplay(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _products() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 74,
              height: 74,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFC477)),
              ),
              child: const Text('🍕', style: TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Margarita Clásica',
                    style: GoogleFonts.dmSerifDisplay(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$28.000 × 2',
                    style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 16),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.dmSerifDisplay(
                color: red,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: Divider(height: 1),
        ),
        Row(
          children: [
            Text(
              'Total',
              style: GoogleFonts.dmSerifDisplay(
                color: ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: GoogleFonts.dmSerifDisplay(
                color: red,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _receipt() {
    return Container(
      height: 235,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE2E8), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EBEF)),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFF9AA6B7),
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sin comprobante',
            style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 17),
          ),
          Text(
            'No se adjuntó archivo de pago',
            style: GoogleFonts.dmSerifDisplay(color: const Color(0xFF9AA6B7)),
          ),
        ],
      ),
    );
  }

  Widget _history(String status) {
    return Column(
      children: [
        _historyRow('Por verificar', '4:10 PM', false),
        _historyRow(status, '4:15 PM', true),
      ],
    );
  }

  Widget _historyRow(String label, String time, bool active) {
    final activeColor = returned
        ? const Color(0xFFB44A00)
        : const Color(0xFF1455C0);
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: active
                        ? (returned
                              ? const Color(0xFFFFC98A)
                              : const Color(0xFFFFD8D8))
                        : muted,
                    shape: BoxShape.circle,
                  ),
                  child: active
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!active)
                  const Expanded(
                    child: VerticalDivider(color: Color(0xFFDDE2E8), width: 1),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? (returned
                        ? const Color(0xFFFFEBCF)
                        : const Color(0xFFD8EAFF))
                  : const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? (returned
                          ? const Color(0xFFFFC477)
                          : const Color(0xFFB6D4FF))
                    : const Color(0xFFFFDA70),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: active ? activeColor : const Color(0xFFB45B00),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(time, style: GoogleFonts.dmSerifDisplay(color: muted)),
        ],
      ),
    );
  }

  Widget _paymentChip() {
    final isNequi = payment == 'Nequi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: isNequi ? const Color(0xFFF0E3FF) : const Color(0xFFFFF0A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isNequi ? '💜  Nequi' : '🏦  Bancolombia',
        style: GoogleFonts.dmSerifDisplay(
          color: isNequi ? const Color(0xFF6E1DCB) : const Color(0xFF7A5900),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: returned ? const Color(0xFFFFEBCF) : const Color(0xFFD8EAFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: returned ? const Color(0xFFFFCA72) : const Color(0xFFB6D4FF),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: returned ? const Color(0xFFB44A00) : const Color(0xFF347DE1),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              color: returned
                  ? const Color(0xFFB44A00)
                  : const Color(0xFF1455C0),
              fontWeight: FontWeight.w600,
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
                  top: BorderSide(color: Color(0xFFE6E8EC)),
                  left: BorderSide(color: Color(0xFFE6E8EC)),
                  right: BorderSide(color: Color(0xFFE6E8EC)),
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
                              color: i == 2 ? red : const Color(0xFF9AA6B7),
                              size: 22,
                            ),
                            Text(
                              items[i].$2,
                              style: GoogleFonts.dmSerifDisplay(
                                color: i == 2
                                    ? red
                                    : const Color(0xFF9AA6B7),
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
}
