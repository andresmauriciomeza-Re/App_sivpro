part of '../purchases_screen.dart';

String _cop(double value) => formatCop(value.round());

String _purchaseQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// Compras realizadas: consulta y anulación (cambio de estado).
class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() =>
      _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  String _query = '';
  String? _estadoFilter; // null = todas
  List<Compra> _purchases = const [];
  bool _loading = true;
  String? _error;

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
      final purchases = await PurchasesRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _purchases = purchases;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'No se pudieron cargar las compras.';
      if (silent && _purchases.isNotEmpty) {
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

  void _replace(Compra updated) {
    if (!mounted) return;
    setState(() {
      _purchases = [
        for (final item in _purchases) item.id == updated.id ? updated : item,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _purchases.where((purchase) {
      if (_estadoFilter != null &&
          purchase.estado.toLowerCase() != _estadoFilter!.toLowerCase()) {
        return false;
      }
      return matchesSearchQuery(_query, [
        purchase.nFactura,
        purchase.proveedorNombre,
        purchase.proveedorNit ?? '',
      ]);
    }).toList();

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
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
                  padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
                  children: [
                    Text(
                      'Gestión Compras',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _loading
                          ? 'Cargando compras...'
                          : '${_purchases.length} compras registradas',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                    AppSearchField(
                      hint: 'Buscar por factura, proveedor o NIT...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip('Todas', null),
                        _filterChip('Recibido', 'Recibido'),
                        _filterChip('Anulado', 'Anulado'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._buildContent(filtered),
                  ],
                ),
              ),
            ),
            _suppliesBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _estadoFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _estadoFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? PurchasesScreen.red : PurchasesScreen.page,
          border: Border.all(
            color: selected ? PurchasesScreen.red : AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : PurchasesScreen.ink,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Compra> filtered) {
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
                style: GoogleFonts.poppins(color: PurchasesScreen.muted),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: PurchasesScreen.red,
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
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              'No se encontraron compras',
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }
    return filtered.map(_buildPurchaseCard).toList();
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _buildPurchaseCard(Compra purchase) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _navigateToDetail(purchase),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: PurchasesScreen.page,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DDDB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    purchase.proveedorNombre,
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _PurchaseStatusBadge(estado: purchase.estado),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('FECHA DE FACTURA'),
                      Text(
                        purchase.fecha,
                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('N° DE FACTURA'),
                      Text(
                        purchase.nFactura,
                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _cop(purchase.total),
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Compra purchase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _PurchaseDetailScreen(purchase: purchase, onUpdated: _replace),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      color: PurchasesScreen.muted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _PurchaseStatusBadge extends StatelessWidget {
  const _PurchaseStatusBadge({required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final received = estado.toLowerCase() == 'recibido';
    final color = received ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final background = received
        ? const Color(0xFFE4F4E7)
        : const Color(0xFFFFE3E6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        estado,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PurchaseDetailScreen extends StatefulWidget {
  const _PurchaseDetailScreen({
    required this.purchase,
    required this.onUpdated,
  });

  final Compra purchase;
  final ValueChanged<Compra> onUpdated;

  @override
  State<_PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<_PurchaseDetailScreen> {
  late Compra _purchase = widget.purchase;
  bool _loading = true;
  String? _error;

  /// Compras > Compra > Editar (anular).
  bool get _canEdit => Permisos.puede('Compras', 'Compra', 'Editar');

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
      final fresh = await PurchasesRepository.instance.obtener(
        widget.purchase.id,
      );
      if (!mounted) return;
      setState(() {
        _purchase = fresh;
        _loading = false;
      });
      widget.onUpdated(fresh);
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

  Future<void> _anular() async {
    final updated = await showDialog<Compra>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AnularCompraDialog(purchase: _purchase),
    );
    if (updated == null || !mounted) return;
    setState(() => _purchase = updated);
    widget.onUpdated(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compra anulada. Las existencias fueron devueltas.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchase = _purchase;
    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalle de Compra',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              purchase.proveedorNombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _PurchaseStatusBadge(estado: purchase.estado)),
          ),
        ],
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                        color: AppColors.statusRedFg,
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
              const SizedBox(height: 8),
            ],
            _buildBanner(),
            const SizedBox(height: 20),
            _readOnlyField('N° Factura', purchase.nFactura),
            const SizedBox(height: 14),
            _readOnlyField('Fecha de factura', purchase.fecha),
            const SizedBox(height: 14),
            _readOnlyField('Proveedor', purchase.proveedorNombre),
            const SizedBox(height: 14),
            _readOnlyField('NIT', purchase.proveedorNit ?? ''),
            if (purchase.idOrdenCompra != null) ...[
              const SizedBox(height: 14),
              _readOnlyField(
                'Orden de compra asociada',
                'OC-${purchase.idOrdenCompra.toString().padLeft(3, '0')}',
              ),
            ],
            const SizedBox(height: 24),
            _buildLinesList(purchase),
            if (purchase.esRecibido && _canEdit) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _anular,
                  icon: const Icon(Icons.block, size: 20),
                  label: Text(
                    'Anular compra',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PurchasesScreen.red,
                    side: const BorderSide(color: PurchasesScreen.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final anulada = _purchase.esAnulado;
    final bg = anulada ? const Color(0xFFFFEEF0) : AppColors.bannerGreenBg;
    final borderColor = anulada
        ? const Color(0xFFF2B8BE)
        : AppColors.bannerGreenBorder;
    final fg = anulada ? const Color(0xFFB3261E) : AppColors.bannerGreenFg;
    final texto = anulada
        ? 'Compra anulada'
              '${_purchase.fechaAnulacion != null ? ' el ${_purchase.fechaAnulacion}' : ''}'
              '${_purchase.motivoAnulacion != null ? '.\nMotivo: ${_purchase.motivoAnulacion}' : '.'}'
        : 'Compra recibida. Solo puede anularse; no puede modificarse.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.poppins(color: fg, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
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
            style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildLinesList(Compra purchase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalle de la compra',
          style: GoogleFonts.montserrat(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.headerDivider),
          ),
          child: Column(
            children: [
              if (purchase.detalle.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Esta compra no tiene líneas de detalle.',
                    style: GoogleFonts.poppins(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              for (var i = 0; i < purchase.detalle.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.headerDivider),
                _buildLineCard(purchase.detalle[i]),
              ],
              const Divider(height: 1, color: AppColors.headerDivider),
              _buildTotals(purchase),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineCard(CompraLinea item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    item.nombre,
                    style: GoogleFonts.poppins(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Text(
                _cop(item.subtotal),
                style: GoogleFonts.poppins(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_purchaseQuantity(item.cantidad)} ${item.medida}',
                style: GoogleFonts.poppins(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              Text(
                '${_cop(item.precioUnitario)} c/u',
                style: GoogleFonts.poppins(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'IVA: ${_cop(item.montoIva)}'
            '${item.esNoSolicitado ? '  •  No solicitado' : ''}',
            style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            _cop(value),
            style: GoogleFonts.poppins(
              color: strong ? PurchasesScreen.red : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(Compra purchase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          _totalRow('Subtotal sin IVA', purchase.subtotalSinIva),
          _totalRow('Total IVA', purchase.totalIva),
          _totalRow('Total', purchase.total, strong: true),
        ],
      ),
    );
  }
}

/// Confirmación + motivo obligatorio para anular una compra.
class _AnularCompraDialog extends StatefulWidget {
  const _AnularCompraDialog({required this.purchase});

  final Compra purchase;

  @override
  State<_AnularCompraDialog> createState() => _AnularCompraDialogState();
}

class _AnularCompraDialogState extends State<_AnularCompraDialog> {
  static const int _maxMotivo = 500;

  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final motivo = _controller.text.trim();
    if (motivo.isEmpty) {
      setState(() => _error = 'El motivo es obligatorio.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await PurchasesRepository.instance.anular(
        widget.purchase.id,
        motivo,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo anular la compra.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Anular compra ${widget.purchase.nFactura}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La anulación devuelve las existencias al inventario y no se '
              'puede deshacer. Indica el motivo.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              enabled: !_saving,
              maxLength: _maxMotivo,
              maxLines: 4,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo de anulación',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.statusRedFg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: PurchasesScreen.red),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const Text('Anular compra'),
        ),
      ],
    );
  }
}
