part of '../purchases_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  static const _modules = [
    (
      icon: Icons.groups_outlined,
      title: 'Gestión Clientes',
      description: 'Administrar base de clientes',
    ),
    (
      icon: Icons.receipt_long_outlined,
      title: 'Gestión Ventas',
      description: 'Consulta y cambio de estado de pedidos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final modules = [
      if (Permisos.ventasClientes) _modules[0],
      if (Permisos.ventas) _modules[1],
    ];

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Gestión de Ventas',

                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),

                        fontSize: 26,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Seleccione el módulo que desea gestionar.',

                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),

                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    for (var i = 0; i < modules.length; i++) ...[
                      ModuleCard(
                        icon: modules[i].icon,
                        title: modules[i].title,
                        description: modules[i].description,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => switch (modules[i].title) {
                              'Gestión Clientes' =>
                                const _ClientManagementScreen(),
                              _ => const _SalesManagementScreen(),
                            },
                          ),
                        ),
                      ),

                      if (i != modules.length - 1) const SizedBox(height: 24),
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
    return AppHeader(
      title: 'La Sirena Pizza',

      onBack: () => Navigator.of(context).pop(),

      initials: currentUserInitials(),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 3);
}

/// Colores (fondo, borde y texto) del badge de cada estado de venta.
({Color background, Color border, Color foreground}) _ventaEstadoColors(
  BuildContext context,
  EstadoVenta? estado,
) {
  switch (estado) {
    case EstadoVenta.porVerificar:
      return (
        background: context.pal.avisoFondo(Color(0xFFFFF1D6)),
        border: context.pal.avisoFondo(Color(0xFFEFC978)),
        foreground: context.pal.avisoTexto(Color(0xFFA66500)),
      );
    case EstadoVenta.enEspera:
      return (
        background: context.pal.infoFondo(Color(0xFFEDE7FA)),
        border: context.pal.infoFondo(Color(0xFFC9B9EE)),
        foreground: context.pal.infoTexto(Color(0xFF5B3FA8)),
      );
    case EstadoVenta.porEntregar:
      return (
        background: context.pal.infoFondo(Color(0xFFE3EDFC)),
        border: context.pal.infoFondo(Color(0xFFAECBF0)),
        foreground: context.pal.infoTexto(Color(0xFF2A5FA8)),
      );
    case EstadoVenta.completado:
      return (
        background: context.pal.exitoFondo(Color(0xFFD3F1D8)),
        border: context.pal.exitoFondo(Color(0xFF7CC287)),
        foreground: context.pal.exitoTexto(Color(0xFF1F6B29)),
      );
    case EstadoVenta.devolucion:
      return (
        background: context.pal.avisoFondo(Color(0xFFFFE9D6)),
        border: context.pal.avisoFondo(Color(0xFFF0B98A)),
        foreground: context.pal.avisoTexto(Color(0xFFA14A00)),
      );
    case EstadoVenta.anulado:
      return (
        background: context.pal.errorFondo(Color(0xFFFFE3E6)),
        border: context.pal.errorFondo(Color(0xFFF2B8BE)),
        foreground: context.pal.errorTexto(Color(0xFFB3261E)),
      );
    case null:
      return (
        background: context.pal.campo(Color(0xFFECEAE9)),
        border: context.pal.borde(Color(0xFFC9C3C1)),
        foreground: context.pal.secundario(Color(0xFF5B4643)),
      );
  }
}

class _VentaEstadoBadge extends StatelessWidget {
  const _VentaEstadoBadge({required this.venta});

  final Venta venta;

