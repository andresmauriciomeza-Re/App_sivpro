part of '../purchases_screen.dart';

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() =>
      _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> {
  String _query = '';

  static const _providers = [
    _Provider(
      'PROV-001',
      'Distribuidora La Cosecha',
      '+57 300 123 4567',
      'ventas@lacosecha.com',
      'Calle 45 # 12-34, Zona Industrial',
      true,
    ),
    _Provider(
      'PROV-002',
      'Lácteos El Buen Pastor',
      '+57 311 987 6543',
      'pedidos@buenpastor.co',
      'Cra 22 # 8-15, Centro',
      true,
    ),
    _Provider(
      'PROV-003',
      'Empaques del Norte SAS',
      '+57 320 555 4433',
      'contacto@empaquesnorte.com',
      'Autopista Norte Km 5, Bodega 4',
      false,
    ),
    _Provider(
      'PROV-004',
      'Harinas y Cereales S.A.',
      '+57 601 234 5678',
      'proveedores@harinas.com',
      'Av. Boyacá # 72-10',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase().trim();
    final filtered = _providers.where((provider) {
      return provider.id.toLowerCase().contains(query) ||
          provider.name.toLowerCase().contains(query) ||
          provider.email.toLowerCase().contains(query);
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
                padding: const EdgeInsets.fromLTRB(20, 42, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_providers.length} proveedores registrados',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID, nombre o email...',
                        hintStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.muted,
                          size: 28,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FBFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: PurchasesScreen.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (final provider in filtered) ...[
                      _buildProviderCard(provider),
                      const SizedBox(height: 20),
                    ],
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            'No se encontraron proveedores.',
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.muted,
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
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'Gestión Proveedor',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0ECEB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GIV',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8E1118),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(_Provider provider) {
    final color = provider.active
        ? const Color(0xFF16813A)
        : const Color(0xFFD04444);
    final background = provider.active
        ? const Color(0xFFE2F3E5)
        : const Color(0xFFFFE6E8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DCDC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EEED),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            provider.id,
                            style: GoogleFonts.robotoMono(
                              color: PurchasesScreen.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            provider.active ? 'ACTIVO' : 'INACTIVO',
                            style: GoogleFonts.poppins(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.name,
                      style: GoogleFonts.poppins(
                        color: provider.active
                            ? PurchasesScreen.ink
                            : PurchasesScreen.muted,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _providerInfo(Icons.phone_outlined, provider.phone),
                    _providerInfo(Icons.mail_outline, provider.email),
                    _providerInfo(Icons.location_on_outlined, provider.address),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _providerAction(
                          Icons.visibility_outlined,
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ProviderDetailScreen(
                                provider: provider,
                              ),
                            ),
                          ),
                        ),
                        _providerAction(
                          Icons.edit_outlined,
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ProviderEditScreen(
                                provider: provider,
                              ),
                            ),
                          ),
                        ),
                        _providerAction(
                          Icons.delete_outline,
                          () => _showDeleteProviderDialog(provider),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerInfo(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, color: PurchasesScreen.muted, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerAction(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: PurchasesScreen.muted, size: 27),
      tooltip: 'Acción',
    );
  }

  Future<void> _showDeleteProviderDialog(_Provider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: PurchasesScreen.page,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Eliminar proveedor',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 17,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Seguro que deseas eliminar al proveedor\n',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EEED),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFE8C7C4),
                            ),
                          ),
                          child: Text(
                            provider.id,
                            style: GoogleFonts.robotoMono(
                              color: PurchasesScreen.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: '? Esta acción no se puede deshacer.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurchasesScreen.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE8C7C4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
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
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${provider.id} eliminado correctamente.')),
    );
  }

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
                  Icon(
                    items[i].$1,
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
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

class _Provider {
  const _Provider(
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.active,
  );

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool active;
}

class _ProviderDetailScreen extends StatelessWidget {
  const _ProviderDetailScreen({required this.provider});

  final _Provider provider;

  @override
  Widget build(BuildContext context) {
    final statusColor = provider.active
        ? const Color(0xFF16813A)
        : const Color(0xFFD04444);
    final statusBackground = provider.active
        ? const Color(0xFFE2F3E5)
        : const Color(0xFFFFE6E8);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Detalle',
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 34,
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
                          provider.id,
                          style: GoogleFonts.robotoMono(
                            color: PurchasesScreen.muted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8C7C4)),
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Proveedor', provider.id, mono: true),
                          _detailRow('Nombre', provider.name),
                          _detailRow(
                            'Teléfono',
                            provider.phone,
                            accent: true,
                          ),
                          _detailRow(
                            'Email',
                            provider.email,
                            accent: true,
                          ),
                          _detailRow('Dirección', provider.address),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Estado',
                                    style: GoogleFonts.poppins(
                                      color: PurchasesScreen.muted,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    '• ${provider.active ? 'Activo' : 'Inactivo'}',
                                    style: GoogleFonts.robotoMono(
                                      color: statusColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PurchasesScreen.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool mono = false,
    bool accent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE3DAD8))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: mono
                  ? GoogleFonts.robotoMono(
                      color: PurchasesScreen.ink,
                      fontSize: 15,
                    )
                  : GoogleFonts.poppins(
                      color: accent
                          ? const Color(0xFF9B2931)
                          : PurchasesScreen.ink,
                      fontSize: 16,
                      height: 1.35,
                      decoration: accent
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i].$1,
                  color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                ),
                Text(
                  items[i].$2,
                  style: GoogleFonts.poppins(
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProviderEditScreen extends StatefulWidget {
  const _ProviderEditScreen({required this.provider});

  final _Provider provider;

  @override
  State<_ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends State<_ProviderEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _phoneController = TextEditingController(text: widget.provider.phone);
    _emailController = TextEditingController(text: widget.provider.email);
    _addressController = TextEditingController(text: widget.provider.address);
    _isActive = widget.provider.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8C7C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Proveedor',
                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFE4C4C1)),
                      const SizedBox(height: 22),
                      _buildStatusField(),
                      const SizedBox(height: 28),
                      _buildField(
                        label: 'NOMBRE DE EMPRESA / CONTACTO',
                        controller: _nameController,
                        icon: Icons.storefront_outlined,
                      ),
                      _buildField(
                        label: 'TELÉFONO PRINCIPAL',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildField(
                        label: 'CORREO ELECTRÓNICO',
                        controller: _emailController,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildField(
                        label: 'DIRECCIÓN FÍSICA',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 30,
            ),
          ),
          Text(
            'Editar',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '—',
            style: TextStyle(color: PurchasesScreen.muted, fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            widget.provider.id,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.muted,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8C7C4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_checked,
            color: PurchasesScreen.muted,
            size: 29,
          ),
          const SizedBox(width: 14),
          Text(
            'Estado',
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: _isActive,
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: true, child: Text('Activo')),
                DropdownMenuItem(value: false, child: Text('Inactivo')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _isActive = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.ink,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: PurchasesScreen.muted, size: 28),
              filled: true,
              fillColor: const Color(0xFFF7F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 17,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5BCB9), width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: PurchasesScreen.red,
                side: const BorderSide(color: PurchasesScreen.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
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
          const SizedBox(width: 22),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.provider.name} actualizado correctamente.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PurchasesScreen.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
        ],
      ),
    );
  }
}

