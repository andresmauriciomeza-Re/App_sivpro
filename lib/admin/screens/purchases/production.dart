part of '../purchases_screen.dart';

class _ProductionOrdersScreen extends StatefulWidget {
  const _ProductionOrdersScreen();

  @override
  State<_ProductionOrdersScreen> createState() =>
      _ProductionOrdersScreenState();
}

class _ProductionOrdersScreenState extends State<_ProductionOrdersScreen> {
  String _query = '';

  /// `productId` es el producto de "Gestión Producto" que esta orden produce:
  /// al completarse la orden, su cantidad producida se suma a ese stock.
  static final List<_ProductionOrder> _orders = [
    _ProductionOrder(
      'ORD-001',
      'REC-001',
      'Margarita Clásica',
      '2024-01-15',
      '19:00',
      20,
      'Completada',
      'PROD-001',
      const [
        _ProductionStatusChange('Completada', '15/01/2024 19:42'),
        _ProductionStatusChange('En Proceso', '15/01/2024 18:20'),
        _ProductionStatusChange('Pendiente', '15/01/2024 17:05'),
      ],
    ),
    _ProductionOrder(
      'ORD-002',
      'REC-002',
      'Pepperoni Premium',
      '2024-01-15',
      '20:30',
      15,
      'En Proceso',
      'PROD-002',
      const [
        _ProductionStatusChange('En Proceso', '15/01/2024 19:10'),
        _ProductionStatusChange('Pendiente', '15/01/2024 18:02'),
      ],
    ),
    _ProductionOrder(
      'ORD-003',
      'REC-003',
      'Cuatro Quesos',
      '2024-01-16',
      '18:00',
      10,
      'Pendiente',
      'PROD-003',
      const [_ProductionStatusChange('Pendiente', '15/01/2024 16:40')],
    ),
    _ProductionOrder(
      'ORD-004',
      'REC-004',
      'Especial La Sirena',
      '2024-01-16',
      '21:00',
      0,
      'Cancelada',
      'PROD-004',
      const [
        _ProductionStatusChange('Cancelada', '15/01/2024 14:25'),
        _ProductionStatusChange('Pendiente', '15/01/2024 13:55'),
      ],
    ),
    _ProductionOrder(
      'ORD-005',
      'REC-005',
      'Vegetariana',
      '2024-01-17',
      '17:30',
      12,
      'Pendiente',
      'PROD-005',
      const [_ProductionStatusChange('Pendiente', '15/01/2024 17:20')],
    ),
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
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_orders.length} órdenes registradas',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppSearchField(
                      hint: 'Buscar por ID orden o receta...',
                      onChanged: (value) => setState(() => _query = value),
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
                        style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          order.recipe,
                          style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.ink,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '◷  ${order.time}',
                          style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isCancelled)
                          const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          _ProductionOrderDetailScreen(order: order),
                    ),
                  ),
                  child: _orderAction(Icons.visibility_outlined),
                ),
                GestureDetector(
                  onTap: isCancelled ? null : () => _openEditOrder(order),
                  child: _orderAction(
                    Icons.edit_outlined,
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
      style: GoogleFonts.poppins(
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
                    style: GoogleFonts.montserrat(
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
                        borderSide: const BorderSide(
                          color: PurchasesScreen.red,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: PurchasesScreen.red,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    items: [
                      for (final status in statuses)
                        DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
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
                            style: GoogleFonts.poppins(
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
                              : () => Navigator.of(
                                  dialogContext,
                                ).pop(selectedStatus),
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
                            style: GoogleFonts.poppins(
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
      _applyOrderUpdate(
        order,
        order.copyWith(status: nextStatus),
        '${order.id} cambió a "$nextStatus".',
      );
    }
  }

  /// Guarda la orden actualizada y, si pasó a "Completada", suma la cantidad
  /// producida al stock del producto en "Gestión Producto".
  void _applyOrderUpdate(
    _ProductionOrder previous,
    _ProductionOrder updated,
    String successMessage,
  ) {
    // Cada transición de estado queda fechada en el historial de la orden.
    final conHistorial = updated.withStatusChange(updated.status);
    final index = _orders.indexWhere((item) => item.id == previous.id);
    if (index >= 0) _orders[index] = conHistorial;
    setState(() {});

    final stock = _sumarStockProducido(previous, conHistorial);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          stock == null ? successMessage : '$successMessage $stock',
        ),
      ),
    );
  }

  /// Suma la cantidad producida al stock del producto y devuelve el detalle del
  /// ajuste, o `null` si el stock no tenía que cambiar.
  ///
  /// Solo suma en la transición a "Completada", así una orden que ya estaba
  /// completada no duplica stock.
  String? _sumarStockProducido(
    _ProductionOrder previous,
    _ProductionOrder updated,
  ) {
    if (previous.status == updated.status) return null;
    if (updated.status != 'Completada') return null;

    final repositorio = ProductsRepository.instance;
    final stockAntes = repositorio.stockOf(updated.productId);
    final stockDespues = repositorio.addStock(
      updated.productId,
      updated.quantity,
    );
    if (stockDespues == null) return null;
    return 'Stock de ${updated.recipe}: $stockAntes → $stockDespues und.';
  }

  Future<void> _openEditOrder(_ProductionOrder order) async {
    final updated = await Navigator.of(context).push<_ProductionOrder>(
      MaterialPageRoute(
        builder: (_) => _ProductionOrderEditScreen(order: order),
      ),
    );
    if (updated == null || !mounted) return;

    _applyOrderUpdate(order, updated, '${order.id} actualizado correctamente.');
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
        style: GoogleFonts.poppins(
          color: _statusColor(status),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
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
    this.productId, [
    this.statusHistory = const [],
  ]);

  final String id;
  final String recipeId;
  final String recipe;
  final String date;
  final String time;
  final int quantity;
  final String status;

  /// Producto de "Gestión Producto" que esta orden produce (PROD-001, ...).
  final String productId;

  /// Transiciones de estado de la orden, de la más reciente a la más antigua.
  final List<_ProductionStatusChange> statusHistory;

  _ProductionOrder copyWith({
    String? date,
    String? time,
    int? quantity,
    String? status,
    List<_ProductionStatusChange>? statusHistory,
  }) => _ProductionOrder(
    id,
    recipeId,
    recipe,
    date ?? this.date,
    time ?? this.time,
    quantity ?? this.quantity,
    status ?? this.status,
    productId,
    statusHistory ?? this.statusHistory,
  );

  /// Copia la orden con [status] y su transición fechada en el historial. Si el
  /// estado no cambia devuelve la misma orden para no duplicar historial.
  _ProductionOrder withStatusChange(String status) {
    if (status == this.status) return this;
    return copyWith(
      status: status,
      statusHistory: [_ProductionStatusChange.now(status), ...statusHistory],
    );
  }
}

/// Cambio de estado de una orden, con la fecha en que ocurrió la transición.
class _ProductionStatusChange {
  const _ProductionStatusChange(this.status, this.date);

  final String status;
  final String date;

  /// Transición generada en este momento, con fecha y hora de hoy.
  factory _ProductionStatusChange.now(String status) {
    final momento = DateTime.now();
    final dia = momento.day.toString().padLeft(2, '0');
    final mes = momento.month.toString().padLeft(2, '0');
    final hora = momento.hour.toString().padLeft(2, '0');
    final minuto = momento.minute.toString().padLeft(2, '0');
    return _ProductionStatusChange(
      status,
      '$dia/$mes/${momento.year} $hora:$minuto',
    );
  }
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
                            style: GoogleFonts.poppins(
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
                      style: GoogleFonts.montserrat(
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
                          style: GoogleFonts.poppins(
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
                          _detailRow(
                            'Inicio de Producción',
                            _startTime(order.time),
                          ),
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
                                    style: GoogleFonts.poppins(
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
                                    style: GoogleFonts.poppins(
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
                                  style: GoogleFonts.poppins(
                                    color: PurchasesScreen.muted,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  order.status == 'Completada'
                                      ? 'Turno mañana sin novedades.'
                                      : 'Pendiente de actualización.',
                                  style: GoogleFonts.poppins(
                                    color: PurchasesScreen.ink,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _statusHistory(order.statusHistory),
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
                          style: GoogleFonts.poppins(
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

  /// Historial de cambios de estado, con la fecha de cada transición.
  Widget _statusHistory(List<_ProductionStatusChange> history) {
    return Container(
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
            'Historial de Estados',
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            Text(
              'Sin cambios de estado registrados.',
              style: GoogleFonts.poppins(
                color: PurchasesScreen.ink,
                fontSize: 17,
              ),
            )
          else
            for (var i = 0; i < history.length; i++) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackground(history[i].status),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      history[i].status,
                      style: GoogleFonts.poppins(
                        color: _statusColor(history[i].status),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      history[i].date,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (i != history.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFE1D8D6), height: 1),
                ),
            ],
        ],
      ),
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
              style: GoogleFonts.poppins(
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
                  ? GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.poppins(
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
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
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
    _quantityController = TextEditingController(
      text: '${widget.order.quantity}',
    );
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
                      style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
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
                          _textField(
                            _dateController,
                            Icons.calendar_today_outlined,
                          ),
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
                            style: GoogleFonts.poppins(
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
                              onPressed: _guardarOrden,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurchasesScreen.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: GoogleFonts.poppins(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(
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

  /// Devuelve la orden ya actualizada para que "Orden Producción" la guarde y
  /// sume el stock si quedó "Completada".
  void _guardarOrden() {
    final quantity = int.tryParse(_quantityController.text.trim());
    Navigator.of(context).pop(
      widget.order.copyWith(
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        quantity: quantity != null && quantity >= 0 ? quantity : null,
        status: _status,
      ),
    );
  }

  Widget _editLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
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
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 17),
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
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 17),
    );
  }

  InputDecoration _fieldDecoration(IconData? icon) {
    return InputDecoration(
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: PurchasesScreen.muted),
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
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Producción',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seleccione el módulo que desea gestionar.',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
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
        padding: const EdgeInsets.fromLTRB(25, 25, 21, 22),
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
                  child: Icon(icon, color: PurchasesScreen.ink, size: 46),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.poppins(
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
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
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
