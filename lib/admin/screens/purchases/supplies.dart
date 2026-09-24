part of '../purchases_screen.dart';

class _SupplyManagementScreen extends StatelessWidget {
  const _SupplyManagementScreen();

  static const _supplies = [
    _Supply(
      'INS-004',
      'CINS-004',
      'Harinas y Masas',
      'Masa Pre-elaborada',
      'und',
      50,
      20,
      '\$3.500',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-005',
      'CINS-003',
      'Vegetales y Hierbas',
      'Champiñones',
      'kg',
      4,
      5,
      '\$12.000',
      _SupplyStatus.low,
    ),
    _Supply(
      'INS-006',
      'CINS-001',
      'Carnes y Proteínas',
      'Pechuga de pollo',
      'kg',
      18,
      10,
      '\$18.500',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-007',
      'CINS-002',
      'Lácteos',
      'Queso mozzarella',
      'kg',
      25,
      12,
      '\$24.000',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-008',
      'CINS-005',
      'Salsas',
      'Salsa de tomate',
      'lt',
      14,
      8,
      '\$8.900',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-009',
      'CINS-006',
      'Vegetales y Hierbas',
      'Pimentón rojo',
      'kg',
      7,
      8,
      '\$6.500',
      _SupplyStatus.low,
    ),
    _Supply(
      'INS-010',
      'CINS-007',
      'Condimentos',
      'Orégano seco',
      'kg',
      6,
      3,
      '\$15.000',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-011',
      'CINS-008',
      'Empaques',
      'Caja para pizza',
      'und',
      120,
      50,
      '\$1.200',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-012',
      'CINS-009',
      'Bebidas',
      'Gaseosa personal',
      'und',
      36,
      20,
      '\$2.800',
      _SupplyStatus.ok,
    ),
  ];

  static final _wastes = <_InsumoWaste>[];

