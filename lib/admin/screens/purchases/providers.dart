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
      '900.123.456-1',
      'Distribuidora La Cosecha',
      '+57 300 123 4567',
      'ventas@lacosecha.com',
      'Calle 45 # 12-34, Zona Industrial',
      true,
      'Carlos Mendoza',
    ),
    _Provider(
      'PROV-002',
      '800.654.321-2',
      'Lácteos El Buen Pastor',
      '+57 311 987 6543',
      'pedidos@buenpastor.co',
      'Cra 22 # 8-15, Centro',
      true,
      'Ana María Ruiz',
    ),
    _Provider(
      'PROV-003',
      '700.111.222-3',
      'Empaques del Norte SAS',
      '+57 320 555 4433',
      'contacto@empaquesnorte.com',
      'Autopista Norte Km 5, Bodega 4',
      false,
      null,
    ),
    _Provider(
      'PROV-004',
      '901.777.888-4',
      'Harinas y Cereales S.A.',
      '+57 601 234 5678',
      'proveedores@harinas.com',
      'Av. Boyacá # 72-10',
      true,
      'Luis Fernando Torres',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase().trim();
    final filtered = _providers.where((provider) {
      return provider.id.toLowerCase().contains(query) ||
          provider.nit.toLowerCase().contains(query) ||
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proveedores',
                          style: GoogleFonts.montserrat(
                            color: PurchasesScreen.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                              borderSide: BorderSide(
                                color: PurchasesScreen.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Text(
                                'No se encontraron proveedores.',
                                style: GoogleFonts.poppins(
                                  color: PurchasesScreen.muted,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 18),
                            itemBuilder: (context, index) =>
                                _providerCard(filtered[index]),
                          ),
                  ),
                ],
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
      title: 'Gestión Proveedor',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _providerCard(_Provider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 14, 13),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _avatarColorFor(provider.id),
                child: Text(
                  getInitials(provider.name),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.id,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _providerInfo('NIT', provider.nit)),
              Expanded(child: _providerInfo('TELÉFONO', provider.phone)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _providerInfo('EMAIL', provider.email)),
              Expanded(
                child: _providerInfo(
                  'ASESOR COMERCIAL',
                  provider.advisor ?? '',
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 11),
            child: Divider(height: 1, color: AppColors.cardDivider),
          ),
          Row(
            children: [
              _statusBadge(provider),
              const Spacer(),
              _providerAction(Icons.visibility_outlined, provider),
              _providerAction(Icons.edit_outlined, provider),
              _providerAction(Icons.delete_outline, provider),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColorFor(String id) {
    final hash = id.codeUnits.fold<int>(0, (acc, code) => acc + code);
    return AppColors.avatarPalette[hash % AppColors.avatarPalette.length];
  }

  Widget _statusBadge(_Provider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: provider.active
            ? AppColors.statusGreenBg
            : AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        provider.active ? 'Activo' : 'Inactivo',
        style: GoogleFonts.poppins(
          color: provider.active
              ? AppColors.statusGreenFg
              : AppColors.statusRedFg,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _providerAction(IconData icon, _Provider provider) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: icon == Icons.visibility_outlined
            ? () => showDialog<void>(
                context: context,
                builder: (_) => _ProviderDetailScreen(provider: provider),
              )
            : icon == Icons.edit_outlined
            ? () => showDialog<void>(
                context: context,
                builder: (_) => _ProviderEditScreen(provider: provider),
              )
            : () => _showDeleteProviderDialog(provider),
        icon: Icon(icon, size: 25, color: AppColors.cardIcon),
      ),
    );
  }

  Widget _providerInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: PurchasesScreen.muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 16),
        ),
      ],
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
                  style: GoogleFonts.montserrat(
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
                            border: Border.all(color: const Color(0xFFE8C7C4)),
                          ),
                          child: Text(
                            provider.id,
                            style: GoogleFonts.poppins(
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
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
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

class _Provider {
  const _Provider(
    this.id,
    this.nit,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.active, [
    this.advisor,
  ]);

  final String id;
  final String nit;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool active;
  final String? advisor;
}

class _ProviderDetailScreen extends StatelessWidget {
  const _ProviderDetailScreen({required this.provider});

  final _Provider provider;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Identificación del proveedor'),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(label: 'NIT', value: provider.nit),
                      right: _ReadOnlyField(
                        label: 'Nombre',
                        value: provider.name,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Contacto'),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(
                        label: 'Asesor Comercial',
                        value: provider.advisor ?? '',
                      ),
                      right: _ReadOnlyField(
                        label: 'Teléfono',
                        value: provider.phone,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(
                        label: 'Email',
                        value: provider.email,
                      ),
                      right: _ReadOnlyField(
                        label: 'Dirección',
                        value: provider.address,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Configuración'),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        alignment: Alignment.centerLeft,
                        child: _ReadOnlyField(
                          label: 'Estado',
                          value: provider.active ? 'Activo' : 'Inactivo',
                        ),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Detalle — ${provider.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonFill,
            foregroundColor: AppColors.ink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            'Cerrar',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
  late final TextEditingController _advisorController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _advisorController = TextEditingController(
      text: widget.provider.advisor ?? '',
    );
    _phoneController = TextEditingController(text: widget.provider.phone);
    _emailController = TextEditingController(text: widget.provider.email);
    _addressController = TextEditingController(text: widget.provider.address);
    _isActive = widget.provider.active;
  }

  @override
  void dispose() {
    _advisorController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Identificación del proveedor'),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _LockedField(
                        label: 'NIT',
                        value: widget.provider.nit,
                      ),
                      right: _LockedField(
                        label: 'Nombre',
                        value: widget.provider.name,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Contacto'),
                    const SizedBox(height: 16),
                    _EditableField(
                      label: 'Asesor Comercial',
                      controller: _advisorController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _EditableField(
                        label: 'Teléfono',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      right: _EditableField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _EditableField(
                      label: 'Dirección',
                      controller: _addressController,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Configuración'),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        alignment: Alignment.centerLeft,
                        child: _buildEstadoField(),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Editar — ${widget.provider.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
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

  Widget _buildEstadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: GoogleFonts.poppins(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<bool>(
          initialValue: _isActive,
          borderRadius: BorderRadius.circular(24),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: AppColors.fieldBorder),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
          ),
          style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
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
                  style: GoogleFonts.poppins(
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
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
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
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.toUpperCase(),
          style: GoogleFonts.poppins(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(color: AppColors.fieldBorder, height: 1, thickness: 1),
      ],
    );
  }
}

class _FieldPair extends StatelessWidget {
  const _FieldPair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 15),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'No se puede modificar',
          style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: AppColors.fieldBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
