part of '../purchases_screen.dart';

class ProductionModulesScreen extends StatelessWidget {
  const ProductionModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Gestión de Producción',
                    style: GoogleFonts.montserrat(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccione el módulo que desea gestionar.',
                    style: GoogleFonts.poppins(
                      color: context.pal.secundario(PurchasesScreen.muted),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cada tarjeta exige su propio permiso de lectura.
                  ...[
                    if (Permisos.produccionOrdenes)
                      _moduleCard(
                        context,
                        Icons.assignment_outlined,
                        'Órdenes de producción',
                        'Consultar, actualizar y cambiar estado de órdenes.',
                        const _ProductionOrdersScreen(),
                      ),
                    if (Permisos.produccionProductos)
                      _moduleCard(
                        context,
                        Icons.inventory_2_outlined,
                        'Productos',
                        'Consultar y actualizar productos.',
                        const _ProductManagementScreen(),
                      ),
                  ].expand((tarjeta) => [tarjeta, const SizedBox(height: 24)]),
                ],
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  /// Misma tarjeta grande que el hub de Compras ([ModuleCard]).
  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Widget destination,
  ) {
    return ModuleCard(
      icon: icon,
      title: title,
      description: description,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => destination)),
    );
  }

  Widget _bottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 2);
}

class _ProductionStatusStyle {
  const _ProductionStatusStyle._();

  static Color color(BuildContext context, String status) => switch (status) {
    'Completada' => context.pal.exitoTexto(Color(0xFF1E7B34)),
    'En proceso' => context.pal.infoTexto(Color(0xFF1E40AF)),
    'Pendiente' => context.pal.avisoTexto(Color(0xFF8A6D00)),
    _ => context.pal.errorTexto(Color(0xFFD32F2F)),
  };

  static Color background(BuildContext context, String status) =>
      switch (status) {
        'Completada' => context.pal.exitoFondo(Color(0xFFD4F7E9)),
        'En proceso' => context.pal.infoFondo(Color(0xFFDCE8FF)),
        'Pendiente' => context.pal.avisoFondo(Color(0xFFFFF4C7)),
        _ => context.pal.errorFondo(Color(0xFFFFE0E3)),
      };
}

class _ProductionOrdersScreen extends StatefulWidget {
  const _ProductionOrdersScreen();

  @override
  State<_ProductionOrdersScreen> createState() =>
      _ProductionOrdersScreenState();
}

