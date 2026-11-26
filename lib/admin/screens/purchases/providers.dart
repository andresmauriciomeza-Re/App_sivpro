part of '../purchases_screen.dart';

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() =>
      _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> {
  String _query = '';
  List<Proveedor> _providers = const [];
  bool _loading = true;
  String? _error;
  final Set<int> _changingStatus = {};

  /// Compras > Proveedores > Editar (editar datos y cambiar estado).
  bool get _canEdit => Permisos.puede('Compras', 'Proveedores', 'Editar');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final providers = await ProvidersRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _providers = providers;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'No se pudieron cargar los proveedores.';
      if (silent && _providers.isNotEmpty) {
        _showMessage(message);
      } else {
        setState(() {
          _loading = false;
          _error = message;
        });
      }
    }
  }

  void _showMessage(String message, [TipoMensaje tipo = TipoMensaje.error]) {
    ScaffoldMessenger.of(context).mostrarMensaje(message, tipo: tipo);
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase().trim();
    final filtered = _providers.where((provider) {
      return provider.codigo.toLowerCase().contains(query) ||
          provider.identificacion.toLowerCase().contains(query) ||
          provider.nombre.toLowerCase().contains(query) ||
          (provider.nombreComercial ?? '').toLowerCase().contains(query) ||
          (provider.email ?? '').toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(silent: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    Text(
                      'Proveedores',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _loading
                          ? 'Cargando proveedores...'
                          : '${_providers.length} proveedores registrados',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppSearchField(
                      hint: 'Buscar por ID, nombre o email...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    ..._buildContent(filtered),
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

  List<Widget> _buildContent(List<Proveedor> filtered) {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(PurchasesScreen.muted),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: context.pal.rojoBoton(PurchasesScreen.red),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ];
    }
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(
              'No se encontraron proveedores.',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
              ),
            ),
          ),
        ),
      ];
    }
    return [
      const SizedBox(height: 28),
      for (var i = 0; i < filtered.length; i++) ...[
        if (i > 0) const SizedBox(height: 18),
        _providerCard(filtered[i]),
      ],
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'Gestión Proveedor',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _providerCard(Proveedor provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 14, 13),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(PurchasesScreen.page),
        border: Border.all(color: context.pal.borde(AppColors.cardBorder)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _avatarColorFor(provider.codigo),
                child: Text(
                  getInitials(provider.nombre),
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
                      provider.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.codigo,
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
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
              Expanded(
                child: _providerInfo(
                  provider.esJuridica ? 'NIT' : 'DOCUMENTO',
                  provider.identificacion,
                ),
              ),
              Expanded(
                child: _providerInfo('TELÉFONO', provider.telefono ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _providerInfo('EMAIL', provider.email ?? '')),
              Expanded(
                child: _providerInfo(
                  'ASESOR COMERCIAL',
                  provider.asesorComercial ?? '',
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 14, bottom: 11),
            child: Divider(
              height: 1,
              color: context.pal.borde(AppColors.cardDivider),
            ),
          ),
          Row(
            children: [
              _statusBadge(provider),
              const Spacer(),
              _providerAction(
                Icons.visibility_outlined,
                () => _showProviderSheet(provider, edit: false),
              ),
              if (_canEdit)
                _providerAction(
                  Icons.edit_outlined,
                  () => _showProviderSheet(provider, edit: true),
                ),
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

  Widget _statusBadge(Proveedor provider) {
    final changing = _changingStatus.contains(provider.id);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: provider.estado
            ? context.pal.exitoFondo(AppColors.statusGreenBg)
            : context.pal.errorFondo(AppColors.statusRedBg),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (changing) ...[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            provider.estado ? 'Activo' : 'Inactivo',
            style: GoogleFonts.poppins(
              color: provider.estado
                  ? context.pal.exitoTexto(AppColors.statusGreenFg)
                  : context.pal.errorTexto(AppColors.statusRedFg),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    // Sin permiso de edición el estado solo se muestra.
    if (!_canEdit) return badge;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: changing ? null : () => _showChangeStatusDialog(provider),
      child: badge,
    );
  }

  Widget _providerAction(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 25,
          color: context.pal.secundario(AppColors.cardIcon),
        ),
      ),
    );
  }

  Future<void> _showProviderSheet(
    Proveedor provider, {
    required bool edit,
  }) async {
    final updated = await showModalBottomSheet<Proveedor>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => edit
          ? _ProviderEditScreen(provider: provider)
          : _ProviderDetailScreen(provider: provider),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _providers = [
        for (final item in _providers) item.id == updated.id ? updated : item,
      ];
    });
    _showMessage('Proveedor actualizado correctamente.', TipoMensaje.exito);
  }

  Future<void> _showChangeStatusDialog(Proveedor provider) async {
    if (_changingStatus.contains(provider.id)) return;
    final target = !provider.estado;
    final targetLabel = target ? 'Activo' : 'Inactivo';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: Text(
          '¿Está seguro de cambiar el estado de ${provider.nombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Cambiar a $targetLabel'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (_changingStatus.contains(provider.id)) return;

    setState(() => _changingStatus.add(provider.id));
    try {
      await ProvidersRepository.instance.cambiarEstado(provider.id, target);
      if (!mounted) return;
      setState(() {
        _providers = [
          for (final item in _providers)
            item.id == provider.id ? item.conEstado(target) : item,
        ];
      });
      _showMessage('Estado cambiado a "$targetLabel".', TipoMensaje.exito);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo cambiar el estado.');
    } finally {
      if (mounted) setState(() => _changingStatus.remove(provider.id));
    }
  }

  Widget _providerInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: context.pal.secundario(PurchasesScreen.muted),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: context.pal.texto(PurchasesScreen.ink),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 1);
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
        color: context.pal.superficie(Colors.white),
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
                color: context.pal.borde(Color(0xFFD2CCCA)),
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

class _ProviderDetailScreen extends StatefulWidget {
  const _ProviderDetailScreen({required this.provider});

  final Proveedor provider;

  @override
  State<_ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<_ProviderDetailScreen> {
  late Proveedor _provider = widget.provider;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Muestra primero los datos de la lista y los reemplaza con `GET /:id`.
  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await ProvidersRepository.instance.obtener(
        widget.provider.id,
      );
      if (!mounted) return;
      setState(() {
        _provider = fresh;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo actualizar el detalle.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _provider;
    return _ProviderSheetFrame(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Divider(
              color: context.pal.borde(AppColors.headerDivider),
              height: 1,
              thickness: 1,
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                color: context.pal.errorTexto(
                                  AppColors.statusRedFg,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _refresh,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const _SectionTitle('Identificación del proveedor'),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(
                        label: 'Tipo de persona',
                        value: p.tipoPersona,
                      ),
                      right: _ReadOnlyField(
                        label: p.esJuridica ? 'Razón social' : 'Nombre',
                        value: p.nombre,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (p.esJuridica)
                      _FieldPair(
                        left: _ReadOnlyField(
                          label: 'NIT',
                          value: p.identificacion,
                        ),
                        right: _ReadOnlyField(
                          label: 'Tipo de sociedad',
                          value: p.tipoSociedad ?? '',
                        ),
                      )
                    else
                      _FieldPair(
                        left: _ReadOnlyField(
                          label: 'Tipo de documento',
                          value: p.tipoDocumento ?? '',
                        ),
                        right: _ReadOnlyField(
                          label: 'Número de documento',
                          value: p.numeroDocumento ?? '',
                        ),
                      ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: 'Nombre comercial',
                      value: p.nombreComercial ?? '',
                    ),
                    if (p.esJuridica) ...[
                      const SizedBox(height: 16),
                      _FieldPair(
                        left: _ReadOnlyField(
                          label: 'Cámara de comercio',
                          value: p.camaraComercio ?? '',
                        ),
                        right: _ReadOnlyField(
                          label: 'Fecha exp. cámara',
                          value: p.fechaExpCamara ?? '',
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle('Representante legal'),
                      const SizedBox(height: 16),
                      _FieldPair(
                        left: _ReadOnlyField(
                          label: 'Nombre',
                          value: p.repLegalNombre ?? '',
                        ),
                        right: _ReadOnlyField(
                          label: 'Documento',
                          value: [
                            p.repLegalTipoDoc,
                            p.repLegalNumDoc,
                          ].whereType<String>().join(' '),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldPair(
                        left: _ReadOnlyField(
                          label: 'Teléfono',
                          value: p.repLegalTelefono ?? '',
                        ),
                        right: _ReadOnlyField(
                          label: 'Email',
                          value: p.repLegalEmail ?? '',
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const _SectionTitle('Contacto'),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(
                        label: 'Asesor Comercial',
                        value: p.asesorComercial ?? '',
                      ),
                      right: _ReadOnlyField(
                        label: 'Teléfono',
                        value: p.telefono ?? '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FieldPair(
                      left: _ReadOnlyField(
                        label: 'Teléfono fijo',
                        value: p.telefonoFijo ?? '',
                      ),
                      right: _ReadOnlyField(
                        label: 'Email',
                        value: p.email ?? '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: 'Dirección',
                      value: p.direccion ?? '',
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
                          value: p.estado ? 'Activo' : 'Inactivo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: context.pal.borde(AppColors.headerDivider),
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
              'Detalle — ${_provider.codigo}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: context.pal.texto(AppColors.ink),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: context.pal.secundario(AppColors.muted),
            ),
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
            backgroundColor: context.pal.campo(AppColors.buttonFill),
            foregroundColor: context.pal.texto(AppColors.ink),
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

enum _ProviderFieldKind { text, phone, email, date, url }

/// Campo editable del proveedor, identificado por su nombre en el backend.
class _ProviderEditableSpec {
  const _ProviderEditableSpec(
    this.key,
    this.label,
    this.kind, {
    this.maxLength,
    this.mandatory = false,
  });

  final String key;
  final String label;
  final _ProviderFieldKind kind;
  final int? maxLength;

  /// Obligatorio según las reglas del backend para este tipo de persona.
  final bool mandatory;
}

class _ProviderEditScreen extends StatefulWidget {
  const _ProviderEditScreen({required this.provider});

  final Proveedor provider;

  @override
  State<_ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends State<_ProviderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  late final List<_ProviderEditableSpec> _specs;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    // Natural: el backend rechaza (400) nombre comercial, teléfono fijo,
    // sociedad, cámara de comercio y representante legal: no se muestran.
    _specs = p.esJuridica
        ? const [
            _ProviderEditableSpec(
              'nombre_comercial',
              'Nombre comercial',
              _ProviderFieldKind.text,
              maxLength: 100,
            ),
            _ProviderEditableSpec(
              'camara_comercio',
              'Cámara de comercio (URL)',
              _ProviderFieldKind.url,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'fecha_exp_camara',
              'Fecha exp. cámara (AAAA-MM-DD)',
              _ProviderFieldKind.date,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'rep_legal_nombre',
              'Representante legal',
              _ProviderFieldKind.text,
              maxLength: 100,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'rep_legal_telefono',
              'Teléfono representante',
              _ProviderFieldKind.phone,
              maxLength: 20,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'rep_legal_email',
              'Email representante',
              _ProviderFieldKind.email,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'asesor_comercial',
              'Asesor Comercial',
              _ProviderFieldKind.text,
              maxLength: 50,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'telefono',
              'Teléfono',
              _ProviderFieldKind.phone,
              maxLength: 20,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'contacto_telefono_fijo',
              'Teléfono fijo',
              _ProviderFieldKind.phone,
              maxLength: 20,
            ),
            _ProviderEditableSpec(
              'email',
              'Email',
              _ProviderFieldKind.email,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'direccion',
              'Dirección',
              _ProviderFieldKind.text,
              maxLength: 100,
              mandatory: true,
            ),
          ]
        : const [
            _ProviderEditableSpec(
              'asesor_comercial',
              'Asesor Comercial',
              _ProviderFieldKind.text,
              maxLength: 50,
            ),
            _ProviderEditableSpec(
              'telefono',
              'Teléfono',
              _ProviderFieldKind.phone,
              maxLength: 20,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'email',
              'Email',
              _ProviderFieldKind.email,
              mandatory: true,
            ),
            _ProviderEditableSpec(
              'direccion',
              'Dirección',
              _ProviderFieldKind.text,
              maxLength: 100,
              mandatory: true,
            ),
          ];
    for (final spec in _specs) {
      _controllers[spec.key] = TextEditingController(
        text: _original(p, spec.key) ?? '',
      );
    }
  }

  String? _original(Proveedor p, String key) {
    return switch (key) {
      'nombre_comercial' => p.nombreComercial,
      'camara_comercio' => p.camaraComercio,
      'fecha_exp_camara' => p.fechaExpCamara,
      'rep_legal_nombre' => p.repLegalNombre,
      'rep_legal_telefono' => p.repLegalTelefono,
      'rep_legal_email' => p.repLegalEmail,
      'asesor_comercial' => p.asesorComercial,
      'telefono' => p.telefono,
      'contacto_telefono_fijo' => p.telefonoFijo,
      'email' => p.email,
      'direccion' => p.direccion,
      _ => null,
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validate(_ProviderEditableSpec spec, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return spec.mandatory ? 'Este campo es obligatorio' : null;
    }
    final max = spec.maxLength;
    if (max != null && text.length > max) {
      return 'Máximo $max caracteres';
    }
    switch (spec.kind) {
      case _ProviderFieldKind.phone:
        if (!RegExp(r'^\d+$').hasMatch(text)) return 'Solo se permiten números';
        if (text.length < 7 || text.length > 20) {
          return 'Debe tener entre 7 y 20 dígitos';
        }
        return null;
      case _ProviderFieldKind.email:
        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)
            ? null
            : 'Ingresa un email válido';
      case _ProviderFieldKind.date:
        return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)
            ? null
            : 'Usa el formato AAAA-MM-DD';
      case _ProviderFieldKind.url:
        final uri = Uri.tryParse(text);
        final valida =
            uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty &&
            !text.contains(RegExp(r'\s'));
        return valida ? null : 'Ingresa una URL válida (http o https)';
      case _ProviderFieldKind.text:
        return null;
    }
  }

  Widget _fieldFor(_ProviderEditableSpec spec) {
    final max = spec.maxLength;
    return _EditableField(
      label: spec.label,
      controller: _controllers[spec.key]!,
      keyboardType: switch (spec.kind) {
        _ProviderFieldKind.phone => TextInputType.phone,
        _ProviderFieldKind.email => TextInputType.emailAddress,
        _ProviderFieldKind.date => TextInputType.datetime,
        _ProviderFieldKind.url => TextInputType.url,
        _ProviderFieldKind.text => TextInputType.text,
      },
      textInputAction: TextInputAction.next,
      inputFormatters: [
        if (spec.kind == _ProviderFieldKind.phone)
          FilteringTextInputFormatter.digitsOnly,
        if (max != null) LengthLimitingTextInputFormatter(max),
      ],
      validator: (value) => _validate(spec, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    return _ProviderSheetFrame(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Divider(
              color: context.pal.borde(AppColors.headerDivider),
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
                          label: 'Tipo de persona',
                          value: p.tipoPersona,
                        ),
                        right: _LockedField(
                          label: p.esJuridica ? 'Razón social' : 'Nombre',
                          value: p.nombre,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LockedField(
                        label: p.esJuridica ? 'NIT' : 'Documento',
                        value: p.identificacion,
                      ),
                      const SizedBox(height: 28),
                      const _SectionTitle('Datos editables'),
                      const SizedBox(height: 16),
                      for (var i = 0; i < _specs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 16),
                        _fieldFor(_specs[i]),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          _error!,
                          style: GoogleFonts.poppins(
                            color: context.pal.errorTexto(
                              AppColors.statusRedFg,
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: context.pal.borde(AppColors.headerDivider),
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
              'Editar — ${widget.provider.codigo}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: context.pal.texto(AppColors.ink),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: context.pal.secundario(AppColors.muted),
            ),
          ),
        ],
      ),
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
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: context.pal.tarjeta(Colors.white),
                  foregroundColor: context.pal.texto(AppColors.ink),
                  side: BorderSide(
                    color: context.pal.borde(AppColors.fieldBorder),
                  ),
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
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.pal.rojoBoton(AppColors.red),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Text(
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

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final changes = <String, String?>{
        for (final spec in _specs)
          spec.key: _controllers[spec.key]!.text.trim(),
      };
      final updated = await ProvidersRepository.instance.actualizar(
        widget.provider.id,
        changes,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo guardar el proveedor.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
            color: context.pal.secundario(AppColors.muted),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Divider(
          color: context.pal.borde(AppColors.fieldBorder),
          height: 1,
          thickness: 1,
        ),
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
            color: context.pal.secundario(AppColors.muted),
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
            color: context.pal.campo(AppColors.fieldFill),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.pal.borde(AppColors.fieldBorder)),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: context.pal.secundario(AppColors.muted),
              fontSize: 15,
            ),
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
            color: context.pal.secundario(AppColors.muted),
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
            color: context.pal.campo(AppColors.fieldFill),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.pal.borde(AppColors.fieldBorder)),
          ),
          child: Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: context.pal.secundario(AppColors.muted),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'No se puede modificar',
          style: GoogleFonts.poppins(
            color: context.pal.secundario(AppColors.muted),
            fontSize: 11,
          ),
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
            color: context.pal.secundario(AppColors.muted),
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
          style: GoogleFonts.poppins(
            color: context.pal.texto(AppColors.ink),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.pal.campo(AppColors.fieldFill),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: context.pal.borde(AppColors.fieldBorder),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: context.pal.borde(AppColors.fieldBorder),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
