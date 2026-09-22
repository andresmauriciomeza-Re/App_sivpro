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
                        fontSize: 31,
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
                        hintStyle: GoogleFonts.poppins(color: PurchasesScreen.ink),
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
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: PurchasesScreen.muted),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
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
              color: Color(0xFFD9565C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'GI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  Text(purchase.id, style: GoogleFonts.robotoMono(fontSize: 18)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${purchase.status} ⌄',
                  style: GoogleFonts.poppins(color: statusColor, fontSize: 12),
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
                    style: GoogleFonts.robotoMono(
                      color: PurchasesScreen.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _PurchaseDetailScreen(purchase: purchase),
                  ),
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.robotoMono(
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
      (Icons.more_horiz, 'Más'),
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
                  Text(items[i].$2, style: GoogleFonts.poppins(color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted, fontSize: 12)),
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
        ? const Color(0xFF2E7D32)
        : purchase.status == 'Anulado'
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE67E00);
    final statusBackground = purchase.status == 'Enviado'
        ? const Color(0xFFE4F4E7)
        : purchase.status == 'Anulado'
            ? const Color(0xFFFFE3E6)
            : const Color(0xFFFFF0D8);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, statusColor, statusBackground),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFB7D1F5)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: GoogleFonts.dmSerifDisplay(
                            color: const Color(0xFF304A72),
                            fontSize: 16,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(text: 'ⓘ   Esta gestión proviene de la '),
                            TextSpan(
                              text: 'Orden de Compra ${purchase.id}.',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  ' Las cantidades solicitadas son de solo lectura; solo puedes editar las cantidades recibidas cuando el estado sea Recibido.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 52),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _detailValue('PROVEEDOR', purchase.provider)),
                        Expanded(child: _detailValue('FECHA', purchase.date)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailLabel('ESTADO'),
                              const SizedBox(height: 10),
                              _statusChip(
                                purchase.status,
                                statusColor,
                                statusBackground,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'INSUMOS SOLICITADOS VS. RECIBIDOS',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSuppliesTable(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8DDDB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'USAR LOTES',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Registra fecha de vencimiento por insumo (calculada automáticamente: recepción + 7 días)',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.muted,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isReceived,
                            onChanged: isReceived ? (_) {} : null,
                            activeThumbColor: PurchasesScreen.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(context, isReceived),
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
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Compra · ${purchase.id}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Vinculada a Orden de Compra: ${purchase.id} · ${purchase.provider}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _statusChip(purchase.status, statusColor, statusBackground),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: PurchasesScreen.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliesTable() {
    const rows = [
      ('INS-001', 'Harina de trigo', '100', '0', 'kg', '\$ 3.500'),
      ('INS-006', 'Levadura', '5000', '0', 'g', '\$ 80'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDDB)),
      ),
      child: Column(
        children: [
          const _SupplyRow(
            values: ['ID', 'NOMBRE', 'SOLIC.', 'RECIB.', 'UNIDAD', 'P. UNIT.'],
            header: true,
          ),
          for (final row in rows)
            _SupplyRow(values: [row.$1, row.$2, row.$3, row.$4, row.$5, row.$6]),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'TOTAL RECIBIDO',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isReceived) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
        border: Border(top: BorderSide(color: Color(0xFFE8DDDB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showChangeStatusDialog(context, 'Anulado'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PurchasesScreen.red,
                side: const BorderSide(color: PurchasesScreen.red),
              ),
              child: const Text('Anular Compra'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isReceived
                  ? null
                  : () => _showChangeStatusDialog(context, 'Recibido'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Recibido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F63),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeStatusDialog(
    BuildContext context,
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

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${purchase.id} cambió a "$targetStatus" correctamente.',
        ),
      ),
    );
  }

  Widget _detailValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_detailLabel(label), const SizedBox(height: 8), Text(value)],
    );
  }

  Widget _detailLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.robotoMono(
        color: PurchasesScreen.muted,
        fontSize: 12,
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
      child: Text(text, style: GoogleFonts.poppins(color: color, fontSize: 12)),
    );
  }
}

class _SupplyRow extends StatelessWidget {
  const _SupplyRow({required this.values, this.header = false});

  final List<String> values;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8DDDB))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              flex: i == 1 ? 2 : 1,
              child: Text(
                values[i],
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: header ? 12 : 13,
                  fontWeight: header ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
