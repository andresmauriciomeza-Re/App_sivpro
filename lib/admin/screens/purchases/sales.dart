part of '../purchases_screen.dart';

class SalesScreen extends StatelessWidget {
    const SalesScreen({super.key});

    static const _modules = [
      (
        icon: Icons.groups_outlined,
        title: 'Gestión Clientes',
        description: 'Administrar base de clientes',
        highlighted: false,
      ),
      (
        icon: Icons.receipt_long_outlined,
        title: 'Gestión Ventas',
        description: 'Registro y control de pedidos',
        highlighted: false,
      ),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: PurchasesScreen.page,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Inicio',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.muted,
                              fontSize: 16,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 9),
                            child: Icon(
                              Icons.chevron_right,
                              color: PurchasesScreen.muted,
                              size: 22,
                            ),
                          ),
                          Text(
                            'Ventas',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Gestión de Ventas',
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Seleccione el módulo que desea gestionar.',
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.muted,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 34),
                      for (var i = 0; i < _modules.length; i++) ...[
                        _salesModuleCard(
                          context,
                          icon: _modules[i].icon,
                          title: _modules[i].title,
                          description: _modules[i].description,
                          highlighted: _modules[i].highlighted,
                        ),
                        if (i != _modules.length - 1)
                          const SizedBox(height: 24),
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
      return Container(
        height: 72,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 29),
            ),
            Expanded(
              child: Text(
                'La Sirena Pizza',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  color: AppColors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 14, right: 14),
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                getInitials('Gloria Inés Vargas'),
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _salesModuleCard(
      BuildContext context, {
      required IconData icon,
      required String title,
      required String description,
      required bool highlighted,
    }) {
      return GestureDetector(
        onTap: title == 'Gestión Clientes'
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _ClientManagementScreen(),
                  ),
                )
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _SalesManagementScreen(),
                  ),
                ),
        child: Container(
          height: 270,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: PurchasesScreen.page,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE5BDB9),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -74,
                right: -46,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECEB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (title == 'Gestión Ventas')
                Positioned(
                  top: 14,
                  right: 14,
                  child: ValueListenableBuilder<int>(
                    valueListenable: PendingSalesService.instance.count,
                    builder: (_, count, _) => PendingSalesBadge(count: count),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 76, 28, 28),
                child: Row(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE8E8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: PurchasesScreen.red,
                        size: 50,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.muted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      return ValueListenableBuilder<int>(
        valueListenable: PendingSalesService.instance.count,
        builder: (_, count, _) => Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEBCBC8)),
            ),
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
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            items[i].$1,
                            color:
                                i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,
                          ),
                          if (i == 3)
                            Positioned(
                              right: -14,
                              top: -7,
                              child: PendingSalesBadge(count: count),
                            ),
                        ],
                      ),
                      Text(
                        items[i].$2,
                        style: GoogleFonts.dmSerifDisplay(
                          color: i == 3
                              ? PurchasesScreen.red
                              : PurchasesScreen.muted,
                          fontSize: 12,
                          fontWeight:
                              i == 3 ? FontWeight.w700 : FontWeight.w400,
                        ),
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

typedef _SaleStatusStyle = ({
  Color foreground,
  Color background,
  Color border,
});

_SaleStatusStyle _saleStatusStyle(String status) {
  return switch (status) {
    'Por verificar' => (
        foreground: const Color(0xFFB07C0E),
        background: const Color(0xFFFFF3D6),
        border: const Color(0xFFE8C87A),
      ),
    'Por entregar' => (
        foreground: const Color(0xFF2F55B0),
        background: const Color(0xFFE4EDFB),
        border: const Color(0xFFB5C8EC),
      ),
    'Listo para recoger' => (
        foreground: const Color(0xFFB5650A),
        background: const Color(0xFFFDEBD6),
        border: const Color(0xFFEFC494),
      ),
    'Completado' => (
        foreground: const Color(0xFF398047),
        background: const Color(0xFFE6F5E8),
        border: const Color(0xFFB8D9BD),
      ),
    'Devolución' => (
        foreground: PurchasesScreen.red,
        background: const Color(0xFFFFE9EC),
        border: const Color(0xFFE9B8C0),
      ),
    _ => (
        foreground: PurchasesScreen.red,
        background: const Color(0xFFFFE9EC),
        border: const Color(0xFFE9B8C0),
      ),
  };
}

Widget _itemCountBadge(int count) {
  return Container(
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Color(0xFFF0EDED),
      shape: BoxShape.circle,
    ),
    child: Text(
      '$count',
      style: GoogleFonts.dmSerifDisplay(
        color: PurchasesScreen.ink,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Sale {
  const _Sale({
    required this.id,
    required this.user,
    required this.date,
    required this.payment,
    required this.paymentColor,
    required this.status,
    required this.total,
    this.receiptImage,
    this.itemCount = 1,
    this.sourceOrderNumero,
  });

  final String id;
  final String user;
  final String date;
  final String payment;
  final Color paymentColor;
  final String status;
  final String total;
  final String? receiptImage;
  final int itemCount;
  final String? sourceOrderNumero;
}

class _SalesManagementScreen extends StatefulWidget {
  const _SalesManagementScreen();

  @override
  State<_SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<_SalesManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  // TODO: reemplazar por ventas reales desde backend/registro de pedidos.
  final List<_Sale> _sales = [
    const _Sale(
      id: 'VEN-001',
      user: 'Cliente de prueba 1',
      date: '2026-09-24',
      payment: 'Nequi',
      paymentColor: Color(0xFFEDE2FF),
      status: 'Por verificar',
      total: '56.000',
      itemCount: 2,
      receiptImage: 'assets/img/Nequi.png',
    ),
    const _Sale(
      id: 'VEN-002',
      user: 'Cliente de prueba 2',
      date: '2026-09-24',
      payment: 'Bancolombia',
      paymentColor: Color(0xFFFFF2B8),
      status: 'Completado',
      total: '56.000',
      itemCount: 1,
      receiptImage: 'assets/img/Bancolombia.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncPendingCount();
    _syncFromClientOrders();
    OrdersRepository.instance.addListener(_onClientOrdersChanged);
  }

  void _syncPendingCount() {
    // TODO: cuando exista backend, reemplazar por la consulta real de pedidos
    // pendientes de verificar (hoy la fuente de verdad es la lista local).
    final pending =
        _sales.where((sale) => sale.status == 'Por verificar').length;
    PendingSalesService.instance.setPendingCount(pending);
  }

  void _onClientOrdersChanged() {
    if (!mounted) return;
    setState(_syncFromClientOrders);
    _syncPendingCount();
  }

  void _syncFromClientOrders() {
    final yaRegistrados =
        _sales.map((s) => s.sourceOrderNumero).whereType<String>().toSet();
    final nuevos = OrdersRepository.instance.orders
        .where((order) => !yaRegistrados.contains(order.numero));
    for (final order in nuevos.toList().reversed) {
      _sales.insert(0, _saleFromClientOrder(order));
    }
  }

  _Sale _saleFromClientOrder(client_order.OrderModel order) {
    final esBancolombia = order.metodoPago.toLowerCase() == 'bancolombia';
    return _Sale(
      id: order.numero,
      user: AuthService.instance.currentName ?? 'Cliente app',
      date: '${order.fecha.year}-${order.fecha.month.toString().padLeft(2, '0')}-${order.fecha.day.toString().padLeft(2, '0')}',
      payment: order.metodoPago,
      paymentColor: esBancolombia ? const Color(0xFFFFF2B8) : const Color(0xFFEDE2FF),
      status: 'Por verificar',
      total: _formatoMiles(order.total),
      itemCount: order.articulos,
      receiptImage: esBancolombia ? 'assets/img/Bancolombia.png' : 'assets/img/Nequi.png',
      sourceOrderNumero: order.numero,
    );
  }

  String _formatoMiles(int valor) {
    final texto = valor.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
      buffer.write(texto[i]);
    }
    return buffer.toString();
  }

  void _syncStatusToClientOrder(_Sale sale, String status) {
    final numero = sale.sourceOrderNumero;
    if (numero == null) return;
    final nuevoEstado = switch (status) {
      'Por verificar' => client_order.OrderStatus.pagoPendiente,
      'Por entregar' => client_order.OrderStatus.enPreparacion,
      'Listo para recoger' => client_order.OrderStatus.listoParaRecoger,
      'Completado' => client_order.OrderStatus.listoParaRecoger,
      'Devolución' => client_order.OrderStatus.cancelada,
      _ => null,
    };
    if (nuevoEstado == null) return;
    OrdersRepository.instance.updateStatus(numero, nuevoEstado);
  }

  @override
  void dispose() {
    OrdersRepository.instance.removeListener(_onClientOrdersChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _sales.where((sale) => sale.status == 'Por verificar').length;
    final filtered = _sales.where((sale) {
      final query = _query.toLowerCase();
      return sale.id.toLowerCase().contains(query) ||
          sale.user.toLowerCase().contains(query) ||
          sale.payment.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBreadcrumb(),
                    const SizedBox(height: 20),
                    Text(
                      'Gestión Ventas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_sales.length} ventas registradas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 16,
                      ),
                    ),
                    if (pendingCount > 0) ...[
                      const SizedBox(height: 14),
                      _pendingBanner(pendingCount),
                    ],
                    const SizedBox(height: 26),
                    _buildSearchField(),
                    const SizedBox(height: 18),
                    for (final sale in filtered) ...[
                      _saleCard(sale),
                      const SizedBox(height: 18),
                    ],
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'No se encontraron ventas.',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.muted,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 27),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        Text('Inicio', style: _breadcrumbStyle(PurchasesScreen.muted)),
        const Icon(Icons.chevron_right, color: PurchasesScreen.muted, size: 20),
        Text('Ventas', style: _breadcrumbStyle(PurchasesScreen.muted)),
        const Icon(Icons.chevron_right, color: PurchasesScreen.muted, size: 20),
        Text('Gestión Ventas', style: _breadcrumbStyle(PurchasesScreen.ink)),
      ],
    );
  }

  TextStyle _breadcrumbStyle(Color color) => GoogleFonts.dmSerifDisplay(
        color: color,
        fontSize: 15,
        fontWeight: color == PurchasesScreen.ink
            ? FontWeight.w500
            : FontWeight.w400,
      );

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: GoogleFonts.dmSerifDisplay(color: PurchasesScreen.ink, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: PurchasesScreen.ink,
          size: 28,
        ),
        hintText: 'Buscar por ID, usuario o producto...',
        hintStyle: GoogleFonts.dmSerifDisplay(
          color: PurchasesScreen.ink,
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFDFD),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5BDB9)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red),
        ),
      ),
    );
  }

  Widget _saleCard(_Sale sale) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 16, 14, 13),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        border: Border.all(color: const Color(0xFFE5BDB9)),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            sale.id,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (sale.itemCount > 1) ...[
                          const SizedBox(width: 8),
                          _itemCountBadge(sale.itemCount),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              _saleAction(
                Icons.visibility_outlined,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SaleDetailScreen(sale: sale),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _saleInfo('USUARIO', sale.user)),
              Expanded(child: _saleInfo('FECHA', sale.date)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 11),
            child: Divider(height: 1, color: Color(0xFFE5D9D7)),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              _paymentBadge(sale),
              if (sale.status == 'Por verificar') _verifyButton(sale),
              _statusButton(sale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pendingBanner(int count) {
    final plural = count != 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        border: Border.all(color: const Color(0xFFE8C87A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: Color(0xFFB07C0E),
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            '$count pedido${plural ? 's' : ''} '
            'pendiente${plural ? 's' : ''} por verificar',
            style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFFB07C0E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.dmSerifDisplay(
        color: PurchasesScreen.muted,
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
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSerifDisplay(
            color: PurchasesScreen.ink,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _saleAction(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF5B4643), size: 25),
      ),
    );
  }

  Widget _paymentBadge(_Sale sale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: sale.paymentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sale.payment == 'Nequi'
                ? Icons.favorite_border
                : Icons.account_balance_outlined,
            color: sale.payment == 'Nequi'
                ? const Color(0xFF7B32D5)
                : const Color(0xFFE08A00),
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            sale.payment,
            style: GoogleFonts.dmSerifDisplay(
              color: sale.payment == 'Nequi'
                  ? const Color(0xFF7023C7)
                  : const Color(0xFFE08A00),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyButton(_Sale sale) {
    return GestureDetector(
      onTap: () => _openVerification(sale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: PurchasesScreen.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, color: Colors.white, size: 15),
            const SizedBox(width: 5),
            Text(
              'Por verificar',
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVerification(_Sale sale) async {
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _SaleVerificationScreen(
          sale: sale,
          onResolve: (newStatus) {
            final index = _sales.indexOf(sale);
            if (index < 0) return;
            setState(() {
              _sales[index] = _copyWithStatus(sale, newStatus);
            });
            _syncStatusToClientOrder(sale, newStatus);
            _syncPendingCount();
          },
        ),
      ),
    );
  }

  _Sale _copyWithStatus(_Sale sale, String status) {
    return _Sale(
      id: sale.id,
      user: sale.user,
      date: sale.date,
      payment: sale.payment,
      paymentColor: sale.paymentColor,
      status: status,
      total: sale.total,
      receiptImage: sale.receiptImage,
      itemCount: sale.itemCount,
      sourceOrderNumero: sale.sourceOrderNumero,
    );
  }

  Widget _statusButton(_Sale sale) {
    final style = _saleStatusStyle(sale.status);
    return PopupMenuButton<String>(
      onSelected: (status) => _requestStatusChange(sale, status),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'Por verificar', child: Text('Por verificar')),
        PopupMenuItem(value: 'Por entregar', child: Text('Por entregar')),
        PopupMenuItem(
          value: 'Listo para recoger',
          child: Text('Listo para recoger'),
        ),
        PopupMenuItem(value: 'Completado', child: Text('Completado')),
        PopupMenuItem(value: 'Devolución', child: Text('Devolución')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: style.background,
          border: Border.all(color: style.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sale.status,
              style: GoogleFonts.dmSerifDisplay(
                color: style.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.keyboard_arrow_down,
              size: 15,
              color: style.foreground,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestStatusChange(_Sale sale, String status) async {
    if (status == sale.status) return;

    if (status == 'Devolución') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: PurchasesScreen.page,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD9D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: PurchasesScreen.red,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cambiar estado',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de cambiar el estado\nde "${sale.status}" a "Devolución"?',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFF5B4643),
              fontSize: 17,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: PurchasesScreen.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Sí, confirmar',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFF8B706C)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final index = _sales.indexOf(sale);
    if (!mounted || index < 0) return;
    setState(() {
      _sales[index] = _copyWithStatus(sale, status);
    });
    _syncStatusToClientOrder(sale, status);
    _syncPendingCount();
  }

  Widget _buildBottomNavigation() {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.person_outline, 'Mi Perfil'),
    ];
    return ValueListenableBuilder<int>(
      valueListenable: PendingSalesService.instance.count,
      builder: (_, count, _) => Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: const BoxDecoration(
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
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          items[i].$1,
                          size: 26,
                          color: i == 3
                              ? PurchasesScreen.red
                              : PurchasesScreen.muted,
                        ),
                        if (i == 3)
                          Positioned(
                            right: -14,
                            top: -7,
                            child: PendingSalesBadge(count: count),
                          ),
                      ],
                    ),
                    Text(
                      items[i].$2,
                      style: GoogleFonts.dmSerifDisplay(
                        color: i == 3
                            ? PurchasesScreen.red
                            : PurchasesScreen.muted,
                        fontSize: 11,
                        fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w400,
                      ),
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

class _SaleDetailScreen extends StatelessWidget {
  const _SaleDetailScreen({required this.sale});

  final _Sale sale;

  @override
  Widget build(BuildContext context) {
    final style = _saleStatusStyle(sale.status);
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 74,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.headerDivider),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.red,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Detalle de Venta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        color: AppColors.red,
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
                child: Column(
                  children: [
                    _informationCard(style),
                    const SizedBox(height: 28),
                    _productsCard(),
                    const SizedBox(height: 28),
                    _receiptCard(),
                    const SizedBox(height: 54),
                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PurchasesScreen.red,
                          side: const BorderSide(
                            color: PurchasesScreen.red,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cerrar Detalle',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 23,
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

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(27, 28, 27, 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDDB)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSerifDisplay(
        color: const Color(0xFF5B4643),
        fontSize: 17,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _informationCard(_SaleStatusStyle style) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('INFORMACIÓN DE LA VENTA'),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _detailValue('ID Venta', sale.id, 25)),
              _detailValue(
                'Estado',
                sale.status,
                16,
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    border: Border.all(color: style.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.status,
                    style: GoogleFonts.dmSerifDisplay(
                      color: style.foreground,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _detailValue('Usuario', sale.user, 24)),
              Expanded(child: _detailValue('Fecha', sale.date, 24)),
            ],
          ),
          const SizedBox(height: 30),
          Text('Método de pago', style: _detailLabelStyle()),
          const SizedBox(height: 10),
          _paymentBadge(),
        ],
      ),
    );
  }

  Widget _detailValue(
    String label,
    String value,
    double size, {
    Widget? valueWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _detailLabelStyle()),
        const SizedBox(height: 5),
        valueWidget ??
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.ink,
                fontSize: size,
              ),
            ),
      ],
    );
  }

  TextStyle _detailLabelStyle() => GoogleFonts.dmSerifDisplay(
        color: const Color(0xFF5B4643),
        fontSize: 16,
      );

  Widget _paymentBadge() {
    final isNequi = sale.payment == 'Nequi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: sale.paymentColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNequi
                ? Icons.account_balance_wallet_outlined
                : Icons.account_balance_outlined,
            color: isNequi
                ? const Color(0xFF7023C7)
                : const Color(0xFFE08A00),
            size: 23,
          ),
          const SizedBox(width: 10),
          Text(
            sale.payment,
            style: GoogleFonts.dmSerifDisplay(
              color: isNequi
                  ? const Color(0xFF7023C7)
                  : const Color(0xFFE08A00),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DETALLE DE LOS PRODUCTOS'),
          const SizedBox(height: 34),
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_pizza_outlined,
                  color: Color(0xFF705A56),
                  size: 39,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Margarita Clásica',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 23,
                      ),
                    ),
                    Text(
                      'Cantidad: 2',
                      style: GoogleFonts.dmSerifDisplay(
                        color: const Color(0xFF5B4643),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${sale.total}',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.red,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Color(0xFFE0D9D7), height: 1),
          ),
          Row(
            children: [
              Text(
                'Total a pagar',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${sale.total}',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.red,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptCard() {
    final image = sale.receiptImage;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('COMPROBANTE DE TRANSFERENCIA'),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE6B8B2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: image != null
                ? Image.asset(
                    image,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _NoReceiptPlaceholder(),
                  )
                : const _NoReceiptPlaceholder(),
          ),
        ],
      ),
    );
  }
}

class _NoReceiptPlaceholder extends StatelessWidget {
  const _NoReceiptPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFC8B9B7),
            size: 54,
          ),
          const SizedBox(height: 20),
          Text(
            'Sin comprobante adjunto',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El cliente no subió imagen de transferencia',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFF5B4643),
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleVerificationScreen extends StatefulWidget {
  const _SaleVerificationScreen({
    required this.sale,
    required this.onResolve,
  });

  final _Sale sale;
  final ValueChanged<String> onResolve;

  @override
  State<_SaleVerificationScreen> createState() =>
      _SaleVerificationScreenState();
}

class _SaleVerificationScreenState extends State<_SaleVerificationScreen> {
  final _receivedController = TextEditingController();

  _Sale get sale => widget.sale;

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: Column(
                  children: [
                    _informationCard(),
                    const SizedBox(height: 28),
                    _productsCard(),
                    const SizedBox(height: 28),
                    _receiptCard(),
                    const SizedBox(height: 28),
                    _verificationCard(),
                    const SizedBox(height: 36),
                    _rejectButton(),
                    const SizedBox(height: 14),
                    _confirmButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 27),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(27, 28, 27, 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DDDB)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSerifDisplay(
        color: const Color(0xFF5B4643),
        fontSize: 17,
        letterSpacing: 1.2,
      ),
    );
  }

  TextStyle _detailLabelStyle() {
    return GoogleFonts.dmSerifDisplay(
      color: const Color(0xFF5B4643),
      fontSize: 16,
    );
  }

  Widget _informationCard() {
    final style = _saleStatusStyle(sale.status);
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('INFORMACIÓN DE LA VENTA'),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _detailValue('ID Venta', sale.id, 25)),
              _detailValue(
                'Estado',
                sale.status,
                16,
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: style.background,
                    border: Border.all(color: style.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.status,
                    style: GoogleFonts.dmSerifDisplay(
                      color: style.foreground,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _detailValue('Usuario', sale.user, 24)),
              Expanded(child: _detailValue('Fecha', sale.date, 24)),
            ],
          ),
          const SizedBox(height: 30),
          Text('Método de pago', style: _detailLabelStyle()),
          const SizedBox(height: 10),
          _paymentBadge(),
        ],
      ),
    );
  }

  Widget _detailValue(
    String label,
    String value,
    double size, {
    Widget? valueWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _detailLabelStyle()),
        const SizedBox(height: 5),
        valueWidget ??
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.ink,
                fontSize: size,
              ),
            ),
      ],
    );
  }

  Widget _paymentBadge() {
    final isNequi = sale.payment == 'Nequi';
    final color =
        isNequi ? const Color(0xFF7023C7) : const Color(0xFFE08A00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: sale.paymentColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNequi
                ? Icons.account_balance_wallet_outlined
                : Icons.account_balance_outlined,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 10),
          Text(
            sale.payment,
            style: GoogleFonts.dmSerifDisplay(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DETALLE DE LOS PRODUCTOS'),
          const SizedBox(height: 34),
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.local_pizza_outlined,
                  color: Color(0xFF705A56),
                  size: 39,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Margarita Clásica',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 23,
                      ),
                    ),
                    Text(
                      'Cantidad: 2',
                      style: GoogleFonts.dmSerifDisplay(
                        color: const Color(0xFF5B4643),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${sale.total}',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.red,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Color(0xFFE0D9D7), height: 1),
          ),
          Row(
            children: [
              Text(
                'Total a pagar',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${sale.total}',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.red,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptCard() {
    final image = sale.receiptImage;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('COMPROBANTE DE TRANSFERENCIA'),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE6B8B2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: image != null
                ? Image.asset(
                    image,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _NoReceiptPlaceholder(),
                  )
                : const _NoReceiptPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _verificationCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('VERIFICACIÓN DEL PAGO'),
          const SizedBox(height: 22),
          Text('Total a recibir', style: _detailLabelStyle()),
          const SizedBox(height: 6),
          Text(
            '\$${sale.total}',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.red,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          Text('Monto recibido', style: _detailLabelStyle()),
          const SizedBox(height: 8),
          TextField(
            controller: _receivedController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 20,
              ),
              hintText: '0',
              hintStyle: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFDFD),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5BDB9)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: PurchasesScreen.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rejectButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: () => _resolve('Devolución'),
        style: OutlinedButton.styleFrom(
          foregroundColor: PurchasesScreen.red,
          side: const BorderSide(color: PurchasesScreen.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'Rechazar pago',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton(
        onPressed: () => _resolve('Por entregar'),
        style: FilledButton.styleFrom(
          backgroundColor: PurchasesScreen.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'Confirmar pago',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _resolve(String newStatus) {
    widget.onResolve(newStatus);
    Navigator.of(context).pop(true);
  }
}