class _ProductionOrdersScreenState extends State<_ProductionOrdersScreen> {
  String _query = '';
  List<OrdenProduccion> _orders = [];
  bool _loading = true;
  String? _errorMessage;
  int? _workingOrderId;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        if (showLoading) _loading = true;
      });
    }
    try {
      final orders = await ProductionRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo completar la operación.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _orders
        .where((order) {
          final lines = order.lineas.map((line) => line.nombre).join(' ');
          return matchesSearchQuery(_query, [
            order.id.toString(),
            order.tipoLabel,
            order.estado,
            order.ventaNumero ?? '',
            order.cliente ?? '',
            lines,
          ]);
        })
        .toList(growable: false);

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  children: [
                    Text(
                      'Órdenes de producción',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_orders.length} órdenes',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppSearchField(
                      hint: 'Buscar por orden, tipo, cliente o producto...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 26),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      _errorView(_errorMessage!, _loadOrders)
                    else if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No hay órdenes para mostrar.',
                            style: GoogleFonts.poppins(
                              color: context.pal.secundario(
                                PurchasesScreen.muted,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      for (final order in filtered) ...[
                        _buildOrderCard(order),
                        const SizedBox(height: 20),
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

  Widget _errorView(String message, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: context.pal.rojo(PurchasesScreen.red),
              ),
            ),
            TextButton(onPressed: retry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
    );
  }

  Widget _buildOrderCard(OrdenProduccion order) {
    final busy = _workingOrderId == order.id;
    final linesSummary = order.lineas
        .map(
          (line) => '${line.nombre}: ${line.cantidadEstimada} ${line.unidad}',
        )
        .join('\n');

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(PurchasesScreen.page),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.pal.borde(Color(0xFFE1D8D6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Orden ${order.id}',
                  style: GoogleFonts.poppins(
                    color: context.pal.texto(PurchasesScreen.ink),
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _statusPill(order.estado),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tipo: ${order.tipoLabel}',
            style: GoogleFonts.poppins(
              color: context.pal.texto(PurchasesScreen.ink),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solicitada: ${_formatDate(order.fechaSolicitada)}'
            '${order.horaSolicitada == null ? '' : ' · ${order.horaSolicitada}'}',
            style: GoogleFonts.poppins(
              color: context.pal.secundario(PurchasesScreen.muted),
            ),
          ),
          if (order.fechaEntregaEstimada != null)
            Text(
              'Entrega estimada: ${_formatDateTime(order.fechaEntregaEstimada!)}',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
              ),
            ),
          if (order.ventaNumero != null)
            Text(
              'Pedido: ${order.ventaNumero}',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
              ),
            ),
          if (order.cliente != null)
            Text(
              'Cliente: ${order.cliente}',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
              ),
            ),
          if (linesSummary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              linesSummary,
              style: GoogleFonts.poppins(
                color: context.pal.texto(PurchasesScreen.ink),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _OrderActions(
            order: order,
            busy: busy,
            onStart: () => _guarded(() => _startOrder(order)),
            onComplete: () => _guarded(() => _completeOrder(order)),
            onDarBaja: () => _guarded(() => _askDarBaja(order)),
            onEdit: () => _guarded(() => _editOrder(order)),
            onDetail: () => _openDetail(order),
            soloIconos: true,
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _ProductionStatusStyle.background(context, status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ProductionStatusStyle.color(context, status),
        ),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: _ProductionStatusStyle.color(context, status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Evita que un doble toque abra dos diálogos o dispare dos acciones.
  bool _acting = false;

  Future<void> _guarded(Future<void> Function() action) async {
    if (_acting) return;
    _acting = true;
    try {
      await action();
    } finally {
      _acting = false;
    }
  }

  Future<bool> _confirm(
    String title,
    String message,
    String confirmLabel,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true && mounted;
  }

  /// Edita la orden (observación, fecha/hora o tiempo según tipo y estado).
  Future<void> _editOrder(OrdenProduccion order) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _OrderEditDialog(order: order, isAdmin: _isAdminRole()),
    );
    if (saved != true || !mounted) return;
    // Se vuelve a consultar la lista (y el detalle, si está abierto) para
    // mostrar lo que quedó guardado.
    await _loadOrders(showLoading: false);
    if (mounted && _errorMessage == null) {
      _showMessage('Orden actualizada.', TipoMensaje.exito);
    }
  }

  Future<void> _startOrder(OrdenProduccion order) async {
    if (!await _confirm(
      'Iniciar orden ${order.id}',
      'La orden pasará a "En proceso".',
      'Iniciar',
    )) {
      return;
    }
    await _runOrderAction(
      order.id,
      () => ProductionRepository.instance.iniciar(order.id),
      'Orden iniciada.',
    );
  }

  Future<void> _completeOrder(OrdenProduccion order) async {
    // En una Preparación, el diálogo de completado ya pide confirmar.
    if (order.tipo == 'Pedido' &&
        !await _confirm(
          'Completar orden ${order.id}',
          'La orden pasará a "Completada" y se descontarán los insumos.',
          'Completar',
        )) {
      return;
    }
    if (!mounted) return;
    setState(() => _workingOrderId = order.id);
    try {
      if (order.tipo == 'Pedido') {
        await ProductionRepository.instance.completar(order.id);
      } else {
        final verification = await ProductionRepository.instance
            .obtenerVerificacion(order.id);
        final hasSizedProducts = order.lineas.any(
          (line) =>
              line.idProducto != null &&
              (line.tamano == 'Mediana' || line.tamano == 'Grande'),
        );
        final products = hasSizedProducts
            ? await ProductsRepository.instance.listar()
            : const <ProductoGestion>[];
        final payload = await _completionDialog(order, verification, products);
        if (payload == null) return;
        await ProductionRepository.instance.completar(order.id, body: payload);
      }
      if (!mounted) return;
      await _loadOrders(showLoading: false);
      if (mounted && _errorMessage == null) {
        _showMessage('Orden completada.', TipoMensaje.exito);
      }
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo completar la operación.');
    } finally {
      if (mounted) setState(() => _workingOrderId = null);
    }
  }

  Future<Map<String, Object?>?> _completionDialog(
    OrdenProduccion order,
    List<LineaVerificacionProduccion> verification,
    List<ProductoGestion> products,
  ) async {
    final requiredByLine = {
      for (final item in verification) item.idDetalle: item.cantidadDebida,
    };
    if (order.lineas.any(
      (line) => !requiredByLine.containsKey(line.idDetalle),
    )) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }

    final quantities = {
      for (final line in order.lineas) line.idDetalle: TextEditingController(),
    };
    final orderProductIds = order.lineas
        .where(
          (line) =>
              line.idProducto != null &&
              (line.tamano == 'Mediana' || line.tamano == 'Grande'),
        )
        .map((line) => line.idProducto!)
        .toSet();
    final pizzas = products
        .where(
          (product) =>
              orderProductIds.contains(product.idProducto) &&
              (product.categoriaNombre ?? '').toLowerCase().contains('pizza'),
        )
        .toList(growable: false);
    final pizzasById = {
      for (final product in pizzas) product.idProducto: product,
    };
    final medianPrices = {
      for (final product in pizzas)
        product.idProducto: TextEditingController(
          text: product.precioVenta > 0 ? product.precioVenta.toString() : '',
        ),
    };
    final largePrices = {
      for (final product in pizzas)
        product.idProducto: TextEditingController(
          text: product.precioGrande != null && product.precioGrande! > 0
              ? product.precioGrande.toString()
              : '',
        ),
    };
    String? validationMessage;

    try {
      return await showDialog<Map<String, Object?>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Completar preparación'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in order.lineas) ...[
                      Text(
                        '${line.nombre}'
                        '${line.tamano == null ? '' : ' · ${line.tamano}'}'
                        ' (debida: ${requiredByLine[line.idDetalle]})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextField(
                        controller: quantities[line.idDetalle],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad real',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (pizzas.isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Precio de venta por porción',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      for (final product in pizzas) ...[
                        const SizedBox(height: 12),
                        Text(product.nombre),
                        TextField(
                          controller: medianPrices[product.idProducto],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Precio actual/requerido Mediana',
                          ),
                        ),
                        TextField(
                          controller: largePrices[product.idProducto],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Precio actual/requerido Grande',
                          ),
                        ),
                      ],
                    ],
                    if (validationMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        validationMessage!,
                        style: TextStyle(
                          color: context.pal.rojo(PurchasesScreen.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final actuals = <Map<String, int>>[];
                  for (final line in order.lineas) {
                    final text = quantities[line.idDetalle]!.text.trim();
                    final actual = int.tryParse(text);
                    final due = requiredByLine[line.idDetalle]!;
                    if (actual == null || actual < 0 || actual > due) {
                      setDialogState(
                        () => validationMessage =
                            'Ingresa una cantidad real entera entre 0 y $due para cada línea.',
                      );
                      return;
                    }
                    actuals.add({
                      'id_detalle_op': line.idDetalle,
                      'cantidad_real': actual,
                    });
                  }

                  final prices = <Map<String, Object?>>[];
                  for (final product in pizzas) {
                    final medium = double.tryParse(
                      medianPrices[product.idProducto]!.text.trim(),
                    );
                    final large = double.tryParse(
                      largePrices[product.idProducto]!.text.trim(),
                    );
                    if (medium == null ||
                        large == null ||
                        !medium.isFinite ||
                        !large.isFinite ||
                        medium <= 0 ||
                        large <= 0 ||
                        large <= medium) {
                      setDialogState(
                        () => validationMessage =
                            'Ingresa precios positivos y un precio Grande mayor que Mediana para cada producto.',
                      );
                      return;
                    }
                    final current = pizzasById[product.idProducto]!;
                    final entry = <String, Object?>{
                      'id_producto': product.idProducto,
                    };
                    if (current.precioVenta <= 0 ||
                        medium != current.precioVenta) {
                      entry['precio_mediana'] = medium;
                    }
                    if (current.precioGrande == null ||
                        current.precioGrande! <= 0 ||
                        large != current.precioGrande) {
                      entry['precio_grande'] = large;
                    }
                    if (entry.length > 1) prices.add(entry);
                  }

                  final body = <String, Object?>{'lineas': actuals};
                  if (prices.isNotEmpty) body['precios'] = prices;
                  Navigator.of(dialogContext).pop(body);
                },
                child: const Text('Completar'),
              ),
            ],
          ),
        ),
      );
    } finally {
      for (final controller in quantities.values) {
        controller.dispose();
      }
      for (final controller in medianPrices.values) {
        controller.dispose();
      }
      for (final controller in largePrices.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _askDarBaja(OrdenProduccion order) async {
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _DarBajaDialog(orderId: order.id),
    );
    if (data == null || !mounted) return;
    await _runOrderAction(
      order.id,
      () => ProductionRepository.instance.darBaja(
        order.id,
        motivo: data['motivo']!,
        descripcion: data['descripcion']!,
      ),
      'Orden dada de baja.',
    );
  }

  Future<void> _runOrderAction(
    int id,
    Future<OrdenProduccion> Function() action,
    String successMessage,
  ) async {
    setState(() => _workingOrderId = id);
    try {
      await action();
      if (!mounted) return;
      await _loadOrders(showLoading: false);
      if (mounted && _errorMessage == null) {
        _showMessage(successMessage, TipoMensaje.exito);
      }
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo completar la operación.');
    } finally {
      if (mounted) setState(() => _workingOrderId = null);
    }
  }

  Future<void> _openDetail(OrdenProduccion order) async {
    try {
      final detail = await ProductionRepository.instance.obtener(order.id);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _ProductionOrderDetailScreen(
            order: detail,
            onStart: (o) => _guarded(() => _startOrder(o)),
            onComplete: (o) => _guarded(() => _completeOrder(o)),
            onDarBaja: (o) => _guarded(() => _askDarBaja(o)),
            onEdit: (o) => _guarded(() => _editOrder(o)),
          ),
        ),
      );
      if (mounted) await _loadOrders(showLoading: false);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo completar la operación.');
    }
  }

  void _showMessage(String message, [TipoMensaje tipo = TipoMensaje.error]) {
    ScaffoldMessenger.of(context).mostrarMensaje(
      message,
      tipo: tipo,
      // Con el detalle de la orden encima no hay barra inferior.
      sobreBarraPanel: ModalRoute.of(context)?.isCurrent ?? true,
    );
  }

  String _formatDate(String value) {
    final date = value.substring(0, value.length < 10 ? value.length : 10);
    final parts = date.split('-');
    return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : value;
  }

  String _formatDateTime(String value) {
    final date = value.replaceFirst('T', ' ');
    return date.length > 16 ? date.substring(0, 16) : date;
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 2);
}

