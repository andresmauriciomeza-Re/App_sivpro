part of '../purchases_screen.dart';

class ProductionModulesScreen extends StatelessWidget {
  const ProductionModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
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
                      color: PurchasesScreen.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccione el módulo que desea gestionar.',
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _moduleCard(
                    context,
                    Icons.assignment_outlined,
                    'Órdenes de producción',
                    const _ProductionOrdersScreen(),
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    Icons.inventory_2_outlined,
                    'Productos',
                    const _ProductManagementScreen(),
                  ),
                ],
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget destination,
  ) {
    return Card(
      color: PurchasesScreen.page,
      child: ListTile(
        leading: Icon(icon, color: PurchasesScreen.red),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => destination)),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.person_outline, 'Mi Perfil'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
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

class _ProductionStatusStyle {
  const _ProductionStatusStyle._();

  static Color color(String status) => switch (status) {
    'Completada' => const Color(0xFF1E7B34),
    'En proceso' => const Color(0xFF1E40AF),
    'Pendiente' => const Color(0xFF8A6D00),
    _ => const Color(0xFFD32F2F),
  };

  static Color background(String status) => switch (status) {
    'Completada' => const Color(0xFFD4F7E9),
    'En proceso' => const Color(0xFFDCE8FF),
    'Pendiente' => const Color(0xFFFFF4C7),
    _ => const Color(0xFFFFE0E3),
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
      backgroundColor: PurchasesScreen.page,
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
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_orders.length} órdenes',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
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
                              color: PurchasesScreen.muted,
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
              style: GoogleFonts.poppins(color: PurchasesScreen.red),
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
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1D8D6)),
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
                    color: PurchasesScreen.ink,
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
              color: PurchasesScreen.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solicitada: ${_formatDate(order.fechaSolicitada)}'
            '${order.horaSolicitada == null ? '' : ' · ${order.horaSolicitada}'}',
            style: GoogleFonts.poppins(color: PurchasesScreen.muted),
          ),
          if (order.fechaEntregaEstimada != null)
            Text(
              'Entrega estimada: ${_formatDateTime(order.fechaEntregaEstimada!)}',
              style: GoogleFonts.poppins(color: PurchasesScreen.muted),
            ),
          if (order.ventaNumero != null)
            Text(
              'Pedido: ${order.ventaNumero}',
              style: GoogleFonts.poppins(color: PurchasesScreen.muted),
            ),
          if (order.cliente != null)
            Text(
              'Cliente: ${order.cliente}',
              style: GoogleFonts.poppins(color: PurchasesScreen.muted),
            ),
          if (linesSummary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              linesSummary,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.ink,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : () => _startOrder(order),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _completeOrder(order),
                icon: const Icon(Icons.check),
                label: const Text('Completar'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _askDarBaja(order),
                icon: const Icon(Icons.block),
                label: const Text('Dar de baja'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _openDetail(order),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Detalle'),
              ),
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
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _ProductionStatusStyle.background(status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ProductionStatusStyle.color(status)),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: _ProductionStatusStyle.color(status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _startOrder(OrdenProduccion order) async {
    await _runOrderAction(
      order.id,
      () => ProductionRepository.instance.iniciar(order.id),
      'Orden iniciada.',
    );
  }

  Future<void> _completeOrder(OrdenProduccion order) async {
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
        _showMessage('Orden completada.');
      }
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
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
                        style: const TextStyle(color: PurchasesScreen.red),
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
    final motivoController = TextEditingController();
    final descripcionController = TextEditingController();
    try {
      final data = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Dar de baja la orden ${order.id}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: motivoController,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Motivo'),
                ),
                TextField(
                  controller: descripcionController,
                  maxLength: 500,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop({
                'motivo': motivoController.text,
                'descripcion': descripcionController.text,
              }),
              child: const Text('Dar de baja'),
            ),
          ],
        ),
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
    } finally {
      motivoController.dispose();
      descripcionController.dispose();
    }
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
        _showMessage(successMessage);
      }
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
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
          builder: (_) => _ProductionOrderDetailScreen(order: detail),
        ),
      );
      if (mounted) await _loadOrders(showLoading: false);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
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

class _ProductionOrderDetailScreen extends StatefulWidget {
  const _ProductionOrderDetailScreen({required this.order});

  final OrdenProduccion order;

  @override
  State<_ProductionOrderDetailScreen> createState() =>
      _ProductionOrderDetailScreenState();
}

class _ProductionOrderDetailScreenState
    extends State<_ProductionOrderDetailScreen> {
  late OrdenProduccion _order;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadDetail();
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
    }
  }

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
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tipo: ${_order.tipoLabel}',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.ink,
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
                      Text(
                        'Líneas',
                        style: GoogleFonts.montserrat(
                          color: PurchasesScreen.ink,
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
            style: GoogleFonts.poppins(color: PurchasesScreen.red),
          ),
          TextButton(onPressed: retry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE1D8D6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: PurchasesScreen.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineCard(OrdenProduccionLinea line) {
    return Card(
      color: PurchasesScreen.page,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              line.nombre,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.ink,
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
