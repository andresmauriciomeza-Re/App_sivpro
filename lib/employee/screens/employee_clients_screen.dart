import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../../shared/page_transitions.dart';
import '../../shared/search.dart';

class EmployeeClientsScreen extends StatefulWidget {
  const EmployeeClientsScreen({super.key});

  @override
  State<EmployeeClientsScreen> createState() => _EmployeeClientsScreenState();
}

class _EmployeeClientsScreenState extends State<EmployeeClientsScreen> {

  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF17243A);
  static const Color muted = Color(0xFF617492);
  static const Color page = Color(0xFFFCFAF9);

  static final List<_Client> clients = [
    _Client(
      'Ana Rodríguez',
      'ana.rodriguez@outlook.com',
      'CLI-003',
      3,
      true,
      Color(0xFF00B27A),
    ),
    _Client(
      'Andrés Castillo',
      'andres.castillo@gmail.com',
      'CLI-010',
      6,
      true,
      Color(0xFF1877E8),
    ),
    _Client(
      'Carlos Martínez',
      'carlos.m@hotmail.com',
      'CLI-002',
      7,
      true,
      Color(0xFF168BD7),
    ),
    _Client(
      'Jorge Vargas',
      'jorge.vargas@gmail.com',
      'CLI-004',
      0,
      false,
      Color(0xFF8B2BE2),
    ),
    _Client(
      'Luis Herrera',
      'lherrera@gmail.com',
      'CLI-006',
      9,
      true,
      Color(0xFFE21B70),
    ),
  ];

  static const _pageSize = 5;
  int _visibleClients = _pageSize;
  final _searchController = TextEditingController();
  String _statusFilter = 'Todos los estados';
  String _sortOrder = 'Ordenar por nombre';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Client> _filteredClients() {
    final query = _searchController.text;
    final filtered = clients.where((client) {
      final matchesQuery = matchesSearchQuery(query, [
        client.name,
        client.email,
        client.id,
        client.active ? 'Activo' : 'Inactivo',
      ]);
      final matchesState = _statusFilter == 'Todos los estados' ||
          (_statusFilter == 'Activo' && client.active) ||
          (_statusFilter == 'Inactivo' && !client.active);
      return matchesQuery && matchesState;
    }).toList();
    if (_sortOrder == 'Ordenar por pedidos') {
      filtered.sort((a, b) {
        final byOrders = b.orders.compareTo(a.orders);
        return byOrders != 0
            ? byOrders
            : normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name));
      });
    } else {
      filtered.sort(
        (a, b) => normalizeForSearch(a.name)
            .compareTo(normalizeForSearch(b.name)),
      );
    }
    return filtered;
  }

  void _toggleClientActive(_Client client) {
    setState(() {
      final index = clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        clients[index] = client.copyWith(active: !client.active);
      }
    });
  }

  void _loadMore() {
    final filtered = _filteredClients().length;
    if (_visibleClients >= filtered) return;
    setState(() {
      _visibleClients += _pageSize;
      if (_visibleClients > filtered) _visibleClients = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clientes',
                                style: GoogleFonts.montserrat(
                                  color: ink,
                                  fontSize: 30,
                                ),
                              ),
                              Text(
                                'Usuarios registrados con tipo cliente en La Sirena',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: muted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () => _showCreateClientDialog(context),
                          icon: const Icon(Icons.person_add, size: 19),
                          label: const Text('Crear cliente'),
                          style: FilledButton.styleFrom(
                            backgroundColor: red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.groups_outlined,
                            value: '${clients.length}',
                            label: 'Total clientes',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.how_to_reg_outlined,
                            value:
                                '${clients.where((c) => c.active).length}',
                            label: 'Activos',
                            active: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.person_off_outlined,
                            value:
                                '${clients.where((c) => !c.active).length}',
                            label: 'Inactivos',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSearch(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PopupMenuButton<String>(
                            initialValue: _statusFilter,
                            onSelected: (value) => setState(() {
                              _statusFilter = value;
                              _visibleClients = _pageSize;
                            }),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Todos los estados',
                                child: Text('Todos los estados'),
                              ),
                              PopupMenuItem(
                                value: 'Activo',
                                child: Text('Activo'),
                              ),
                              PopupMenuItem(
                                value: 'Inactivo',
                                child: Text('Inactivo'),
                              ),
                            ],
                            child: _FilterButton(label: _statusFilter),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PopupMenuButton<String>(
                            initialValue: _sortOrder,
                            onSelected: (value) => setState(() {
                              _sortOrder = value;
                              _visibleClients = _pageSize;
                            }),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Ordenar por nombre',
                                child: Text('Ordenar por nombre'),
                              ),
                              PopupMenuItem(
                                value: 'Ordenar por pedidos',
                                child: Text('Ordenar por pedidos'),
                              ),
                            ],
                            child: _FilterButton(label: _sortOrder),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LISTADO DE CLIENTES',
                          style: GoogleFonts.poppins(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_visibleClients >= _filteredClients().length ? _filteredClients().length : _visibleClients} DE ${_filteredClients().length}',
                          style: GoogleFonts.poppins(
                            color: muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_filteredClients().isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'No se encontraron clientes',
                            style: GoogleFonts.poppins(
                              color: muted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._filteredClients().take(_visibleClients).map(
                        (client) => _ClientCard(
                          client: client,
                          onView: () => _showClientDetail(context, client),
                          onEdit: () => _showEditClientDialog(context, client),
                          onToggle: () => _toggleClientActive(client),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 27),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 28),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(color: red, fontSize: 24),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: Text(
              getInitials('María González'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final hasText = _searchController.text.isNotEmpty;
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() => _visibleClients = _pageSize),
      style: GoogleFonts.poppins(color: ink, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, correo o estado...',
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFF91A3C0),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF8DA0BE),
          size: 23,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 23,
        ),
        suffixIcon: hasText
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _visibleClients = _pageSize);
                },
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF91A3C0),
                  size: 20,
                ),
                tooltip: 'Limpiar búsqueda',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E1DF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: red),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.people_outline, 'Clientes'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.sync_alt, 'Devoluciones'),
      (Icons.person_outline, 'Perfil'),
    ];
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
                  top: BorderSide(color: red, width: 1),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: InkWell(
                        onTap: () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].$1,
                              color: index == 1 ? red : muted,
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.poppins(
                                color: index == 1 ? red : muted,
                                fontSize: 10,
                                fontWeight: index == 1
                                    ? FontWeight.w700
                                    : FontWeight.w400,
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

  void _showCreateClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    var active = true;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Crear Cliente',
                          style: GoogleFonts.montserrat(
                            color: ink,
                            fontSize: 30,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: Colors.black38),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    _DialogField(
                      label: 'Nombre completo',
                      required: true,
                      hint: 'Ej: Laura Martínez',
                      controller: nameController,
                    ),
                    const SizedBox(height: 18),
                    _DialogField(
                      label: 'Correo electrónico',
                      required: true,
                      hint: 'correo@ejemplo.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    _DialogField(
                      label: 'Teléfono',
                      optional: true,
                      hint: '3001234567',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Estado',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF454545),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    InkWell(
                      onTap: () => setDialogState(() => active = !active),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFCFB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE3E1DE)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              active ? 'Activo' : 'Inactivo',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF353535),
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: const BorderSide(color: Color(0xFFE2DEDC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                color: ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty ||
                                  emailController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa el nombre y el correo electrónico.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cliente creado correctamente.',
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: red,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Crear cliente',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    });
  }

  void _showClientDetail(BuildContext context, _Client client) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 28, 36, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Detalle Cliente',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 30,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.black45),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 43,
                      backgroundColor: client.color,
                      child: Text(
                        client.initials,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: GoogleFonts.poppins(
                              color: ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.id,
                            style: GoogleFonts.poppins(
                              color: muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _DetailRow(label: 'Correo', value: client.email),
                _DetailRow(label: 'Pedidos totales', value: '${client.orders}'),
                _DetailRow(
                  label: 'Estado',
                  value: client.active ? 'Activo' : 'Inactivo',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F4),
                      foregroundColor: ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _showEditClientDialog(BuildContext context, _Client client) {
    final nameController = TextEditingController(text: client.name);
    final emailController = TextEditingController(text: client.email);
    final ordersController = TextEditingController(text: '${client.orders}');
    var active = client.active;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Editar Cliente',
                          style: GoogleFonts.montserrat(
                            color: ink,
                            fontSize: 30,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: Colors.black38),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: client.color,
                          child: Text(
                            client.initials,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: GoogleFonts.poppins(
                                  color: ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                client.id,
                                style: GoogleFonts.poppins(
                                  color: muted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _DialogField(
                      label: 'Nombre completo',
                      hint: 'Nombre completo',
                      controller: nameController,
                    ),
                    const SizedBox(height: 16),
                    _DialogField(
                      label: 'Correo',
                      hint: 'correo@ejemplo.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _DialogField(
                      label: 'Pedidos',
                      hint: '0',
                      controller: ordersController,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estado',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF454545),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    InkWell(
                      onTap: () => setDialogState(() => active = !active),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFCFB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE3E1DE)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              active ? 'Activo' : 'Inactivo',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF353535),
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: const BorderSide(color: Color(0xFFE2DEDC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.poppins(
                                color: ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty ||
                                  emailController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa el nombre y el correo.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cliente actualizado correctamente.',
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: red,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Guardar cambios',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      ordersController.dispose();
    });
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: _EmployeeClientsScreenState.muted,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: _EmployeeClientsScreenState.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.optional = false,
    this.readOnly = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final bool optional;
  final bool readOnly;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF454545),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: _EmployeeClientsScreenState.red),
                ),
              if (optional)
                const TextSpan(
                  text: ' (opcional)',
                  style: TextStyle(
                    color: Color(0xFF9D9895),
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: readOnly
                ? const Color(0xFF9D9895)
                : const Color(0xFF353535),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: readOnly
                  ? const Color(0xFF9D9895)
                  : const Color(0xFF353535),
              fontSize: 16,
            ),
            filled: true,
            fillColor: readOnly
                ? AppColors.fieldFill
                : const Color(0xFFFCFCFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE3E1DE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: _EmployeeClientsScreenState.red),
            ),
          ),
        ),
        if (readOnly) ...[
          const SizedBox(height: 5),
          Text(
            'No se puede modificar',
            style: GoogleFonts.poppins(
              color: const Color(0xFF9D9895),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.active = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
      decoration: BoxDecoration(
        color: active ? AppColors.statGreenBg : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? AppColors.statGreenBorder : AppColors.statCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.iconCircleBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _EmployeeClientsScreenState.red,
              size: 21,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: active
                    ? AppColors.statGreenNumber
                    : _EmployeeClientsScreenState.ink,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: active
                  ? AppColors.statGreenLabel
                  : _EmployeeClientsScreenState.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE3DEDC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: _EmployeeClientsScreenState.ink,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: _EmployeeClientsScreenState.muted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.onView,
    required this.onEdit,
    required this.onToggle,
  });
  final _Client client;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E1DF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: client.color,
                child: Text(
                  client.initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            client.name,
                            style: GoogleFonts.poppins(
                              color: _EmployeeClientsScreenState.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            client.id,
                            style: GoogleFonts.poppins(
                              color: _EmployeeClientsScreenState.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      client.email,
                      style: GoogleFonts.poppins(
                        color: _EmployeeClientsScreenState.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: client.active
                      ? const Color(0xFFD2F8E5)
                      : const Color(0xFFF0F3F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  client.active ? 'Activo' : 'Inactivo',
                  style: GoogleFonts.poppins(
                    color: client.active
                        ? const Color(0xFF086E4C)
                        : _EmployeeClientsScreenState.muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                'Pedidos: ',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF91A3C0),
                  fontSize: 14,
                ),
              ),
              Text(
                '${client.orders}',
                style: GoogleFonts.poppins(
                  color: _EmployeeClientsScreenState.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onView,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: _EmployeeClientsScreenState.muted,
                  size: 21,
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _EmployeeClientsScreenState.muted,
                  size: 21,
                ),
              ),
              const SizedBox(width: 2),
              _ClientStatusSwitch(value: client.active, onTap: onToggle),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientStatusSwitch extends StatelessWidget {
  const _ClientStatusSwitch({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 40,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: IgnorePointer(
            child: Transform.scale(
              scale: 0.75,
              child: Switch(
                value: value,
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
}

class _Client {
  const _Client(
    this.name,
    this.email,
    this.id,
    this.orders,
    this.active,
    this.color,
  );
  final String name;
  final String email;
  final String id;
  final int orders;
  final bool active;
  final Color color;

  _Client copyWith({bool? active}) {
    return _Client(
      name,
      email,
      id,
      orders,
      active ?? this.active,
      color,
    );
  }

  String get initials => getInitials(name);
}
