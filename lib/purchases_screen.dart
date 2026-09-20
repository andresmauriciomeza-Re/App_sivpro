import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Está seguro de que desea cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Color(0xFFC9151E),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

void navigateToBottomModule(BuildContext context, int index) {
  if (index == 0) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  final Widget destination = switch (index) {
    1 => const PurchasesScreen(),
    2 => const _ProductionScreen(),
    3 => const SalesScreen(),
    4 => const MoreOptionsScreen(),
    _ => const PurchasesScreen(),
  };

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => route.isFirst,
  );
}

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  static const Color red = Color(0xFFC62828);
  static const Color ink = Color(0xFF261B1A);
  static const Color muted = Color(0xFF6E5A58);
  static const Color page = Color(0xFFFFFBFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compras',
                      style: GoogleFonts.dmSerifDisplay(
                        color: ink,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seleccione un módulo para administrar',
                      style: GoogleFonts.dmSerifDisplay(
                        color: muted,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _ModuleCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Compras',
                      description:
                          'Registrar y consultar órdenes de compra a proveedores.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PurchaseManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ModuleCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Insumos',
                      description:
                          'Control de inventario, stock bajo y actualización de unidades.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _SupplyManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ModuleCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Proveedores',
                      description:
                          'Directorio de contactos, estados e historial de distribuidores.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProviderManagementScreen(),
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
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: muted, size: 28),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0ECEB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8E1118),
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(top: 9, bottom: 8),
      decoration: const BoxDecoration(
        color: page,
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
                    color: i == 1 ? red : muted,
                    size: 27,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1 ? red : muted,
                      fontSize: 12,
                      fontWeight: i == 1 ? FontWeight.w700 : FontWeight.w400,
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
                            style: GoogleFonts.robotoMono(
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
                            style: GoogleFonts.robotoMono(
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
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Seleccione el módulo que desea gestionar.',
                        style: GoogleFonts.poppins(
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
          border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: PurchasesScreen.red, size: 29),
            ),
            Expanded(
              child: Text(
                'La Sirena Pizza',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFAD0E14),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.search,
              color: PurchasesScreen.muted,
              size: 32,
            ),
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 14, right: 14),
              decoration: const BoxDecoration(
                color: PurchasesScreen.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'GI',
                style: GoogleFonts.poppins(
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
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: GoogleFonts.robotoMono(
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
        (Icons.more_horiz, 'Más'),
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
                      style: GoogleFonts.poppins(
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

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  static const _red = Color(0xFFC9151E);
  static const _ink = Color(0xFF211616);
  static const _muted = Color(0xFF6E5A58);
  static const _page = Color(0xFFFFFBFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Más opciones',
                      style: GoogleFonts.dmSerifDisplay(
                        color: _ink,
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 38),
                    _optionsCard(context),
                    const SizedBox(height: 48),
                    Center(
                      child: Text(
                        'La Sirena Pizza – S.I.V.PRO',
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Versión 2.1.4',
                        style: GoogleFonts.robotoMono(
                          color: _muted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: _muted, size: 29),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _red,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              'GI',
              style: GoogleFonts.poppins(
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

  Widget _optionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _page,
        border: Border.all(color: const Color(0xFFE5BDB9)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 38, 24, 34),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: _red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'GI',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
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
                        'Gloria Inés Vargas',
                        style: GoogleFonts.poppins(
                          color: _ink,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Administrador',
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E2E1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'S.I.V.PRO',
                          style: GoogleFonts.poppins(
                            color: _muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _optionTile(
            icon: Icons.analytics_outlined,
            title: 'Reportes e Informes',
            onTap: () => _showComingSoon(context, 'Reportes e Informes'),
          ),
          _optionTile(
            icon: Icons.person_outline,
            title: 'Perfil',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          InkWell(
            onTap: () => _confirmSignOut(context),
            child: Container(
              height: 84,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: _red, size: 31),
                  const SizedBox(width: 25),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.poppins(color: _red, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
        ),
        child: Row(
          children: [
            Icon(icon, color: _muted, size: 29),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: _ink, fontSize: 20),
              ),
            ),
            const Icon(Icons.chevron_right, color: _muted, size: 30),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$item estará disponible próximamente.')),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
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
            GestureDetector(
              onTap: () => navigateToBottomModule(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].$1,
                    size: 27,
                    color: i == 4 ? _red : _muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4 ? _red : _muted,
                      fontSize: 11,
                      fontWeight: i == 4 ? FontWeight.w700 : FontWeight.w400,
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nameController =
      TextEditingController(text: 'Gloria Inés Vargas');
  final _emailController =
      TextEditingController(text: 'gloria@lasirena.com.co');
  final _phoneController = TextEditingController(text: '3001234567');
  String _savedEmail = 'gloria@lasirena.com.co';
  String _savedPhone = '3001234567';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _savedEmail = _emailController.text;
      _savedPhone = _phoneController.text;
      _editing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _emailController.text = _savedEmail;
      _phoneController.text = _savedPhone;
      _editing = false;
    });
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    setState(() {
      _savedEmail = _emailController.text.trim();
      _savedPhone = _phoneController.text.trim();
      _emailController.text = _savedEmail;
      _phoneController.text = _savedPhone;
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Inicio', style: _crumb(const Color(0xFF9A9290))),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFFB9B0AE)),
                        Text('Mi perfil', style: _crumb(const Color(0xFF211616))),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.dmSerifDisplay(
                        color: const Color(0xFF211616),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Consulta y actualiza tu información de contacto',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF776D6A),
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _profileCard(context),
                    const SizedBox(height: 56),
                    Center(
                      child: Text('La Sirena Pizza',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF5B514F), fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text('S.I.V.PRO — Panel Administrativo',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFFAAA19F), fontSize: 15)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text('© 2026 La Sirena Pizza · Medellín, Colombia · Desde 1994',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: const Color(0xFFAAA19F), fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  TextStyle _crumb(Color color) => GoogleFonts.poppins(
        color: color,
        fontSize: 16,
        fontWeight: color == const Color(0xFF211616)
            ? FontWeight.w600
            : FontWeight.w400,
      );

  Widget _header(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8)))),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5B514F), size: 29),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('La Sirena Pizza',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFC9151E),
                        fontSize: 23,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
                color: Color(0xFFC9151E), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('G',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DFDD)),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;
              final avatarRadius = compact ? 42.0 : 51.0;
              final topContent = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: const Color(0xFFD5262D),
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 31 : 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 14 : 25),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gloria Inés Vargas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSerifDisplay(
                            color: const Color(0xFF211616),
                            fontSize: compact ? 21 : 26,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Administrador',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFAD2525),
                              fontSize: compact ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final editButton = FilledButton.icon(
                onPressed: _editing ? _saveProfile : _startEditing,
                icon: Icon(
                  _editing ? Icons.check : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(_editing ? 'Guardar' : 'Editar'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD5262D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                ),
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 18 : 30,
                  compact ? 22 : 28,
                  compact ? 18 : 28,
                  compact ? 22 : 28,
                ),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          topContent,
                          const SizedBox(height: 14),
                          editButton,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: topContent),
                          const SizedBox(width: 14),
                          editButton,
                        ],
                      ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEDE8E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 28, 36, 28),
            child: Column(
              children: [
                _field(Icons.person_outline, 'Nombre completo',
                    _nameController,
                    enabled: false),
                const SizedBox(height: 25),
                _field(Icons.mail_outline, 'Correo electrónico', _emailController),
                const SizedBox(height: 25),
                _field(Icons.phone_outlined, 'Número de teléfono', _phoneController),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDE8E7)),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                if (_editing) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _cancelEditing,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF211616),
                        side: const BorderSide(color: Color(0xFFE5BDB9)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar cambios'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD5262D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al inicio'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5B514F),
                        backgroundColor: const Color(0xFFF7F6F6),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC9151E),
                        side: const BorderSide(color: Color(0xFFFFBFC2)),
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(IconData icon, String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: const Color(0xFF968D8B), size: 25),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF5B514F), fontSize: 18)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled && _editing,
          style: GoogleFonts.poppins(
              color: const Color(0xFF211616), fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled && _editing
                ? const Color(0xFFFFFEFE)
                : const Color(0xFFF8F5F4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE5DFDD))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE5DFDD))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                    color: Color(0xFFD5262D), width: 2)),
          ),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 7),
            child: Text('Este campo no es editable',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFAAA19F), fontSize: 14)),
          ),
      ],
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_bag_outlined, 'Compras'),
      (Icons.inventory_2_outlined, 'Producción'),
      (Icons.bar_chart_outlined, 'Ventas'),
      (Icons.more_horiz, 'Más'),
    ];
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEBCBC8)))),
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
                    size: 28,
                    color: i == 4
                        ? const Color(0xFFC9151E)
                        : const Color(0xFFAAA19F),
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4
                          ? const Color(0xFFC9151E)
                          : const Color(0xFFAAA19F),
                      fontSize: 11,
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
      user: 'María González',
      date: '2024-01-15',
      payment: 'Nequi',
      paymentColor: Color(0xFFEDE2FF),
      status: 'Venta',
    ),
    const _Sale(
      id: 'VEN-002',
      user: 'Carlos Martínez',
      date: '2024-01-15',
      payment: 'Bancolombia',
      paymentColor: Color(0xFFFFF2B8),
      status: 'Venta',
    ),
    const _Sale(
      id: 'VEN-003',
      user: 'Ana Rodríguez',
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
      status: 'Pérdida',
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
      user: 'Luis Pérez',
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
      user: 'Diego Ramírez',
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
                      'Gestión Ventas',
                      style: GoogleFonts.dmSerifDisplay(
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
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: PurchasesScreen.red, size: 27),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFFAD0E14),
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
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: GoogleFonts.poppins(
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

  TextStyle _breadcrumbStyle(Color color) => GoogleFonts.poppins(
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
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: PurchasesScreen.ink,
          size: 28,
        ),
        hintText: 'Buscar por ID, usuario o producto...',
        hintStyle: GoogleFonts.poppins(
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
    final isLoss = sale.status == 'Pérdida';
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
                      style: GoogleFonts.robotoMono(
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

  TextStyle _labelStyle() => GoogleFonts.robotoMono(
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
          style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
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
        PopupMenuItem(value: 'Pérdida', child: Text('Pérdida')),
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
              style: GoogleFonts.poppins(
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

    if (status == 'Pérdida' && sale.status == 'Venta') {
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
            '¿Estás seguro de cambiar el estado\nde "Venta" a "Pérdida"?',
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

class _SaleDetailScreen extends StatelessWidget {
  const _SaleDetailScreen({required this.sale});

  final _Sale sale;

  @override
  Widget build(BuildContext context) {
    final isLoss = sale.status == 'Pérdida';
    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 74,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBCBC8)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: PurchasesScreen.red,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Detalle de Venta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.red,
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
      style: GoogleFonts.robotoMono(
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
                    color: isLoss
                        ? const Color(0xFFFFE9EC)
                        : const Color(0xFFE6F5E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.status,
                    style: GoogleFonts.poppins(
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

  TextStyle _detailLabelStyle() => GoogleFonts.robotoMono(
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
                style: GoogleFonts.robotoMono(
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
                style: GoogleFonts.robotoMono(
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

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() =>
      _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> {
  String _query = '';

  static const _providers = [
    _Provider(
      'PROV-001',
      'Distribuidora La Cosecha',
      '+57 300 123 4567',
      'ventas@lacosecha.com',
      'Calle 45 # 12-34, Zona Industrial',
      true,
    ),
    _Provider(
      'PROV-002',
      'Lácteos El Buen Pastor',
      '+57 311 987 6543',
      'pedidos@buenpastor.co',
      'Cra 22 # 8-15, Centro',
      true,
    ),
    _Provider(
      'PROV-003',
      'Empaques del Norte SAS',
      '+57 320 555 4433',
      'contacto@empaquesnorte.com',
      'Autopista Norte Km 5, Bodega 4',
      false,
    ),
    _Provider(
      'PROV-004',
      'Harinas y Cereales S.A.',
      '+57 601 234 5678',
      'proveedores@harinas.com',
      'Av. Boyacá # 72-10',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase().trim();
    final filtered = _providers.where((provider) {
      return provider.id.toLowerCase().contains(query) ||
          provider.name.toLowerCase().contains(query) ||
          provider.email.toLowerCase().contains(query);
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
                padding: const EdgeInsets.fromLTRB(20, 42, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_providers.length} proveedores registrados',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID, nombre o email...',
                        hintStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.muted,
                          size: 28,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FBFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: PurchasesScreen.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (final provider in filtered) ...[
                      _buildProviderCard(provider),
                      const SizedBox(height: 20),
                    ],
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            'No se encontraron proveedores.',
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.muted,
                            ),
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
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'Gestión Proveedor',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0ECEB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GIV',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8E1118),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(_Provider provider) {
    final color = provider.active
        ? const Color(0xFF16813A)
        : const Color(0xFFD04444);
    final background = provider.active
        ? const Color(0xFFE2F3E5)
        : const Color(0xFFFFE6E8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0DCDC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EEED),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            provider.id,
                            style: GoogleFonts.robotoMono(
                              color: PurchasesScreen.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            provider.active ? 'ACTIVO' : 'INACTIVO',
                            style: GoogleFonts.poppins(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.name,
                      style: GoogleFonts.poppins(
                        color: provider.active
                            ? PurchasesScreen.ink
                            : PurchasesScreen.muted,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _providerInfo(Icons.phone_outlined, provider.phone),
                    _providerInfo(Icons.mail_outline, provider.email),
                    _providerInfo(Icons.location_on_outlined, provider.address),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _providerAction(
                          Icons.visibility_outlined,
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ProviderDetailScreen(
                                provider: provider,
                              ),
                            ),
                          ),
                        ),
                        _providerAction(
                          Icons.edit_outlined,
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ProviderEditScreen(
                                provider: provider,
                              ),
                            ),
                          ),
                        ),
                        _providerAction(
                          Icons.delete_outline,
                          () => _showDeleteProviderDialog(provider),
                        ),
                      ],
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

  Widget _providerInfo(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, color: PurchasesScreen.muted, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerAction(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: PurchasesScreen.muted, size: 27),
      tooltip: 'Acción',
    );
  }

  Future<void> _showDeleteProviderDialog(_Provider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: PurchasesScreen.page,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: PurchasesScreen.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Eliminar proveedor',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 17,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Seguro que deseas eliminar al proveedor\n',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EEED),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFE8C7C4),
                            ),
                          ),
                          child: Text(
                            provider.id,
                            style: GoogleFonts.robotoMono(
                              color: PurchasesScreen.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: '? Esta acción no se puede deshacer.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurchasesScreen.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Sí, confirmar',
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE8C7C4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
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

    if (!mounted || confirmed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${provider.id} eliminado correctamente.')),
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
                  Icon(
                    items[i].$1,
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
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

class _Provider {
  const _Provider(
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.active,
  );

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool active;
}

class _ProviderDetailScreen extends StatelessWidget {
  const _ProviderDetailScreen({required this.provider});

  final _Provider provider;

  @override
  Widget build(BuildContext context) {
    final statusColor = provider.active
        ? const Color(0xFF16813A)
        : const Color(0xFFD04444);
    final statusBackground = provider.active
        ? const Color(0xFFE2F3E5)
        : const Color(0xFFFFE6E8);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Detalle',
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '—',
                          style: TextStyle(
                            color: PurchasesScreen.muted,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          provider.id,
                          style: GoogleFonts.robotoMono(
                            color: PurchasesScreen.muted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8C7C4)),
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Proveedor', provider.id, mono: true),
                          _detailRow('Nombre', provider.name),
                          _detailRow(
                            'Teléfono',
                            provider.phone,
                            accent: true,
                          ),
                          _detailRow(
                            'Email',
                            provider.email,
                            accent: true,
                          ),
                          _detailRow('Dirección', provider.address),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Estado',
                                    style: GoogleFonts.poppins(
                                      color: PurchasesScreen.muted,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    '• ${provider.active ? 'Activo' : 'Inactivo'}',
                                    style: GoogleFonts.robotoMono(
                                      color: statusColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
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
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PurchasesScreen.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool mono = false,
    bool accent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE3DAD8))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: mono
                  ? GoogleFonts.robotoMono(
                      color: PurchasesScreen.ink,
                      fontSize: 15,
                    )
                  : GoogleFonts.poppins(
                      color: accent
                          ? const Color(0xFF9B2931)
                          : PurchasesScreen.ink,
                      fontSize: 16,
                      height: 1.35,
                      decoration: accent
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
        color: PurchasesScreen.page,
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
                  color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
                ),
                Text(
                  items[i].$2,
                  style: GoogleFonts.poppins(
                    color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted,
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

class _ProviderEditScreen extends StatefulWidget {
  const _ProviderEditScreen({required this.provider});

  final _Provider provider;

  @override
  State<_ProviderEditScreen> createState() => _ProviderEditScreenState();
}

class _ProviderEditScreenState extends State<_ProviderEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.provider.name);
    _phoneController = TextEditingController(text: widget.provider.phone);
    _emailController = TextEditingController(text: widget.provider.email);
    _addressController = TextEditingController(text: widget.provider.address);
    _isActive = widget.provider.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8C7C4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Proveedor',
                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFE4C4C1)),
                      const SizedBox(height: 22),
                      _buildStatusField(),
                      const SizedBox(height: 28),
                      _buildField(
                        label: 'NOMBRE DE EMPRESA / CONTACTO',
                        controller: _nameController,
                        icon: Icons.storefront_outlined,
                      ),
                      _buildField(
                        label: 'TELÉFONO PRINCIPAL',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildField(
                        label: 'CORREO ELECTRÓNICO',
                        controller: _emailController,
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildField(
                        label: 'DIRECCIÓN FÍSICA',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(context),
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
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 30,
            ),
          ),
          Text(
            'Editar',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '—',
            style: TextStyle(color: PurchasesScreen.muted, fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            widget.provider.id,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.muted,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8C7C4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.radio_button_checked,
            color: PurchasesScreen.muted,
            size: 29,
          ),
          const SizedBox(width: 14),
          Text(
            'Estado',
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: _isActive,
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: true, child: Text('Activo')),
                DropdownMenuItem(value: false, child: Text('Inactivo')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _isActive = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.ink,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: PurchasesScreen.muted, size: 28),
              filled: true,
              fillColor: const Color(0xFFF7F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 17,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE5BCB9), width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: PurchasesScreen.red,
                side: const BorderSide(color: PurchasesScreen.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.provider.name} actualizado correctamente.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PurchasesScreen.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Guardar',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplyManagementScreen extends StatelessWidget {
  const _SupplyManagementScreen();

  static const _supplies = [
    _Supply(
      'INS-004',
      'CINS-004',
      'Harinas y Masas',
      'Masa Pre-elaborada',
      'und',
      50,
      20,
      '\$3.500',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-005',
      'CINS-003',
      'Vegetales y Hierbas',
      'Champiñones',
      'kg',
      4,
      5,
      '\$12.000',
      _SupplyStatus.low,
    ),
    _Supply(
      'INS-006',
      'CINS-001',
      'Carnes y Proteínas',
      'Pechuga de pollo',
      'kg',
      18,
      10,
      '\$18.500',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-007',
      'CINS-002',
      'Lácteos',
      'Queso mozzarella',
      'kg',
      25,
      12,
      '\$24.000',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-008',
      'CINS-005',
      'Salsas',
      'Salsa de tomate',
      'lt',
      14,
      8,
      '\$8.900',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-009',
      'CINS-006',
      'Vegetales y Hierbas',
      'Pimentón rojo',
      'kg',
      7,
      8,
      '\$6.500',
      _SupplyStatus.low,
    ),
    _Supply(
      'INS-010',
      'CINS-007',
      'Condimentos',
      'Orégano seco',
      'kg',
      6,
      3,
      '\$15.000',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-011',
      'CINS-008',
      'Empaques',
      'Caja para pizza',
      'und',
      120,
      50,
      '\$1.200',
      _SupplyStatus.ok,
    ),
    _Supply(
      'INS-012',
      'CINS-009',
      'Bebidas',
      'Gaseosa personal',
      'und',
      36,
      20,
      '\$2.800',
      _SupplyStatus.ok,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lowCount = _supplies
        .where((supply) => supply.status == _SupplyStatus.low)
        .length;
    final emptyCount = _supplies
        .where((supply) => supply.status == _SupplyStatus.empty)
        .length;

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 86, 17, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _summaryChip(
                          '${_supplies.length}',
                          'Total insumos',
                          const Color(0xFFE8C7C4),
                        ),
                        const SizedBox(width: 8),
                        _summaryChip(
                          '$lowCount',
                          'Stock bajo',
                          const Color(0xFFF5D9A5),
                        ),
                        const SizedBox(width: 8),
                        _summaryChip(
                          '$emptyCount',
                          'Agotados',
                          const Color(0xFFF4C8CF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    for (final supply in _supplies) ...[
                      _buildSupplyCard(context, supply),
                      const SizedBox(height: 16),
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
      height: 50,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(
    String count,
    String label,
    Color borderColor,
  ) {
    final isWarning = label == 'Stock bajo';
    final isEmpty = label == 'Agotados';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFFFF3DF)
            : isEmpty
                ? const Color(0xFFFFE8EB)
                : PurchasesScreen.page,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.dmSerifDisplay(
            color: isWarning
                ? const Color(0xFFB65D0A)
                : isEmpty
                    ? PurchasesScreen.red
                    : PurchasesScreen.ink,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$count ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard(BuildContext context, _Supply supply) {
    final isLow = supply.status == _SupplyStatus.low;
    final isEmpty = supply.status == _SupplyStatus.empty;
    final statusColor = isLow || isEmpty
        ? PurchasesScreen.red
        : const Color(0xFF3D824B);
    final statusBackground = isLow || isEmpty
        ? const Color(0xFFFFE8EB)
        : const Color(0xFFE3F2E5);

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8D6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                supply.id,
                style: GoogleFonts.robotoMono(
                  color: PurchasesScreen.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${supply.categoryId} • ${supply.category}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  isLow
                      ? 'Stock\nbajo'
                      : isEmpty
                          ? 'Agotado'
                          : 'O\nK',
                  style: GoogleFonts.dmSerifDisplay(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            supply.name,
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Unidad: ${supply.unit}',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 12,
            ),
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: 'Stock actual: '),
                      TextSpan(
                        text: '${supply.current} ${supply.unit}',
                        style: TextStyle(
                          color: isLow ? PurchasesScreen.red : PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '\nStock mín.: '),
                      TextSpan(
                        text: '${supply.minimum} ${supply.unit}',
                        style: const TextStyle(
                          color: PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Precio unit.',
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    supply.price,
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _supplyAction(
                Icons.visibility_outlined,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _SupplyDetailScreen(supply: supply),
                  ),
                ),
              ),
              _supplyAction(
                Icons.delete_outline,
                () => _showDeleteSupplyDialog(context, supply),
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _supplyAction(
    IconData icon,
    VoidCallback onPressed, {
    bool danger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: danger
              ? const Color(0xFFFFD8D8)
              : const Color(0xFFF8F5F4),
        ),
        icon: Icon(
          icon,
          color: danger ? PurchasesScreen.red : PurchasesScreen.muted,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _showDeleteSupplyDialog(
    BuildContext context,
    _Supply supply,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: PurchasesScreen.page,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: PurchasesScreen.red,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Eliminar insumo',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Seguro que deseas eliminar el insumo ',
                      ),
                      TextSpan(
                        text: supply.id,
                        style: GoogleFonts.robotoMono(
                          color: PurchasesScreen.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text: '? Esta acción no se puede deshacer.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PurchasesScreen.ink,
                      side: const BorderSide(color: Color(0xFFE8C7C4)),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurchasesScreen.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Eliminar',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${supply.id} eliminado correctamente.')),
      );
    }
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
                  Icon(
                    items[i].$1,
                    color: i == 1
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1
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

enum _SupplyStatus { ok, low, empty }

class _Supply {
  const _Supply(
    this.id,
    this.categoryId,
    this.category,
    this.name,
    this.unit,
    this.current,
    this.minimum,
    this.price,
    this.status,
  );

  final String id;
  final String categoryId;
  final String category;
  final String name;
  final String unit;
  final int current;
  final int minimum;
  final String price;
  final _SupplyStatus status;
}

class _SupplyDetailScreen extends StatelessWidget {
  const _SupplyDetailScreen({required this.supply});

  final _Supply supply;

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
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1D8D6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Detalle',
                            style: GoogleFonts.dmSerifDisplay(
                              color: PurchasesScreen.ink,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '—',
                            style: TextStyle(
                              color: PurchasesScreen.muted,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            supply.id,
                            style: GoogleFonts.robotoMono(
                              color: PurchasesScreen.muted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _supplyDetailRow('ID Insumo', supply.id, mono: true),
                      _supplyDetailRow(
                        'ID Cat. Insumo',
                        '${supply.categoryId} — ${supply.category}',
                      ),
                      _supplyDetailRow('Nombre', supply.name),
                      _supplyDetailRow('Unidad Medida', supply.unit),
                      _supplyDetailRow(
                        'Stock Actual',
                        '${supply.current} ${supply.unit}',
                      ),
                      _supplyDetailRow(
                        'Stock Mínimo',
                        '${supply.minimum} ${supply.unit}',
                      ),
                      _supplyDetailRow('Precio Unitario', supply.price),
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
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _supplyDetailRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E0DE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.robotoMono(
                      color: PurchasesScreen.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                    ),
            ),
          ),
        ],
      ),
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
                  Icon(
                    items[i].$1,
                    color: i == 1
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 1
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

class _ProductionOrdersScreen extends StatefulWidget {
  const _ProductionOrdersScreen();

  @override
  State<_ProductionOrdersScreen> createState() => _ProductionOrdersScreenState();
}

class _ProductionOrdersScreenState extends State<_ProductionOrdersScreen> {
  String _query = '';

  static const _orders = [
    _ProductionOrder('ORD-001', 'REC-001', 'Margarita Clásica', '2024-01-15', '19:00', 20, 'Completada'),
    _ProductionOrder('ORD-002', 'REC-002', 'Pepperoni Premium', '2024-01-15', '20:30', 15, 'En Proceso'),
    _ProductionOrder('ORD-003', 'REC-003', 'Cuatro Quesos', '2024-01-16', '18:00', 10, 'Pendiente'),
    _ProductionOrder('ORD-004', 'REC-004', 'Especial La Sirena', '2024-01-16', '21:00', 0, 'Cancelada'),
    _ProductionOrder('ORD-005', 'REC-005', 'Vegetariana', '2024-01-17', '17:30', 12, 'Pendiente'),
  ];

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = _orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
          order.recipeId.toLowerCase().contains(query) ||
          order.recipe.toLowerCase().contains(query);
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
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden Producción',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_orders.length} órdenes registradas',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID orden o receta...',
                        hintStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.ink,
                          size: 28,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F5F4),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE8C7C4)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: PurchasesScreen.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: PurchasesScreen.ink, size: 26),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
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
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(_ProductionOrder order) {
    final statusColor = _statusColor(order.status);
    final statusBackground = _statusBackground(order.status);
    final isCancelled = order.status == 'Cancelada';

    return Opacity(
      opacity: isCancelled ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: PurchasesScreen.page,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE1D8D6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _orderLabel('ID ORDEN'),
                      const SizedBox(height: 5),
                      Text(
                        order.id,
                        style: GoogleFonts.robotoMono(
                          color: PurchasesScreen.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _orderLabel('CANT. PRODUCIDA'),
                    const SizedBox(height: 5),
                    Text(
                      '${order.quantity}',
                      style: GoogleFonts.robotoMono(
                        color: PurchasesScreen.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _orderLabel('RECETA'),
                        const SizedBox(height: 7),
                        Text(
                          order.recipeId,
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          order.recipe,
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.muted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _orderLabel('FECHA & HORA'),
                        const SizedBox(height: 7),
                        Text(
                          '▣  ${order.date}',
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.ink,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '◷  ${order.time}',
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.ink,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                GestureDetector(
                  onTap: isCancelled
                      ? null
                      : () => _showChangeOrderStatusDialog(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.status,
                          style: GoogleFonts.robotoMono(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isCancelled) const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ProductionOrderDetailScreen(order: order),
                    ),
                  ),
                  child: _orderAction(Icons.visibility_outlined),
                ),
                GestureDetector(
                  onTap: isCancelled
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  _ProductionOrderEditScreen(order: order),
                            ),
                          ),
                  child: _orderAction(Icons.edit_outlined, disabled: isCancelled),
                ),
                GestureDetector(
                  onTap: isCancelled ? null : () => _showDeleteOrderDialog(order),
                  child: _orderAction(
                    Icons.delete_outline,
                    disabled: isCancelled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.robotoMono(
        color: PurchasesScreen.muted,
        fontSize: 11,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _orderAction(IconData icon, {bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Icon(
        icon,
        color: disabled ? const Color(0xFFB9ADAA) : PurchasesScreen.muted,
        size: 25,
      ),
    );
  }

  Future<void> _showChangeOrderStatusDialog(_ProductionOrder order) async {
    const statuses = ['Pendiente', 'En Proceso', 'Completada', 'Cancelada'];
    final nextStatus = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        var selectedStatus = order.status;

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
        backgroundColor: PurchasesScreen.page,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar estado de la orden',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: PurchasesScreen.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD4F7E9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: PurchasesScreen.red),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: PurchasesScreen.red),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                items: [
                  for (final status in statuses)
                    DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF087A65),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
                onChanged: (status) {
                  if (status != null) {
                    setState(() => selectedStatus = status);
                  }
                },
              ),
              if (selectedStatus != order.status) ...[
                const SizedBox(height: 18),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF9800),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'La orden ${order.id} pasará de:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.muted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statusPill(order.status)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 24),
                    ),
                    Expanded(child: _statusPill(selectedStatus)),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PurchasesScreen.red,
                        side: const BorderSide(color: PurchasesScreen.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedStatus == order.status
                          ? null
                          : () => Navigator.of(dialogContext).pop(selectedStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PurchasesScreen.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirmar',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
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
          ),
        );
      },
    );

    if (mounted && nextStatus != null && nextStatus != order.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} cambió a "$nextStatus".')),
      );
    }
  }

  Widget _statusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor(status).withAlpha(80)),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: _statusColor(status),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showDeleteOrderDialog(_ProductionOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar orden'),
        content: Text(
          '¿Seguro que deseas eliminar la orden ${order.id}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PurchasesScreen.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (mounted && confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${order.id} eliminada correctamente.')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E8B3C);
      case 'En Proceso':
        return const Color(0xFF806A68);
      case 'Pendiente':
        return const Color(0xFFB84B00);
      default:
        return PurchasesScreen.red;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFFB9F5B8);
      case 'En Proceso':
        return const Color(0xFFEDE6E4);
      case 'Pendiente':
        return const Color(0xFFF8D0A9);
      default:
        return const Color(0xFFFFE0E3);
    }
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
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

class _ProductionOrder {
  const _ProductionOrder(
    this.id,
    this.recipeId,
    this.recipe,
    this.date,
    this.time,
    this.quantity,
    this.status,
  );

  final String id;
  final String recipeId;
  final String recipe;
  final String date;
  final String time;
  final int quantity;
  final String status;
}

class _ProductionOrderDetailScreen extends StatelessWidget {
  const _ProductionOrderDetailScreen({required this.order});

  final _ProductionOrder order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final statusBackground = _statusBackground(order.status);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 28, 30, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            '←  Volver a Producción',
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.page,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    Text(
                      'Detalle',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '—',
                          style: TextStyle(
                            color: PurchasesScreen.muted,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          order.id,
                          style: GoogleFonts.robotoMono(
                            color: PurchasesScreen.ink,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 18, 28, 18),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE1D8D6)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _detailRow('ID Orden', order.id, mono: true),
                          _detailRow(
                            'ID Receta',
                            '${order.recipeId} — ${order.recipe}',
                          ),
                          _detailRow('Fecha Entrega', order.date),
                          _detailRow('Hora Entrega', order.time),
                          _detailRow('Inicio de Producción', _startTime(order.time)),
                          _detailRow(
                            'Cantidad Producida',
                            '${order.quantity} und.',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Estado Orden',
                                    style: GoogleFonts.poppins(
                                      color: PurchasesScreen.muted,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: GoogleFonts.poppins(
                                      color: statusColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F4F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Observación',
                                  style: GoogleFonts.poppins(
                                    color: PurchasesScreen.muted,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  order.status == 'Completada'
                                      ? 'Turno mañana sin novedades.'
                                      : 'Pendiente de actualización.',
                                  style: GoogleFonts.poppins(
                                    color: PurchasesScreen.ink,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 74),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE8C7C4)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
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
      height: 60,
      color: PurchasesScreen.page,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.muted,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GV',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE1D8D6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.robotoMono(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _startTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final startHour = (hour - 1).toString().padLeft(2, '0');
    return '$startHour:${parts.length > 1 ? parts[1] : '00'}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFF2E8B3C);
      case 'En Proceso':
        return const Color(0xFF806A68);
      case 'Pendiente':
        return const Color(0xFFB84B00);
      default:
        return PurchasesScreen.red;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Completada':
        return const Color(0xFFE3F2E5);
      case 'En Proceso':
        return const Color(0xFFEDE6E4);
      case 'Pendiente':
        return const Color(0xFFF8D0A9);
      default:
        return const Color(0xFFFFE0E3);
    }
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
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

class _ProductionOrderEditScreen extends StatefulWidget {
  const _ProductionOrderEditScreen({required this.order});

  final _ProductionOrder order;

  @override
  State<_ProductionOrderEditScreen> createState() =>
      _ProductionOrderEditScreenState();
}

class _ProductionOrderEditScreenState
    extends State<_ProductionOrderEditScreen> {
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _observationController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.order.date);
    _timeController = TextEditingController(text: widget.order.time);
    _quantityController =
        TextEditingController(text: '${widget.order.quantity}');
    _observationController = TextEditingController(
      text: widget.order.status == 'Completada'
          ? 'Turno mañana sin novedades.'
          : 'Pendiente de actualización.',
    );
    _status = widget.order.status;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _quantityController.dispose();
    _observationController.dispose();
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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          '—',
                          style: TextStyle(
                            color: PurchasesScreen.muted,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.order.id,
                          style: GoogleFonts.robotoMono(
                            color: PurchasesScreen.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8C7C4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editLabel('ID RECETA *'),
                          _readOnlyField(
                            '${widget.order.recipeId} — ${widget.order.recipe}',
                            Icons.menu_book_outlined,
                          ),
                          _editLabel('INICIO DE PRODUCCIÓN'),
                          _readOnlyField(
                            'Inicio: ${_startTime(widget.order.time)}   (20 min antes de ${widget.order.time})',
                            Icons.access_time,
                          ),
                          _editLabel('FECHA DE ENTREGA *'),
                          _textField(_dateController, Icons.calendar_today_outlined),
                          _editLabel('HORA DE ENTREGA (HH:MM) *'),
                          _textField(_timeController, Icons.access_time),
                          _editLabel('CANTIDAD PRODUCIDA'),
                          _textField(
                            _quantityController,
                            null,
                            keyboardType: TextInputType.number,
                          ),
                          _editLabel('ESTADO ORDEN'),
                          _statusField(),
                          _editLabel('OBSERVACIÓN'),
                          TextField(
                            controller: _observationController,
                            maxLines: 4,
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 17,
                            ),
                            decoration: _fieldDecoration(null),
                          ),
                          const SizedBox(height: 22),
                          const Divider(color: Color(0xFFE8C7C4)),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.order.id} actualizado correctamente.',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurchasesScreen.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.ink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
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
      height: 60,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.muted,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GV',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          color: PurchasesScreen.muted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _readOnlyField(String value, IconData icon) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _fieldDecoration(icon),
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 17),
    );
  }

  Widget _textField(
    TextEditingController controller,
    IconData? icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _fieldDecoration(icon),
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 17),
    );
  }

  InputDecoration _fieldDecoration(IconData? icon) {
    return InputDecoration(
      prefixIcon: icon == null ? null : Icon(icon, color: PurchasesScreen.muted),
      filled: true,
      fillColor: const Color(0xFFF7F3F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE4DEDC)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: PurchasesScreen.red),
      ),
    );
  }

  Widget _statusField() {
    return DropdownButtonFormField<String>(
      initialValue: _status,
      items: const [
        DropdownMenuItem(value: 'Completada', child: Text('Completada')),
        DropdownMenuItem(value: 'En Proceso', child: Text('En Proceso')),
        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _status = value);
      },
      decoration: _fieldDecoration(Icons.expand_more),
    );
  }

  String _startTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    return '${(hour - 1).toString().padLeft(2, '0')}:${parts.length > 1 ? parts[1] : '00'}';
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
        color: PurchasesScreen.page,
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
                  color: i == 2
                      ? PurchasesScreen.red
                      : PurchasesScreen.muted,
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
        ],
      ),
    );
  }
}

class _Product {
  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String imagePath;
}

class _ProductManagementScreen extends StatefulWidget {
  const _ProductManagementScreen();

  @override
  State<_ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<_ProductManagementScreen> {
  final _searchController = TextEditingController();
  final _products = const [
    _Product(
      id: 'PROD-001',
      name: 'Margarita Clásica',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 24000,
      stock: 50,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-002',
      name: 'Pepperoni Premium',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 28000,
      stock: 40,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-003',
      name: 'Cuatro Quesos',
      category: 'CAT-002 - Pizzas Especiales',
      price: 30000,
      stock: 30,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-004',
      name: 'Especial La Sirena',
      category: 'CAT-002 - Pizzas Especiales',
      price: 32000,
      stock: 25,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-005',
      name: 'Veggie Mediterránea',
      category: 'CAT-003 - Pizzas Vegetarianas',
      price: 26000,
      stock: 20,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredProducts = _products
        .where(
          (product) =>
              product.id.toLowerCase().contains(query) ||
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
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
                padding: const EdgeInsets.fromLTRB(23, 26, 23, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión Producto',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_products.length} productos registrados',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID, nombre o categoría...',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6E7587),
                          fontSize: 18,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.muted,
                          size: 30,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFFBFA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                          horizontal: 14,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE5BDB9)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: PurchasesScreen.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    for (final product in filteredProducts) ...[
                      _productCard(product),
                      const SizedBox(height: 22),
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
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: PurchasesScreen.red),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFFAD0E14),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF0ECEB),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8E1118),
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(_Product product) {
    final isLowStock = product.stock <= 25;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 14),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5BDB9)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE8B66A),
                    alignment: Alignment.center,
                    child: const Text(
                      'Pizza',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _productTag(product.id),
                        Text(
                          product.category,
                          style: GoogleFonts.poppins(
                            color: PurchasesScreen.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5BDB9), height: 1),
          ),
          Row(
            children: [
              Text(
                '\$${_formatPrice(product.price)}',
                style: GoogleFonts.robotoMono(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductDetailScreen(product: product),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                  size: 29,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductEditScreen(product: product),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: PurchasesScreen.muted,
                  size: 29,
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteProductDialog(product),
                icon: const Icon(
                  Icons.delete_outline,
                  color: PurchasesScreen.red,
                  size: 29,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: isLowStock
                      ? PurchasesScreen.red
                      : const Color(0xFF167B27),
                  size: 21,
                ),
                const SizedBox(width: 6),
                Text(
                  'Stock: ${product.stock}',
                  style: GoogleFonts.poppins(
                    color: isLowStock
                        ? PurchasesScreen.red
                        : const Color(0xFF167B27),
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

  Widget _productTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECEB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          color: PurchasesScreen.ink,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  Future<void> _showDeleteProductDialog(_Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: PurchasesScreen.page,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 28, 25, 26),
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD9D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: PurchasesScreen.red,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Eliminar producto',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.black,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text: '¿Seguro que deseas eliminar el producto ',
                        ),
                        TextSpan(
                          text: '${product.id}?',
                          style: GoogleFonts.robotoMono(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(
                          text: ' Esta acción no se puede deshacer.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5BDB9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PurchasesScreen.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Sí, confirmar',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: PurchasesScreen.muted,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (mounted && confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.id} eliminado correctamente.')),
      );
    }
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
                  color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
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
        ],
      ),
    );
  }
}

class _ProductDetailScreen extends StatelessWidget {
  const _ProductDetailScreen({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    final categoryParts = product.category.split(' - ');
    final categoryId = categoryParts.first;
    final categoryName = categoryParts.length > 1
        ? categoryParts.sublist(1).join(' - ')
        : product.category;

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _productAppHeader(context),
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Detalle',
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '—',
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.id,
                    style: GoogleFonts.robotoMono(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE5BDB9)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _detailSection(
                        'ID PRODUCTO',
                        product.id,
                        valueStyle: GoogleFonts.robotoMono(
                          color: PurchasesScreen.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _detailSection(
                        'NOMBRE',
                        product.name,
                        valueStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _detailSection(
                        'ID CATEGORÍA',
                        '$categoryId  -  $categoryName',
                        icon: Icons.category_outlined,
                        valueColor: PurchasesScreen.red,
                      ),
                      _detailSection(
                        'PRECIO UNITARIO',
                        '\$${_formatPrice(product.price)}',
                        valueStyle: GoogleFonts.robotoMono(
                          color: PurchasesScreen.red,
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: const Color(0xFFF9F5F4),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _detailValueColumn(
                                'UNIDAD DE VENTA',
                                'und',
                                GoogleFonts.poppins(
                                  color: PurchasesScreen.ink,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            _detailValueColumn(
                              'STOCK',
                              '${product.stock} und',
                              GoogleFonts.robotoMono(
                                color: PurchasesScreen.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              valueBackground: const Color(0xFFE9E7E6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 72,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PurchasesScreen.red,
                    side: const BorderSide(
                      color: PurchasesScreen.red,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _productAppHeader(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(
    String label,
    String value, {
    IconData? icon,
    TextStyle? valueStyle,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 23),
      decoration: BoxDecoration(
        color: backgroundColor ?? PurchasesScreen.page,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5BDB9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.muted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: PurchasesScreen.muted, size: 23),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ??
                      GoogleFonts.poppins(
                        color: valueColor ?? PurchasesScreen.ink,
                        fontSize: 20,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailValueColumn(
    String label,
    String value,
    TextStyle valueStyle, {
    Color? valueBackground,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: PurchasesScreen.muted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: valueBackground == null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: valueBackground == null
              ? null
              : BoxDecoration(
                  color: valueBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
          child: Text(value, style: valueStyle),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }
}

class _ProductEditScreen extends StatefulWidget {
  const _ProductEditScreen({required this.product});

  final _Product product;

  @override
  State<_ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<_ProductEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _category = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      'CAT-001 - Pizzas Clásicas',
      'CAT-002 - Pizzas Especiales',
      'CAT-003 - Pizzas Vegetarianas',
    ];

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _productAppHeader(context),
            _buildEditTitleHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(27, 28, 27, 28),
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0D9D7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Nombre *'),
                      _textField(_nameController),
                      const SizedBox(height: 28),
                      _fieldLabel('Imagen del producto'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_outlined),
                              label: const Text('Subir archivo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.ink,
                                side: const BorderSide(
                                  color: Color(0xFFE5BDB9),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _textField(
                              TextEditingController(
                                text: 'https://image...',
                              ),
                              hintText: 'URL de imagen',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.product.imagePath,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black87,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _fieldLabel('ID Categoría *'),
                      _dropdownField(
                        value: _category,
                        items: categories,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 26),
                      _fieldLabel('Precio unitario (COP)'),
                      _textField(
                        _priceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 26),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Unidad de venta'),
                                _dropdownField(
                                  value: 'und',
                                  items: const ['und', 'kg', 'l'],
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Stock disponible'),
                                _textField(
                                  _stockController,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.red,
                                side: const BorderSide(
                                  color: PurchasesScreen.red,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurchasesScreen.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
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
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _productAppHeader(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTitleHeader() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            'Editar',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '—',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 23,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.product.id,
            style: GoogleFonts.robotoMono(
              color: PurchasesScreen.ink,
              fontSize: 17,
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
          color: PurchasesScreen.muted,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: PurchasesScreen.ink,
        fontSize: 21,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 17,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down),
      style: GoogleFonts.robotoMono(
        color: PurchasesScreen.ink,
        fontSize: 18,
      ),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xFFF7F8F9),
        contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 17),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
      ],
    );
  }

  void _saveProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.id} actualizado correctamente.'),
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
                  color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
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
        ],
      ),
    );
  }
}

class _ProductionScreen extends StatelessWidget {
  const _ProductionScreen();

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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Producción',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seleccione el módulo que desea gestionar.',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _productionCard(
                      icon: Icons.assignment_outlined,
                      title: 'Orden Producción',
                      description:
                          'Gestione las órdenes de producción diarias y su estado de preparación.',
                      highlighted: false,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _ProductionOrdersScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _productionCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Productos',
                      description:
                          'Administre el catálogo de productos disponibles para la producción y venta.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _ProductManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 72),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(36, 34, 36, 36),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFE8C7C4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de Hoy',
                            style: GoogleFonts.poppins(
                              color: PurchasesScreen.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: _summaryValue(
                                  'ÓRDENES ACTIVAS',
                                  '12',
                                  PurchasesScreen.red,
                                ),
                              ),
                              Expanded(
                                child: _summaryValue(
                                  'COMPLETADAS',
                                  '45',
                                  const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
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
            icon: const Icon(
              Icons.arrow_back,
              color: PurchasesScreen.ink,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GV',
              style: GoogleFonts.poppins(
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

  Widget _productionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(36, 36, 30, 32),
        decoration: BoxDecoration(
          color: PurchasesScreen.page,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE8C7C4), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -64,
              right: -42,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2C9CA),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9E8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: PurchasesScreen.ink,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.muted,
                    fontSize: 18,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryValue(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: PurchasesScreen.muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.dmSerifDisplay(color: color, fontSize: 42),
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
                  Icon(
                    items[i].$1,
                    color: i == 2
                        ? PurchasesScreen.red
                        : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2
                          ? FontWeight.w700
                          : FontWeight.w400,
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 288,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 36, 26, 28),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8C7C4), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -72,
            right: -58,
            child: Container(
              width: 164,
              height: 164,
              decoration: const BoxDecoration(
                color: Color(0xFFF2C9CA),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9E8),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: Colors.black87,
                  size: 38,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.muted,
                  fontSize: 19,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() =>
      _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  String _query = '';

  static const _purchases = [
    _Purchase('COM-001', 'Distribuidora La Cosecha', '2024-01-10', '\$119.000', 'Enviado'),
    _Purchase('COM-002', 'Carnes Premium Ltda.', '2024-01-12', '\$178.500', 'En Proceso'),
    _Purchase('COM-003', 'Quesos del Norte S.A.S.', '2024-01-14', '\$59.500', 'Enviado'),
    _Purchase('COM-004', 'Distribuidora La Cosecha', '2024-01-15', '\$238.000', 'Anulado'),
    _Purchase('COM-005', 'Bebidas y Más', '2024-01-16', '\$89.250', 'En Proceso'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _purchases.where((purchase) {
      final query = _query.toLowerCase();
      return purchase.id.toLowerCase().contains(query) ||
          purchase.provider.toLowerCase().contains(query);
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
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión Compras',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_purchases.length} compras registradas',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID o proveedor...',
                        hintStyle: GoogleFonts.poppins(color: PurchasesScreen.ink),
                        prefixIcon: const Icon(Icons.search, color: PurchasesScreen.ink),
                        filled: true,
                        fillColor: const Color(0xFFFFFBFA),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE8DDDB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...filtered.map(_buildPurchaseCard),
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
      height: 48,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: PurchasesScreen.muted),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: const Color(0xFF8E1118),
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFD9565C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'GI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(_Purchase purchase) {
    final statusColor = purchase.status == 'Enviado'
        ? const Color(0xFF2E7D32)
        : purchase.status == 'Anulado'
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE67E00);
    final statusBackground = purchase.status == 'Enviado'
        ? const Color(0xFFE4F4E7)
        : purchase.status == 'Anulado'
            ? const Color(0xFFFFE3E6)
            : const Color(0xFFFFF0D8);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDDB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('ID COMPRA'),
                  Text(purchase.id, style: GoogleFonts.robotoMono(fontSize: 18)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${purchase.status} ⌄',
                  style: GoogleFonts.poppins(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('PROVEEDOR'), Text(purchase.provider)],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('FECHA'), Text(purchase.date)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE8DDDB)),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('TOTAL'),
                  Text(
                    purchase.total,
                    style: GoogleFonts.robotoMono(
                      color: PurchasesScreen.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _PurchaseDetailScreen(purchase: purchase),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.robotoMono(
          color: PurchasesScreen.muted,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      );

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
                  Icon(items[i].$1, color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted),
                  Text(items[i].$2, style: GoogleFonts.poppins(color: i == 1 ? PurchasesScreen.red : PurchasesScreen.muted, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Purchase {
  const _Purchase(this.id, this.provider, this.date, this.total, this.status);

  final String id;
  final String provider;
  final String date;
  final String total;
  final String status;
}

class _PurchaseDetailScreen extends StatelessWidget {
  const _PurchaseDetailScreen({required this.purchase});

  final _Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final isReceived = purchase.status == 'Recibido';
    final statusColor = purchase.status == 'Enviado'
        ? const Color(0xFF2E7D32)
        : purchase.status == 'Anulado'
            ? const Color(0xFFD32F2F)
            : const Color(0xFFE67E00);
    final statusBackground = purchase.status == 'Enviado'
        ? const Color(0xFFE4F4E7)
        : purchase.status == 'Anulado'
            ? const Color(0xFFFFE3E6)
            : const Color(0xFFFFF0D8);

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, statusColor, statusBackground),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFB7D1F5)),
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: GoogleFonts.dmSerifDisplay(
                            color: const Color(0xFF304A72),
                            fontSize: 16,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(text: 'ⓘ   Esta gestión proviene de la '),
                            TextSpan(
                              text: 'Orden de Compra ${purchase.id}.',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  ' Las cantidades solicitadas son de solo lectura; solo puedes editar las cantidades recibidas cuando el estado sea Recibido.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 52),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _detailValue('PROVEEDOR', purchase.provider)),
                        Expanded(child: _detailValue('FECHA', purchase.date)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailLabel('ESTADO'),
                              const SizedBox(height: 10),
                              _statusChip(
                                purchase.status,
                                statusColor,
                                statusBackground,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'INSUMOS SOLICITADOS VS. RECIBIDOS',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildSuppliesTable(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: BoxDecoration(
                        color: PurchasesScreen.page,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8DDDB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'USAR LOTES',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Registra fecha de vencimiento por insumo (calculada automáticamente: recepción + 7 días)',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: PurchasesScreen.muted,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isReceived,
                            onChanged: isReceived ? (_) {} : null,
                            activeThumbColor: PurchasesScreen.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(context, isReceived),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color statusColor,
    Color statusBackground,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Compra · ${purchase.id}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Vinculada a Orden de Compra: ${purchase.id} · ${purchase.provider}',
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _statusChip(purchase.status, statusColor, statusBackground),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: PurchasesScreen.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliesTable() {
    const rows = [
      ('INS-001', 'Harina de trigo', '100', '0', 'kg', '\$ 3.500'),
      ('INS-006', 'Levadura', '5000', '0', 'g', '\$ 80'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDDB)),
      ),
      child: Column(
        children: [
          const _SupplyRow(
            values: ['ID', 'NOMBRE', 'SOLIC.', 'RECIB.', 'UNIDAD', 'P. UNIT.'],
            header: true,
          ),
          for (final row in rows)
            _SupplyRow(values: [row.$1, row.$2, row.$3, row.$4, row.$5, row.$6]),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'TOTAL RECIBIDO',
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isReceived) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      decoration: const BoxDecoration(
        color: PurchasesScreen.page,
        border: Border(top: BorderSide(color: Color(0xFFE8DDDB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showChangeStatusDialog(context, 'Anulado'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PurchasesScreen.red,
                side: const BorderSide(color: PurchasesScreen.red),
              ),
              child: const Text('Anular Compra'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isReceived
                  ? null
                  : () => _showChangeStatusDialog(context, 'Recibido'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Recibido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008F63),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeStatusDialog(
    BuildContext context,
    String targetStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: PurchasesScreen.red,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cambiar estado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSerifDisplay(
                    color: PurchasesScreen.ink,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 17,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿Deseas cambiar el estado de la compra\n',
                      ),
                      TextSpan(
                        text: purchase.id,
                        style: const TextStyle(
                          color: PurchasesScreen.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' a "$targetStatus"?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PurchasesScreen.ink,
                      side: const BorderSide(color: PurchasesScreen.muted),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PurchasesScreen.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sí, confirmar',
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
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

    if (!context.mounted || confirmed != true) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${purchase.id} cambió a "$targetStatus" correctamente.',
        ),
      ),
    );
  }

  Widget _detailValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_detailLabel(label), const SizedBox(height: 8), Text(value)],
    );
  }

  Widget _detailLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.robotoMono(
        color: PurchasesScreen.muted,
        fontSize: 12,
      ),
    );
  }

  Widget _statusChip(String text, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: GoogleFonts.poppins(color: color, fontSize: 12)),
    );
  }
}

class _SupplyRow extends StatelessWidget {
  const _SupplyRow({required this.values, this.header = false});

  final List<String> values;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8DDDB))),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              flex: i == 1 ? 2 : 1,
              child: Text(
                values[i],
                style: GoogleFonts.dmSerifDisplay(
                  color: PurchasesScreen.ink,
                  fontSize: header ? 12 : 13,
                  fontWeight: header ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