  @override
  Widget build(BuildContext context) {
    final lowCount = _supplies
        .where((supply) => supply.status == _SupplyStatus.low)
        .length;
    final emptyCount = _supplies
        .where((supply) => supply.status == _SupplyStatus.empty)
        .length;

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 86, 17, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _summaryChip(
                          '${_supplies.length}',
                          'Total insumos',
                          const Color(0xFFE8C7C4),
                        ),
                        const SizedBox(width: 8),
                        _summaryChip(
                          '$lowCount',
                          'Stock bajo',
                          const Color(0xFFF5D9A5),
                        ),
                        const SizedBox(width: 8),
                        _summaryChip(
                          '$emptyCount',
                          'Agotados',
                          const Color(0xFFF4C8CF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    for (final supply in _supplies) ...[
                      _buildSupplyCard(context, supply),
                      const SizedBox(height: 16),
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
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.red,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 24,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(
    String count,
    String label,
    Color borderColor,
  ) {
    final isWarning = label == 'Stock bajo';
    final isEmpty = label == 'Agotados';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFFFF3DF)
            : isEmpty
                ? const Color(0xFFFFE8EB)
                : PurchasesScreen.page,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.dmSerifDisplay(
            color: isWarning
                ? const Color(0xFFB65D0A)
                : isEmpty
                    ? PurchasesScreen.red
                    : PurchasesScreen.ink,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$count ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard(BuildContext context, _Supply supply) {
    final isLow = supply.status == _SupplyStatus.low;
    final isEmpty = supply.status == _SupplyStatus.empty;
    final statusColor = isLow || isEmpty
        ? PurchasesScreen.red
        : const Color(0xFF3D824B);
    final statusBackground = isLow || isEmpty
        ? const Color(0xFFFFE8EB)
        : const Color(0xFFE3F2E5);

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                supply.id,
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${supply.categoryId} • ${supply.category}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  isLow
                      ? 'Stock\nbajo'
                      : isEmpty
                          ? 'Agotado'
                          : 'O\nK',
                  style: GoogleFonts.dmSerifDisplay(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            supply.name,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Unidad: ${supply.unit}',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 12,
            ),
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: 'Stock actual: '),
                      TextSpan(
                        text: '${supply.current} ${supply.unit}',
                        style: TextStyle(
                          color: isLow ? PurchasesScreen.red : PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '\nStock mín.: '),
                      TextSpan(
                        text: '${supply.minimum} ${supply.unit}',
                        style: const TextStyle(
                          color: PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Precio unit.',
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    supply.price,
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _supplyAction(
                Icons.visibility_outlined,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SupplyDetailScreen(supply: supply),
                  ),
                ),
              ),
              _supplyAction(
                Icons.delete_outline,
                () => _showDeleteSupplyDialog(context, supply),
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _supplyAction(
    IconData icon,
    VoidCallback onPressed, {
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: danger
              ? const Color(0xFFFFD8D8)
              : const Color(0xFFF8F5F4),
        ),
        icon: Icon(
          icon,
          color: danger ? PurchasesScreen.red : PurchasesScreen.muted,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _showDeleteSupplyDialog(
    BuildContext context,
    _Supply supply,
  ) async {
    final result = await showDialog<({double amount, String unit})>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DeleteSupplyDialog(supply: supply),
    );

    if (result == null || !context.mounted) {
      return;
    }

    _wastes.add(
      _InsumoWaste(
        id: supply.id,
        amount: result.amount,
        unit: result.unit,
        date: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Insumo eliminado. Desperdicio registrado: '
          '${_formatAmount(result.amount)} ${result.unit}',
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
                    color: i == 1
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
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

enum _SupplyStatus { ok, low, empty }

class _Supply {
  const _Supply(
    this.id,
    this.categoryId,
    this.category,
    this.name,
    this.unit,
    this.current,
    this.minimum,
    this.price,
    this.status,
  );

  final String id;
  final String categoryId;
  final String category;
  final String name;
  final String unit;
  final int current;
  final int minimum;
  final String price;
  final _SupplyStatus status;
}

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toInt().toString();
  }
  return amount.toString();
}

class _InsumoWaste {
  const _InsumoWaste({
    required this.id,
    required this.amount,
    required this.unit,
    required this.date,
  });

  final String id;
  final double amount;
  final String unit;
  final DateTime date;
}

class _DeleteSupplyDialog extends StatefulWidget {
  const _DeleteSupplyDialog({required this.supply});

  final _Supply supply;

  @override
  State<_DeleteSupplyDialog> createState() => _DeleteSupplyDialogState();
}

class _DeleteSupplyDialogState extends State<_DeleteSupplyDialog> {
  static const _unitOptions = <(String, String)>[
    ('und', 'Unidad (und)'),
    ('kg', 'Kilogramo (kg)'),
    ('g', 'Gramo (g)'),
    ('lt', 'Litro (lt)'),
    ('L', 'Litro (L)'),
    ('ml', 'Mililitro (ml)'),
    ('lb', 'Libra (lb)'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _unit;

  _Supply get supply => widget.supply;

  @override
  void initState() {
    super.initState();
    _unit = supply.unit;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop((
        amount: double.parse(_amountController.text.trim().replaceAll(',', '.')),
        unit: _unit,
      ));
    }
  }

  String? _validateAmount(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa la cantidad a desperdiciar';
    }
    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (amount == null) {
      return 'Cantidad no válida';
    }
    if (amount < 0) {
      return 'No puede ser negativa';
    }
    if (_unit == 'und' && amount != amount.roundToDouble()) {
      return 'En unidades solo se permiten enteros';
    }
    if (_exceedsStock(amount, _unit)) {
      return 'No puede ser mayor al stock actual '
          '(${supply.current} ${supply.unit})';
    }
    return null;
  }

  bool _exceedsStock(double amount, String unit) {
    final supplyUnit = supply.unit;
    if (unit == supplyUnit) {
      return amount > supply.current;
    }
    if (!_compatibleUnits(unit, supplyUnit)) {
      return false;
    }
    return _toBaseUnit(unit, amount) >
        _toBaseUnit(supplyUnit, supply.current.toDouble());
  }

  static const _massUnits = {'kg', 'g', 'lb'};
  static const _volumeUnits = {'L', 'lt', 'ml'};

  bool _compatibleUnits(String a, String b) {
    if (a == b) return true;
    final bothMass = _massUnits.contains(a) && _massUnits.contains(b);
    final bothVolume = _volumeUnits.contains(a) && _volumeUnits.contains(b);
    return bothMass || bothVolume;
  }

  double _toBaseUnit(String unit, double value) {
    switch (unit) {
      case 'g':
        return value / 1000;
      case 'lb':
        return value * 0.45359237;
      case 'ml':
        return value / 1000;
      case 'kg':
      case 'L':
      case 'lt':
        return value;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(context),
            const Divider(
              color: AppColors.headerDivider,
              height: 1,
              thickness: 1,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indica cuánto de este insumo se desperdicia al '
                        'eliminarlo.',
                        style: GoogleFonts.dmSans(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stock actual: ${supply.current} ${supply.unit}',
                        style: GoogleFonts.dmSans(
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final amountField = _buildAmountField();
                          final unitField = _buildUnitField();
                          if (constraints.maxWidth < 380) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                amountField,
                                const SizedBox(height: 16),
                                unitField,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: amountField),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: unitField),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              color: AppColors.headerDivider,
              height: 1,
              thickness: 1,
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eliminar insumo',
                  style: GoogleFonts.dmSerifDisplay(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${supply.name} · ${supply.id}',
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad desperdiciada',
          style: GoogleFonts.dmSans(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          style: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.dmSans(color: AppColors.muted, fontSize: 15),
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.fieldFill),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            errorStyle: GoogleFonts.dmSans(color: AppColors.red, fontSize: 12),
          ),
          validator: _validateAmount,
        ),
      ],
    );
  }

  Widget _buildUnitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unidad de medida',
          style: GoogleFonts.dmSans(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _unit,
          isExpanded: true,
          borderRadius: BorderRadius.circular(24),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.fieldFill),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
          ),
          style: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 15),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
          items: [
            for (final (code, label) in _unitOptions)
              DropdownMenuItem(
                value: code,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 15),
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _unit = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.fieldBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplyDetailScreen extends StatelessWidget {
  const _SupplyDetailScreen({required this.supply});

  final _Supply supply;

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
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(16),
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
                      Row(
                        children: [
                          Text(
                            'Detalle',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '—',
                            style: TextStyle(
                              color: PurchasesScreen.muted,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            supply.id,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.muted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _supplyDetailRow('ID Insumo', supply.id, mono: true),
                      _supplyDetailRow(
                        'ID Cat. Insumo',
                        '${supply.categoryId} — ${supply.category}',
                      ),
                      _supplyDetailRow('Nombre', supply.name),
                      _supplyDetailRow('Unidad Medida', supply.unit),
                      _supplyDetailRow(
                        'Stock Actual',
                        '${supply.current} ${supply.unit}',
                      ),
                      _supplyDetailRow(
                        'Stock Mínimo',
                        '${supply.minimum} ${supply.unit}',
                      ),
                      _supplyDetailRow('Precio Unitario', supply.price),
                    ],
                  ),
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
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.red,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supplyDetailRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E0DE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                    ),
            ),
          ),
        ],
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
                    color: i == 1
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
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

