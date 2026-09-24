part of '../purchases_screen.dart';

class _ProductionOrdersScreen extends StatefulWidget {
  const _ProductionOrdersScreen();

  @override
  State<_ProductionOrdersScreen> createState() => _ProductionOrdersScreenState();
}

class _ProductionOrdersScreenState extends State<_ProductionOrdersScreen> {
  String _query = '';

  static const _orders = [
    _ProductionOrder('ORD-001', 'REC-001', 'Margarita Clásica', '2024-01-15', '19:00', 20, 'Completada'),
    _ProductionOrder('ORD-002', 'REC-002', 'Pepperoni Premium', '2024-01-15', '20:30', 15, 'En Proceso'),
    _ProductionOrder('ORD-003', 'REC-003', 'Cuatro Quesos', '2024-01-16', '18:00', 10, 'Pendiente'),
    _ProductionOrder('ORD-004', 'REC-004', 'Especial La Sirena', '2024-01-16', '21:00', 0, 'Cancelada'),
    _ProductionOrder('ORD-005', 'REC-005', 'Vegetariana', '2024-01-17', '17:30', 12, 'Pendiente'),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = _orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
          order.recipeId.toLowerCase().contains(query) ||
          order.recipe.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden Producción',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_orders.length} órdenes registradas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID orden o receta...',
                        hintStyle: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.ink,
                          size: 28,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F5F4),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE8C7C4)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: PurchasesScreen.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    for (final order in filtered) ...[
                      _buildOrderCard(order),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _buildOrderCard(_ProductionOrder order) {
    final statusColor = _statusColor(order.status);
    final statusBackground = _statusBackground(order.status);
    final isCancelled = order.status == 'Cancelada';

    return Opacity(
      opacity: isCancelled ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: PurchasesScreen.page,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE1D8D6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _orderLabel('ID ORDEN'),
                      const SizedBox(height: 5),
                      Text(
                        order.id,
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _orderLabel('CANT. PRODUCIDA'),
                    const SizedBox(height: 5),
                    Text(
                      '${order.quantity}',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _orderLabel('RECETA'),
                        const SizedBox(height: 7),
                        Text(
                          order.recipeId,
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          order.recipe,
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.muted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _orderLabel('FECHA & HORA'),
                        const SizedBox(height: 7),
                        Text(
                          '▣  ${order.date}',
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '◷  ${order.time}',
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                GestureDetector(
                  onTap: isCancelled
                      ? null
                      : () => _showChangeOrderStatusDialog(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.status,
                          style: GoogleFonts.dmSerifDisplay(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isCancelled) const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ProductionOrderDetailScreen(order: order),
                    ),
                  ),
                  child: _orderAction(Icons.visibility_outlined),
                ),
                GestureDetector(
                  onTap: isCancelled
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  _ProductionOrderEditScreen(order: order),
                            ),
                          ),
                  child: _orderAction(Icons.edit_outlined, disabled: isCancelled),
                ),
                GestureDetector(
                  onTap: isCancelled ? null : () => _showDeleteOrderDialog(order),
                  child: _orderAction(
                    Icons.delete_outline,
                    disabled: isCancelled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSerifDisplay(
        color: PurchasesScreen.muted,
        fontSize: 11,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _orderAction(IconData icon, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Icon(
        icon,
        color: disabled ? const Color(0xFFB9ADAA) : PurchasesScreen.muted,
        size: 25,
      ),
    );
  }

  Future<void> _showChangeOrderStatusDialog(_ProductionOrder order) async {
    const statuses = ['Pendiente', 'En Proceso', 'Completada', 'Cancelada'];
    final nextStatus = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        var selectedStatus = order.status;

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
        backgroundColor: PurchasesScreen.page,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar estado de la orden',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD4F7E9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: PurchasesScreen.red),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: PurchasesScreen.red),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                items: [
                  for (final status in statuses)
                    DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: GoogleFonts.dmSerifDisplay(
                          color: const Color(0xFF087A65),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
                onChanged: (status) {
                  if (status != null) {
                    setState(() => selectedStatus = status);
                  }
                },
              ),
              if (selectedStatus != order.status) ...[
                const SizedBox(height: 18),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF9800),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'La orden ${order.id} pasará de:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statusPill(order.status)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 24),
                    ),
                    Expanded(child: _statusPill(selectedStatus)),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PurchasesScreen.red,
                        side: const BorderSide(color: PurchasesScreen.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedStatus == order.status
                          ? null
                          : () => Navigator.of(dialogContext).pop(selectedStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PurchasesScreen.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirmar',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
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
          ),
        );
      },
    );

    if (mounted && nextStatus != null && nextStatus != order.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} cambió a "$nextStatus".')),
      );
    }
  }

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor(status).withAlpha(80)),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSerifDisplay(
          color: _statusColor(status),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showDeleteOrderDialog(_ProductionOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar orden'),
        content: Text(
          '¿Seguro que deseas eliminar la orden ${order.id}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PurchasesScreen.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (mounted && confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} eliminada correctamente.')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E8B3C);
      case 'En Proceso':
        return const Color(0xFF806A68);
      case 'Pendiente':
        return const Color(0xFFB84B00);
      default:
        return PurchasesScreen.red;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFFB9F5B8);
      case 'En Proceso':
        return const Color(0xFFEDE6E4);
      case 'Pendiente':
        return const Color(0xFFF8D0A9);
      default:
        return const Color(0xFFFFE0E3);
    }
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
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductionOrder {
  const _ProductionOrder(
    this.id,
    this.recipeId,
    this.recipe,
    this.date,
    this.time,
    this.quantity,
    this.status,
  );

  final String id;
  final String recipeId;
  final String recipe;
  final String date;
  final String time;
  final int quantity;
  final String status;
}