  @override
  Widget build(BuildContext context) {
    final colors = _ventaEstadoColors(context, venta.estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        venta.estadoLabel,
        style: GoogleFonts.poppins(
          color: colors.foreground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Lista de ventas del admin (solo consulta).
class _SalesManagementScreen extends StatefulWidget {
  const _SalesManagementScreen({this.estadoInicial});

  /// Filtro de estado con el que abre la lista (null = todas).
  final EstadoVenta? estadoInicial;

  @override
  State<_SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<_SalesManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  late EstadoVenta? _estadoFilter = widget.estadoInicial; // null = todos
  List<Venta> _sales = const [];
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
      final sales = await VentasRepository.instance.listar();
      if (!mounted) return;
      PendingSalesService.instance.actualizarDesde(sales);
      setState(() {
        _sales = sales;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'No se pudieron cargar las ventas.';
      if (silent && _sales.isNotEmpty) {
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

  int get _pendingCount =>
      _sales.where((s) => s.estado == EstadoVenta.porVerificar).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _sales.where((sale) {
      if (_estadoFilter != null && sale.estado != _estadoFilter) return false;
      return matchesSearchQuery(_query, [
        sale.codigo,
        sale.id.toString(),
        sale.clienteNombre,
        sale.documento ?? '',
      ]);
    }).toList();

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: currentUserInitials(),
              mostrarCampana: false,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(silent: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  children: [
                    Text(
                      'Gestión Ventas',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _loading
                          ? 'Cargando ventas...'
                          : '${_sales.length} ventas registradas',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
                        fontSize: 16,
                      ),
                    ),
                    if (!_loading && _error == null && _pendingCount > 0) ...[
                      const SizedBox(height: 20),
                      _buildPendingBanner(_pendingCount),
                    ],
                    const SizedBox(height: 26),
                    AppSearchField(
                      controller: _searchController,
                      hint: 'Buscar por número o cliente...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip('Todas', null),
                        for (final estado in EstadoVenta.values)
                          _filterChip(estado.label, estado),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ..._buildContent(filtered),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, EstadoVenta? value) {
    final selected = _estadoFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _estadoFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? context.pal.rojoBoton(PurchasesScreen.red)
              : context.pal.tarjeta(PurchasesScreen.page),
          border: Border.all(
            color: selected
                ? context.pal.rojo(PurchasesScreen.red)
                : context.pal.borde(AppColors.cardBorder),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected
                ? Colors.white
                : context.pal.texto(PurchasesScreen.ink),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Venta> filtered) {
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
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Text(
              'No se encontraron ventas.',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      for (final sale in filtered) ...[
        _saleCard(sale),
        const SizedBox(height: 18),
      ],
    ];
  }

  Widget _buildPendingBanner(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: context.pal.avisoFondo(Color(0xFFFFF1D6)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.pal.avisoFondo(Color(0xFFEFC978))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.pal.avisoFondo(Color(0xFFFFE1A8)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_outlined,
              color: context.pal.avisoTexto(Color(0xFFA66500)),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$count pedido${count == 1 ? '' : 's'} pendiente${count == 1 ? '' : 's'} por verificar',
              style: GoogleFonts.poppins(
                color: context.pal.avisoTexto(Color(0xFF8A5600)),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saleCard(Venta sale) {
    return GestureDetector(
      onTap: () => _openDetail(sale),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 16, 14, 13),
        decoration: BoxDecoration(
          color: context.pal.tarjeta(PurchasesScreen.page),
          border: Border.all(color: context.pal.borde(Color(0xFFE5BDB9))),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID VENTA', style: _labelStyle()),
                      const SizedBox(height: 5),
                      Text(
                        sale.codigo,
                        style: GoogleFonts.poppins(
                          color: context.pal.texto(PurchasesScreen.ink),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _VentaEstadoBadge(venta: sale),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _saleInfo('CLIENTE', sale.clienteNombre)),
                Expanded(
                  child: _saleInfo('FECHA', formatFechaHoraVenta(sale.fecha)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _saleInfo('MONTO', formatCop(sale.monto.round())),
                ),
                Expanded(
                  child: _saleInfo(
                    sale.ventaLocal ? 'ORIGEN' : 'RECOGIDA',
                    sale.ventaLocal
                        ? 'Venta en local'
                        : formatHoraVenta(sale.horaRecogida),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 14, bottom: 8),
              child: Divider(
                height: 1,
                color: context.pal.borde(Color(0xFFE5D9D7)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _openDetail(sale),
                tooltip: 'Ver detalle',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  Icons.visibility_outlined,
                  color: context.pal.secundario(PurchasesScreen.muted),
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Venta sale) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SaleDetailScreen(sale: sale, onUpdated: _replace),
      ),
    );
  }

  /// Reemplaza la fila actualizada desde el detalle y recalcula el contador.
  void _replace(Venta updated) {
    if (!mounted) return;
    final sales = [
      for (final item in _sales) item.id == updated.id ? updated : item,
    ];
    PendingSalesService.instance.actualizarDesde(sales);
    setState(() => _sales = sales);
  }

  TextStyle _labelStyle() => GoogleFonts.poppins(
    color: context.pal.secundario(PurchasesScreen.muted),
    fontSize: 12,
  );

  Widget _saleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: context.pal.texto(PurchasesScreen.ink),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() => const ModuleBottomNav(selected: 3);
}

/// Detalle de una venta: consulta y cambios de estado.
class _SaleDetailScreen extends StatefulWidget {
  const _SaleDetailScreen({required this.sale, required this.onUpdated});

  final Venta sale;
  final ValueChanged<Venta> onUpdated;

  @override
  State<_SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<_SaleDetailScreen> {
  late Venta _sale = widget.sale;
  DateTime _fetchedAt = DateTime.now();
  bool _loading = true;
  String? _error;
  ResumenPagos? _resumen;
  String? _resumenError;

  /// Ventas > Ventas > Editar (todas las acciones).
  bool get _canEdit => Permisos.puede('Ventas', 'Ventas', 'Editar');

  bool get _enVerificacion =>
      _sale.estado == EstadoVenta.porVerificar ||
      _sale.estado == EstadoVenta.enEspera;

  /// Segundos que quedan para anular, descontando el tiempo desde la consulta.
  int get _segundosRestantes {
    final transcurridos = DateTime.now().difference(_fetchedAt).inSeconds;
    final restantes = _sale.segundosRestantesAnulacion - transcurridos;
    return restantes > 0 ? restantes : 0;
  }

  bool get _puedeAnular => ventaAnulable(_sale.estado, _segundosRestantes);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Muestra primero los datos de la lista y los reemplaza con `GET /:id`
  /// (que además trae el comprobante de cada pago).
  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await VentasRepository.instance.obtener(widget.sale.id);
      if (!mounted) return;
      _aplicar(fresh);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo actualizar el detalle.';
      });
    }
    await _cargarResumen();
  }

  void _aplicar(Venta fresh) {
    setState(() {
      _sale = fresh;
      _fetchedAt = DateTime.now();
    });
    widget.onUpdated(fresh);
  }

  Future<void> _cargarResumen() async {
    if (!_canEdit || !_enVerificacion) {
      if (mounted) {
        setState(() {
          _resumen = null;
          _resumenError = null;
        });
      }
      return;
    }
    try {
      final resumen = await VentasRepository.instance.resumenPagos(_sale.id);
      if (!mounted) return;
      setState(() {
        _resumen = resumen;
        _resumenError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resumenError = error is ApiException
            ? error.message
            : 'No se pudo cargar el resumen de pagos.';
      });
    }
  }

  /// Vuelve a consultar la venta después de una acción (no se usa la
  /// respuesta del PATCH) y refresca la lista y el contador.
  Future<void> _despuesDeAccion({bool resumen = true}) async {
    try {
      final fresh = await VentasRepository.instance.obtener(_sale.id);
      if (!mounted) return;
      _aplicar(fresh);
      setState(() => _error = null);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'La acción se realizó, pero no se pudo actualizar el detalle. '
              'Vuelve a intentarlo.';
        });
      }
    }
    if (resumen) await _cargarResumen();
    unawaited(PendingSalesService.instance.refrescar());
  }

  Future<void> _ejecutar({
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(String? motivo, int? monto) accion,
    required String exito,
    List<String>? motivos,
    String? warning,
    String? amountLabel,
    int? initialAmount,
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SaleActionDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        motivos: motivos,
        warning: warning,
        amountLabel: amountLabel,
        initialAmount: initialAmount,
        destructive: destructive,
        onSubmit: accion,
      ),
    );
    if (ok != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito)));
  }

  Future<void> _aceptar() => _ejecutar(
    title: 'Aceptar venta ${_sale.codigo}',
    message:
        'La venta pasará a "Por entregar" y se creará la orden de producción.',
    confirmLabel: 'Aceptar venta',
    exito: 'Venta aceptada.',
    accion: (_, _) async {
      await VentasRepository.instance.aceptar(_sale.id);
      await _despuesDeAccion();
    },
  );

  Future<void> _pedirMontoFaltante() => _ejecutar(
    title: 'Pedir monto faltante',
    message:
        'La venta pasará a "En espera" y el cliente recibirá un correo '
        'indicando el monto que falta.',
    confirmLabel: 'Pedir monto faltante',
    exito: 'Se pidió el monto faltante al cliente.',
    accion: (_, _) async {
      await VentasRepository.instance.pedirMontoFaltante(_sale.id);
      await _despuesDeAccion();
    },
  );

  Future<void> _rechazar() => _ejecutar(
    title: 'Rechazar venta ${_sale.codigo}',
    message: 'La venta pasará a "Anulado". Elige el motivo del rechazo.',
    confirmLabel: 'Rechazar venta',
    motivos: motivosRechazoVenta,
    destructive: true,
    exito: 'Venta rechazada.',
    accion: (motivo, _) async {
      await VentasRepository.instance.rechazar(_sale.id, motivo!);
      await _despuesDeAccion();
    },
  );

  Future<void> _marcarListo() => _ejecutar(
    title: 'Marcar como lista',
    message: '¿Confirmas que el pedido ${_sale.codigo} está listo?',
    confirmLabel: 'Marcar como lista',
    exito: 'Venta marcada como lista.',
    accion: (_, _) async {
      await VentasRepository.instance.marcarListo(_sale.id);
      await _despuesDeAccion(resumen: false);
    },
  );

  Future<void> _anular() => _ejecutar(
    title: 'Anular venta ${_sale.codigo}',
    message: 'Elige el motivo de la anulación.',
    warning:
        'Con "Cliente canceló el pedido" se reembolsa el 80 % del monto; con '
        'los demás motivos, el 100 %.',
    confirmLabel: 'Anular venta',
    motivos: motivosAnulacionVenta,
    destructive: true,
    exito: 'Venta anulada.',
    accion: (motivo, _) async {
      await VentasRepository.instance.anular(_sale.id, motivo!);
      await _despuesDeAccion();
    },
  );

  Future<void> _confirmarPago(PagoResumen pago) => _ejecutar(
    title: 'Confirmar pago',
    message:
        'Indica el monto recibido en pesos para el pago '
        '${pago.tipo ?? '#${pago.id}'}.',
    confirmLabel: 'Confirmar pago',
    amountLabel: 'Monto confirmado (COP)',
    initialAmount: pago.montoDeclarado?.round(),
    exito: 'Pago confirmado.',
    accion: (_, monto) async {
      final resumen = await VentasRepository.instance.confirmarPago(
        _sale.id,
        pago.id,
        monto!,
      );
      if (mounted) setState(() => _resumen = resumen);
      await _despuesDeAccion(resumen: false);
    },
  );

  @override
  Widget build(BuildContext context) {
    final s = _sale;
    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: currentUserInitials(),
              mostrarCampana: false,
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Venta ${s.codigo}',
                            style: GoogleFonts.montserrat(
                              color: context.pal.texto(PurchasesScreen.ink),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _VentaEstadoBadge(venta: s),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                color: context.pal.rojo(PurchasesScreen.red),
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
                    ],
                    const SizedBox(height: 16),
                    if (_canEdit && _enVerificacion) _verificationCard(),
                    if (_canEdit && _actionsAvailable) _actionsCard(),
                    if (s.estado == EstadoVenta.anulado)
                      _sectionCard(
                        background: context.pal.errorFondo(Color(0xFFFFEEF0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Venta anulada'),
                            _row('Motivo', s.motivoRechazo ?? '—'),
                            _row('Anulada por', s.anuladoPor ?? '—'),
                            if (s.montoReembolso != null)
                              _row(
                                'Monto reembolsado',
                                formatCop(s.montoReembolso!.round()),
                              ),
                          ],
                        ),
                      ),
                    if (s.estado == EstadoVenta.devolucion)
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Devolución'),
                            _row('Estado', s.devolucionEstado ?? '—'),
                            if (s.montoReembolso != null)
                              _row(
                                'Monto reembolsado',
                                formatCop(s.montoReembolso!.round()),
                              ),
                          ],
                        ),
                      ),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Cliente'),
                          _row('Nombre', s.clienteNombre),
                          _row(
                            'Documento',
                            [
                                  s.tipoDocumento,
                                  s.documento,
                                ].whereType<String>().join(' ').trim().isEmpty
                                ? '—'
                                : [
                                    s.tipoDocumento,
                                    s.documento,
                                  ].whereType<String>().join(' '),
                          ),
                          _row('Teléfono', s.telefono ?? '—'),
                          _row('Correo', s.correo ?? '—'),
                        ],
                      ),
                    ),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Pedido'),
                          _row('Fecha', formatFechaHoraVenta(s.fecha)),
                          _row(
                            s.ventaLocal ? 'Origen' : 'Hora de recogida',
                            s.ventaLocal
                                ? 'Venta en local'
                                : formatHoraVenta(s.horaRecogida),
                          ),
                          _row('Estado', s.estadoLabel),
                          _row(
                            'Orden de producción',
                            s.estadoOrden ?? 'Sin orden',
                          ),
                          _row(
                            'Monto',
                            formatCop(s.monto.round()),
                            strong: true,
                          ),
                        ],
                      ),
                    ),
                    _productsCard(s),
                    _paymentsCard(s),
                  ],
                ),
              ),
            ),
            const ModuleBottomNav(selected: 3),
          ],
        ),
      ),
    );
  }

  bool get _actionsAvailable =>
      _enVerificacion ||
      _sale.estado == EstadoVenta.porEntregar ||
      _puedeAnular;

  /// Resumen de pagos y confirmación de cada pago (Por verificar / En espera).
  Widget _verificationCard() {
    final resumen = _resumen;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Verificación de pagos'),
          if (resumen == null && _resumenError == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (_resumenError != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _resumenError!,
                    style: GoogleFonts.poppins(
                      color: context.pal.rojo(PurchasesScreen.red),
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _cargarResumen,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          if (resumen != null) ...[
            _row('Total', formatCop(resumen.total.round())),
            _row('Recibido', formatCop(resumen.recibido.round())),
            _row('En revisión', formatCop(resumen.enRevision.round())),
            _row(
              'Falta',
              formatCop(resumen.falta.round()),
              strong: resumen.falta > 0,
            ),
            if (resumen.saldoAFavor > 0)
              _row('Saldo a favor', formatCop(resumen.saldoAFavor.round())),
            for (final pago in resumen.pagos) ...[
              Divider(height: 22, color: context.pal.borde(Color(0xFFE5D9D7))),
              _row('Pago', pago.tipo ?? '#${pago.id}'),
              _row('Estado', pago.estado ?? '—'),
              _row(
                'Declarado',
                pago.montoDeclarado == null
                    ? '—'
                    : formatCop(pago.montoDeclarado!.round()),
              ),
              _row(
                'Confirmado',
                pago.montoConfirmado == null
                    ? '—'
                    : formatCop(pago.montoConfirmado!.round()),
              ),
              if (pago.pendienteDeConfirmar)
                Align(
                  alignment: Alignment.centerRight,
                  child: _actionButton(
                    'Confirmar pago',
                    Icons.payments_outlined,
                    () => _confirmarPago(pago),
                    compact: true,
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _actionsCard() {
    final resumen = _resumen;
    final puedeAceptar = resumen != null && resumen.falta <= 0;
    final faltaMonto = resumen != null && resumen.falta > 0;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Acciones'),
          if (_enVerificacion) ...[
            if (resumen != null && !puedeAceptar)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Faltan ${formatCop(resumen.falta.round())} por recibir. '
                  'Confirma los pagos para poder aceptar la venta.',
                  style: GoogleFonts.poppins(
                    color: context.pal.avisoTexto(Color(0xFF8A5600)),
                    fontSize: 13,
                  ),
                ),
              ),
            _actionButton(
              'Aceptar venta',
              Icons.check_circle_outline,
              puedeAceptar ? _aceptar : null,
              filled: true,
            ),
            if (faltaMonto) ...[
              const SizedBox(height: 10),
              _actionButton(
                'Pedir monto faltante',
                Icons.mark_email_unread_outlined,
                _pedirMontoFaltante,
              ),
            ],
            const SizedBox(height: 10),
            _actionButton(
              'Rechazar',
              Icons.cancel_outlined,
              _rechazar,
              destructive: true,
            ),
          ],
          if (_sale.estado == EstadoVenta.porEntregar) ...[
            _actionButton(
              'Marcar como lista',
              Icons.done_all,
              _marcarListo,
              filled: true,
            ),
          ],
          if (_puedeAnular) ...[
            const SizedBox(height: 10),
            _actionButton(
              'Anular venta',
              Icons.block,
              _anular,
              destructive: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback? onPressed, {
    bool filled = false,
    bool destructive = false,
    bool compact = false,
  }) {
    final color = destructive
        ? context.pal.rojo(PurchasesScreen.red)
        : context.pal.texto(PurchasesScreen.ink);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(compact ? 20 : 25),
    );
    final child = Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: compact ? 13 : 15,
        fontWeight: FontWeight.w700,
      ),
    );
    final button = filled
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 19),
            label: child,
            style: FilledButton.styleFrom(
              backgroundColor: context.pal.rojoBoton(PurchasesScreen.red),
              shape: shape,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 19),
            label: child,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(
                color: onPressed == null
                    ? context.pal.borde(Color(0xFFD8D0CE))
                    : color,
              ),
              shape: shape,
            ),
          );
    if (compact) return button;
    return SizedBox(width: double.infinity, height: 48, child: button);
  }

  Widget _sectionCard({required Widget child, Color? background}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: background ?? context.pal.tarjeta(PurchasesScreen.page),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.pal.borde(Color(0xFFE5BDB9))),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: context.pal.texto(PurchasesScreen.ink),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: strong
                    ? context.pal.rojo(PurchasesScreen.red)
                    : context.pal.texto(PurchasesScreen.ink),
                fontSize: strong ? 17 : 14,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsCard(Venta s) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Productos'),
          if (s.detalles.isEmpty)
            Text(
              'Sin productos registrados.',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 13,
              ),
            ),
          for (var i = 0; i < s.detalles.length; i++) ...[
            if (i > 0)
              Divider(height: 18, color: context.pal.borde(Color(0xFFE5D9D7))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.detalles[i].nombre,
                        style: GoogleFonts.poppins(
                          color: context.pal.texto(PurchasesScreen.ink),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_purchaseQuantity(s.detalles[i].cantidad)} × '
                        '${formatCop(s.detalles[i].precioUnitario.round())}'
                        '${s.detalles[i].tamano != null ? '  •  ${s.detalles[i].tamano}' : ''}',
                        style: GoogleFonts.poppins(
                          color: context.pal.secundario(PurchasesScreen.muted),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatCop(s.detalles[i].subTotal.round()),
                  style: GoogleFonts.poppins(
                    color: context.pal.texto(PurchasesScreen.ink),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentsCard(Venta s) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Pagos'),
          if (s.pagos.isEmpty)
            Text(
              'Sin pagos registrados.',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 13,
              ),
            ),
          for (var i = 0; i < s.pagos.length; i++) ...[
            if (i > 0)
              Divider(height: 24, color: context.pal.borde(Color(0xFFE5D9D7))),
            _row('Tipo', s.pagos[i].tipo ?? '—'),
            _row('Estado', s.pagos[i].estado ?? '—'),
            if (s.pagos[i].fecha != null)
              _row('Fecha', formatFechaHoraVenta(s.pagos[i].fecha)),
            _row(
              'Cantidad a pagar',
              s.pagos[i].cantidadPagar == null
                  ? '—'
                  : formatCop(s.pagos[i].cantidadPagar!.round()),
            ),
            _row(
              'Depositado',
              s.pagos[i].depositado == null
                  ? '—'
                  : formatCop(s.pagos[i].depositado!.round()),
            ),
            _row(
              'Faltante',
              s.pagos[i].faltante == null
                  ? '—'
                  : formatCop(s.pagos[i].faltante!.round()),
            ),
            if (s.pagos[i].tieneComprobante) ...[
              const SizedBox(height: 10),
              Text(
                'Comprobante',
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(PurchasesScreen.muted),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _ReceiptImage(value: s.pagos[i].comprobante, loading: _loading),
            ],
          ],
        ],
      ),
    );
  }
}

