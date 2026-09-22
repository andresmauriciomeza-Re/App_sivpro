part of '../purchases_screen.dart';

class _Client {
 const _Client({
   required this.id,
   required this.name,
   required this.email,
   required this.orders,
   required this.active,
   required this.initials,
   required this.color,
 });

 final String id;
 final String name;
 final String email;
 final int orders;
 final bool active;
 final String initials;
 final Color color;
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
 int _currentPage = 0;
 static const _pageSize = 5;

 static const _clients = [
   _Client(
     id: 'CLI-003',
     name: 'Ana Rodríguez',
     email: 'ana.rodriguez@outlook.com',
     orders: 3,
     active: true,
     initials: 'AR',
     color: Color(0xFF008D83),
   ),
   _Client(
     id: 'CLI-018',
     name: 'Andrés Castillo',
     email: 'andres.castillo@gmail.com',
     orders: 6,
     active: true,
     initials: 'AC',
     color: Color(0xFF1478C9),
   ),
   _Client(
     id: 'CLI-021',
     name: 'Carlos Martínez',
     email: 'carlos.m@outlook.com',
     orders: 7,
     active: true,
     initials: 'CM',
     color: Color(0xFF176CC0),
   ),
   _Client(
     id: 'CLI-084',
     name: 'Jorge Vargas',
     email: 'jorge.vargas@gmail.com',
     orders: 0,
     active: false,
     initials: 'JV',
     color: Color(0xFF9C79CF),
   ),
   _Client(
     id: 'CLI-086',
     name: 'Luis Herrera',
     email: 'lherrera@gmail.com',
     orders: 9,
     active: true,
     initials: 'LH',
     color: Color(0xFFE91561),
   ),
   _Client(
     id: 'CLI-102',
     name: 'Mariana Gómez',
     email: 'mariana.gomez@gmail.com',
     orders: 4,
     active: true,
     initials: 'MG',
     color: Color(0xFFE58B36),
   ),
   _Client(
     id: 'CLI-117',
     name: 'Nicolás Pérez',
     email: 'nicolas.perez@outlook.com',
     orders: 2,
     active: true,
     initials: 'NP',
     color: Color(0xFF6D59B5),
   ),
   _Client(
     id: 'CLI-129',
     name: 'Paula Torres',
     email: 'paula.torres@gmail.com',
     orders: 8,
     active: true,
     initials: 'PT',
     color: Color(0xFFDB4772),
   ),
   _Client(
     id: 'CLI-141',
     name: 'Ricardo Sánchez',
     email: 'ricardo.sanchez@gmail.com',
     orders: 1,
     active: false,
     initials: 'RS',
     color: Color(0xFF7A8B9C),
   ),
   _Client(
     id: 'CLI-155',
     name: 'Sofía Ramírez',
     email: 'sofia.ramirez@outlook.com',
     orders: 5,
     active: true,
     initials: 'SR',
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
   final query = _searchController.text.toLowerCase();
   final filteredClients = _clients
       .where(
         (client) =>
             client.name.toLowerCase().contains(query) ||
             client.email.toLowerCase().contains(query) ||
             client.id.toLowerCase().contains(query),
       )
       .where(
         (client) =>
             _statusFilter == 'Todos los estados' ||
             (_statusFilter == 'Activos' && client.active) ||
             (_statusFilter == 'Inactivos' && !client.active),
       )
       .toList();
   if (_sortOrder == 'Ordenar por nombre') {
     filteredClients.sort((a, b) => a.name.compareTo(b.name));
   } else {
     filteredClients.sort((a, b) => b.orders.compareTo(a.orders));
   }
    final totalPages = (filteredClients.length / _pageSize).ceil();
    final safePage = totalPages == 0
        ? 0
        : _currentPage.clamp(0, totalPages - 1);
    final startIndex = safePage * _pageSize;
    final visibleClients = filteredClients
        .skip(startIndex)
        .take(_pageSize)
        .toList();

   return Scaffold(
     backgroundColor: PurchasesScreen.page,
     body: SafeArea(
       bottom: false,
       child: Column(
         children: [
           _buildHeader(context),
           Expanded(
             child: SingleChildScrollView(
               padding: const EdgeInsets.fromLTRB(10, 16, 10, 20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   _breadcrumb(),
                   const SizedBox(height: 14),
                   Text(
                     'Clientes',
                     style: GoogleFonts.dmSerifDisplay(
                       color: PurchasesScreen.ink,
                       fontSize: 28,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                   Text(
                     'Usuarios registrados con tipo cliente en La Sirena',
                     style: GoogleFonts.poppins(
                       color: PurchasesScreen.muted,
                       fontSize: 11,
                     ),
                   ),
                   const SizedBox(height: 14),
                   Row(
                     children: [
                       Expanded(
                         child: _summaryCard(
                           '${_clients.length}',
                           'Total clientes',
                           const Color(0xFFF3F3F3),
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: _summaryCard(
                           '${_clients.where((client) => client.active).length}',
                           'Activos',
                           const Color(0xFFE2F4E5),
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: _summaryCard(
                           '${_clients.where((client) => !client.active).length}',
                           'Inactivos',
                           const Color(0xFFF5F0F0),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 14),
                   _searchField(),
                   const SizedBox(height: 8),
                   _selectField(
                     value: _statusFilter,
                     items: const [
                       'Todos los estados',
                       'Activos',
                       'Inactivos',
                     ],
                     onChanged: (value) => setState(() {
                       _statusFilter = value!;
                       _currentPage = 0;
                     }),
                   ),
                   const SizedBox(height: 8),
                   _selectField(
                     value: _sortOrder,
                     items: const ['Ordenar por nombre', 'Más pedidos'],
                     onChanged: (value) => setState(() {
                       _sortOrder = value!;
                       _currentPage = 0;
                     }),
                   ),
                   const SizedBox(height: 14),
                   for (final client in visibleClients) ...[
                     _clientCard(client),
                     const SizedBox(height: 1),
                   ],
                   _clientPagination(
                     currentPage: safePage,
                     totalPages: totalPages,
                     onPageChanged: (page) {
                       setState(() => _currentPage = page);
                     },
                   ),
                   Center(
                     child: Text(
                       filteredClients.isEmpty
                           ? 'No hay clientes para mostrar'
                           : 'Mostrando ${startIndex + 1}–'
                               '${(startIndex + visibleClients.length)} '
                               'de ${filteredClients.length} clientes',
                       style: GoogleFonts.poppins(
                         color: PurchasesScreen.muted,
                         fontSize: 11,
                       ),
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
   return Container(
     height: 62,
     decoration: const BoxDecoration(
       border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
     ),
     child: Row(
       children: [
         IconButton(
           onPressed: () => Navigator.of(context).pop(),
           icon: const Icon(Icons.arrow_back, color: PurchasesScreen.muted, size: 18),
         ),
         Expanded(
           child: Text(
             'La Sirena Pizza',
             textAlign: TextAlign.center,
             style: GoogleFonts.poppins(
               color: const Color(0xFFAD0E14),
               fontSize: 14,
               fontWeight: FontWeight.w700,
             ),
           ),
         ),
         Container(
           width: 30,
           height: 30,
           margin: const EdgeInsets.only(right: 10),
           decoration: const BoxDecoration(
             color: PurchasesScreen.red,
             shape: BoxShape.circle,
           ),
           alignment: Alignment.center,
           child: Text(
             'G',
             style: GoogleFonts.poppins(
               color: Colors.white,
               fontSize: 11,
               fontWeight: FontWeight.w700,
             ),
           ),
         ),
       ],
     ),
   );
 }

 Widget _breadcrumb() {
   return Row(
     children: [
       const Icon(Icons.home_outlined, size: 12, color: PurchasesScreen.muted),
       Text(
         ' Inicio  ›  Ventas  ›  Clientes',
         style: GoogleFonts.poppins(
           color: PurchasesScreen.muted,
           fontSize: 9,
         ),
       ),
     ],
   );
 }

 Widget _summaryCard(String value, String label, Color color) {
   return Container(
     height: 52,
     padding: const EdgeInsets.fromLTRB(9, 5, 6, 4),
     clipBehavior: Clip.antiAlias,
     decoration: BoxDecoration(
       color: PurchasesScreen.page,
       borderRadius: BorderRadius.circular(7),
       border: Border.all(color: const Color(0xFFE5BDB9)),
     ),
     child: Stack(
       children: [
         Positioned(
           right: -13,
           top: -14,
           child: Container(
             width: 54,
             height: 54,
             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
           ),
         ),
         Text(
           value,
           style: GoogleFonts.dmSerifDisplay(
             color: PurchasesScreen.ink,
             fontSize: 23,
             fontWeight: FontWeight.w700,
           ),
         ),
         Positioned(
           bottom: 0,
           left: 0,
           child: Text(
             label,
             style: GoogleFonts.poppins(
               color: PurchasesScreen.muted,
               fontSize: 12,
             ),
           ),
         ),
       ],
     ),
   );
 }

 Widget _searchField() {
   return TextField(
     controller: _searchController,
     onChanged: (_) => setState(() => _currentPage = 0),
     style: GoogleFonts.poppins(fontSize: 11),
     decoration: InputDecoration(
       hintText: 'Buscar por nombre, correo o estado...',
       hintStyle: GoogleFonts.poppins(fontSize: 10),
       prefixIcon: const Icon(Icons.search, size: 17),
       contentPadding: const EdgeInsets.symmetric(vertical: 9),
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
     style: GoogleFonts.poppins(
       color: PurchasesScreen.muted,
       fontSize: 10,
     ),
     icon: const Icon(Icons.keyboard_arrow_down, size: 17),
     decoration: const InputDecoration(
       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
     padding: const EdgeInsets.fromLTRB(11, 5, 9, 1),
     decoration: const BoxDecoration(
       color: PurchasesScreen.page,
       border: Border(
         top: BorderSide(color: Color(0xFFE5BDB9)),
         left: BorderSide(color: Color(0xFFE5BDB9)),
         right: BorderSide(color: Color(0xFFE5BDB9)),
       ),
     ),
     child: Column(
       children: [
         Row(
           children: [
             CircleAvatar(
               radius: 16,
               backgroundColor: client.color,
               child: Text(
                 client.initials,
                 style: GoogleFonts.poppins(
                   color: Colors.white,
                   fontSize: 11,
                   fontWeight: FontWeight.w700,
                 ),
               ),
             ),
             const SizedBox(width: 8),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   client.name,
                   style: GoogleFonts.poppins(
                     color: PurchasesScreen.ink,
                     fontSize: 17,
                     fontWeight: FontWeight.w700,
                   ),
                 ),
                 Text(
                   client.id,
                   style: GoogleFonts.robotoMono(
                     color: PurchasesScreen.muted,
                     fontSize: 12,
                   ),
                 ),
               ],
             ),
           ],
         ),
         const SizedBox(height: 3),
         _clientData('CORREO', client.email),
         const SizedBox(height: 3),
         Row(
           children: [
             Text(
               'PEDIDOS',
               style: GoogleFonts.robotoMono(
                 color: PurchasesScreen.muted,
                 fontSize: 12,
               ),
             ),
             const Spacer(),
             Text(
               '${client.orders}',
               style: GoogleFonts.robotoMono(
                 color: PurchasesScreen.ink,
                 fontSize: 17,
               ),
             ),
           ],
         ),
         const SizedBox(height: 3),
         Row(
           children: [
             Text(
               'ESTADO',
               style: GoogleFonts.robotoMono(
                 color: PurchasesScreen.muted,
                 fontSize: 12,
               ),
             ),
             const SizedBox(width: 38),
             Container(
               padding: const EdgeInsets.symmetric(
                 horizontal: 8,
                 vertical: 3,
               ),
               decoration: BoxDecoration(
                 color: client.active
                     ? const Color(0xFFE2F4E5)
                     : const Color(0xFFF1EAEA),
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Text(
                 client.active ? 'Activo' : 'Inactivo',
                 style: GoogleFonts.poppins(
                   color: client.active
                       ? const Color(0xFF278044)
                       : PurchasesScreen.muted,
                   fontSize: 12,
                 ),
               ),
             ),
           ],
         ),
        const Padding(
           padding: EdgeInsets.only(top: 3),
           child: Divider(color: Color(0xFFE5BDB9), height: 1),
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
             _clientAction(Icons.visibility_outlined, client),
             _clientAction(Icons.edit_outlined, client),
             _clientAction(Icons.delete_outline, client),
           ],
         ),
       ],
     ),
   );
 }

 Widget _clientAction(IconData icon, _Client client) {
   return SizedBox(
     width: 40,
     height: 40,
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
       icon: Icon(icon, size: 16, color: PurchasesScreen.ink),
     ),
   );
 }

 Widget _clientPagination({
   required int currentPage,
   required int totalPages,
   required ValueChanged<int> onPageChanged,
 }) {
   if (totalPages <= 1) {
     return const SizedBox(height: 8);
   }

   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 10),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         _pageButton(
           icon: Icons.chevron_left,
           enabled: currentPage > 0,
           onPressed: () => onPageChanged(currentPage - 1),
         ),
         for (var page = 0; page < totalPages; page++)
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 3),
             child: _pageNumber(
               page: page,
               selected: page == currentPage,
               onPressed: () => onPageChanged(page),
             ),
           ),
         _pageButton(
           icon: Icons.chevron_right,
           enabled: currentPage < totalPages - 1,
           onPressed: () => onPageChanged(currentPage + 1),
         ),
       ],
     ),
   );
 }

 Widget _pageButton({
   required IconData icon,
   required bool enabled,
   required VoidCallback onPressed,
 }) {
   return SizedBox(
     width: 40,
     height: 40,
     child: IconButton(
       onPressed: enabled ? onPressed : null,
       icon: Icon(icon, size: 22),
       color: PurchasesScreen.red,
       disabledColor: const Color(0xFFD6C9C7),
     ),
   );
 }

 Widget _pageNumber({
   required int page,
   required bool selected,
   required VoidCallback onPressed,
 }) {
   return SizedBox(
     width: 34,
     height: 34,
     child: OutlinedButton(
       onPressed: onPressed,
       style: OutlinedButton.styleFrom(
         padding: EdgeInsets.zero,
         backgroundColor:
             selected ? PurchasesScreen.red : PurchasesScreen.page,
         foregroundColor: selected ? Colors.white : PurchasesScreen.ink,
         side: BorderSide(
           color: selected
               ? PurchasesScreen.red
               : const Color(0xFFE5BDB9),
         ),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(7),
         ),
       ),
       child: Text(
         '${page + 1}',
         style: GoogleFonts.poppins(
           fontSize: 12,
           fontWeight: FontWeight.w700,
         ),
       ),
     ),
   );
 }

 Widget _clientData(String label, String value) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         label,
         style: GoogleFonts.robotoMono(
           color: PurchasesScreen.muted,
           fontSize: 12,
         ),
       ),
       const SizedBox(height: 4),
       Text(
         value,
         style: GoogleFonts.poppins(
           color: PurchasesScreen.muted,
           fontSize: 13,
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
     (Icons.more_horiz, 'Más'),
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
           Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(
                 items[i].$1,
                 size: 25,
                 color: i == 3 ? PurchasesScreen.red : PurchasesScreen.muted,
               ),
               Text(
                 items[i].$2,
                 style: GoogleFonts.poppins(
                   color: i == 3
                       ? PurchasesScreen.red
                       : PurchasesScreen.muted,
                   fontSize: 10,
                 ),
               ),
             ],
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
              color: PurchasesScreen.page,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: PurchasesScreen.muted,
                      size: 27,
                    ),
                  ),
                  Text(
                    'Detalle Cliente',
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
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
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            client.id,
                            style: GoogleFonts.robotoMono(
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
                            valueStyle: GoogleFonts.robotoMono(
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
                                style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
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
                              color: PurchasesScreen.red,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Volver a Clientes',
                              style: GoogleFonts.poppins(
                                color: PurchasesScreen.red,
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
                        style: GoogleFonts.robotoMono(
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
                            _textField(
                              _ordersController,
                              keyboardType: TextInputType.number,
                            ),
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
                                  style: GoogleFonts.poppins(
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
                                  style: GoogleFonts.poppins(
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
      return Container(
        height: 72,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: PurchasesScreen.muted, size: 26),
            ),
            Expanded(
              child: Text(
                'La Sirena Pizza',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFAD0E14),
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(right: 14),
              decoration: const BoxDecoration(
                color: PurchasesScreen.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'GV',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _fieldLabel(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
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
        (Icons.more_horiz, 'Más'),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].$1,
                    color: i == 4 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              style: GoogleFonts.poppins(
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
                        GoogleFonts.poppins(
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
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.muted,
              size: 23,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GV',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