class _ProductionOrderDetailScreen extends StatelessWidget {
  const _ProductionOrderDetailScreen({required this.order});

  final _ProductionOrder order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final statusBackground = _statusBackground(order.status);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 28, 30, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            '←  Volver a Producción',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.page,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    Text(
                      'Detalle',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '—',
                          style: TextStyle(
                            color: PurchasesScreen.muted,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          order.id,
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE1D8D6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Orden', order.id, mono: true),
                          _detailRow(
                            'ID Receta',
                            '${order.recipeId} — ${order.recipe}',
                          ),
                          _detailRow('Fecha Entrega', order.date),
                          _detailRow('Hora Entrega', order.time),
                          _detailRow('Inicio de Producción', _startTime(order.time)),
                          _detailRow(
                            'Cantidad Producida',
                            '${order.quantity} und.',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Estado Orden',
                                    style: GoogleFonts.dmSerifDisplay(
                                      color: PurchasesScreen.muted,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: GoogleFonts.dmSerifDisplay(
                                      color: statusColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F4F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Observación',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.muted,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  order.status == 'Completada'
                                      ? 'Turno mañana sin novedades.'
                                      : 'Pendiente de actualización.',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.ink,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 74),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE8C7C4)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE1D8D6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _startTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final startHour = (hour - 1).toString().padLeft(2, '0');
    return '$startHour:${parts.length > 1 ? parts[1] : '00'}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E8B3C);
      case 'En Proceso':
        return const Color(0xFF806A68);
      case 'Pendiente':
        return const Color(0xFFB84B00);
      default:
        return PurchasesScreen.red;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFFE3F2E5);
      case 'En Proceso':
        return const Color(0xFFEDE6E4);
      case 'Pendiente':
        return const Color(0xFFF8D0A9);
      default:
        return const Color(0xFFFFE0E3);
    }
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
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductionOrderEditScreen extends StatefulWidget {
  const _ProductionOrderEditScreen({required this.order});

  final _ProductionOrder order;

  @override
  State<_ProductionOrderEditScreen> createState() =>
      _ProductionOrderEditScreenState();
}

class _ProductionOrderEditScreenState
    extends State<_ProductionOrderEditScreen> {
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _observationController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.order.date);
    _timeController = TextEditingController(text: widget.order.time);
    _quantityController =
        TextEditingController(text: '${widget.order.quantity}');
    _observationController = TextEditingController(
      text: widget.order.status == 'Completada'
          ? 'Turno mañana sin novedades.'
          : 'Pendiente de actualización.',
    );
    _status = widget.order.status;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _quantityController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '—',
                          style: TextStyle(
                            color: PurchasesScreen.muted,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.order.id,
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8C7C4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editLabel('ID RECETA *'),
                          _readOnlyField(
                            '${widget.order.recipeId} — ${widget.order.recipe}',
                            Icons.menu_book_outlined,
                          ),
                          _editLabel('INICIO DE PRODUCCIÓN'),
                          _readOnlyField(
                            'Inicio: ${_startTime(widget.order.time)}   (20 min antes de ${widget.order.time})',
                            Icons.access_time,
                          ),
                          _editLabel('FECHA DE ENTREGA *'),
                          _textField(_dateController, Icons.calendar_today_outlined),
                          _editLabel('HORA DE ENTREGA (HH:MM) *'),
                          _textField(_timeController, Icons.access_time),
                          _editLabel('CANTIDAD PRODUCIDA'),
                          _textField(
                            _quantityController,
                            null,
                            keyboardType: TextInputType.number,
                          ),
                          _editLabel('ESTADO ORDEN'),
                          _statusField(),
                          _editLabel('OBSERVACIÓN'),
                          TextField(
                            controller: _observationController,
                            maxLines: 4,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 17,
                            ),
                            decoration: _fieldDecoration(null),
                          ),
                          const SizedBox(height: 22),
                          const Divider(color: Color(0xFFE8C7C4)),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.order.id} actualizado correctamente.',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurchasesScreen.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.ink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _editLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.dmSerifDisplay(
          color: PurchasesScreen.muted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _readOnlyField(String value, IconData icon) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _fieldDecoration(icon),
      style: GoogleFonts.dmSerifDisplay(color: PurchasesScreen.ink, fontSize: 17),
    );
  }

  Widget _textField(
    TextEditingController controller,
    IconData? icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _fieldDecoration(icon),
      style: GoogleFonts.dmSerifDisplay(color: PurchasesScreen.ink, fontSize: 17),
    );
  }

  InputDecoration _fieldDecoration(IconData? icon) {
    return InputDecoration(
      prefixIcon: icon == null ? null : Icon(icon, color: PurchasesScreen.muted),
      filled: true,
      fillColor: const Color(0xFFF7F3F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE4DEDC)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: PurchasesScreen.red),
      ),
    );
  }

  Widget _statusField() {
    return DropdownButtonFormField<String>(
      initialValue: _status,
      items: const [
        DropdownMenuItem(value: 'Completada', child: Text('Completada')),
        DropdownMenuItem(value: 'En Proceso', child: Text('En Proceso')),
        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _status = value);
      },
      decoration: _fieldDecoration(Icons.expand_more),
    );
  }

  String _startTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    return '${(hour - 1).toString().padLeft(2, '0')}:${parts.length > 1 ? parts[1] : '00'}';
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
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductionScreen extends StatelessWidget {
  const _ProductionScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Producción',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seleccione el módulo que desea gestionar.',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _productionCard(
                      icon: Icons.assignment_outlined,
                      title: 'Orden Producción',
                      description:
                          'Gestione las órdenes de producción diarias y su estado de preparación.',
                      highlighted: false,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _ProductionOrdersScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _productionCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Productos',
                      description:
                          'Administre el catálogo de productos disponibles para la producción y venta.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _ProductManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 72),
                    const ProductionSummaryCard(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _productionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(36, 36, 30, 32),
        decoration: BoxDecoration(
          color: PurchasesScreen.page,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE8C7C4), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -64,
              right: -42,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2C9CA),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9E8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: PurchasesScreen.ink,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 18,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ],
        ),
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
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

