import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employee_sale_detail_screen.dart';
import '../../shared/page_transitions.dart';

class EmployeeSalesManagementScreen extends StatefulWidget {
  const EmployeeSalesManagementScreen({super.key});

  @override
  State<EmployeeSalesManagementScreen> createState() =>
      _EmployeeSalesManagementScreenState();
}

class _EmployeeSalesManagementScreenState
    extends State<EmployeeSalesManagementScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final _searchController = TextEditingController();
  String _query = '';

  final sales = <_Sale>[
    _Sale(
      1,
      'María González',
      '2024-01-15',
      'Nequi',
      '\$56.000',
      'Por entregar',
    ),
    _Sale(
      2,
      'Carlos Martínez',
      '2024-01-15',
      'Bancolombia',
      '\$28.000',
      'Por entregar',
    ),
    _Sale(
      3,
      'Ana Rodríguez',
      '2024-01-16',
      'Nequi',
      '\$90.000',
      'Por verificar',
    ),
    _Sale(
      4,
      'Jorge Vargas',
      '2024-01-16',
      'Bancolombia',
      '\$32.000',
      'Devolución',
    ),
    _Sale(5, 'Patricia Soto', '2024-01-17', 'Nequi', '\$54.000', 'Completado'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = sales
        .where(
          (sale) => sale.customer.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBreadcrumb(),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gestión Ventas',
                                style: GoogleFonts.dmSerifDisplay(
                                  color: ink,
                                  fontSize: 29,
                                ),
                              ),
                              Text(
                                '${sales.length + 3} ventas registradas',
                                style: GoogleFonts.poppins(
                                  color: muted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _showNewOrderDialog(context),
                          icon: const Icon(Icons.add, size: 19),
                          label: const Text('Nuevo pedido'),
                          style: FilledButton.styleFrom(
                            backgroundColor: red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSearch(),
                    const SizedBox(height: 18),
                    ...filtered.map(
                      (sale) => _SaleCard(
                        sale: sale,
                        onStatusChanged: (status) =>
                            _changeSaleStatus(context, sale, status),
                        onDeleted: () => _deleteSale(context, sale),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPagination(),
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
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE6E8EC))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: ink, size: 27),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 28),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.dmSerifDisplay(color: ink, fontSize: 23),
          ),
          Container(
            margin: const EdgeInsets.only(left: 9),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E9),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'MOBILE',
              style: GoogleFonts.poppins(
                color: red,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.nightlight_outlined, color: muted, size: 24),
          const SizedBox(width: 22),
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: const Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, color: muted, size: 17),
        const SizedBox(width: 5),
        Text('Inicio', style: GoogleFonts.poppins(color: muted, fontSize: 13)),
        const Icon(Icons.chevron_right, color: muted, size: 18),
        Text(
          'ventas-pedidos',
          style: GoogleFonts.poppins(color: ink, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: muted),
        hintText: 'Buscar por #, cliente o producto...',
        hintStyle: GoogleFonts.poppins(color: ink, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: red),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chevron_left, color: muted),
        const SizedBox(width: 22),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
          child: const Text(
            '1',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 28),
        const Text('2', style: TextStyle(color: ink)),
        const SizedBox(width: 28),
        const Icon(Icons.chevron_right, color: ink),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long, 'Ventas'),
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
                  top: BorderSide(color: red),
                  left: BorderSide(color: Color(0xFFE6E8EC)),
                  right: BorderSide(color: Color(0xFFE6E8EC)),
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
                              items[index].$1,
                              color: index == 3 ? red : muted,
                              size: 19,
                            ),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.poppins(
                                color: index == 3 ? red : muted,
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta función estará disponible próximamente.'),
      ),
    );
  }

  Future<void> _changeSaleStatus(
    BuildContext context,
    _Sale sale,
    String status,
  ) async {
    if (status == sale.status) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SaleConfirmationDialog(
        title: 'Cambiar estado',
        message:
            '¿Estás seguro de cambiar el estado de\n"${sale.status}" a "$status"?',
      ),
    );
    if (confirmed == true && context.mounted) {
      setState(() {
        final saleIndex = sales.indexOf(sale);
        sales[saleIndex] = sale.copyWith(status: status);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta ${sale.index} actualizada.')),
      );
    }
  }

  Future<void> _deleteSale(BuildContext context, _Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SaleConfirmationDialog(
        title: 'Eliminar venta',
        message:
            '¿Seguro que deseas eliminar la venta ${sale.index}?\nEsta acción no se puede deshacer.',
      ),
    );
    if (confirmed == true && context.mounted) {
      setState(() => sales.remove(sale));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Venta ${sale.index} eliminada.')));
    }
  }

  void _showNewOrderDialog(BuildContext context) {
    final userController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    var paymentMethod = 'Nequi';

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nuevo pedido',
                          style: GoogleFonts.dmSerifDisplay(
                            color: ink,
                            fontSize: 30,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: muted, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _OrderField(
                      label: 'Usuario',
                      required: true,
                      hint: 'Escribe el nombre del usuario...',
                      controller: userController,
                    ),
                    const SizedBox(height: 18),
                    _OrderField(
                      label: 'Fecha',
                      required: true,
                      hint: 'DD/MM/AAAA',
                      controller: dateController,
                      suffixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 18),
                    _OrderField(
                      label: 'Productos',
                      required: true,
                      hint: 'Seleccionar productos del catálogo...',
                      suffixIcon: Icons.keyboard_arrow_down,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Estado',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFC52E)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color(0xFFFFA400),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Por verificar',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9B4610),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Se asigna automáticamente',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD47700),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Método de pago *',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentButton(
                            label: '💜  Nequi',
                            selected: paymentMethod == 'Nequi',
                            onTap: () =>
                                setDialogState(() => paymentMethod = 'Nequi'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PaymentButton(
                            label: '🏦  Bancolombia',
                            selected: paymentMethod == 'Bancolombia',
                            onTap: () => setDialogState(
                              () => paymentMethod = 'Bancolombia',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Hora de recogida',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6FFF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '●  Atendemos de 4:00 PM a 10:00 PM',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF087653),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _OrderField(
                      label: '',
                      hint: '--:-- -----',
                      controller: timeController,
                      suffixIcon: Icons.access_time,
                    ),
                    Text(
                      'Ej: 06:30 PM — opcional',
                      style: GoogleFonts.poppins(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Comprobante de transferencia',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      width: double.infinity,
                      height: 132,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFDDE1E7),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showComingSoon(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              color: Colors.black38,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Subir imagen del comprobante',
                              style: GoogleFonts.poppins(
                                color: ink,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'PNG, JPG, WEBP',
                              style: GoogleFonts.poppins(
                                color: Colors.black38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: const BorderSide(color: Color(0xFFE0E3E7)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                color: ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (userController.text.trim().isEmpty ||
                                  dateController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa el usuario y la fecha.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pedido creado correctamente.'),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: red,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Guardar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      userController.dispose();
      dateController.dispose();
      timeController.dispose();
    });
  }
}

class _OrderField extends StatelessWidget {
  const _OrderField({
    required this.label,
    required this.hint,
    this.controller,
    this.required = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool required;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                color: _EmployeeSalesManagementScreenState.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: _EmployeeSalesManagementScreenState.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 15),
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: Colors.black54),
            filled: true,
            fillColor: const Color(0xFFFCFCFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE0E3E7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: _EmployeeSalesManagementScreenState.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        backgroundColor: selected ? const Color(0xFFFFFEFE) : Colors.white,
        side: BorderSide(
          color: selected
              ? _EmployeeSalesManagementScreenState.red
              : const Color(0xFFE0E3E7),
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: _EmployeeSalesManagementScreenState.ink,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.onStatusChanged,
    required this.onDeleted,
  });

  final _Sale sale;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E4E9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFF1F3F5),
                child: Text(
                  '${sale.index}',
                  style: const TextStyle(
                    color: _EmployeeSalesManagementScreenState.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                sale.date,
                style: GoogleFonts.poppins(
                  color: _EmployeeSalesManagementScreenState.muted,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EmployeeSaleDetailScreen(
                      index: sale.index,
                      customer: sale.customer,
                      date: sale.date,
                      payment: sale.payment,
                      amount: sale.amount,
                      returned: sale.status == 'Devolución',
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: _EmployeeSalesManagementScreenState.muted,
                  size: 19,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: onDeleted,
                icon: const Icon(
                  Icons.delete_outline,
                  color: _EmployeeSalesManagementScreenState.muted,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLIENTE',
                    style: GoogleFonts.poppins(
                      color: _EmployeeSalesManagementScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sale.customer,
                    style: GoogleFonts.poppins(
                      color: _EmployeeSalesManagementScreenState.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.poppins(
                      color: _EmployeeSalesManagementScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sale.amount,
                    style: GoogleFonts.robotoMono(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: sale.payment == 'Nequi'
                      ? const Color(0xFFF0E3FF)
                      : const Color(0xFFFFF0A8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sale.payment == 'Nequi' ? '💜 Nequi' : '🏦 Bancolombia',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4F416D),
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: onStatusChanged,
                tooltip: 'Cambiar estado',
                offset: const Offset(0, 42),
                color: const Color(0xFFE7F0FF),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                itemBuilder: (_) => _statusOptions
                    .map(
                      (status) => PopupMenuItem<String>(
                        value: status,
                        height: 38,
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1747A6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                child: _StatusBadge(status: sale.status),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _statusOptions = [
  'Por entregar',
  'Devolución',
  'Por verificar',
  'Completado',
];

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isReturned = status == 'Devolución';
    final isCompleted = status == 'Completado';
    final isPending = status == 'Por verificar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isReturned
            ? const Color(0xFFFFEBCF)
            : isPending
            ? const Color(0xFFFFFBF0)
            : isCompleted
            ? const Color(0xFFE0F5E9)
            : const Color(0xFFD8EAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReturned
              ? const Color(0xFFFFC477)
              : isPending
              ? const Color(0xFFFFDA70)
              : isCompleted
              ? const Color(0xFF9BD5B0)
              : const Color(0xFFB6D4FF),
        ),
      ),
      child: Text(
        '$status ⌄',
        style: GoogleFonts.poppins(
          color: isReturned
              ? const Color(0xFFB44A00)
              : isPending
              ? const Color(0xFFB45B00)
              : isCompleted
              ? const Color(0xFF19733B)
              : const Color(0xFF2861B7),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SaleConfirmationDialog extends StatelessWidget {
  const _SaleConfirmationDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD5D5)),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE1252B),
                    size: 34,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.dmSerifDisplay(
                      color: _EmployeeSalesManagementScreenState.ink,
                      fontSize: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: _EmployeeSalesManagementScreenState.ink,
                fontSize: 17,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      side: const BorderSide(color: Color(0xFFE0E4E9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _EmployeeSalesManagementScreenState.red,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Sí, confirmar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Sale {
  const _Sale(
    this.index,
    this.customer,
    this.date,
    this.payment,
    this.amount,
    this.status,
  );
  final int index;
  final String customer;
  final String date;
  final String payment;
  final String amount;
  final String status;

  _Sale copyWith({String? status}) {
    return _Sale(index, customer, date, payment, amount, status ?? this.status);
  }
}
