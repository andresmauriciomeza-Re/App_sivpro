import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin/services/clients_repository.dart';
import '../../network/api_exception.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../../shared/periodic_refresh.dart';
import '../../shared/permission_helper.dart';
import '../../shared/search.dart';
import '../../theme/app_colors.dart';

class EmployeeClientsScreen extends StatefulWidget {
  const EmployeeClientsScreen({super.key});

  @override
  State<EmployeeClientsScreen> createState() => _EmployeeClientsScreenState();
}

class _EmployeeClientsScreenState extends State<EmployeeClientsScreen>
    with PeriodicRefreshMixin<EmployeeClientsScreen> {
  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF17243A);
  static const Color muted = Color(0xFF617492);
  static const Color page = Color(0xFFFCFAF9);

  final _searchController = TextEditingController();
  List<Cliente> _clientes = const [];
  bool _cargando = true;
  bool _recargando = false;
  String? _error;
  String _statusFilter = 'Todos los estados';
  String _sortOrder = 'Ordenar por nombre';

  bool get _puedeVer => PermissionHelper.puedeVerClientes;

  @override
  void initState() {
    super.initState();
    if (_puedeVer) {
      _cargar();
      iniciarRefrescoPeriodico();
    } else {
      _cargando = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Future<void> refrescarPeriodico() async {
    if (_puedeVer) await _cargar(silencioso: true);
  }

  Future<void> _cargar({bool silencioso = false}) async {
    if (_recargando) return;
    setState(() {
      _recargando = true;
      if (!silencioso) _cargando = _clientes.isEmpty;
      if (!silencioso) _error = null;
    });
    try {
      final clientes = await ClientsRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _clientes = clientes;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar los clientes.');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
          _recargando = false;
        });
      }
    }
  }

  List<Cliente> _filteredClients() {
    final query = _searchController.text;
    final filtered = _clientes.where((cliente) {
      final matchesQuery = matchesSearchQuery(query, [
        cliente.nombre,
        cliente.correo ?? '',
        cliente.documento,
        cliente.codigo,
        cliente.activo ? 'Activo' : 'Inactivo',
      ]);
      final matchesState =
          _statusFilter == 'Todos los estados' ||
          (_statusFilter == 'Activo' && cliente.activo) ||
          (_statusFilter == 'Inactivo' && !cliente.activo);
      return matchesQuery && matchesState;
    }).toList();
    if (_sortOrder == 'Ordenar por pedidos') {
      filtered.sort((a, b) {
        final byOrders = b.pedidos.compareTo(a.pedidos);
        return byOrders != 0
            ? byOrders
            : normalizeForSearch(a.nombre).compareTo(
                normalizeForSearch(b.nombre),
              );
      });
    } else {
      filtered.sort(
        (a, b) => normalizeForSearch(
          a.nombre,
        ).compareTo(normalizeForSearch(b.nombre)),
      );
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: red,
                onRefresh: () => _cargar(silencioso: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: _contenido(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (!_puedeVer) {
      return _mensajeBloque(
        'No tienes permiso para ver los clientes.',
        icon: Icons.lock_outline,
      );
    }
    if (_cargando && _clientes.isEmpty) {
      return const SizedBox(
        height: 380,
        child: Center(child: CircularProgressIndicator(color: red)),
      );
    }
    if (_error != null && _clientes.isEmpty) {
      return _mensajeBloque(_error!, onRetry: _cargar);
    }

    final filtered = _filteredClients();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          _errorBanner(_error!),
          const SizedBox(height: 14),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.groups_outlined,
                value: '${_clientes.length}',
                label: 'Total clientes',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.how_to_reg_outlined,
                value: '${_clientes.where((c) => c.activo).length}',
                label: 'Activos',
                active: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.person_off_outlined,
                value: '${_clientes.where((c) => !c.activo).length}',
                label: 'Inactivos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppSearchField(
          controller: _searchController,
          hint: 'Buscar por nombre, correo o documento...',
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
                  PopupMenuItem(value: 'Activo', child: Text('Activo')),
                  PopupMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                child: _FilterButton(label: _statusFilter),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PopupMenuButton<String>(
                initialValue: _sortOrder,
                onSelected: (value) => setState(() => _sortOrder = value),
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
            Text(
              '${filtered.length}',
              style: GoogleFonts.poppins(color: muted, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                _clientes.isEmpty
                    ? 'No hay clientes registrados.'
                    : 'No se encontraron clientes.',
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
            ),
          )
        else
          for (final cliente in filtered)
            _ClientCard(
              cliente: cliente,
              onView: () => _showClientDetail(cliente),
            ),
      ],
    );
  }

  Widget _errorBanner(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9B4610), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: _recargando ? null : _cargar,
            child: Text(
              'Reintentar',
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensajeBloque(
    String mensaje, {
    IconData icon = Icons.cloud_off_outlined,
    Future<void> Function()? onRetry,
  }) {
    return SizedBox(
      height: 380,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: muted, size: 42),
            const SizedBox(height: 14),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: ink, fontSize: 15),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _recargando ? null : onRetry,
                style: FilledButton.styleFrom(backgroundColor: red),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 27),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 28),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(color: red, fontSize: 24),
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

  Widget _buildBottomNavigation(BuildContext context) {
    final items = employeeNavItems();
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: red, width: 1),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            handleEmployeeBottomNav(context, items[index].index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].index == 1
                                  ? items[index].activeIcon ?? items[index].icon
                                  : items[index].icon,
                              color: items[index].index == 1 ? red : muted,
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].label,
                              style: GoogleFonts.poppins(
                                color: items[index].index == 1 ? red : muted,
                                fontSize: 10,
                                fontWeight: items[index].index == 1
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showClientDetail(Cliente cliente) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => _ClientDetailScreen(cliente: cliente),
    );
  }
}

