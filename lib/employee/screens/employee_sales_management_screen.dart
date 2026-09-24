import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
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

  static const _pageSize = 5;
  int _visibleSales = _pageSize;

  List<_Sale> get _filtered => sales
      .where(
        (sale) => sale.customer.toLowerCase().contains(_query.toLowerCase()),
      )
      .toList();

  void _loadMore() {
    if (_visibleSales >= _filtered.length) return;
    setState(() {
      _visibleSales += _pageSize;
      if (_visibleSales > _filtered.length) _visibleSales = _filtered.length;
    });
  }

  final sales = <_Sale>[
    _Sale(
      index: 1,
      code: 'VEN-2024-0156',
      customer: 'María González',
      phone: '310 456 7890',
      address: 'Cra 45 #12-45, Medellín',
      date: '2024-01-15',
      time: '18:30',
      payment: 'Nequi',
      amount: '\$56.000',
      status: 'Por entregar',
      products: const [
        _SaleProduct(2, 'Pizza Maicitos', 'Familiar', '\$28.000'),
        _SaleProduct(2, 'Pizza Jamón con Queso', 'Mediana', '\$28.000'),
      ],
    ),
    _Sale(
      index: 2,
      code: 'VEN-2024-0155',
      customer: 'Carlos Martínez',
      phone: '320 567 8901',
      address: 'Cll 8B #23-10, Envigado',
      date: '2024-01-15',
      time: '18:15',
      payment: 'Bancolombia',
      amount: '\$28.000',
      status: 'Por entregar',
      products: const [
        _SaleProduct(2, 'Pizza Jamón con Queso', 'Grande', '\$28.000'),
      ],
    ),
    _Sale(
      index: 3,
      code: 'VEN-2024-0154',
      customer: 'Ana Rodríguez',
      phone: '301 678 9012',
      address: 'Av 33 #56-21, Medellín',
      date: '2024-01-16',
      time: '17:45',
      payment: 'Nequi',
      amount: '\$90.000',
      status: 'Por verificar',
      products: const [
        _SaleProduct(2, 'Pizza Cañon', 'Familiar', '\$32.000'),
        _SaleProduct(2, 'Pizza Tocineta', 'Familiar', '\$32.000'),
        _SaleProduct(1, 'Pizza Maicitos', 'Grande', '\$14.000'),
        _SaleProduct(4, 'Coca Cola', null, '\$12.000'),
      ],
    ),
    _Sale(
      index: 4,
      code: 'VEN-2024-0153',
      customer: 'Jorge Vargas',
      phone: '312 789 0123',
      address: 'Cra 70 #4-89, Itagüí',
      date: '2024-01-16',
      time: '17:20',
      payment: 'Bancolombia',
      amount: '\$32.000',
      status: 'Devolución',
      products: const [
        _SaleProduct(2, 'Pizza Cañon', 'Mediana', '\$32.000'),
      ],
    ),
    _Sale(
      index: 5,
      code: 'VEN-2024-0152',
      customer: 'Patricia Soto',
      phone: '314 890 1234',
      address: 'Cll 20 #41-33, Bello',
      date: '2024-01-17',
      time: '16:50',
      payment: 'Nequi',
      amount: '\$54.000',
      status: 'Completado',
      products: const [
        _SaleProduct(2, 'Pizza Jamón con Queso', 'Grande', '\$28.000'),
        _SaleProduct(1, 'Pizza Maicitos', 'Grande', '\$14.000'),
        _SaleProduct(4, 'Coca Cola', null, '\$12.000'),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                    _loadMore();
                  }
                  return false;
                },
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
                                '${sales.length} ventas registradas',
                                style: GoogleFonts.dmSerifDisplay(
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
                    ...filtered.take(_visibleSales).map(
                      (sale) => _SaleCard(
                        sale: sale,
                        onTap: () => _showSaleDetailDialog(context, sale),
                        onStatusChanged: (status) =>
                            _changeSaleStatus(context, sale, status),
                        onDeleted: () => _deleteSale(context, sale),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('María González'),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, color: muted, size: 17),
        const SizedBox(width: 5),
        Text('Inicio', style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 13)),
        const Icon(Icons.chevron_right, color: muted, size: 18),
        Text(
          'ventas-pedidos',
          style: GoogleFonts.dmSerifDisplay(color: ink, fontSize: 13),
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
        hintStyle: GoogleFonts.dmSerifDisplay(color: ink, fontSize: 15),
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

  Widget _buildBottomNavigation(BuildContext context) {
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
                              color: index == 2 ? red : muted,
                              size: 19,
                            ),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.dmSerifDisplay(
                                color: index == 2 ? red : muted,
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
                      style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
                              color: const Color(0xFF9B4610),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Se asigna automáticamente',
                            style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                        style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Comprobante de transferencia',
                      style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
                                color: ink,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'PNG, JPG, WEBP',
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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

  void _showSaleDetailDialog(BuildContext context, _Sale sale) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Detalle de venta',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.code,
                            style: GoogleFonts.dmSerifDisplay(
                              color: muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${sale.date}  ·  ${sale.time}',
                            style: GoogleFonts.dmSerifDisplay(
                              color: muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SaleStatusBadge(status: sale.status),
                        const SizedBox(height: 10),
                        Text(
                          sale.amount,
                          style: GoogleFonts.dmSerifDisplay(
                            color: ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SaleDetailRow(label: 'Teléfono', value: sale.phone),
                _SaleDetailRow(label: 'Dirección de entrega', value: sale.address),
                _SaleDetailRow(label: 'Método de pago', value: sale.payment),
                const SizedBox(height: 18),
                Text(
                  'PRODUCTOS',
                  style: GoogleFonts.dmSerifDisplay(
                    color: muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...sale.products.map(
                  (product) => _SaleProductRow(product: product),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),
                Text(
                  'Cambiar estado:',
                  style: GoogleFonts.dmSerifDisplay(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _stateChips(_currentChipStatus(sale.status)),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F4),
                      foregroundColor: ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stateChips(String current) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final chip in _estadoChips)
          _EstadoChip(
            label: chip.label,
            active: chip.label == current,
            background: chip.background,
            border: chip.border,
            foreground: chip.foreground,
          ),
      ],
    );
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
              style: GoogleFonts.dmSerifDisplay(
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
            hintStyle: GoogleFonts.dmSerifDisplay(color: Colors.black38, fontSize: 15),
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
        style: GoogleFonts.dmSerifDisplay(
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
    required this.onTap,
    required this.onStatusChanged,
    required this.onDeleted,
  });

  final _Sale sale;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
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
                style: GoogleFonts.dmSerifDisplay(
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
                    style: GoogleFonts.dmSerifDisplay(
                      color: _EmployeeSalesManagementScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sale.customer,
                    style: GoogleFonts.dmSerifDisplay(
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
                    style: GoogleFonts.dmSerifDisplay(
                      color: _EmployeeSalesManagementScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    sale.amount,
                    style: GoogleFonts.dmSerifDisplay(
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
                  style: GoogleFonts.dmSerifDisplay(
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
                          style: GoogleFonts.dmSerifDisplay(
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
        ),
      ),
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
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        '$status ⌄',
        style: GoogleFonts.dmSerifDisplay(
          color: colors.foreground,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SaleStatusBadge extends StatelessWidget {
  const _SaleStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSerifDisplay(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

({Color background, Color border, Color foreground}) _statusColors(
  String status,
) {
  if (status == 'Devolución') {
    return (
      background: const Color(0xFFFFEBCF),
      border: const Color(0xFFFFC477),
      foreground: const Color(0xFFB44A00),
    );
  }
  if (status == 'Completado') {
    return (
      background: const Color(0xFFE0F5E9),
      border: const Color(0xFF9BD5B0),
      foreground: const Color(0xFF19733B),
    );
  }
  if (status == 'Por verificar') {
    return (
      background: const Color(0xFFFFFBF0),
      border: const Color(0xFFFFDA70),
      foreground: const Color(0xFFB45B00),
    );
  }
  return (
    background: const Color(0xFFD8EAFF),
    border: const Color(0xFFB6D4FF),
    foreground: const Color(0xFF2861B7),
  );
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
              style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
  const _Sale({
    required this.index,
    required this.code,
    required this.customer,
    required this.phone,
    required this.address,
    required this.date,
    required this.time,
    required this.payment,
    required this.amount,
    required this.status,
    required this.products,
  });

  final int index;
  final String code;
  final String customer;
  final String phone;
  final String address;
  final String date;
  final String time;
  final String payment;
  final String amount;
  final String status;
  final List<_SaleProduct> products;

  _Sale copyWith({String? status}) {
    return _Sale(
      index: index,
      code: code,
      customer: customer,
      phone: phone,
      address: address,
      date: date,
      time: time,
      payment: payment,
      amount: amount,
      status: status ?? this.status,
      products: products,
    );
  }
}

class _SaleProduct {
  const _SaleProduct(this.quantity, this.name, this.size, this.price);
  final int quantity;
  final String name;
  final String? size;
  final String price;
}

class _SaleDetailRow extends StatelessWidget {
  const _SaleDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              color: _EmployeeSalesManagementScreenState.muted,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSerifDisplay(
                color: _EmployeeSalesManagementScreenState.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleProductRow extends StatelessWidget {
  const _SaleProductRow({required this.product});

  final _SaleProduct product;

  @override
  Widget build(BuildContext context) {
    final sizeText = product.size == null ? '' : ' (${product.size})';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '${product.quantity} × ${product.name}$sizeText',
              style: GoogleFonts.dmSerifDisplay(
                color: _EmployeeSalesManagementScreenState.ink,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            product.price,
            style: GoogleFonts.dmSerifDisplay(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoChipData {
  const _EstadoChipData(
    this.label,
    this.background,
    this.border,
    this.foreground,
  );
  final String label;
  final Color background;
  final Color border;
  final Color foreground;
}

const _estadoChips = [
  _EstadoChipData(
    'Pendiente',
    Color(0xFFFFFBF0),
    Color(0xFFFFDA70),
    Color(0xFFB45B00),
  ),
  _EstadoChipData(
    'En preparación',
    Color(0xFFD8EAFF),
    Color(0xFFB6D4FF),
    Color(0xFF2861B7),
  ),
  _EstadoChipData(
    'Listo',
    Color(0xFFE0F5E9),
    Color(0xFF9BD5B0),
    Color(0xFF19733B),
  ),
  _EstadoChipData(
    'Entregado',
    Color(0xFFEFF2F5),
    Color(0xFFC9D2DB),
    Color(0xFF6D7B91),
  ),
  _EstadoChipData(
    'Cancelado',
    Color(0xFFFFEBCF),
    Color(0xFFFFC477),
    Color(0xFFB44A00),
  ),
];

String _currentChipStatus(String status) {
  if (status == 'Por entregar' || status == 'Por verificar') return 'Pendiente';
  if (status == 'Completado') return 'Entregado';
  if (status == 'Devolución') return 'Cancelado';
  return status;
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({
    required this.label,
    required this.active,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String label;
  final bool active;
  final Color background;
  final Color border;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? background : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? border : const Color(0xFFE0E4E9),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSerifDisplay(
          color: active
              ? foreground
              : _EmployeeSalesManagementScreenState.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
