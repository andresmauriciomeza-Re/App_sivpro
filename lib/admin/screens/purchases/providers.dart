part of '../purchases_screen.dart';

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() =>
      _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> {
  String _query = '';

  final List<_Provider> _providers = [
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
                        AppSearchField(
                          hint: 'Buscar por ID, nombre o email...',
                          onChanged: (value) => setState(() => _query = value),
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showChangeStatusDialog(provider),
      child: Container(
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
            ? () => _showProviderSheet(provider, edit: false)
            : () => _showProviderSheet(provider, edit: true),
        icon: Icon(icon, size: 25, color: AppColors.cardIcon),
      ),
    );
  }

  Future<void> _showProviderSheet(
    _Provider provider, {
    required bool edit,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => edit
          ? _ProviderEditScreen(provider: provider)
          : _ProviderDetailScreen(provider: provider),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _showChangeStatusDialog(_Provider provider) async {
    final targetStatus = provider.active ? 'Inactivo' : 'Activo';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: const Text('¿Está seguro de cambiar el estado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Cambiar a $targetStatus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final previous = provider.active;
    setState(() => provider.active = !previous);
    try {
      await _persistProviderStatus(provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado cambiado a "$targetStatus".')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => provider.active = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cambiar el estado.')),
        );
      }
    }
  }

  Future<void> _persistProviderStatus(_Provider provider) async {
    // Simula la persistencia del endpoint mientras la app funciona sin backend.
    await Future<void>.delayed(Duration.zero);
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

class _Provider {
  _Provider(
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
  String phone;
  String email;
  String address;
  bool active;
  String? advisor;
}

class _ProviderSheetFrame extends StatelessWidget {
  const _ProviderSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD2CCCA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _ProviderDetailScreen extends StatelessWidget {
  const _ProviderDetailScreen({required this.provider});

  final _Provider provider;

  @override
  Widget build(BuildContext context) {
    return _ProviderSheetFrame(
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
  final _formKey = GlobalKey<FormState>();
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
    _phoneController = TextEditingController(
      text: widget.provider.phone.replaceAll(RegExp(r'\D'), ''),
    );
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
    return _ProviderSheetFrame(
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
              child: Form(
                key: _formKey,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]'),
                          ),
                        ],
                        validator: _lettersValidator,
                      ),
                      const SizedBox(height: 16),
                      _FieldPair(
                        left: _EditableField(
                          label: 'Teléfono',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _phoneValidator,
                        ),
                        right: _EditableField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EditableField(
                        label: 'Dirección',
                        controller: _addressController,
                        textInputAction: TextInputAction.done,
                        validator: _requiredValidator,
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
                onPressed: _save,
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _lettersValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(
          r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$',
        ).hasMatch(value.trim())
        ? null
        : 'Solo se permiten letras';
  }

  String? _phoneValidator(String? value) {
    final error = _requiredValidator(value);
    if (error != null) return error;
    return RegExp(r'^\d+$').hasMatch(value!)
        ? null
        : 'Solo se permiten números';
  }

  String? _emailValidator(String? value) {
    final error = _requiredValidator(value);
    if (error != null) return error;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!)
        ? null
        : 'Ingresa un email válido';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.provider
      ..advisor = _advisorController.text.trim()
      ..phone = _phoneController.text
      ..email = _emailController.text.trim()
      ..address = _addressController.text.trim()
      ..active = _isActive;
    Navigator.of(context).pop(true);
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
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

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
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
