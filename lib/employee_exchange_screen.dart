import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employee_substitution_picker_screen.dart';
import 'page_transitions.dart';
import 'return_service.dart';

class EmployeeExchangeScreen extends StatefulWidget {
  const EmployeeExchangeScreen({super.key, required this.record});

  final ReturnRecord record;

  @override
  State<EmployeeExchangeScreen> createState() => _EmployeeExchangeScreenState();
}

class _EmployeeExchangeScreenState extends State<EmployeeExchangeScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final Set<int> _seleccionados = {};

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
                    Text(
                      'Canje por producto',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _saleSummary(),
                    const SizedBox(height: 24),
                    Text(
                      'Marca los productos de la venta que el cliente devolverá para canje:',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < widget.record.products.length; i++)
                      _productTile(i, widget.record.products[i]),
                    const SizedBox(height: 14),
                    _note(),
                  ],
                ),
              ),
            ),
            _confirmBar(),
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

  Widget _productTile(int index, ReturnProduct product) {
    final selected = _seleccionados.contains(index);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? red : const Color(0xFFE4E1DF),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _seleccionados.add(index);
                } else {
                  _seleccionados.remove(index);
                }
              });
            },
            activeColor: red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 54,
              height: 54,
              child: Image.asset(
                product.imagen,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF1F3F5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.local_pizza, color: red, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  style: GoogleFonts.poppins(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${product.precioTexto} · Cant: ${product.cantidad}',
                  style: GoogleFonts.poppins(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _note() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9B4610), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Al confirmar, se abrirá el menú para escoger el nuevo producto de sustitución equivalente.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmBar() {
    final hasSelection = _seleccionados.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: hasSelection ? _confirmarCanje : null,
          style: FilledButton.styleFrom(
            backgroundColor: red,
            disabledBackgroundColor: red.withValues(alpha: 0.15),
            disabledForegroundColor: red.withValues(alpha: 0.45),
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            'Confirmar canje',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarCanje() async {
    final replacement = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const EmployeeSubstitutionPickerScreen(),
      ),
    );
    if (replacement == null || replacement.isEmpty || !mounted) return;

    final devueltos = [
      for (var i = 0; i < widget.record.products.length; i++)
        if (_seleccionados.contains(i)) widget.record.products[i],
    ];
    ReturnService.instance.resolveCanje(widget.record, devueltos, replacement);
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
}