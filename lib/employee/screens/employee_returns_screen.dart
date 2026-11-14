import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import 'employee_exchange_screen.dart';
import 'employee_refund_screen.dart';
import '../../shared/page_transitions.dart';
import '../../shared/search.dart';
import '../services/return_service.dart';

class EmployeeReturnsScreen extends StatefulWidget {
  const EmployeeReturnsScreen({super.key});

  @override
  State<EmployeeReturnsScreen> createState() => _EmployeeReturnsScreenState();
}

class _EmployeeReturnsScreenState extends State<EmployeeReturnsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'todas';
  int? _gestionandoId;

  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF211616);
  static const muted = Color(0xFF766B68);
  static const page = Color(0xFFFCF9F8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReturnService.instance.cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _bottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: ReturnService.instance,
          builder: (context, _) {
            final service = ReturnService.instance;
            final pendientes = service.pendientes;
            final resueltas = service.resueltas;
            final todos = <DevolucionVenta>[...pendientes, ...resueltas];
            final source = _filter == 'pendientes'
                ? pendientes
                : _filter == 'resueltas'
                ? resueltas
                : todos;
            final resultados = source
                .where(
                  (r) => matchesSearchQuery(_query, [
                    '${r.idVenta}',
                    r.customer,
                    r.fechaTexto,
                    r.montoTexto,
                    r.payment,
                    r.tipoVentaTexto,
                    ...r.lineas.map((l) => l.nombre),
                    ...r.lineas.map((l) => l.motivo ?? ''),
                    r.devolucionEstado ?? '',
                    r.devolucionTipo ?? '',
                    r.devolucionMonto?.toString() ?? '',
                    r.devolucionNota ?? '',
                    r.idVentaReemplazo?.toString() ?? '',
                  ]),
                )
                .toList();
            final filteredPendientes = resultados
                .where((r) => !r.resuelta)
                .toList();
            final filteredResueltas = resultados
                .where((r) => r.resuelta)
                .toList();
            return Column(
              children: [
                _header(context),
                Expanded(
                  child: RefreshIndicator(
                    color: red,
                    onRefresh: () => ReturnService.instance.cargar(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Devoluciones',
                            style: GoogleFonts.montserrat(
                              color: ink,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppSearchField(
                            controller: _searchController,
                            hint: 'Buscar devoluciones...',
                            onChanged: (value) =>
                                setState(() => _query = value),
                            showClearButton: true,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _filterChip(
                                  'todas',
                                  'Todas',
                                  todos.length,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _filterChip(
                                  'pendientes',
                                  'Pendientes',
                                  pendientes.length,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _filterChip(
                                  'resueltas',
                                  'Resueltas',
                                  resueltas.length,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          if (service.isLoading && todos.isNotEmpty) ...[
                            const LinearProgressIndicator(
                              color: red,
                              backgroundColor: Color(0xFFF3E9E7),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (service.error != null && todos.isNotEmpty) ...[
                            _errorBanner(service.error!),
                            const SizedBox(height: 16),
                          ],
                          if (service.isLoading && todos.isEmpty)
                            _loadingBlock()
                          else if (service.error != null && todos.isEmpty)
                            _errorBlock(service.error!)
                          else if (resultados.isEmpty)
                            _emptySearchResult()
                          else ...[
                            if (filteredPendientes.isNotEmpty) ...[
                              _sectionTitle(
                                'PENDIENTES DE RESOLUCIÓN',
                                badge: '${filteredPendientes.length} en cola',
                              ),
                              const SizedBox(height: 18),
                              ...filteredPendientes.map(
                                (item) => _ReturnCard(
                                  item: item,
                                  loading: _gestionandoId == item.idVenta,
                                  onManage: () => _showManageDialog(item),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            if (filteredResueltas.isNotEmpty) ...[
                              _sectionTitle('RESUELTAS'),
                              const SizedBox(height: 18),
                              ...filteredResueltas.map(
                                (item) => _ResolvedCard(
                                  item: item,
                                  onTap: () => _showDetailDialog(context, item),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                            _resolutionInfo(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('María González'),
    );
  }

  Widget _loadingBlock() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator(color: red)),
    );
  }

  Widget _errorBlock(String message) {
    return Container(
      width: double.infinity,
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
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: ink, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => ReturnService.instance.cargar(),
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

  Widget _errorBanner(String message) {
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
              message,
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ReturnService.instance.cargar(),
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

  Widget _sectionTitle(String title, {String? badge}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFFA49A97),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: .4,
          ),
        ),
        const Spacer(),
        if (badge != null) _queueBadge(badge),
      ],
    );
  }

  Widget _queueBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        border: Border.all(color: const Color(0xFFFFD55A)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF9B4610),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label, int count) {
    final selected = _filter == value;
    final foreground = !selected
        ? muted
        : switch (value) {
            'pendientes' => AppColors.returnChipPendingFg,
            'resueltas' => AppColors.returnChipResolvedFg,
            _ => AppColors.returnChipAllFg,
          };
    final background = !selected
        ? Colors.white
        : switch (value) {
            'pendientes' => AppColors.returnChipPendingBg,
            'resueltas' => AppColors.returnChipResolvedBg,
            _ => AppColors.returnChipAllBg,
          };
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? foreground : AppColors.fieldBorder,
          ),
        ),
        child: Text(
          '$label $count',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: foreground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _emptySearchResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No se encontraron devoluciones',
          style: GoogleFonts.poppins(color: muted, fontSize: 15),
        ),
      ),
    );
  }

  Widget _resolutionInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '?',
              style: TextStyle(color: muted, fontSize: 18),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolución de devoluciones',
                  style: GoogleFonts.poppins(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Las devoluciones aprobadas se sincronizarán directamente con el módulo de caja y se notificará al cliente vía WhatsApp.',
                  style: GoogleFonts.poppins(
                    color: muted,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
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
                  top: BorderSide(color: Color(0xFFEDE6E4)),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            handleEmployeeBottomNav(context, items[i].index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].icon,
                              color: items[i].index == 3
                                  ? red
                                  : const Color(0xFFA49A97),
                              size: 22,
                            ),
                            Text(
                              items[i].label,
                              style: GoogleFonts.poppins(
                                color: items[i].index == 3
                                    ? red
                                    : const Color(0xFFA49A97),
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

  Future<void> _showManageDialog(DevolucionVenta item) async {
    if (_gestionandoId != null) return;
    setState(() => _gestionandoId = item.idVenta);
    try {
      final detalle = await ReturnService.instance.detalle(item.idVenta);
      if (!mounted) return;
      setState(() => _gestionandoId = null);
      final resolved = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => _ReturnManagementScreen(item: detalle),
        ),
      );
      if (resolved == 'canje' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devolución realizada correctamente.')),
        );
      } else if (resolved == 'dinero' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reembolso registrado correctamente.')),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _gestionandoId = null);
    }
  }

  Future<void> _showDetailDialog(BuildContext context, DevolucionVenta item) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ResolvedDetailDialog(item: item),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.item,
    required this.onManage,
    required this.loading,
  });

  final DevolucionVenta item;
  final VoidCallback onManage;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(26, 27, 26, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECD7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sync, color: Color(0xFFE84A08), size: 34),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${item.idVenta}  ${item.customer}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.fechaTexto,
                  style: GoogleFonts.poppins(color: const Color(0xFFA49A97)),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.montoTexto,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _PaymentBadge(payment: item.payment),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: loading ? null : onManage,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7A2B0C),
              side: const BorderSide(color: Color(0xFFFFC51C)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7A2B0C),
                    ),
                  )
                : const Text('Gestionar'),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.payment});

  final String payment;

  @override
  Widget build(BuildContext context) {
    final esNequi = payment == 'Nequi';
    final esBancolombia = payment == 'Bancolombia';
    final esEfectivo = payment == 'Efectivo';
    final background = esNequi
        ? const Color(0xFFF0E3FF)
        : esBancolombia
        ? const Color(0xFFFFF3C7)
        : const Color(0xFFE8F0FE);
    final foreground = esNequi
        ? const Color(0xFF6E1DCB)
        : esBancolombia
        ? const Color(0xFF8B3F11)
        : const Color(0xFF1A4B8C);
    final icon = esNequi
        ? '💜 '
        : esBancolombia
        ? '🏦 '
        : esEfectivo
        ? '💵 '
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$icon$payment',
        style: GoogleFonts.poppins(color: foreground, fontSize: 13),
      ),
    );
  }
}

class _ResolvedCard extends StatelessWidget {
  const _ResolvedCard({required this.item, required this.onTap});

  final DevolucionVenta item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        padding: const EdgeInsets.fromLTRB(26, 27, 26, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF9BD5B0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF19733B),
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${item.idVenta}  ${item.customer}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.fechaTexto,
                    style: GoogleFonts.poppins(color: const Color(0xFFA49A97)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ResolutionBadge(label: item.etiquetaResolucion),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.descripcionResolucion,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF19733B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (item.devolucionNota != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.devolucionNota!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF766B68),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        item.montoTexto,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ver detalle',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF19733B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF19733B),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionBadge extends StatelessWidget {
  const _ResolutionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: const Color(0xFF19733B),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResolvedDetailDialog extends StatelessWidget {
  const _ResolvedDetailDialog({required this.item});

  final DevolucionVenta item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Devolución #${item.idVenta}',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF211616),
                        fontSize: 22,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                '${item.customer} · ${item.fechaTexto}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF766B68),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _filaDetalle('Resolución', item.etiquetaResolucion),
              _filaDetalle('Monto devuelto', item.montoDevolucionTexto),
              if (item.idVentaReemplazo != null)
                _filaDetalle('Venta de reemplazo', '#${item.idVentaReemplazo}'),
              if (item.devolucionNota != null)
                _filaDetalle('Nota', item.devolucionNota!),
              const Divider(height: 30),
              Text(
                'PRODUCTOS DEVUELTOS',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFA49A97),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 12),
              if (item.lineas.isEmpty)
                Text(
                  'Sin detalle de productos.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF766B68),
                    fontSize: 13,
                  ),
                )
              else
                ...item.lineas.map(_lineaDetalle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF766B68),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: const Color(0xFF211616),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineaDetalle(DevolucionLinea linea) {
    final motivo = linea.motivo == null
        ? 'Sin motivo registrado'
        : linea.descripcionMotivo == null ||
              linea.descripcionMotivo!.trim().isEmpty
        ? linea.motivo!
        : '${linea.motivo}: ${linea.descripcionMotivo}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE6E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _productImage(linea.imagen, size: 52),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linea.nombreCompleto,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF211616),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Cantidad original: ${linea.cantidad} · ${linea.precioTexto} c/u',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF766B68),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Motivo: $motivo',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B4610),
                    fontSize: 12,
                    height: 1.35,
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

class _ReturnManagementScreen extends StatefulWidget {
  const _ReturnManagementScreen({required this.item});

  final DevolucionVenta item;

  @override
  State<_ReturnManagementScreen> createState() =>
      _ReturnManagementScreenState();
}

class _ReturnManagementScreenState extends State<_ReturnManagementScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  String _resolution = 'money';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _bottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _returnSummary(),
                    const SizedBox(height: 22),
                    Text(
                      '¿Cómo se resuelve esta devolución?',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _resolutionCard(
                      value: 'product',
                      title: 'Producto por producto',
                      description:
                          'El cliente devuelve el pedido y recibe un producto de reemplazo.',
                      color: const Color(0xFFB8D2FF),
                      iconColor: const Color(0xFFD9E7FF),
                    ),
                    const SizedBox(height: 20),
                    _resolutionCard(
                      value: 'money',
                      title: 'Producto por dinero',
                      description:
                          'El cliente devuelve el pedido y se le reembolsa el valor pagado.',
                      color: const Color(0xFF15B98A),
                      iconColor: const Color(0xFFC9F7E5),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _confirmResolution(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: red,
                          minimumSize: const Size.fromHeight(68),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Confirmar y procesar resolución',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

  Widget _header() {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('María González'),
    );
  }

  Widget _returnSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF5CC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${widget.item.idVenta}  ${widget.item.customer} · ${widget.item.fechaTexto}',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.montoTexto,
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _paymentBadge(),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted,
                  side: const BorderSide(color: Color(0xFFE0E4E9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 22),
            child: Divider(color: Color(0xFFF1EBD6)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '¿Cómo se resuelve esta devolución?',
              style: GoogleFonts.montserrat(
                color: ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge() {
    final esNequi = widget.item.payment == 'Nequi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: esNequi ? const Color(0xFFF0E3FF) : const Color(0xFFFFF3C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        esNequi ? '💜 Nequi' : '🏦 ${widget.item.payment}',
        style: GoogleFonts.poppins(
          color: esNequi ? const Color(0xFF6E1DCB) : const Color(0xFF8B3F11),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _resolutionCard({
    required String value,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    final selected = _resolution == value;
    return InkWell(
      onTap: () => setState(() => _resolution = value),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(26, 26, 22, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: .65),
            width: selected ? 3 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? color : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                color: muted,
                fontSize: 16,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    final items = employeeNavItems();
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            handleEmployeeBottomNav(context, items[i].index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].icon,
                              color: items[i].index == 3
                                  ? red
                                  : const Color(0xFFA4AAB5),
                              size: 21,
                            ),
                            Text(
                              items[i].label,
                              style: GoogleFonts.poppins(
                                color: items[i].index == 3
                                    ? red
                                    : const Color(0xFFA4AAB5),
                                fontSize: 10,
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

  Future<void> _confirmResolution(BuildContext context) async {
    if (_resolution == 'product') {
      final resolved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => EmployeeExchangeScreen(record: widget.item),
        ),
      );
      if (resolved == true && context.mounted) {
        Navigator.of(context).pop('canje');
      }
      return;
    }

    final resolved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EmployeeRefundScreen(record: widget.item),
      ),
    );
    if (resolved == true && context.mounted) {
      Navigator.of(context).pop('dinero');
    }
  }
}

Widget _productImage(String? path, {double size = 52}) {
  final placeholder = Container(
    width: size,
    height: size,
    color: const Color(0xFFF1F3F5),
    alignment: Alignment.center,
    child: const Icon(Icons.local_pizza, color: Color(0xFFC9151E), size: 24),
  );
  if (path == null || path.isEmpty) return placeholder;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
  return Image.asset(
    path,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => placeholder,
  );
}