class _ClientDetailScreen extends StatelessWidget {
  const _ClientDetailScreen({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: _EmployeeClientsScreenState.page,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle Cliente',
                      style: GoogleFonts.montserrat(
                        color: _EmployeeClientsScreenState.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.black45),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                  decoration: BoxDecoration(
                    color: _EmployeeClientsScreenState.page,
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
                          CircleAvatar(
                            radius: 43,
                            backgroundColor: _EmployeeClientsScreenState.red,
                            child: Text(
                              getInitials(cliente.nombre),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente.nombre,
                                  style: GoogleFonts.poppins(
                                    color: _EmployeeClientsScreenState.ink,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cliente.codigo,
                                  style: GoogleFonts.poppins(
                                    color: _EmployeeClientsScreenState.muted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _ClientDetailRow(
                        label: 'ID Cliente',
                        value: cliente.codigo,
                        emphasize: true,
                      ),
                      _ClientDetailRow(
                        label: 'Nombre completo',
                        value: cliente.nombre,
                      ),
                      if (cliente.documento.isNotEmpty)
                        _ClientDetailRow(
                          label: 'Documento',
                          value: cliente.documento,
                        ),
                      _ClientDetailRow(
                        label: 'Correo electrónico',
                        value: cliente.correo ?? 'Sin correo',
                        singleLine: true,
                      ),
                      _ClientDetailRow(
                        label: 'Teléfono',
                        value: cliente.telefono ?? 'Sin teléfono',
                      ),
                      _ClientDetailRow(
                        label: 'Pedidos totales',
                        value: '${cliente.pedidos}',
                      ),
                      _ClientDetailRow(
                        label: 'Estado',
                        value: cliente.activo ? 'Activo' : 'Inactivo',
                        status: cliente.activo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F4),
                    foregroundColor: _EmployeeClientsScreenState.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientDetailRow extends StatelessWidget {
  const _ClientDetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.singleLine = false,
    this.status,
  });

  final String label;
  final String value;
  final bool emphasize;
  final bool singleLine;
  final bool? status;

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.poppins(
      color: _EmployeeClientsScreenState.ink,
      fontSize: 17,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
    );

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
              style: GoogleFonts.poppins(
                color: _EmployeeClientsScreenState.muted,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: status == null
                ? (singleLine
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(value, style: valueStyle),
                        )
                      : Text(
                          value,
                          textAlign: TextAlign.right,
                          style: valueStyle,
                        ))
                : _ClientStatusBadge(active: status!),
          ),
        ],
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
              : _EmployeeClientsScreenState.muted,
          fontSize: 12,
        ),
      ),
    );
  }
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
            child: Icon(icon, color: _EmployeeClientsScreenState.red, size: 21),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: active
                    ? AppColors.statGreenNumber
                    : _EmployeeClientsScreenState.ink,
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
                  : _EmployeeClientsScreenState.muted,
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
                color: _EmployeeClientsScreenState.ink,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: _EmployeeClientsScreenState.muted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.cliente, required this.onView});

  final Cliente cliente;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                backgroundColor: _EmployeeClientsScreenState.red,
                child: Text(
                  getInitials(cliente.nombre),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cliente.nombre,
                            style: GoogleFonts.poppins(
                              color: _EmployeeClientsScreenState.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cliente.codigo,
                            style: GoogleFonts.poppins(
                              color: _EmployeeClientsScreenState.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      cliente.correo ?? 'Sin correo',
                      style: GoogleFonts.poppins(
                        color: _EmployeeClientsScreenState.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _ClientStatusBadge(active: cliente.activo),
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
                '${cliente.pedidos}',
                style: GoogleFonts.poppins(
                  color: _EmployeeClientsScreenState.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onView,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: _EmployeeClientsScreenState.muted,
                  size: 21,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
