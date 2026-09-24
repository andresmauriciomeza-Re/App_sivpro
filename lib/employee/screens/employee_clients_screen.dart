import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../../shared/page_transitions.dart';

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

  static const clients = [
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

  void _loadMore() {
    if (_visibleClients >= clients.length) return;
    setState(() {
      _visibleClients += _pageSize;
      if (_visibleClients > clients.length) _visibleClients = clients.length;
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
                    _buildBreadcrumb(),
                    const SizedBox(height: 4),
                    Text(
                      'Clientes',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'Usuarios registrados con tipo cliente en La Sirena',
                      style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.description_outlined,
                            label: 'Generar reporte',
                            onTap: () => _showComingSoon(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.person_add_alt_1_outlined,
                            label: 'Crear cliente',
                            filled: true,
                            onTap: () => _showCreateClientDialog(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '${clients.length}',
                            label: 'Total clientes',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value:
                                '${clients.where((c) => c.active).length}',
                            label: 'Activos',
                            active: true,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
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
                          child: _FilterButton(label: 'Todos los estados'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterButton(label: 'Ordenar por nombre'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LISTADO DE CLIENTES',
                          style: GoogleFonts.dmSerifDisplay(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_visibleClients >= clients.length ? clients.length : _visibleClients} DE ${clients.length}',
                          style: GoogleFonts.dmSerifDisplay(
                            color: muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...clients.take(_visibleClients).map(
                      (client) => _ClientCard(
                        client: client,
                        onView: () => _showClientDetail(context, client),
                        onEdit: () => _showEditClientDialog(context, client),
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
            style: GoogleFonts.dmSerifDisplay(color: red, fontSize: 24),
          ),
          const Spacer(),
          const Icon(Icons.nightlight_outlined, color: AppColors.red, size: 24),
          const SizedBox(width: 24),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: Text(
              getInitials('María González'),
              style: GoogleFonts.dmSerifDisplay(
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

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        const Icon(Icons.home_outlined, color: Color(0xFF91A0B8), size: 17),
        const SizedBox(width: 5),
        Text('Inicio', style: GoogleFonts.dmSerifDisplay(color: muted, fontSize: 14)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Icon(Icons.chevron_right, color: muted, size: 17),
        ),
        Text('clientes', style: GoogleFonts.dmSerifDisplay(color: ink, fontSize: 14)),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E1DF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8DA0BE), size: 23),
          const SizedBox(width: 14),
          Text(
            'Buscar por nombre, correo o estado...',
            style: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFF91A3C0),
              fontSize: 13,
            ),
          ),
        ],
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
                              style: GoogleFonts.dmSerifDisplay(
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta función estará disponible próximamente.'),
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
                          style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                        style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
                              color: ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.id,
                            style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
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
                          style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
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
                                style: GoogleFonts.dmSerifDisplay(
                                  color: ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                client.id,
                                style: GoogleFonts.dmSerifDisplay(
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
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estado',
                      style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
                              style: GoogleFonts.dmSerifDisplay(
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
            style: GoogleFonts.dmSerifDisplay(
              color: _EmployeeClientsScreenState.muted,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSerifDisplay(
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
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final bool optional;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.dmSerifDisplay(
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
          keyboardType: keyboardType,
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF353535),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSerifDisplay(
              color: const Color(0xFF353535),
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFFCFCFB),
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
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: filled ? Colors.white : _EmployeeClientsScreenState.ink,
          size: 20,
        ),
        label: Text(
          label,
          style: GoogleFonts.dmSerifDisplay(
            color: filled ? Colors.white : _EmployeeClientsScreenState.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? _EmployeeClientsScreenState.red : Colors.white,
          side: BorderSide(
            color: filled ? _EmployeeClientsScreenState.red : const Color(0xFFD7D1CF),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.active = false,
  });
  final String value;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0FFF7) : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? const Color(0xFF8DE9BD) : const Color(0xFFE5E0DE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              color: active
                  ? const Color(0xFF009C68)
                  : _EmployeeClientsScreenState.ink,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              color: active
                  ? const Color(0xFF167653)
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
              style: GoogleFonts.dmSerifDisplay(
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
  });
  final _Client client;
  final VoidCallback onView;
  final VoidCallback onEdit;

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
                  style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
                              color: _EmployeeClientsScreenState.muted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      client.email,
                      style: GoogleFonts.dmSerifDisplay(
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
                  style: GoogleFonts.dmSerifDisplay(
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
                style: GoogleFonts.dmSerifDisplay(
                  color: const Color(0xFF91A3C0),
                  fontSize: 14,
                ),
              ),
              Text(
                '${client.orders}',
                style: GoogleFonts.dmSerifDisplay(
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
              const SizedBox(width: 24),
              const Icon(
                Icons.sync,
                color: _EmployeeClientsScreenState.muted,
                size: 21,
              ),
            ],
          ),
        ],
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

  String get initials => getInitials(name);
}
