part of '../purchases_screen.dart';

class _Client {
 const _Client({
   required this.id,
   required this.name,
   required this.email,
   required this.orders,
   required this.active,
   required this.color,
 });

 final String id;
 final String name;
 final String email;
 final int orders;
final bool active;
  final Color color;

  _Client copyWith({bool? active}) {
    return _Client(
      id: id,
      name: name,
      email: email,
      orders: orders,
      active: active ?? this.active,
      color: color,
    );
  }

  String get initials => getInitials(name);
}

class _ClientManagementScreen extends StatefulWidget {
 const _ClientManagementScreen();

 @override
 State<_ClientManagementScreen> createState() =>
     _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<_ClientManagementScreen> {
 final _searchController = TextEditingController();
 String _statusFilter = 'Todos los estados';
 String _sortOrder = 'Ordenar por nombre';
 static const _pageSize = 5;
 int _visibleClients = _pageSize;

 void _toggleClientActive(_Client client) {
    setState(() {
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client.copyWith(active: !client.active);
      }
    });
  }

  void _loadMore() {
   if (_visibleClients >= _clients.length) return;
   setState(() {
     _visibleClients += _pageSize;
     if (_visibleClients > _clients.length) {
       _visibleClients = _clients.length;
     }
   });
 }

static final List<_Client> _clients = [
    _Client(
      id: 'CLI-003',
      name: 'Ana Rodríguez',
      email: 'ana.rodriguez@outlook.com',
      orders: 3,
      active: true,
      color: Color(0xFF008D83),
    ),
   _Client(
     id: 'CLI-018',
     name: 'Andrés Castillo',
     email: 'andres.castillo@gmail.com',
     orders: 6,
active: true,
      color: Color(0xFF1478C9),
   ),
   _Client(
     id: 'CLI-021',
     name: 'Carlos Martínez',
     email: 'carlos.m@outlook.com',
     orders: 7,
active: true,
      color: Color(0xFF176CC0),
   ),
   _Client(
     id: 'CLI-084',
     name: 'Jorge Vargas',
     email: 'jorge.vargas@gmail.com',
     orders: 0,
active: false,
      color: Color(0xFF9C79CF),
   ),
   _Client(
     id: 'CLI-086',
     name: 'Luis Herrera',
     email: 'lherrera@gmail.com',
     orders: 9,
active: true,
      color: Color(0xFFE91561),
   ),
   _Client(
     id: 'CLI-102',
     name: 'Mariana Gómez',
     email: 'mariana.gomez@gmail.com',
     orders: 4,
active: true,
      color: Color(0xFFE58B36),
   ),
   _Client(
     id: 'CLI-117',
     name: 'Nicolás Pérez',
     email: 'nicolas.perez@outlook.com',
     orders: 2,
active: true,
      color: Color(0xFF6D59B5),
   ),
   _Client(
     id: 'CLI-129',
     name: 'Paula Torres',
     email: 'paula.torres@gmail.com',
     orders: 8,
active: true,
      color: Color(0xFFDB4772),
   ),
   _Client(
     id: 'CLI-141',
     name: 'Ricardo Sánchez',
     email: 'ricardo.sanchez@gmail.com',
     orders: 1,
active: false,
      color: Color(0xFF7A8B9C),
   ),
   _Client(
     id: 'CLI-155',
     name: 'Sofía Ramírez',
     email: 'sofia.ramirez@outlook.com',
     orders: 5,
active: true,
      color: Color(0xFF2B9C6A),
   ),
 ] ;

 @override
 void dispose() {
   _searchController.dispose();
   super.dispose();
 }

@override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final filteredClients = _clients
        .where(
          (client) =>
              matchesSearchQuery(query, [
                client.name,
                client.email,
                client.id,
                client.active ? 'Activo' : 'Inactivo',
              ]),
        )
        .where(
          (client) =>
              _statusFilter == 'Todos los estados' ||
              (_statusFilter == 'Activo' && client.active) ||
              (_statusFilter == 'Inactivo' && !client.active),
        )
        .toList();
    if (_sortOrder == 'Ordenar por pedidos') {
      filteredClients.sort((a, b) {
        final byOrders = b.orders.compareTo(a.orders);
        return byOrders != 0
            ? byOrders
            : normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name));
      });
    } else {
      filteredClients.sort(
        (a, b) =>
            normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name)),
      );
    }
