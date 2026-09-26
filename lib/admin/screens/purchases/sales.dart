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
    return ListenableBuilder(
      listenable: SalesRepository.instance,

      builder: (context, _) {
        final pendingCount = SalesRepository.instance.pendingVerificationCount;

        return Scaffold(
          backgroundColor: PurchasesScreen.page,

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
                            color: PurchasesScreen.ink,

                            fontSize: 26,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Seleccione el módulo que desea gestionar.',

                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.muted,

                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 24),

                        for (var i = 0; i < _modules.length; i++) ...[
                          _salesModuleCard(
                            context,

                            icon: _modules[i].icon,

                            title: _modules[i].title,

                            description: _modules[i].description,

                            highlighted: _modules[i].highlighted,

                            pendingCount:
                                _modules[i].title == 'Gestión Clientes'
                                ? 0
                                : pendingCount,
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',

      onBack: () => Navigator.of(context).pop(),

      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _salesModuleCard(
    BuildContext context, {

    required IconData icon,

    required String title,

    required String description,

    required bool highlighted,

    required int pendingCount,
  }) {
    final hasPending = pendingCount > 0;

    return GestureDetector(
      onTap: title == 'Gestión Clientes'
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const _ClientManagementScreen(),
              ),
            )
          : () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _SalesManagementScreen()),
            ),

      child: Container(
        height: 270,

        width: double.infinity,

        clipBehavior: Clip.antiAlias,

        decoration: BoxDecoration(
          color: PurchasesScreen.page,

          borderRadius: BorderRadius.circular(17),

          border: Border.all(
            color: hasPending
                ? const Color(0xFFE39A94)
                : const Color(0xFFE5BDB9),

            width: hasPending ? 2.5 : 1.5,
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

            if (hasPending)
              Positioned(
                top: 14,

                right: 14,

                child: SalesPendingBadge(
                  count: pendingCount,

                  fontSize: 13,

                  borderColor: PurchasesScreen.page,
                ),
              ),

            if (hasPending)
              Positioned(
                top: 22,

                right: 62,

                child: Icon(
                  Icons.notifications_active_outlined,

                  color: const Color(0xFFB85A52),

                  size: 20,
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(34, 53, 20, 20),

              child: Row(
                children: [
                  Container(
                    width: 96,

                    height: 96,

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE8E8),

                      shape: BoxShape.circle,
                    ),

                    child: Icon(icon, color: PurchasesScreen.red, size: 50),
                  ),

                  const SizedBox(width: 25),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          title,

                          style: GoogleFonts.montserrat(
                            color: PurchasesScreen.ink,

                            fontSize: 25,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          description,

                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.muted,

                            fontSize: 16,
                          ),
                        ),

                        if (hasPending) ...[
                          const SizedBox(height: 12),

                          Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.schedule_outlined,

                                color: Color(0xFFB85A52),

                                size: 18,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                '$pendingCount por verificar',

                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFB85A52),

                                  fontSize: 14,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
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

    return Container(
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
                  AdminBottomNavIcon(
                    icon: items[i].$1,

                    color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,

                    showPendingBadge: i == adminSalesNavIndex,
                  ),

                  Text(
                    items[i].$2,

                    style: GoogleFonts.poppins(
                      color: i == 3
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,

                      fontSize: 12,

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
}

class _SalesHeaderBar extends StatelessWidget {
  const _SalesHeaderBar({
    required this.title,
    required this.initials,
    this.onBack,
  });

  final String title;

  final String initials;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,

      padding: const EdgeInsets.symmetric(horizontal: 28),

      decoration: const BoxDecoration(
        color: PurchasesScreen.page,

        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),

      child: Stack(
        children: [
          if (onBack != null)
            Positioned(
              left: 0,

              top: 0,

              bottom: 0,

              child: GestureDetector(
                onTap: onBack,

                behavior: HitTestBehavior.opaque,

                child: const Icon(
                  Icons.arrow_back,

                  color: PurchasesScreen.red,

                  size: 27,
                ),
              ),
            ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),

              child: Text(
                title,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                textAlign: TextAlign.center,

                style: GoogleFonts.montserrat(
                  color: PurchasesScreen.red,

                  fontSize: 24,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Positioned(
            right: 0,

            top: 0,

            bottom: 0,

            child: Center(
              child: Container(
                width: 44,

                height: 44,

                alignment: Alignment.center,

                decoration: const BoxDecoration(
                  color: PurchasesScreen.red,

                  shape: BoxShape.circle,
                ),

                child: Text(
                  initials,

                  style: GoogleFonts.poppins(
                    color: Colors.white,

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
}

class _SalesManagementScreen extends StatefulWidget {
  const _SalesManagementScreen();

  @override
  State<_SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<_SalesManagementScreen> {
  final _searchController = TextEditingController();

  String _query = '';

  SalesRepository get _repository => SalesRepository.instance;

  List<Sale> get _sales => _repository.sales;

  int get _pendingCount => _repository.pendingVerificationCount;

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,

      builder: (context, _) {
        final filtered = _sales.where((sale) {
          final query = _query.toLowerCase();

          return sale.id.toLowerCase().contains(query) ||
              sale.user.toLowerCase().contains(query) ||
              sale.payment.toLowerCase().contains(query) ||
              sale.status.label.toLowerCase().contains(query);
        }).toList();

        return Scaffold(
          backgroundColor: PurchasesScreen.page,

          body: SafeArea(
            bottom: false,

            child: Column(
              children: [
                _buildHeader(context),

                _buildBreadcrumb(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Gestión Ventas',

                          style: GoogleFonts.montserrat(
                            color: PurchasesScreen.ink,

                            fontSize: 30,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          '${_sales.length} ventas registradas',

                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.muted,

                            fontSize: 16,
                          ),
                        ),

                        if (_pendingCount > 0) ...[
                          const SizedBox(height: 20),

                          _buildPendingBanner(_pendingCount),
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

                                style: GoogleFonts.poppins(
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
      },
    );
  }

  Widget _buildPendingBanner(int count) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D6),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFFEFC978)),
      ),

      child: Row(
        children: [
          Container(
            width: 40,

            height: 40,

            decoration: const BoxDecoration(
              color: Color(0xFFFFE1A8),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.schedule_outlined,

              color: Color(0xFFA66500),

              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  '$count pedido${count == 1 ? '' : 's'} pendiente${count == 1 ? '' : 's'} por verificar',

                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8A5600),

                    fontSize: 15,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Revisa el comprobante y confirma el pago recibido.',

                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA66500),

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _SalesHeaderBar(
      title: 'La Sirena Pizza',

      onBack: () => Navigator.of(context).pop(),

      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),

      decoration: const BoxDecoration(
        color: PurchasesScreen.page,

        border: Border(bottom: BorderSide(color: Color(0xFFF0E2E0))),
      ),

      child: Row(
        children: [
          _breadcrumbItem('Inicio', bold: false),

          const Icon(Icons.chevron_right, color: Color(0xFFB7A5A2), size: 20),

          _breadcrumbItem('Ventas', bold: false),

          const Icon(Icons.chevron_right, color: Color(0xFFB7A5A2), size: 20),

          _breadcrumbItem('Gestión Ventas', bold: true),
        ],
      ),
    );
  }

  Widget _breadcrumbItem(String label, {required bool bold}) {
    return Text(
      label,

      style: GoogleFonts.poppins(
        color: bold ? PurchasesScreen.muted : const Color(0xFF9C8986),

        fontSize: 14,

        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildSearchField() {
    return AppSearchField(
      controller: _searchController,
      hint: 'Buscar por ID, usuario o producto...',
      onChanged: (value) => setState(() => _query = value),
    );
  }

  Widget _saleCard(Sale sale) {
    return GestureDetector(
      onTap: () => _openDetail(sale),

      child: Container(
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

                      Text(
                        sale.id,

                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,

                          fontSize: 22,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                _saleAction(Icons.visibility_outlined, () => _openDetail(sale)),
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

            _saleActionsRow(sale),
          ],
        ),
      ),
    );
  }

  void _openDetail(Sale sale) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _SaleDetailScreen(sale: sale)));
  }

  TextStyle _labelStyle() =>
      GoogleFonts.poppins(color: PurchasesScreen.muted, fontSize: 12);

  Widget _saleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(label, style: _labelStyle()),

        const SizedBox(height: 6),

        Text(
          value,

          overflow: TextOverflow.ellipsis,

          style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 16),
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

  /// Separación horizontal entre los 3 pills de la fila "Por verificar".
  static const double _pillsSpacing = 8;

  /// Estilo de texto de los pills compactos. Se comparte entre el dibujado y
  /// la medición para que ambos nunca se desincronicen.
  TextStyle _compactPillStyle(
    Color color, {
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: weight);

  /// Ancho intrínseco de un pill compacto: texto + ícono + separaciones.
  double _compactPillWidth(
    String text,
    TextStyle style, {
    required double iconSize,
    required double padding,
    double gap = 5,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = painter.width + iconSize + gap + padding * 2;

    painter.dispose();

    return width;
  }

  /// Fila inferior de la tarjeta.
  ///
  /// - Estado "Por verificar": badge de pago + botón rojo de verificación + pill
  ///   de estado, en ese orden, con estilo compacto. Si los 3 no caben en una
  ///   sola línea se usa Wrap para que bajen de línea dentro de la tarjeta.
  /// - Cualquier otro estado: badge de pago + pill de estado (sin cambios).
  Widget _saleActionsRow(Sale sale) {
    final isPending = sale.status == SaleStatus.porVerificar;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isPending) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Flexible(child: _paymentBadge(sale)),

              _statusButton(sale),
            ],
          );
        }

        final palette = saleStatusPalette(sale.status);

        final needed =
            _compactPillWidth(
              sale.payment,
              _compactPillStyle(palette.foreground),
              iconSize: 15,
              padding: 9,
            ) +
            _compactPillWidth(
              SaleStatus.porVerificar.label,
              _compactPillStyle(Colors.white, weight: FontWeight.w700),
              iconSize: 14,
              padding: 10,
            ) +
            _compactPillWidth(
              sale.status.label,
              _compactPillStyle(palette.foreground),
              iconSize: 15,
              padding: 10,
              gap: 3,
            ) +
            _pillsSpacing * 2;

        final pills = <Widget>[
          _paymentBadge(sale, compact: true),

          _verifyButton(sale, compact: true),

          _statusButton(sale, compact: true),
        ];

        if (needed > constraints.maxWidth) {
          return Wrap(
            spacing: _pillsSpacing,

            runSpacing: _pillsSpacing,

            children: pills,
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Flexible(child: pills[0]),

            const SizedBox(width: _pillsSpacing),

            Flexible(child: pills[1]),

            const SizedBox(width: _pillsSpacing),

            pills[2],
          ],
        );
      },
    );
  }

  Widget _paymentBadge(Sale sale, {bool compact = false}) {
    final foreground = sale.payment == 'Nequi'
        ? const Color(0xFF7023C7)
        : const Color(0xFFE08A00);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 9, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 13, vertical: 9),

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

            size: compact ? 15 : 18,
          ),

          SizedBox(width: compact ? 5 : 7),

          Flexible(
            child: Text(
              sale.payment,

              overflow: TextOverflow.ellipsis,

              maxLines: 1,

              style: compact
                  ? _compactPillStyle(foreground)
                  : GoogleFonts.poppins(
                      color: foreground,

                      fontSize: 14,

                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón rojo sólido que lleva a la pantalla de verificación de pago.
  Widget _verifyButton(Sale sale, {bool compact = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentVerificationScreen(saleId: sale.id),
        ),
      ),

      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 13, vertical: 9),

        decoration: BoxDecoration(
          color: PurchasesScreen.red,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.receipt_long,

              color: Colors.white,

              size: compact ? 14 : 18,
            ),

            SizedBox(width: compact ? 5 : 7),

            Flexible(
              child: Text(
                SaleStatus.porVerificar.label,

                overflow: TextOverflow.ellipsis,

                maxLines: 1,

                style: compact
                    ? _compactPillStyle(Colors.white, weight: FontWeight.w700)
                    : GoogleFonts.poppins(
                        color: Colors.white,

                        fontSize: 14,

                        fontWeight: FontWeight.w700,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(Sale sale, {bool compact = false}) {
    final palette = saleStatusPalette(sale.status);

    return PopupMenuButton<SaleStatus>(
      onSelected: (status) => _requestStatusChange(sale, status),

      itemBuilder: (_) => [
        for (final status in SaleStatus.values)
          PopupMenuItem<SaleStatus>(value: status, child: Text(status.label)),
      ],

      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

        decoration: BoxDecoration(
          color: palette.background,

          border: Border.all(color: palette.border),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Flexible(
              child: Text(
                sale.status.label,

                overflow: TextOverflow.ellipsis,

                maxLines: 1,

                style: compact
                    ? _compactPillStyle(palette.foreground)
                    : GoogleFonts.poppins(
                        color: palette.foreground,

                        fontSize: 14,

                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),

            SizedBox(width: compact ? 3 : 5),

            Icon(
              Icons.keyboard_arrow_down,

              size: compact ? 15 : 17,

              color: palette.foreground,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestStatusChange(Sale sale, SaleStatus status) async {
    if (status == sale.status) return;

    if (status == SaleStatus.devolucion) {
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

                style: GoogleFonts.montserrat(
                  color: Colors.black,

                  fontSize: 28,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          content: Text(
            '¿Estás seguro de cambiar el estado\nde "${sale.status.label}" a "Devolución"?',

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
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

                  style: GoogleFonts.poppins(
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

                  style: GoogleFonts.poppins(
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

    _repository.updateStatus(sale.id, status);
  }

  Widget _buildBottomNavigation() {
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

                    size: 26,

                    color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,

                    showPendingBadge: i == adminSalesNavIndex,
                  ),

                  Text(
                    items[i].$2,

                    style: GoogleFonts.poppins(
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
    );
  }
}

class _SaleDetailScreen extends StatelessWidget {
  const _SaleDetailScreen({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,

      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Detalle de Venta',

              onBack: () => Navigator.of(context).pop(),

              initials: getInitials('Gloria Inés Vargas'),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),

                child: Column(
                  children: [
                    _informationCard(),

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

                          style: GoogleFonts.poppins(
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

      style: GoogleFonts.montserrat(
        color: const Color(0xFF5B4643),

        fontSize: 17,

        letterSpacing: 1.2,
      ),
    );
  }

  Widget _informationCard() {
    final palette = saleStatusPalette(sale.status);

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

                sale.status.label,

                16,

                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,

                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: palette.background,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    sale.status.label,

                    style: GoogleFonts.poppins(
                      color: palette.foreground,

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

              style: GoogleFonts.poppins(
                color: PurchasesScreen.ink,

                fontSize: size,
              ),
            ),
      ],
    );
  }

  TextStyle _detailLabelStyle() =>
      GoogleFonts.poppins(color: const Color(0xFF5B4643), fontSize: 16);

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

            color: isNequi ? const Color(0xFF7023C7) : const Color(0xFFE08A00),

            size: 23,
          ),

          const SizedBox(width: 10),

          Text(
            sale.payment,

            style: GoogleFonts.poppins(
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

                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.ink,

                        fontSize: 23,
                      ),
                    ),

                    Text(
                      'Cantidad: 2',

                      style: GoogleFonts.poppins(
                        color: const Color(0xFF5B4643),

                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '\$56.000',

                style: GoogleFonts.poppins(
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

                style: GoogleFonts.poppins(
                  color: PurchasesScreen.ink,

                  fontSize: 25,

                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              Text(
                '\$56.000',

                style: GoogleFonts.poppins(
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
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionTitle('COMPROBANTE DE TRANSFERENCIA'),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,

            padding: sale.receiptAsset == null
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 60)
                : const EdgeInsets.all(12),

            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6B8B2), width: 2),

              borderRadius: BorderRadius.circular(16),
            ),

            child: sale.receiptAsset != null
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                        child: Image.asset(
                          sale.receiptAsset!,

                          width: double.infinity,

                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Comprobante ${sale.payment} enviado por ${sale.user}',

                        textAlign: TextAlign.center,

                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5B4643),

                          fontSize: 17,
                        ),
                      ),
                    ],
                  )
                : Column(
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

                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,

                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'El cliente no subió imagen de transferencia',

                        textAlign: TextAlign.center,

                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5B4643),

                          fontSize: 17,
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

class _PaymentVerificationScreen extends StatefulWidget {
  const _PaymentVerificationScreen({required this.saleId});

  final String saleId;

  @override
  State<_PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState
    extends State<_PaymentVerificationScreen> {
  late final TextEditingController _amountController;

  String? _amountError;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();

    super.dispose();
  }

  int? _parseAmount() {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return null;

    return int.tryParse(digits);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SalesRepository.instance,

      builder: (context, _) {
        final sale = SalesRepository.instance.saleById(widget.saleId);

        if (sale == null) {
          return Scaffold(
            backgroundColor: PurchasesScreen.page,

            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),

                  Expanded(
                    child: Center(
                      child: Text(
                        'El pedido ya no está disponible.',

                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.muted,

                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: PurchasesScreen.page,

          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),

                    child: Column(
                      children: [
                        _informationCard(sale),

                        const SizedBox(height: 28),

                        _productsCard(sale),

                        const SizedBox(height: 28),

                        _receiptCard(sale),

                        const SizedBox(height: 28),

                        _amountCard(),

                        const SizedBox(height: 54),

                        SizedBox(
                          width: double.infinity,

                          height: 80,

                          child: FilledButton(
                            onPressed: () => _confirmPayment(sale),

                            style: FilledButton.styleFrom(
                              backgroundColor: PurchasesScreen.red,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: Text(
                              'Confirmar pago',

                              style: GoogleFonts.poppins(
                                fontSize: 23,

                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,

                          height: 80,

                          child: OutlinedButton(
                            onPressed: () => _rejectPayment(sale),

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
                              'Rechazar pago',

                              style: GoogleFonts.poppins(
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _SalesHeaderBar(
      title: 'La Sirena Pizza',

      onBack: () => Navigator.of(context).pop(),

      initials: getInitials('Gloria Inés Vargas'),
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

      style: GoogleFonts.montserrat(
        color: const Color(0xFF5B4643),

        fontSize: 17,

        letterSpacing: 1.2,
      ),
    );
  }

  TextStyle _detailLabelStyle() =>
      GoogleFonts.poppins(color: const Color(0xFF5B4643), fontSize: 16);

  Widget _detailValue(String label, String value, double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(label, style: _detailLabelStyle()),

        const SizedBox(height: 5),

        Text(
          value,

          overflow: TextOverflow.ellipsis,

          style: GoogleFonts.poppins(
            color: PurchasesScreen.ink,

            fontSize: size,
          ),
        ),
      ],
    );
  }

  Widget _informationCard(Sale sale) {
    final palette = saleStatusPalette(sale.status);

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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Estado', style: _detailLabelStyle()),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,

                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: palette.background,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      sale.status.label,

                      style: GoogleFonts.poppins(
                        color: palette.foreground,

                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(child: _detailValue('Cliente', sale.user, 22)),

              Expanded(child: _detailValue('Fecha', sale.date, 22)),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _detailValue('Hora de recogida', sale.pickupTime, 22),
              ),

              Expanded(child: _detailValue('Total', formatCop(sale.total), 22)),
            ],
          ),

          const SizedBox(height: 30),

          Text('Método de pago', style: _detailLabelStyle()),

          const SizedBox(height: 10),

          _paymentBadge(sale),
        ],
      ),
    );
  }

  Widget _paymentBadge(Sale sale) {
    final isNequi = sale.isNequi;

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

            color: isNequi ? const Color(0xFF7023C7) : const Color(0xFFE08A00),

            size: 23,
          ),

          const SizedBox(width: 10),

          Text(
            sale.payment,

            style: GoogleFonts.poppins(
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

  Widget _productsCard(Sale sale) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionTitle('DETALLE DE LOS PRODUCTOS'),

          const SizedBox(height: 34),

          for (final product in sale.products) ...[
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
                        product.name,

                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,

                          fontSize: 23,
                        ),
                      ),

                      Text(
                        'Cantidad: ${product.quantity}',

                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5B4643),

                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  formatCop(product.total),

                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.red,

                    fontSize: 22,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],

          const Divider(color: Color(0xFFE0D9D7), height: 1),

          const SizedBox(height: 24),

          Row(
            children: [
              Text(
                'Total a pagar',

                style: GoogleFonts.poppins(
                  color: PurchasesScreen.ink,

                  fontSize: 25,

                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              Text(
                formatCop(sale.total),

                style: GoogleFonts.poppins(
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

  Widget _receiptCard(Sale sale) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionTitle('COMPROBANTE DE TRANSFERENCIA'),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,

            padding: sale.receiptAsset == null
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 50)
                : const EdgeInsets.all(12),

            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6B8B2), width: 2),

              borderRadius: BorderRadius.circular(16),
            ),

            child: sale.receiptAsset != null
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                        child: Image.asset(
                          sale.receiptAsset!,

                          width: double.infinity,

                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Comprobante ${sale.payment} enviado por ${sale.user}',

                        textAlign: TextAlign.center,

                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5B4643),

                          fontSize: 17,
                        ),
                      ),
                    ],
                  )
                : Column(
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

                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,

                          fontSize: 22,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'El cliente no subió imagen de transferencia',

                        textAlign: TextAlign.center,

                        style: GoogleFonts.poppins(
                          color: const Color(0xFF5B4643),

                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          _sectionTitle('MONTO RECIBIDO'),

          const SizedBox(height: 28),

          TextField(
            controller: _amountController,

            keyboardType: TextInputType.number,

            style: GoogleFonts.poppins(
              color: PurchasesScreen.ink,

              fontSize: 22,

              fontWeight: FontWeight.w500,
            ),

            decoration: InputDecoration(
              prefixText: '\$ ',

              prefixStyle: GoogleFonts.poppins(
                color: PurchasesScreen.muted,

                fontSize: 22,

                fontWeight: FontWeight.w500,
              ),

              hintText: '0',

              hintStyle: GoogleFonts.poppins(
                color: PurchasesScreen.ink,

                fontSize: 22,
              ),

              filled: true,

              fillColor: const Color(0xFFFFFDFD),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,

                vertical: 18,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

                borderSide: const BorderSide(color: Color(0xFFE5BDB9)),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),

                borderSide: const BorderSide(color: PurchasesScreen.red),
              ),

              errorStyle: GoogleFonts.poppins(
                color: PurchasesScreen.red,

                fontSize: 14,
              ),
            ),

            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),

          if (_amountError != null) ...[
            const SizedBox(height: 10),

            Text(
              _amountError!,

              style: GoogleFonts.poppins(
                color: PurchasesScreen.red,

                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmPayment(Sale sale) {
    final amount = _parseAmount();

    if (amount == null || amount <= 0) {
      setState(
        () => _amountError = 'Ingresa el monto recibido por el cliente.',
      );

      return;
    }

    SalesRepository.instance.updateStatus(
      sale.id,

      SaleStatus.porEntregar,

      receivedAmount: amount,
    );

    Navigator.of(context).pop();
  }

  Future<void> _rejectPayment(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: PurchasesScreen.page,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

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
              'Rechazar pago',

              textAlign: TextAlign.center,

              style: GoogleFonts.montserrat(
                color: Colors.black,

                fontSize: 28,

                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        content: Text(
          '¿Estás seguro de rechazar el pago\nde "${sale.id}"?\nEl pedido pasará a "Devolución".',

          textAlign: TextAlign.center,

          style: GoogleFonts.poppins(
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
                'Sí, rechazar',

                style: GoogleFonts.poppins(
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

                style: GoogleFonts.poppins(
                  fontSize: 17,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    SalesRepository.instance.updateStatus(sale.id, SaleStatus.devolucion);

    Navigator.of(context).pop();
  }
}
