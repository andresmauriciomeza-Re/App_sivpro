part of '../purchases_screen.dart';

/// Clientes: consulta de información (solo lectura en el móvil).
class _ClientManagementScreen extends StatefulWidget {
  const _ClientManagementScreen();

  @override
  State<_ClientManagementScreen> createState() =>
      _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<_ClientManagementScreen> {
  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF17243A);
  static const Color muted = Color(0xFF617492);
  static const Color page = Color(0xFFFCFAF9);

  final _searchController = TextEditingController();
  String _statusFilter = 'Todos los estados';
  String _sortOrder = 'Ordenar por nombre';
  List<Cliente> _clients = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final clients = await ClientsRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _clients = clients;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'No se pudieron cargar los clientes.';
      if (silent && _clients.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        setState(() {
          _loading = false;
          _error = message;
        });
      }
    }
  }

  List<Cliente> _filteredClients() {
    final query = _searchController.text;
    final filtered = _clients.where((client) {
      final matchesQuery = matchesSearchQuery(query, [
        client.nombre,
        client.numeroDocumento ?? '',
        client.correo ?? '',
        client.telefono ?? '',
      ]);
      final matchesState =
          _statusFilter == 'Todos los estados' ||
          (_statusFilter == 'Activo' && client.activo) ||
          (_statusFilter == 'Inactivo' && !client.activo);
      return matchesQuery && matchesState;
    }).toList();
    if (_sortOrder == 'Ordenar por pedidos') {
      filtered.sort((a, b) {
        final byOrders = b.pedidos.compareTo(a.pedidos);
        return byOrders != 0
            ? byOrders
            : normalizeForSearch(
                a.nombre,
              ).compareTo(normalizeForSearch(b.nombre));
      });
    } else {
      filtered.sort(
        (a, b) =>
            normalizeForSearch(a.nombre).compareTo(normalizeForSearch(b.nombre)),
      );
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredClients();
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _clientsBottomNavigation(context),
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    Text(
                      'Clientes',
                      style: GoogleFonts.montserrat(color: ink, fontSize: 30),
                    ),
                    Text(
                      'Usuarios registrados con tipo cliente en La Sirena',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: muted, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.groups_outlined,
                            value: '${_clients.length}',
                            label: 'Total clientes',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.how_to_reg_outlined,
                            value: '${_clients.where((c) => c.activo).length}',
                            label: 'Activos',
                            active: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.person_off_outlined,
                            value: '${_clients.where((c) => !c.activo).length}',
                            label: 'Inactivos',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Buscar por nombre, documento, correo o teléfono...',
                      onChanged: (_) => setState(() {}),
                      showClearButton: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PopupMenuButton<String>(
                            initialValue: _statusFilter,
                            onSelected: (value) =>
                                setState(() => _statusFilter = value),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Todos los estados',
                                child: Text('Todos los estados'),
                              ),
                              PopupMenuItem(
                                value: 'Activo',
                                child: Text('Activo'),
                              ),
                              PopupMenuItem(
                                value: 'Inactivo',
                                child: Text('Inactivo'),
                              ),
                            ],
                            child: _FilterButton(label: _statusFilter),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PopupMenuButton<String>(
                            initialValue: _sortOrder,
                            onSelected: (value) =>
                                setState(() => _sortOrder = value),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Ordenar por nombre',
                                child: Text('Ordenar por nombre'),
                              ),
                              PopupMenuItem(
                                value: 'Ordenar por pedidos',
                                child: Text('Ordenar por pedidos'),
                              ),
                            ],
                            child: _FilterButton(label: _sortOrder),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LISTADO DE CLIENTES',
                          style: GoogleFonts.poppins(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_loading && _error == null)
                          Text(
                            '${filtered.length} DE ${_clients.length}',
                            style: GoogleFonts.poppins(
                              color: muted,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._buildContent(filtered),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Cliente> filtered) {
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
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: muted),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                style: FilledButton.styleFrom(backgroundColor: red),
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
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              'No se encontraron clientes',
              style: GoogleFonts.poppins(color: muted, fontSize: 14),
            ),
          ),
        ),
      ];
    }
    return [
      for (final client in filtered)
        _ClientCard(
          client: client,
          onView: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ClientDetailScreen(client: client),
            ),
          ),
        ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 27),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 28),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(color: Colors.black, fontSize: 24),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: Text(
              currentUserInitials(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _clientColor(Cliente client) =>
    AppColors.avatarPalette[client.id % AppColors.avatarPalette.length];

Widget _clientsBottomNavigation(BuildContext context) {
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
                  size: 25,
                  color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,
                  showPendingBadge: i == adminSalesNavIndex,
                ),
                Text(
                  items[i].$2,
                  style: GoogleFonts.poppins(
                    color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,
                    fontSize: 10,
                    fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.active = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
      decoration: BoxDecoration(
        color: active ? AppColors.statGreenBg : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? AppColors.statGreenBorder : AppColors.statCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.iconCircleBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _ClientManagementScreenState.red,
              size: 21,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: active
                    ? AppColors.statGreenNumber
                    : _ClientManagementScreenState.ink,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: active
                  ? AppColors.statGreenLabel
                  : _ClientManagementScreenState.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE3DEDC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: _ClientManagementScreenState.ink,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: _ClientManagementScreenState.muted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onView});
  final Cliente client;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onView,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(17, 18, 17, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E1DF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: _clientColor(client),
                  child: Text(
                    getInitials(client.nombre),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _ClientManagementScreenState.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        client.documento.isEmpty ? '—' : client.documento,
                        style: GoogleFonts.poppins(
                          color: _ClientManagementScreenState.muted,
                          fontSize: 13,
                        ),
                      ),
                      if (client.correo != null)
                        Text(
                          client.correo!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: _ClientManagementScreenState.muted,
                            fontSize: 13,
                          ),
                        ),
                      if (client.telefono != null)
                        Text(
                          client.telefono!,
                          style: GoogleFonts.poppins(
                            color: _ClientManagementScreenState.muted,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ClientStatusBadge(active: client.activo),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Text(
                  'Pedidos: ',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF91A3C0),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${client.pedidos}',
                  style: GoogleFonts.poppins(
                    color: _ClientManagementScreenState.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.visibility_outlined,
                  color: _ClientManagementScreenState.muted,
                  size: 21,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientStatusBadge extends StatelessWidget {
  const _ClientStatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD2F8E5) : const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        active ? 'Activo' : 'Inactivo',
        style: GoogleFonts.poppins(
          color: active
              ? const Color(0xFF086E4C)
              : _ClientManagementScreenState.muted,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Detalle de solo lectura: los datos salen de la lista de clientes.
class _ClientDetailScreen extends StatelessWidget {
  const _ClientDetailScreen({required this.client});

  final Cliente client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: currentUserInitials(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
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
                                style: GoogleFonts.montserrat(
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
                                client.codigo,
                                style: GoogleFonts.poppins(
                                  color: PurchasesScreen.muted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 59,
                            backgroundColor: _clientColor(client),
                            child: Text(
                              getInitials(client.nombre),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            client.nombre,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        children: [
                          _detailClientRow(
                            'Tipo de documento',
                            client.tipoDocumento ?? '—',
                          ),
                          _detailClientRow(
                            'Número de documento',
                            client.numeroDocumento ?? '—',
                          ),
                          _detailClientRow('Correo', client.correo ?? '—'),
                          _detailClientRow('Teléfono', client.telefono ?? '—'),
                          _detailClientRow(
                            'Pedidos totales',
                            '${client.pedidos}',
                            valueStyle: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _detailClientRow(
                            'Estado',
                            client.activo ? 'Activo' : 'Inactivo',
                            valueWidget: _ClientStatusBadge(
                              active: client.activo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _clientsBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _detailClientRow(
    String label,
    String value, {
    TextStyle? valueStyle,
    Widget? valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D9D7))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  valueWidget ??
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      style:
                          valueStyle ??
                          GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
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