final visibleClients =
       filteredClients.take(_visibleClients).toList();

   return Scaffold(
     backgroundColor: PurchasesScreen.page,
     body: SafeArea(
       bottom: false,
       child: Column(
         children: [
           _buildHeader(context),
           Expanded(
             child: NotificationListener<ScrollNotification>(
               onNotification: (notification) {
                 if (notification.metrics.pixels >=
                     notification.metrics.maxScrollExtent - 200) {
                   _loadMore();
                 }
                 return false;
               },
child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _breadcrumb(),
                   const SizedBox(height: 18),
Text(
                      'Clientes',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Usuarios registrados con tipo cliente en La Sirena',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 16,
                      ),
                    ),
                   const SizedBox(height: 18),
                   Row(
                     children: [
Expanded(
                          child: _summaryCard(
                            '${_clients.length}',
                            'Total clientes',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryCard(
                            '${_clients.where((client) => client.active).length}',
                            'Activos',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryCard(
                            '${_clients.where((client) => !client.active).length}',
                            'Inactivos',
                          ),
                        ),
                     ],
                   ),
                   const SizedBox(height: 18),
                   _searchField(),
                   const SizedBox(height: 12),
_selectField(
                      value: _statusFilter,
                      items: const [
                        'Todos los estados',
                        'Activo',
                        'Inactivo',
                      ],
onChanged: (value) => setState(() {
                         _statusFilter = value!;
                         _visibleClients = _pageSize;
                       }),
                    ),
                    const SizedBox(height: 12),
                    _selectField(
                      value: _sortOrder,
                      items: const [
                        'Ordenar por nombre',
                        'Ordenar por pedidos',
                      ],
onChanged: (value) => setState(() {
                         _sortOrder = value!;
                         _visibleClients = _pageSize;
                       }),
                    ),
                   const SizedBox(height: 18),
for (final client in visibleClients) ...[
                      _clientCard(client),
                      const SizedBox(height: 18),
                    ],
Center(
                      child: Text(
                        filteredClients.isEmpty
                            ? 'No se encontraron clientes'
                            : 'Mostrando ${visibleClients.length} de '
                                '${filteredClients.length} clientes',
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.muted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
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
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

Widget _breadcrumb() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, size: 20, color: PurchasesScreen.muted),
        Text(
          ' Inicio  ›  Ventas  ›  Clientes',
          style: GoogleFonts.dmSerifDisplay(
            color: PurchasesScreen.muted,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

Widget _summaryCard(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5BDB9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() => _visibleClients = _pageSize),
      style: GoogleFonts.dmSerifDisplay(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, correo o estado...',
        hintStyle: GoogleFonts.dmSerifDisplay(fontSize: 15),
        prefixIcon: const Icon(Icons.search, size: 28),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _visibleClients = _pageSize);
                },
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: PurchasesScreen.muted,
                ),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
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

 Widget _selectField({
   required String value,
   required List<String> items,
   required ValueChanged<String?> onChanged,
 }) {
return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      style: GoogleFonts.dmSerifDisplay(
        color: PurchasesScreen.muted,
        fontSize: 14,
      ),
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5BDB9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red),
        ),
      ),
     items: [
       for (final item in items)
         DropdownMenuItem<String>(value: item, child: Text(item)),
     ],
   );
 }

Widget _clientCard(_Client client) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: client.color,
                child: Text(
                  client.initials,
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.id,
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _clientAction(Icons.visibility_outlined, client),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _clientInfo('CORREO', client.email)),
              Expanded(child: _clientInfo('PEDIDOS', '${client.orders}')),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 14, bottom: 11),
            child: Divider(height: 1, color: Color(0xFFE5D9D7)),
          ),
          Row(
            children: [
              _statusBadge(client),
              const Spacer(),
              _clientAction(Icons.edit_outlined, client),
              _statusSwitch(client),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_Client client) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: client.active
            ? const Color(0xFFE2F4E5)
            : const Color(0xFFF1EAEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        client.active ? 'Activo' : 'Inactivo',
        style: GoogleFonts.dmSerifDisplay(
          color: client.active ? const Color(0xFF278044) : PurchasesScreen.muted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusSwitch(_Client client) {
    return SizedBox(
      width: 46,
      height: 40,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleClientActive(client),
        child: Center(
          child: IgnorePointer(
            child: Transform.scale(
              scale: 0.75,
              child: Switch(
                value: client.active,
                onChanged: (_) {},
                activeTrackColor: AppColors.switchTrackActive,
                inactiveTrackColor: AppColors.red,
                thumbColor: WidgetStateProperty.all(Colors.white),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _clientAction(IconData icon, _Client client) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: icon == Icons.visibility_outlined
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ClientDetailScreen(client: client),
                  ),
                )
            : icon == Icons.edit_outlined
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ClientEditScreen(client: client),
                      ),
                    )
                : () {},
        icon: Icon(icon, size: 25, color: const Color(0xFF5B4643)),
      ),
    );
  }

  Widget _clientInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSerifDisplay(
            color: PurchasesScreen.muted,
            fontSize: 12,
          ),
        ),
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

 Widget _buildBottomNavigation(BuildContext context) {
   const items = [
     (Icons.home_outlined, 'Inicio'),
     (Icons.shopping_cart_outlined, 'Compras'),
     (Icons.factory_outlined, 'Producción'),
     (Icons.receipt_long_outlined, 'Ventas'),
     (Icons.person_outline, 'Mi Perfil'),
   ];
   return Container(
     padding: const EdgeInsets.only(top: 7, bottom: 7),
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
                    size: 25,
                    color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
                      color: i == 3
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 10,
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

class _ClientDetailScreen extends StatelessWidget {
  const _ClientDetailScreen({required this.client});

  final _Client client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppHeader(context),
            Container(
              height: 58,
              color: AppColors.page,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.red,
                      size: 27,
                    ),
                  ),
                  Text(
                    'Detalle Cliente',
                    style: GoogleFonts.dmSerifDisplay(
                      color: AppColors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 59,
                            backgroundColor: client.color,
                            child: Text(
                              client.initials,
                              style: GoogleFonts.dmSerifDisplay(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            client.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            client.id,
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.muted,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        children: [
                          _detailClientRow('Correo', client.email),
                          _detailClientRow(
                            'Pedidos totales',
                            '${client.orders}',
                            valueStyle: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _detailClientRow(
                            'Estado',
                            client.active ? 'Activo' : 'Inactivo',
                            valueWidget: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: client.active
                                    ? const Color(0xFFE2F4E5)
                                    : const Color(0xFFF1EAEA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                client.active ? 'Activo' : 'Inactivo',
                                style: GoogleFonts.dmSerifDisplay(
                                  color: client.active
                                      ? const Color(0xFF278044)
                                      : PurchasesScreen.muted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 72,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: PurchasesScreen.page,
                          foregroundColor: Colors.black,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 25,
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

}

class _ClientEditScreen extends StatefulWidget {
    const _ClientEditScreen({required this.client});

    final _Client client;

    @override
    State<_ClientEditScreen> createState() => _ClientEditScreenState();
  }

class _ClientEditScreenState extends State<_ClientEditScreen> {
    late final TextEditingController _nameController;
    late final TextEditingController _emailController;
    late final TextEditingController _ordersController;
    late bool _active;

    @override
    void initState() {
      super.initState();
      _nameController = TextEditingController(text: widget.client.name);
      _emailController = TextEditingController(text: widget.client.email);
      _ordersController = TextEditingController(
        text: '${widget.client.orders}',
      );
      _active = widget.client.active;
    }

    @override
    void dispose() {
      _nameController.dispose();
      _emailController.dispose();
      _ordersController.dispose();
      super.dispose();
    }

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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: AppColors.red,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Volver a Clientes',
                              style: GoogleFonts.dmSerifDisplay(
                                color: AppColors.red,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Editar Cliente',
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID: ${widget.client.id}',
                        style: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.muted,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                        decoration: BoxDecoration(
                          color: PurchasesScreen.page,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(color: const Color(0xFFE0D9D7)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Nombre completo'),
                            _textField(_nameController),
                            const SizedBox(height: 24),
                            _fieldLabel('Correo'),
                            _textField(
                              _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            _fieldLabel('Pedidos'),
                            _lockedField(_ordersController),
                            const SizedBox(height: 24),
                            _fieldLabel('Estado'),
                            Row(
                              children: [
                                Expanded(
                                  child: _dropdownField(),
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.sync,
                                  color: PurchasesScreen.red,
                                  size: 30,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: PurchasesScreen.red,
                                  side: const BorderSide(
                                    color: PurchasesScreen.red,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'Cancelar',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _saveClient,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PurchasesScreen.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'Guardar cambios',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
        initials: getInitials('Gloria Inés Vargas'),
      );
    }

    Widget _fieldLabel(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: GoogleFonts.dmSerifDisplay(
            color: PurchasesScreen.ink,
            fontSize: 20,
          ),
        ),
      );
    }

    Widget _textField(
      TextEditingController controller, {
      TextInputType? keyboardType,
    }) {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSerifDisplay(
          color: PurchasesScreen.ink,
          fontSize: 20,
        ),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF7F8F9),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
          ),
        ),
      );
    }

    Widget _lockedField(TextEditingController controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: false,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF7F8F9),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No se puede modificar',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    Widget _dropdownField() {
      return DropdownButtonFormField<String>(
        initialValue: _active ? 'Activo' : 'Inactivo',
        isExpanded: true,
        onChanged: (value) {
          if (value != null) {
            setState(() => _active = value == 'Activo');
          }
        },
        icon: const Icon(Icons.keyboard_arrow_down),
        style: GoogleFonts.dmSerifDisplay(
          color: PurchasesScreen.ink,
          fontSize: 20,
        ),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF7F8F9),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Activo', child: Text('Activo')),
          DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
        ],
      );
    }

    void _saveClient() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.client.id} actualizado correctamente.'),
        ),
      );
      Navigator.of(context).pop();
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
                    Icon(
                      items[i].$1,
                      color: i == 4 ? PurchasesScreen.red : PurchasesScreen.muted,
                    ),
                    Text(
                      items[i].$2,
                      style: GoogleFonts.dmSerifDisplay(
                        color: i == 4
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

extension _ClientDetailHelpers on _ClientDetailScreen {
  Widget _detailClientRow(
    String label,
    String value, {
    TextStyle? valueStyle,
    Widget? valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0D9D7))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.dmSerifDisplay(
                color: PurchasesScreen.muted,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle ??
                        GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 16,
                        ),
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }
}

