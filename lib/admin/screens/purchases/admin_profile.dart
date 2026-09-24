part of '../purchases_screen.dart';

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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                          child: Text(
                            'Inicio',
                            style: _crumb(const Color(0xFF9A9290)),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFFB9B0AE)),
                        Text('Mi perfil', style: _crumb(const Color(0xFF211616))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
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
                    const SizedBox(height: 24),
                    _profileCard(context),
                    const SizedBox(height: 40),
                    Center(
                      child: Text('La Sirena Pizza',
                          style: GoogleFonts.montserrat(
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
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFFD5262D),
                      child: Text(
                        getInitials('Gloria Inés Vargas'),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Gloria Inés Vargas',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF211616),
                                    fontSize: compact ? 21 : 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              editButton,
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
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
                ),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEDE8E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 18, 36, 28),
            child: Column(
              children: [
                _field(Icons.person_outline, 'Nombre completo',
                    _nameController,
                    enabled: false),
                const SizedBox(height: 18),
                _field(Icons.mail_outline, 'Correo electrónico', _emailController),
                const SizedBox(height: 18),
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
      (Icons.person_outline, 'Mi Perfil'),
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

