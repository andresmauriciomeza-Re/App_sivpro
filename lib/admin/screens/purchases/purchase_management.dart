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
    _Purchase('COM-001', 'Distribuidora La Cosecha', '2024-01-10', '\$119.000', 'Enviado'),
    _Purchase('COM-002', 'Carnes Premium Ltda.', '2024-01-12', '\$178.500', 'En Proceso'),
    _Purchase('COM-003', 'Quesos del Norte S.A.S.', '2024-01-14', '\$59.500', 'Enviado'),
    _Purchase('COM-004', 'Distribuidora La Cosecha', '2024-01-15', '\$238.000', 'Anulado'),
    _Purchase('COM-005', 'Bebidas y Más', '2024-01-16', '\$89.250', 'En Proceso'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _purchases.where((purchase) {
      final query = _query.toLowerCase();
      return purchase.id.toLowerCase().contains(query) ||
          purchase.provider.toLowerCase().contains(query);
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
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_purchases.length} compras registradas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID o proveedor...',
                        hintStyle: GoogleFonts.dmSerifDisplay(color: PurchasesScreen.ink),
                        prefixIcon: const Icon(Icons.search, color: PurchasesScreen.ink),
                        filled: true,
                        fillColor: const Color(0xFFFFFBFA),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE8DDDB)),
                        ),
                      ),
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
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(_Purchase purchase) {
    final statusColor = purchase.status == 'Enviado'
        ? const Color(0xFF2E7D32)
        : purchase.status == 'Anulado'
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE67E00);
    final statusBackground = purchase.status == 'Enviado'
        ? const Color(0xFFE4F4E7)
        : purchase.status == 'Anulado'
            ? const Color(0xFFFFE3E6)
            : const Color(0xFFFFF0D8);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDDB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('ID COMPRA'),
                  Text(purchase.id, style: GoogleFonts.dmSerifDisplay(fontSize: 18)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showChangeStatusDialog(context, purchase, 'Recibido'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '${purchase.status} ⌄',
                    style: GoogleFonts.dmSerifDisplay(color: statusColor, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('PROVEEDOR'), Text(purchase.provider)],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('FECHA'), Text(purchase.date)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE8DDDB)),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('TOTAL'),
                  Text(
                    purchase.total,
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _PurchaseDetailScreen(purchase: purchase),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                ),
              ),
            ],
          ),
        ],
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
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 17,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Deseas cambiar el estado de la compra\n',
                      ),
                      TextSpan(
                        text: purchase.id,
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
                      style: GoogleFonts.dmSerifDisplay(
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
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${purchase.id} cambió a "$targetStatus" correctamente.',
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSerifDisplay(
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
                  Icon(items[i].$1, color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted),
                  Text(items[i].$2, style: GoogleFonts.dmSerifDisplay(color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Purchase {
  const _Purchase(this.id, this.provider, this.date, this.total, this.status);

  final String id;
  final String provider;
  final String date;
  final String total;
  final String status;
}

class _PurchaseDetailScreen extends StatelessWidget {
  const _PurchaseDetailScreen({required this.purchase});

  final _Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final isReceived = purchase.status == 'Recibido';
    final statusColor = purchase.status == 'Enviado'
        ? AppColors.bannerGreenFg
        : purchase.status == 'Anulado'
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE67E00);
    final statusBackground = purchase.status == 'Enviado'
        ? AppColors.bannerGreenBg
        : purchase.status == 'Anulado'
            ? const Color(0xFFFFE3E6)
            : const Color(0xFFFFF0D8);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, statusColor, statusBackground),
            const Divider(color: AppColors.headerDivider, height: 1, thickness: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(isReceived),
                    const SizedBox(height: 16),
                    _readOnlyField('N° Orden de Compra', purchase.id),
                    const SizedBox(height: 14),
                    _readOnlyField('N° Factura', '—'),
                    const SizedBox(height: 14),
                    _readOnlyField('Fecha de factura', '—'),
                    const SizedBox(height: 14),
                    _readOnlyField('Valor total', purchase.total),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.headerDivider, height: 1, thickness: 1),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color statusColor,
    Color statusBackground,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle de Compra',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión ${purchase.id} · ${purchase.provider}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _statusChip(purchase.status, statusColor, statusBackground),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(bool isReceived) {
    final bg = isReceived ? AppColors.bannerGreenBg : AppColors.bannerBlueBg;
    final borderColor =
        isReceived ? AppColors.bannerGreenBorder : AppColors.bannerBlueBorder;
    final fg = isReceived ? AppColors.bannerGreenFg : AppColors.bannerBlueFg;
    final message = isReceived
        ? 'Factura registrada. Esta gestión ya no puede modificarse.'
        : 'Esta gestión proviene de la Orden de Compra ${purchase.id}. '
            'Las cantidades solicitadas son de solo lectura.';

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
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: fg,
                fontSize: 13,
                height: 1.35,
              ),
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
          style: GoogleFonts.dmSans(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: AppColors.ink,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildSuppliesCards() {
    const insumos = [
      ('INS-001', 'Harina de trigo', '100', '0', 'kg', '\$ 3.500'),
      ('INS-006', 'Levadura', '5000', '0', 'g', '\$ 80'),
    ];
    return Column(
      children: [
        for (var i = 0; i < insumos.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _SupplyCard(insumo: insumos[i]),
        ],
      ],
    );
  }

  // ignore: unused_element
  Widget _buildLotesCard(bool isReceived) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.page,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.headerDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usar lotes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra fecha de vencimiento por insumo (calculada automáticamente: recepción + 7 días)',
                  style: GoogleFonts.dmSerifDisplay(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isReceived,
            onChanged: isReceived ? (_) {} : null,
            activeThumbColor: AppColors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.fieldBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            'Cerrar',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: GoogleFonts.dmSerifDisplay(color: color, fontSize: 12)),
    );
  }
}

class _SupplyCard extends StatelessWidget {
  const _SupplyCard({required this.insumo});

  final (String, String, String, String, String, String) insumo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.headerDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  insumo.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                insumo.$1,
                style: GoogleFonts.dmSerifDisplay(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cell('Solicitado', insumo.$3),
              _cell('Recibido', insumo.$4),
              _cell('Unidad', insumo.$5),
              _cell('P. unit.', insumo.$6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.ink,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
