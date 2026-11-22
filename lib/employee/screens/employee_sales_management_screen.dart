import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin/services/ventas_repository.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../../shared/periodic_refresh.dart';
import '../../shared/search.dart';
import 'employee_sale_detail_screen.dart';

class EmployeeSalesManagementScreen extends StatefulWidget {
  const EmployeeSalesManagementScreen({super.key});

  @override
  State<EmployeeSalesManagementScreen> createState() =>
      _EmployeeSalesManagementScreenState();
}

class _EmployeeSalesManagementScreenState
    extends State<EmployeeSalesManagementScreen>
    with PeriodicRefreshMixin<EmployeeSalesManagementScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final _searchController = TextEditingController();
  String _query = '';
  EstadoVenta? _estadoFiltro;

  List<Venta> _ventas = const [];
  bool _cargando = true;
  bool _recargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    iniciarRefrescoPeriodico();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Future<void> refrescarPeriodico() => _cargar(silencioso: true);

  Future<void> _cargar({bool silencioso = false}) async {
    if (_recargando) return;
    setState(() {
      _recargando = true;
      if (!silencioso) _cargando = _ventas.isEmpty;
      if (!silencioso) _error = null;
    });
    try {
      final ventas = await VentasRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _ventas = ventas;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudieron cargar las ventas.');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
          _recargando = false;
        });
      }
    }
  }

  List<Venta> get _filtradas {
    return _ventas.where((venta) {
      final coincideEstado =
          _estadoFiltro == null || venta.estado == _estadoFiltro;
      final coincideTexto = matchesSearchQuery(_query, [
        venta.codigo,
        venta.clienteNombre,
        venta.estadoLabel,
        venta.documento ?? '',
        venta.correo ?? '',
        venta.telefono ?? '',
        ...venta.pagos.map((pago) => pago.tipo ?? ''),
      ]);
      return coincideEstado && coincideTexto;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 18),
                      _buildSearch(),
                      const SizedBox(height: 14),
                      _buildFilters(),
                      const SizedBox(height: 18),
                      if (_recargando && _ventas.isNotEmpty) ...[
                        const LinearProgressIndicator(
                          color: red,
                          backgroundColor: Color(0xFFF3E9E7),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_error != null && _ventas.isNotEmpty) ...[
                        _errorBanner(_error!),
                        const SizedBox(height: 14),
                      ],
                      if (_cargando && _ventas.isEmpty)
                        _loadingBlock()
                      else if (_error != null && _ventas.isEmpty)
                        _errorBlock(_error!)
                      else if (_ventas.isEmpty)
                        _emptyBlock(
                          'No hay ventas registradas en este momento.',
                        )
                      else if (filtradas.isEmpty)
                        _emptyBlock(
                          'No hay ventas que coincidan con el filtro.',
                        )
                      else
                        ...filtradas.map(
                          (venta) => _VentaCard(
                            venta: venta,
                            onTap: () => _abrirDetalle(venta),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión Ventas',
          style: GoogleFonts.montserrat(color: ink, fontSize: 29),
        ),
        Text(
          '${_ventas.length} ventas registradas',
          style: GoogleFonts.poppins(color: muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return AppSearchField(
      controller: _searchController,
      hint: 'Buscar por #, cliente, documento o pago...',
      onChanged: (value) => setState(() => _query = value),
      showClearButton: true,
    );
  }

  Widget _buildFilters() {
    final opciones = <({EstadoVenta? estado, String label})>[
      (estado: null, label: 'Todas'),
      for (final estado in EstadoVenta.values)
        (estado: estado, label: estado.label),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opcion in opciones) ...[
            _EstadoFiltroChip(
              label: opcion.label,
              cantidad: opcion.estado == null
                  ? _ventas.length
                  : _ventas
                        .where((venta) => venta.estado == opcion.estado)
                        .length,
              estado: opcion.estado,
              selected: _estadoFiltro == opcion.estado,
              onTap: () => setState(() => _estadoFiltro = opcion.estado),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _loadingBlock() {
    return const SizedBox(
      height: 320,
      child: Center(child: CircularProgressIndicator(color: red)),
    );
  }

  Widget _emptyBlock(String mensaje) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, color: muted, size: 44),
            const SizedBox(height: 14),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBlock(String mensaje) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5E4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: muted, size: 42),
          const SizedBox(height: 14),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: ink, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _recargando ? null : _cargar,
            style: FilledButton.styleFrom(backgroundColor: red),
            child: Text(
              'Reintentar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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
                  top: BorderSide(color: red),
                  left: BorderSide(color: Color(0xFFE6E8EC)),
                  right: BorderSide(color: Color(0xFFE6E8EC)),
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
                              items[index].icon,
                              color: items[index].index == 2 ? red : muted,
                              size: 19,
                            ),
                            Text(
                              items[index].label,
                              style: GoogleFonts.poppins(
                                color: items[index].index == 2 ? red : muted,
                                fontSize: 10,
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

  Future<void> _abrirDetalle(Venta venta) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EmployeeSaleDetailScreen(idVenta: venta.id),
      ),
    );
    if (mounted) await _cargar(silencioso: true);
  }
}

String _formatearMonto(double valor) {
  final redondeado = valor.round();
  final texto = redondeado.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return '\$${redondeado < 0 ? '-' : ''}$buffer';
}

class _VentaCard extends StatelessWidget {
  const _VentaCard({required this.venta, required this.onTap});

  final Venta venta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tiposPago = venta.pagos
        .map((pago) => pago.tipo?.trim())
        .whereType<String>()
        .where((tipo) => tipo.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0E4E9)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0xFFF1F3F5),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: _EmployeeSalesManagementScreenState.ink,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venta.codigo,
                            style: GoogleFonts.poppins(
                              color: _EmployeeSalesManagementScreenState.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            formatFechaHoraVenta(venta.fecha),
                            style: GoogleFonts.poppins(
                              color: _EmployeeSalesManagementScreenState.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _EstadoBadge(
                      estado: venta.estado,
                      label: venta.estadoLabel,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: _EmployeeSalesManagementScreenState.muted,
                        size: 19,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Ver detalle',
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLIENTE',
                            style: GoogleFonts.poppins(
                              color: _EmployeeSalesManagementScreenState.muted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            venta.clienteNombre,
                            style: GoogleFonts.poppins(
                              color: _EmployeeSalesManagementScreenState.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.poppins(
                            color: _EmployeeSalesManagementScreenState.muted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatearMonto(venta.monto),
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (tiposPago.isNotEmpty || venta.horaRecogida != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      if (tiposPago.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tiposPago.join(' · '),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF4F5B6D),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (venta.horaRecogida != null) ...[
                        const Icon(
                          Icons.access_time,
                          color: _EmployeeSalesManagementScreenState.muted,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Recogida ${formatHoraVenta(venta.horaRecogida)}',
                          style: GoogleFonts.poppins(
                            color: _EmployeeSalesManagementScreenState.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstadoFiltroChip extends StatelessWidget {
  const _EstadoFiltroChip({
    required this.label,
    required this.cantidad,
    required this.estado,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int cantidad;
  final EstadoVenta? estado;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = _estadoColors(estado);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colores.background : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colores.border : const Color(0xFFE0E4E9),
          ),
        ),
        child: Text(
          '$label ($cantidad)',
          style: GoogleFonts.poppins(
            color: selected
                ? colores.foreground
                : _EmployeeSalesManagementScreenState.muted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado, required this.label});

  final EstadoVenta? estado;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colores = _estadoColors(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colores.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colores.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: colores.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

({Color background, Color border, Color foreground}) _estadoColors(
  EstadoVenta? estado,
) {
  return switch (estado) {
    EstadoVenta.porVerificar => (
      background: const Color(0xFFFFFBF0),
      border: const Color(0xFFFFDA70),
      foreground: const Color(0xFFB45B00),
    ),
    EstadoVenta.enEspera => (
      background: const Color(0xFFEEF0FF),
      border: const Color(0xFFC7CEFF),
      foreground: const Color(0xFF3B4BA8),
    ),
    EstadoVenta.porEntregar => (
      background: const Color(0xFFD8EAFF),
      border: const Color(0xFFB6D4FF),
      foreground: const Color(0xFF2861B7),
    ),
    EstadoVenta.completado => (
      background: const Color(0xFFE0F5E9),
      border: const Color(0xFF9BD5B0),
      foreground: const Color(0xFF19733B),
    ),
    EstadoVenta.devolucion => (
      background: const Color(0xFFFFEBCF),
      border: const Color(0xFFFFC477),
      foreground: const Color(0xFFB44A00),
    ),
    EstadoVenta.anulado => (
      background: const Color(0xFFFDE8E8),
      border: const Color(0xFFF5B5B5),
      foreground: const Color(0xFFA11D1D),
    ),
    null => (
      background: const Color(0xFFEFF2F5),
      border: const Color(0xFFC9D2DB),
      foreground: const Color(0xFF6D7B91),
    ),
  };
}
