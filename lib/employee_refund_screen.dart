import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_transitions.dart';
import 'return_service.dart';

class EmployeeRefundScreen extends StatefulWidget {
  const EmployeeRefundScreen({super.key, required this.record});

  final ReturnRecord record;

  @override
  State<EmployeeRefundScreen> createState() => _EmployeeRefundScreenState();
}

class _EmployeeRefundScreenState extends State<EmployeeRefundScreen> {
  static const red = Color(0xFFC9151E);
  static const green = Color(0xFF15B98A);
  static const greenDark = Color(0xFF19733B);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
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
                    _title(),
                    const SizedBox(height: 22),
                    _saleSummary(),
                    const SizedBox(height: 22),
                    _refundAmountCard(),
                    const SizedBox(height: 22),
                    _noteField(),
                    const SizedBox(height: 16),
                    _warningBox(),
                    const SizedBox(height: 26),
                    _confirmButton(),
                    const SizedBox(height: 12),
                    _cancelButton(),
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
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EBEF))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: ink, size: 28),
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
                style: GoogleFonts.poppins(
                  color: red,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'S.I.V.PRO Mobile',
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFC62828),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'M',
              style: TextStyle(
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
        Text('Inicio', style: GoogleFonts.poppins(color: muted, fontSize: 16)),
        const SizedBox(width: 36),
        Text(
          'devoluciones',
          style: GoogleFonts.poppins(color: muted, fontSize: 16),
        ),
        const SizedBox(width: 36),
        Text(
          'gestionar',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _title() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFC9F7E5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.attach_money,
            color: greenDark,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Reembolso en dinero',
            style: GoogleFonts.dmSerifDisplay(
              color: ink,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _saleSummary() {
    final isNequi = widget.record.payment == 'Nequi';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF5CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF9B4610),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${widget.record.index}  ${widget.record.customer}',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.record.date,
                      style: GoogleFonts.poppins(color: muted, fontSize: 14),
                    ),
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
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFF1EBD6)),
          ),
          _summaryRow('Monto', widget.record.amount),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Método de pago',
                style: GoogleFonts.poppins(color: muted, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isNequi
                      ? const Color(0xFFF0E3FF)
                      : const Color(0xFFFFF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isNequi ? '💜 Nequi' : '🏦 Bancolombia',
                  style: GoogleFonts.poppins(
                    color: isNequi
                        ? const Color(0xFF6E1DCB)
                        : const Color(0xFF8B3F11),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _summaryRow('Tipo de venta', widget.record.tipoVenta),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(color: muted, fontSize: 15)),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _refundAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9BD5B0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.currency_exchange,
                color: greenDark,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'MONTO A REEMBOLSAR',
                style: GoogleFonts.poppins(
                  color: greenDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.record.amountTexto,
            style: GoogleFonts.robotoMono(
              color: greenDark,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Método original: ${widget.record.payment == 'Nequi' ? 'Nequi' : 'Bancolombia'}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C6E4F),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota del reembolso (opcional)',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Transferido por Nequi el 10/09...',
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _warningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9BD5B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: greenDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Asegúrate de haber realizado la transferencia antes de confirmar. Esta acción no se puede deshacer.',
              style: GoogleFonts.poppins(
                color: greenDark,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _confirmarReembolso,
        style: FilledButton.styleFrom(
          backgroundColor: green,
          disabledBackgroundColor: green.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Confirmar reembolso',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: muted,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          'Cancelar y volver',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarReembolso() async {
    setState(() => _isSubmitting = true);
    ReturnService.instance.resolveMoney(
      widget.record,
      _noteController.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _bottomNavigation() {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_bag_outlined, 'Compras'),
      (Icons.local_fire_department_outlined, 'Producción'),
      (Icons.receipt_long, 'Ventas'),
      (Icons.menu, 'Más'),
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
                              style: GoogleFonts.poppins(
                                color: i == 3
                                    ? red
                                    : const Color(0xFFA4AAB5),
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
}