/// Diálogo de confirmación para una acción sobre una venta: motivo opcional
/// (opciones fijas u "Otro: …" con máx. 80 caracteres), monto opcional,
/// spinner, bloqueo de doble envío y errores del backend dentro del diálogo
/// (incluida la lista de faltantes de stock).
class _SaleActionDialog extends StatefulWidget {
  const _SaleActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onSubmit,
    this.motivos,
    this.warning,
    this.amountLabel,
    this.initialAmount,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final List<String>? motivos;
  final String? warning;
  final String? amountLabel;
  final int? initialAmount;
  final bool destructive;
  final Future<void> Function(String? motivo, int? monto) onSubmit;

  @override
  State<_SaleActionDialog> createState() => _SaleActionDialogState();
}

class _SaleActionDialogState extends State<_SaleActionDialog> {
  static const String _otro = motivoOtroVenta;
  static const int _maxOtro = maxDetalleMotivoVenta;

  late final TextEditingController _otroController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController(
    text: widget.initialAmount?.toString() ?? '',
  );
  String? _selected;
  bool _saving = false;
  String? _error;
  List<FaltanteStock> _faltantes = const [];

  @override
  void dispose() {
    _otroController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    String? motivo;
    int? monto;

    if (widget.motivos != null) {
      if (_selected == null) {
        setState(() => _error = 'Elige un motivo.');
        return;
      }
      if (_selected == _otro) {
        final detalle = _otroController.text.trim();
        if (detalle.isEmpty) {
          setState(() => _error = 'Escribe el detalle del motivo.');
          return;
        }
        motivo = motivoVentaParaEnviar(_otro, detalle);
      } else {
        motivo = _selected;
      }
    }
    if (widget.amountLabel != null) {
      monto = int.tryParse(_amountController.text.trim());
      if (monto == null || monto <= 0) {
        setState(() => _error = 'Ingresa un monto entero mayor a 0.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
      _faltantes = const [];
    });
    try {
      await widget.onSubmit(motivo, monto);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _faltantes = FaltanteStock.desde(error);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo completar la acción.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final motivos = widget.motivos;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            if (widget.warning != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.warning!,
                style: TextStyle(
                  color: context.pal.avisoTexto(Color(0xFF8A5600)),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (motivos != null) ...[
              const SizedBox(height: 12),
              for (final opcion in [...motivos, _otro])
                InkWell(
                  onTap: _saving
                      ? null
                      : () => setState(() => _selected = opcion),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _selected == opcion
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: _selected == opcion
                              ? context.pal.rojo(PurchasesScreen.red)
                              : context.pal.secundario(PurchasesScreen.muted),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(opcion)),
                      ],
                    ),
                  ),
                ),
              if (_selected == _otro) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _otroController,
                  enabled: !_saving,
                  maxLength: _maxOtro,
                  decoration: const InputDecoration(
                    labelText: 'Detalle del motivo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
            if (widget.amountLabel != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: widget.amountLabel,
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(
                  color: context.pal.errorTexto(AppColors.statusRedFg),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_faltantes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Existencias insuficientes:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final f in _faltantes)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '• ${f.nombre}: requerido ${_qty(f.requerido, f.unidad)}, '
                    'stock ${_qty(f.stock, f.unidad)}, '
                    'falta ${_qty(f.falta, f.unidad)}'
                    '${f.motivo != null ? ' (${f.motivo})' : ''}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: widget.destructive
                ? context.pal.rojoBoton(PurchasesScreen.red)
                : context.pal.borde(PurchasesScreen.ink),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }

  String _qty(double? value, String? unit) {
    if (value == null) return '—';
    final texto = _purchaseQuantity(value);
    return unit == null ? texto : '$texto $unit';
  }
}

/// Muestra el comprobante de pago según el formato en que llegue:
/// URL http(s) o data URL / base64. Cualquier otro formato se indica sin
/// intentar adivinarlo.
class _ReceiptImage extends StatelessWidget {
  const _ReceiptImage({required this.value, required this.loading});

  final Object? value;
  final bool loading;

  static final RegExp _base64 = RegExp(r'^[A-Za-z0-9+/=\s_-]+$');

  @override
  Widget build(BuildContext context) {
    final raw = value;
    if (raw == null) {
      return _message(
        context,
        loading ? 'Cargando comprobante...' : 'Comprobante no disponible.',
      );
    }
    if (raw is! String || raw.trim().isEmpty) {
      return _message(context, 'Formato de comprobante no reconocido.');
    }
    final text = raw.trim();

    Widget image;
    if (text.startsWith('http://') || text.startsWith('https://')) {
      image = Image.network(
        text,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
        errorBuilder: (_, _, _) =>
            _message(context, 'No se pudo cargar el comprobante.'),
      );
    } else {
      final bytes = _decodeBytes(text);
      if (bytes == null) {
        return _message(context, 'Formato de comprobante no reconocido.');
      }
      image = Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            _message(context, 'No se pudo mostrar el comprobante.'),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(10), child: image);
  }

  Uint8List? _decodeBytes(String text) {
    var data = text;
    if (data.startsWith('data:')) {
      final coma = data.indexOf(',');
      if (coma < 0) return null;
      data = data.substring(coma + 1);
    } else if (data.length < 100 || !_base64.hasMatch(data)) {
      return null;
    }
    try {
      return base64Decode(base64.normalize(data.replaceAll(RegExp(r'\s'), '')));
    } on FormatException {
      return null;
    }
  }

  Widget _message(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.pal.campo(AppColors.fieldFill),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: context.pal.secundario(AppColors.muted),
          fontSize: 13,
        ),
      ),
    );
  }
}