class _ProductionOrderDetailScreen extends StatefulWidget {
  const _ProductionOrderDetailScreen({
    required this.order,
    required this.onStart,
    required this.onComplete,
    required this.onDarBaja,
    required this.onEdit,
  });

  final OrdenProduccion order;
  final Future<void> Function(OrdenProduccion) onStart;
  final Future<void> Function(OrdenProduccion) onComplete;
  final Future<void> Function(OrdenProduccion) onDarBaja;
  final Future<void> Function(OrdenProduccion) onEdit;

  @override
  State<_ProductionOrderDetailScreen> createState() =>
      _ProductionOrderDetailScreenState();
}

class _ProductionOrderDetailScreenState
    extends State<_ProductionOrderDetailScreen> {
  late OrdenProduccion _order;
  bool _loading = true;
  bool _busy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadDetail();
  }

  /// Ejecuta una acción de la lista y vuelve a consultar la orden.
  Future<void> _act(Future<void> Function(OrdenProduccion) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action(_order);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) await _loadDetail(showLoading: false);
  }

  Future<void> _loadDetail({bool showLoading = true}) async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        if (showLoading) _loading = true;
      });
    }
    try {
      final order = await ProductionRepository.instance.obtener(_order.id);
      if (!mounted) return;
      setState(() {
        _order = order;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo completar la operación.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDetail,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Orden ${_order.id}',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tipo: ${_order.tipoLabel}',
                      style: GoogleFonts.poppins(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _errorView(_errorMessage!, () => _loadDetail())
                    else ...[
                      _detailRow('Estado', _order.estado),
                      if (_order.tiempoPreparacionMin != null)
                        _detailRow(
                          'Tiempo de preparación',
                          '${_order.tiempoPreparacionMin} min',
                        ),
                      _detailRow(
                        'Fecha solicitada',
                        _formatDate(_order.fechaSolicitada),
                      ),
                      if (_order.horaSolicitada != null)
                        _detailRow('Hora solicitada', _order.horaSolicitada!),
                      if (_order.fechaEntregaEstimada != null)
                        _detailRow(
                          'Entrega estimada',
                          _formatDateTime(_order.fechaEntregaEstimada!),
                        ),
                      if (_order.ventaNumero != null)
                        _detailRow('Pedido', _order.ventaNumero!),
                      if (_order.cliente != null)
                        _detailRow('Cliente', _order.cliente!),
                      if (_order.observacion != null)
                        _detailRow('Observación', _order.observacion!),
                      if (_order.descripcionPreparacion != null)
                        _detailRow(
                          'Descripción de preparación',
                          _order.descripcionPreparacion!,
                        ),
                      const SizedBox(height: 18),
                      _OrderActions(
                        order: _order,
                        busy: _busy,
                        onStart: () => _act(widget.onStart),
                        onComplete: () => _act(widget.onComplete),
                        onDarBaja: () => _act(widget.onDarBaja),
                        onEdit: () => _act(widget.onEdit),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Líneas',
                        style: GoogleFonts.montserrat(
                          color: context.pal.texto(PurchasesScreen.ink),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      for (final line in _order.lineas) _lineCard(line),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String message, VoidCallback retry) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: context.pal.rojo(PurchasesScreen.red),
            ),
          ),
          TextButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.pal.borde(Color(0xFFE1D8D6))),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: context.pal.texto(PurchasesScreen.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineCard(OrdenProduccionLinea line) {
    return Card(
      color: context.pal.tarjeta(PurchasesScreen.page),
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.nombre,
              style: GoogleFonts.poppins(
                color: context.pal.texto(PurchasesScreen.ink),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (line.tamano != null) Text('Tamaño: ${line.tamano}'),
            Text('Cantidad estimada: ${line.cantidadEstimada} ${line.unidad}'),
            if (line.cantidadDebida != null)
              Text('Cantidad debida: ${line.cantidadDebida} ${line.unidad}'),
            if (line.cantidadReal != null)
              Text('Cantidad real: ${line.cantidadReal} ${line.unidad}'),
            if (line.merma != null) Text('Merma: ${line.merma} ${line.unidad}'),
          ],
        ),
      ),
    );
  }

  String _formatDate(String value) {
    final date = value.substring(0, value.length < 10 ? value.length : 10);
    final parts = date.split('-');
    return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : value;
  }

  String _formatDateTime(String value) {
    final date = value.replaceFirst('T', ' ');
    return date.length > 16 ? date.substring(0, 16) : date;
  }
}

/// El rol de la sesión es Administrador (sin distinguir mayúsculas).
bool _isAdminRole() =>
    (AuthService.instance.usuario?.rol ?? '').trim().toLowerCase() ==
    'administrador';

/// Botones de una orden según su estado y los permisos del usuario.
///
/// Pendiente -> Iniciar / Dar de baja / Editar; En proceso -> Completar /
/// Dar de baja (y Editar el tiempo de un Pedido, solo Administrador);
/// Completada y Cancelada no tienen acciones. Todo requiere
/// Producción > Orden de Producción > Editar.
class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.order,
    required this.busy,
    required this.onStart,
    required this.onComplete,
    required this.onDarBaja,
    required this.onEdit,
    this.onDetail,
    this.soloIconos = false,
  });

  final OrdenProduccion order;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onDarBaja;
  final VoidCallback onEdit;
  final VoidCallback? onDetail;

  /// En las tarjetas de la lista las acciones se muestran solo con su ícono,
  /// juntas en una fila.
  final bool soloIconos;

  /// Botón de acción: con texto, o solo el ícono con su nombre en el tooltip
  /// y en la etiqueta de accesibilidad.
  Widget _accion(IconData icono, String nombre, VoidCallback? alTocar) {
    if (!soloIconos) {
      return OutlinedButton.icon(
        onPressed: busy ? null : alTocar,
        icon: Icon(icono),
        label: Text(nombre),
      );
    }
    return Tooltip(
      message: nombre,
      child: OutlinedButton(
        onPressed: busy ? null : alTocar,
        style: OutlinedButton.styleFrom(
          fixedSize: const Size.square(48),
          minimumSize: const Size.square(48),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Icon(icono, size: 22, semanticLabel: nombre),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = Permisos.puede(
      'Producción',
      'Orden de Producción',
      'Editar',
    );
    final pendiente = order.estado == 'Pendiente';
    final enProceso = order.estado == 'En proceso';
    final puedeEditar =
        canEdit &&
        (pendiente || (order.tipo == 'Pedido' && enProceso && _isAdminRole()));

    final acciones = [
      if (canEdit && pendiente) _accion(Icons.play_arrow, 'Iniciar', onStart),
      if (canEdit && enProceso) _accion(Icons.check, 'Completar', onComplete),
      if (canEdit && (pendiente || enProceso))
        _accion(Icons.block, 'Dar de baja', onDarBaja),
      if (puedeEditar) _accion(Icons.edit_outlined, 'Editar', onEdit),
      if (onDetail != null)
        _accion(Icons.visibility_outlined, 'Detalle', onDetail),
    ];

    return Wrap(
      spacing: soloIconos ? 12 : 8,
      runSpacing: 8,
      children: [
        // Los íconos son un solo bloque: nunca se parten en dos filas.
        if (soloIconos)
          Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: acciones)
        else
          ...acciones,
        if (busy)
          const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

/// Formulario de edición de una orden con solo los campos permitidos:
/// - Pedido: observación y, solo el Administrador, el tiempo de preparación
///   (un Pedido En proceso solo admite el tiempo).
/// - Preparación Pendiente: observación, fecha y hora solicitadas.
/// No edita líneas. Solo se envían los campos que cambian; los errores del
/// backend se muestran dentro del formulario.
class _OrderEditDialog extends StatefulWidget {
  const _OrderEditDialog({required this.order, required this.isAdmin});

  final OrdenProduccion order;
  final bool isAdmin;

  @override
  State<_OrderEditDialog> createState() => _OrderEditDialogState();
}

class _OrderEditDialogState extends State<_OrderEditDialog> {
  late final bool _editObservacion;
  late final bool _editFechaHora;
  late final bool _editTiempo;

  late final TextEditingController _observacion;
  late final TextEditingController _tiempo;
  late DateTime? _fecha;
  late TimeOfDay? _hora;
  late final bool _horaConSegundos;

  bool _saving = false;
  String? _error;

  OrdenProduccion get _order => widget.order;

  @override
  void initState() {
    super.initState();
    final pendiente = _order.estado == 'Pendiente';
    final esPedido = _order.tipo == 'Pedido';
    _editObservacion = pendiente;
    _editFechaHora = pendiente && !esPedido;
    _editTiempo = esPedido && widget.isAdmin;

    _observacion = TextEditingController(text: _order.observacion ?? '');
    _tiempo = TextEditingController(
      text: _order.tiempoPreparacionMin?.toString() ?? '',
    );
    _fecha = DateTime.tryParse(
      _order.fechaSolicitada.substring(
        0,
        _order.fechaSolicitada.length < 10 ? _order.fechaSolicitada.length : 10,
      ),
    );
    final hora = _order.horaSolicitada;
    final partes = hora?.split(':');
    _hora = partes != null && partes.length >= 2
        ? TimeOfDay(
            hour: int.tryParse(partes[0]) ?? 0,
            minute: int.tryParse(partes[1]) ?? 0,
          )
        : null;
    // Se conserva el formato en que llega la hora (HH:MM o HH:MM:SS).
    _horaConSegundos = hora == null || hora.split(':').length >= 3;
  }

  @override
  void dispose() {
    _observacion.dispose();
    _tiempo.dispose();
    super.dispose();
  }

  String _fechaTexto(DateTime f) =>
      '${f.year.toString().padLeft(4, '0')}-'
      '${f.month.toString().padLeft(2, '0')}-'
      '${f.day.toString().padLeft(2, '0')}';

  String _horaTexto(TimeOfDay h) {
    final base =
        '${h.hour.toString().padLeft(2, '0')}:'
        '${h.minute.toString().padLeft(2, '0')}';
    return _horaConSegundos ? '$base:00' : base;
  }

  String _horaVisible(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _submit() async {
    if (_saving) return;
    final cambios = <String, Object?>{};

    if (_editObservacion) {
      final texto = _observacion.text.trim();
      if (texto.length > 255) {
        setState(() => _error = 'La observación admite máximo 255 caracteres.');
        return;
      }
      if (texto != (_order.observacion ?? '').trim()) {
        cambios['observacion'] = texto;
      }
    }

    if (_editFechaHora) {
      final fecha = _fecha;
      if (fecha != null &&
          _fechaTexto(fecha) !=
              _order.fechaSolicitada.substring(
                0,
                _order.fechaSolicitada.length < 10
                    ? _order.fechaSolicitada.length
                    : 10,
              )) {
        if (_fechaTexto(fecha).compareTo(diaBogotaTexto()) < 0) {
          setState(() => _error = 'La fecha solicitada no puede ser pasada.');
          return;
        }
        cambios['fecha_solicitada'] = _fechaTexto(fecha);
      }
      final hora = _hora;
      final original = _order.horaSolicitada;
      if (hora != null &&
          (original == null ||
              _horaVisible(hora) != original.split(':').take(2).join(':'))) {
        cambios['hora_solicitada'] = _horaTexto(hora);
      }
    }

    if (_editTiempo) {
      final texto = _tiempo.text.trim();
      if (texto.isNotEmpty) {
        final minutos = int.tryParse(texto);
        if (minutos == null || minutos < 5 || minutos > 180) {
          setState(
            () => _error = 'El tiempo debe ser un entero de 5 a 180 minutos.',
          );
          return;
        }
        if (minutos != _order.tiempoPreparacionMin) {
          cambios['tiempo_preparacion_min'] = minutos;
        }
      }
    }

    if (cambios.isEmpty) {
      setState(() => _error = 'No hay cambios que guardar.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ProductionRepository.instance.actualizar(
        _order.id,
        cambios,
        tipo: _order.tipo,
        estado: _order.estado,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo guardar la orden.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar orden ${_order.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_editObservacion)
              TextField(
                controller: _observacion,
                enabled: !_saving,
                maxLength: 255,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observación',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_editFechaHora) ...[
              const SizedBox(height: 12),
              _pickerRow(
                'Fecha solicitada',
                _fecha == null ? 'Elegir fecha' : _fechaTexto(_fecha!),
                _saving ? null : _pickFecha,
              ),
              const SizedBox(height: 10),
              _pickerRow(
                'Hora solicitada',
                _hora == null ? 'Elegir hora' : _horaVisible(_hora!),
                _saving ? null : _pickHora,
              ),
            ],
            if (_editTiempo) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _tiempo,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Tiempo de preparación (min, de 5 a 180)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: context.pal.errorTexto(AppColors.statusRedFg),
                  fontWeight: FontWeight.w600,
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
            backgroundColor: context.pal.rojoBoton(PurchasesScreen.red),
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
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _pickerRow(String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}

/// Diálogo de "Dar de baja": motivo (obligatorio, máx. 100) y descripción
/// (obligatoria, máx. 500), ambos no vacíos tras recortar espacios. El botón
/// queda deshabilitado mientras falte alguno.
class _DarBajaDialog extends StatefulWidget {
  const _DarBajaDialog({required this.orderId});

  final int orderId;

  @override
  State<_DarBajaDialog> createState() => _DarBajaDialogState();
}

class _DarBajaDialogState extends State<_DarBajaDialog> {
  final _motivo = TextEditingController();
  final _descripcion = TextEditingController();

  bool get _valido =>
      _motivo.text.trim().isNotEmpty && _descripcion.text.trim().isNotEmpty;

  @override
  void dispose() {
    _motivo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dar de baja la orden ${widget.orderId}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _motivo,
              maxLength: 100,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Motivo'),
            ),
            TextField(
              controller: _descripcion,
              maxLength: 500,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            if (!_valido)
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'El motivo y la descripción son obligatorios.',
                  style: TextStyle(
                    color: context.pal.errorTexto(AppColors.statusRedFg),
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _valido
              ? () => Navigator.of(context).pop({
                  'motivo': _motivo.text.trim(),
                  'descripcion': _descripcion.text.trim(),
                })
              : null,
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }
}
