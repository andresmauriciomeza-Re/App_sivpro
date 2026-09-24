part of '../purchases_screen.dart';



class SalesScreen extends StatelessWidget {

    const SalesScreen({super.key});



    static const _modules = [

      (

        icon: Icons.groups_outlined,

        title: 'Gesti├│n Clientes',

        description: 'Administrar base de clientes',

        highlighted: false,

      ),

      (

        icon: Icons.receipt_long_outlined,

        title: 'Gesti├│n Ventas',

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

                        'Gesti├│n de Ventas',

                        style: GoogleFonts.dmSerifDisplay(

                          color: PurchasesScreen.ink,

                          fontSize: 34,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

                      const SizedBox(height: 6),

                      Text(

                        'Seleccione el m├│dulo que desea gestionar.',

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

      return AppHeader(

        title: 'La Sirena Pizza',

        onBack: () => Navigator.of(context).pop(),

        initials: getInitials('Gloria In├®s Vargas'),

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

        onTap: title == 'Gesti├│n Clientes'

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

        (Icons.factory_outlined, 'Producci├│n'),

        (Icons.receipt_long_outlined, 'Ventas'),

        (Icons.person_outline, 'Mi Perfil'),

      ];

      return Container(

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

                    Icon(

                      items[i].$1,

                      color:

                          i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,

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

      );

    }

  }



class _Sale {

  const _Sale({

    required this.id,

    required this.user,

    required this.date,

    required this.payment,

    required this.paymentColor,

    required this.status,

  });



  final String id;

  final String user;

  final String date;

  final String payment;

  final Color paymentColor;

  final String status;

}



class _SalesManagementScreen extends StatefulWidget {

  const _SalesManagementScreen();



  @override

  State<_SalesManagementScreen> createState() => _SalesManagementScreenState();

}



class _SalesManagementScreenState extends State<_SalesManagementScreen> {

  final _searchController = TextEditingController();

  String _query = '';

  final List<_Sale> _sales = [

    const _Sale(

      id: 'VEN-001',

      user: 'Mar├¡a Gonz├ílez',

      date: '2024-01-15',

      payment: 'Nequi',

      paymentColor: Color(0xFFEDE2FF),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-002',

      user: 'Carlos Mart├¡nez',

      date: '2024-01-15',

      payment: 'Bancolombia',

      paymentColor: Color(0xFFFFF2B8),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-003',

      user: 'Ana Rodr├¡guez',

      date: '2024-01-16',

      payment: 'Nequi',

      paymentColor: Color(0xFFEDE2FF),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-004',

      user: 'Jorge Vargas',

      date: '2024-01-16',

      payment: 'Bancolombia',

      paymentColor: Color(0xFFFFF2B8),

      status: 'P├®rdida',

    ),

    const _Sale(

      id: 'VEN-005',

      user: 'Patricia Soto',

      date: '2024-01-17',

      payment: 'Nequi',

      paymentColor: Color(0xFFEDE2FF),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-006',

      user: 'Luis P├®rez',

      date: '2024-01-17',

      payment: 'Bancolombia',

      paymentColor: Color(0xFFFFF2B8),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-007',

      user: 'Camila Torres',

      date: '2024-01-18',

      payment: 'Nequi',

      paymentColor: Color(0xFFEDE2FF),

      status: 'Venta',

    ),

    const _Sale(

      id: 'VEN-008',

      user: 'Diego Ram├¡rez',

      date: '2024-01-18',

      payment: 'Bancolombia',

      paymentColor: Color(0xFFFFF2B8),

      status: 'Venta',

    ),

  ];



  @override

  void dispose() {

    _searchController.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

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

                      'Gesti├│n Ventas',

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

    return AppHeader(

      title: 'La Sirena Pizza',

      onBack: () => Navigator.of(context).pop(),

      initials: getInitials('Gloria In├®s Vargas'),

    );

  }



  Widget _buildBreadcrumb() {

    return Row(

      children: [

        Text('Inicio', style: _breadcrumbStyle(PurchasesScreen.muted)),

        const Icon(Icons.chevron_right, color: PurchasesScreen.muted, size: 20),

        Text('Ventas', style: _breadcrumbStyle(PurchasesScreen.muted)),

        const Icon(Icons.chevron_right, color: PurchasesScreen.muted, size: 20),

        Text('Gesti├│n Ventas', style: _breadcrumbStyle(PurchasesScreen.ink)),

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

    final isLoss = sale.status == 'P├®rdida';

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

                    Text(

                      sale.id,

                      style: GoogleFonts.dmSerifDisplay(

                        color: PurchasesScreen.ink,

                        fontSize: 22,

                        fontWeight: FontWeight.w500,

                      ),

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

          Row(

            children: [

              _paymentBadge(sale),

              const Spacer(),

              _statusButton(sale, isLoss),

            ],

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

      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),

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

            size: 18,

          ),

          const SizedBox(width: 7),

          Text(

            sale.payment,

            style: GoogleFonts.dmSerifDisplay(

              color: sale.payment == 'Nequi'

                  ? const Color(0xFF7023C7)

                  : const Color(0xFFE08A00),

              fontSize: 14,

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }



  Widget _statusButton(_Sale sale, bool isLoss) {

    return PopupMenuButton<String>(

      onSelected: (status) => _requestStatusChange(sale, status),

      itemBuilder: (_) => const [

        PopupMenuItem(value: 'Venta', child: Text('Venta')),

        PopupMenuItem(value: 'P├®rdida', child: Text('P├®rdida')),

      ],

      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

        decoration: BoxDecoration(

          color: isLoss ? const Color(0xFFFFE9EC) : const Color(0xFFE6F5E8),

          border: Border.all(

            color: isLoss ? const Color(0xFFE9B8C0) : const Color(0xFFB8D9BD),

          ),

          borderRadius: BorderRadius.circular(20),

        ),

        child: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text(

              sale.status,

              style: GoogleFonts.dmSerifDisplay(

                color: isLoss ? PurchasesScreen.red : const Color(0xFF398047),

                fontSize: 14,

                fontWeight: FontWeight.w600,

              ),

            ),

            const SizedBox(width: 5),

            Icon(

              Icons.keyboard_arrow_down,

              size: 17,

              color: isLoss ? PurchasesScreen.red : const Color(0xFF398047),

            ),

          ],

        ),

      ),

    );

  }



  Future<void> _requestStatusChange(_Sale sale, String status) async {

    if (status == sale.status) return;



    if (status == 'P├®rdida' && sale.status == 'Venta') {

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

            '┬┐Est├ís seguro de cambiar el estado\nde "Venta" a "P├®rdida"?',

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

                  'S├¡, confirmar',

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

      _sales[index] = _Sale(

        id: sale.id,

        user: sale.user,

        date: sale.date,

        payment: sale.payment,

        paymentColor: sale.paymentColor,

        status: status,

      );

    });

  }



  Widget _buildBottomNavigation() {

    const items = [

      (Icons.home_outlined, 'Inicio'),

      (Icons.shopping_cart_outlined, 'Compras'),

      (Icons.factory_outlined, 'Producci├│n'),

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

                  Icon(

                    items[i].$1,

                    size: 26,

                    color:

                        i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,

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

    );

  }

}



class _SaleDetailScreen extends StatelessWidget {

  const _SaleDetailScreen({required this.sale});



  final _Sale sale;



  @override

  Widget build(BuildContext context) {

    final isLoss = sale.status == 'P├®rdida';

    return Scaffold(

      backgroundColor: PurchasesScreen.page,

      body: SafeArea(

        child: Column(

          children: [

            AppHeader(

              title: 'Detalle de Venta',

              onBack: () => Navigator.of(context).pop(),

              initials: getInitials('Gloria In├®s Vargas'),

            ),

            Expanded(

              child: SingleChildScrollView(

                padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),

                child: Column(

                  children: [

                    _informationCard(isLoss),

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



  Widget _informationCard(bool isLoss) {

    return _sectionCard(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _sectionTitle('INFORMACI├ôN DE LA VENTA'),

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

                    color: isLoss

                        ? const Color(0xFFFFE9EC)

                        : const Color(0xFFE6F5E8),

                    borderRadius: BorderRadius.circular(20),

                  ),

                  child: Text(

                    sale.status,

                    style: GoogleFonts.dmSerifDisplay(

                      color: isLoss

                          ? PurchasesScreen.red

                          : const Color(0xFF398047),

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

          Text('M├®todo de pago', style: _detailLabelStyle()),

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

                      'Margarita Cl├ísica',

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

                '\$56.000',

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

                '\$56.000',

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

    return _sectionCard(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _sectionTitle('COMPROBANTE DE TRANSFERENCIA'),

          const SizedBox(height: 28),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),

            decoration: BoxDecoration(

              border: Border.all(

                color: const Color(0xFFE6B8B2),

                width: 2,

              ),

              borderRadius: BorderRadius.circular(16),

            ),

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

                  'El cliente no subi├│ imagen de transferencia',

                  textAlign: TextAlign.center,

                  style: GoogleFonts.dmSerifDisplay(

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

