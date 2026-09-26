part of '../purchases_screen.dart';

class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() =>
      _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  String _query = '';

  static const _purchases = [
    _Purchase(
      'Distribuidora La Cosecha',
      '2024-01-10',
      'FAC-001',
      '\$119.000',
      'Recibido',
      [
        _SupplyItem(
          name: 'Harina de trigo',
          quantity: '100',
          unit: 'kg',
          unitPrice: '\$1.200',
          subtotal: '\$120.000',
        ),
        _SupplyItem(
          name: 'Aceite vegetal',
          quantity: '20',
          unit: 'L',
          unitPrice: '\$8.500',
          subtotal: '\$170.000',
        ),
        _SupplyItem(
          name: 'Tomate',
          quantity: '50',
          unit: 'kg',
          unitPrice: '\$900',
          subtotal: '\$45.000',
        ),
      ],
    ),
    _Purchase(
      'Carnes Premium Ltda.',
      '2024-01-12',
      'FAC-002',
      '\$178.500',
      'Recibido',
      [
        _SupplyItem(
          name: 'Pollo entero',
          quantity: '80',
          unit: 'kg',
          unitPrice: '\$2.100',
          subtotal: '\$168.000',
        ),
        _SupplyItem(
          name: 'Cerdo',
          quantity: '30',
          unit: 'kg',
          unitPrice: '\$4.500',
          subtotal: '\$135.000',
        ),
        _SupplyItem(
          name: 'Tocino',
          quantity: '10',
          unit: 'kg',
          unitPrice: '\$6.000',
          subtotal: '\$60.000',
        ),
      ],
    ),
    _Purchase(
      'Quesos del Norte S.A.S.',
      '2024-01-14',
      'FAC-003',
      '\$59.500',
      'Recibido',
      [
        _SupplyItem(
          name: 'Queso mozzarella',
          quantity: '25',
          unit: 'kg',
          unitPrice: '\$3.200',
          subtotal: '\$80.000',
        ),
        _SupplyItem(
          name: 'Queso parmesano',
          quantity: '10',
          unit: 'kg',
          unitPrice: '\$7.500',
          subtotal: '\$75.000',
        ),
      ],
    ),
    _Purchase(
      'Distribuidora La Cosecha',
      '2024-01-15',
      'FAC-004',
      '\$238.000',
      'Anulado',
      [
        _SupplyItem(
          name: 'Harina de trigo',
          quantity: '200',
          unit: 'kg',
          unitPrice: '\$1.200',
          subtotal: '\$240.000',
        ),
        _SupplyItem(
          name: 'Levadura',
          quantity: '5',
          unit: 'kg',
          unitPrice: '\$15.000',
          subtotal: '\$75.000',
        ),
        _SupplyItem(
          name: 'Azúcar',
          quantity: '50',
          unit: 'kg',
          unitPrice: '\$1.800',
          subtotal: '\$90.000',
        ),
      ],
    ),
    _Purchase('Bebidas y Más', '2024-01-16', 'FAC-005', '\$89.250', 'Anulado', [
      _SupplyItem(
        name: 'Gaseosa cola',
        quantity: '120',
        unit: 'un',
        unitPrice: '\$1.500',
        subtotal: '\$180.000',
      ),
      _SupplyItem(
        name: 'Jugo natural',
        quantity: '60',
        unit: 'un',
        unitPrice: '\$1.200',
        subtotal: '\$72.000',
      ),
      _SupplyItem(
        name: 'Agua mineral',
        quantity: '100',
        unit: 'un',
        unitPrice: '\$800',
        subtotal: '\$80.000',
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _purchases.where((purchase) {
      final query = _query.toLowerCase();
      return purchase.provider.toLowerCase().contains(query) ||
          purchase.invoiceNumber.toLowerCase().contains(query);
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
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión Compras',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_purchases.length} compras registradas',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                    AppSearchField(
                      hint: 'Buscar por proveedor o N° de factura...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 24),
                    ...filtered.map(_buildPurchaseCard),
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

  Widget _buildPurchaseCard(_Purchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDDB)),
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
                child: Text(
                  purchase.provider,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusDropdown(
                currentStatus: purchase.status,
                onStatusChanged: (newStatus) {
                  _showChangeStatusDialog(context, purchase, newStatus);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('FECHA DE FACTURA'),
                    Text(
                      purchase.date,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.ink,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('N° DE FACTURA'),
                    Text(
                      purchase.invoiceNumber,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.ink,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  purchase.total,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _navigateToDetail(context, purchase),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, _Purchase purchase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PurchaseDetailScreen(purchase: purchase),
      ),
    );
  }

  Future<void> _showChangeStatusDialog(
    BuildContext context,
    _Purchase purchase,
    String targetStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: PurchasesScreen.red,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cambiar estado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: PurchasesScreen.ink,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 17,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Deseas cambiar el estado de la compra\n',
                      ),
                      TextSpan(
                        text: purchase.invoiceNumber,
                        style: const TextStyle(
                          color: PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' a "$targetStatus"?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PurchasesScreen.ink,
                      side: const BorderSide(color: PurchasesScreen.muted),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurchasesScreen.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sí, confirmar',
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
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${purchase.invoiceNumber} cambió a "$targetStatus" correctamente.',
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      color: PurchasesScreen.muted,
      fontSize: 11,
      letterSpacing: 0.3,
    ),
  );

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
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1
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

class _SupplyItem {
  const _SupplyItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.subtotal,
  });

  final String name;
  final String quantity;
  final String unit;
  final String unitPrice;
  final String subtotal;
}

class _Purchase {
  const _Purchase(
    this.provider,
    this.date,
    this.invoiceNumber,
    this.total,
    this.status,
    this.supplies,
  );

  final String provider;
  final String date;
  final String invoiceNumber;
  final String total;
  final String status;
  final List<_SupplyItem> supplies;
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isReceived = currentStatus == 'Recibido';
    final statusColor = isReceived
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);
    final statusBackground = isReceived
        ? const Color(0xFFE4F4E7)
        : const Color(0xFFFFE3E6);

    return PopupMenuButton<String>(
      onSelected: onStatusChanged,
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE8DDDB)),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'Recibido',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Recibido',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (currentStatus == 'Recibido')
                const Icon(Icons.check, color: Color(0xFF2E7D32), size: 18),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Anulado',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE3E6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Anulado',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD32F2F),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (currentStatus == 'Anulado')
                const Icon(Icons.check, color: Color(0xFFD32F2F), size: 18),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: statusBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStatus,
              style: GoogleFonts.poppins(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: statusColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _PurchaseDetailScreen extends StatelessWidget {
  const _PurchaseDetailScreen({required this.purchase});

  final _Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final statusColor = purchase.status == 'Recibido'
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);
    final statusBackground = purchase.status == 'Recibido'
        ? const Color(0xFFE4F4E7)
        : const Color(0xFFFFE3E6);

    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalle de Compra',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              purchase.provider,
              style: GoogleFonts.montserrat(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              purchase.status,
              style: GoogleFonts.poppins(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            _readOnlyField('N° Factura', purchase.invoiceNumber),
            const SizedBox(height: 14),
            _readOnlyField('Fecha de factura', purchase.date),
            const SizedBox(height: 14),
            _readOnlyField('Proveedor', purchase.provider),
            const SizedBox(height: 14),
            _readOnlyField('Valor total', purchase.total),
            const SizedBox(height: 24),
            _buildSuppliesList(purchase),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final bg = AppColors.bannerGreenBg;
    final borderColor = AppColors.bannerGreenBorder;
    final fg = AppColors.bannerGreenFg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Factura registrada. Esta gestión ya no puede modificarse.',
              style: GoogleFonts.poppins(color: fg, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.fieldFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSuppliesList(_Purchase purchase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insumos solicitados',
          style: GoogleFonts.montserrat(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.headerDivider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < purchase.supplies.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.headerDivider),
                _buildSupplyCard(purchase.supplies[i]),
              ],
              const Divider(height: 1, color: AppColors.headerDivider),
              _buildTotalFooter(purchase.total),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplyCard(_SupplyItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Text(
                item.subtotal,
                style: GoogleFonts.poppins(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} ${item.unit}',
                style: GoogleFonts.poppins(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              Text(
                '${item.unitPrice} c/u',
                style: GoogleFonts.poppins(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter(String total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.poppins(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            total,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.red,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
