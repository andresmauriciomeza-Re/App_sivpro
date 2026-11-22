part of '../purchases_screen.dart';

/// Perfil del Administrador con los datos vigentes de la sesión.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _documentController;
  late final TextEditingController _documentTypeController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  Usuario? _usuario;
  String _savedEmail = '';
  String _savedPhone = '';
  bool _editing = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final usuario = AuthService.instance.usuario;
    _usuario = usuario;
    _nameController = TextEditingController(text: usuario?.nombre ?? '');
    _documentController = TextEditingController(
      text: usuario?.numeroDocumento ?? '',
    );
    _documentTypeController = TextEditingController(
      text: usuario?.tipoDocumento ?? '',
    );
    _emailController = TextEditingController(text: usuario?.correo ?? '');
    _phoneController = TextEditingController(text: usuario?.telefono ?? '');
    _savedEmail = _emailController.text;
    _savedPhone = _phoneController.text;
    _refrescarPerfil();
  }

  Future<void> _refrescarPerfil() async {
    try {
      final usuario = await AuthService.instance.refrescarPerfil();
      if (!mounted || _editing) return;
      setState(() => _actualizarCampos(usuario));
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _actualizarCampos(Usuario usuario) {
    _usuario = usuario;
    _nameController.text = usuario.nombre;
    _documentController.text = usuario.numeroDocumento;
    _documentTypeController.text = usuario.tipoDocumento;
    _emailController.text = usuario.correo;
    _phoneController.text = usuario.telefono;
    _savedEmail = usuario.correo;
    _savedPhone = usuario.telefono;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _documentTypeController.dispose();
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProfile() async {
    if (_guardando) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final errorContacto = validateProfileContact(email, phone);
    if (errorContacto != null) {
      _showMessage(errorContacto);
      return;
    }
    setState(() => _guardando = true);
    try {
      final usuario = await AuthService.instance.actualizarPerfil(
        correo: email,
        telefono: phone,
      );
      if (!mounted) return;
      setState(() {
        _actualizarCampos(usuario);
        _editing = false;
      });
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.montserrat(
                        color: AppColors.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tu información de contacto',
                      style: GoogleFonts.poppins(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _headerCard(),
                    const SizedBox(height: 12),
                    _fieldsCard(),
                    const SizedBox(height: 14),
                    _actions(),
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

  Widget _header() {
    final nombre = _usuario?.nombre ?? '';
    return AppHeader(title: 'La Sirena Pizza', initials: getInitials(nombre));
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.profileCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.red,
            child: Text(
              getInitials(_usuario?.nombre ?? ''),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _usuario?.nombre ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _usuario?.rol ?? '',
                  style: GoogleFonts.poppins(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _guardando
                ? null
                : (_editing ? _saveProfile : _startEditing),
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(_editing ? Icons.check : Icons.edit_outlined, size: 16),
            label: Text(
              _guardando ? 'Guardando' : (_editing ? 'Guardar' : 'Editar'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.profileCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            icon: Icons.person_outline,
            label: 'Nombre completo',
            controller: _nameController,
            keyboardType: TextInputType.text,
            editable: false,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.badge_outlined,
            label: 'Número de documento',
            controller: _documentController,
            keyboardType: TextInputType.number,
            editable: false,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.badge_outlined,
            label: 'Tipo de documento',
            controller: _documentTypeController,
            keyboardType: TextInputType.text,
            editable: false,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.mail_outline,
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            editable: true,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.phone_outlined,
            label: 'Número de teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            editable: true,
            inputFormatters: profilePhoneFormatters(),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required bool editable,
    List<TextInputFormatter> inputFormatters = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.profileLabelIcon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.profileLabel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: _editing && editable,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.poppins(color: AppColors.ink, fontSize: 14.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: _editing && editable
                ? AppColors.profileFieldFillActive
                : AppColors.profileFieldFill,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    if (_editing) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _guardando ? null : _cancelEditing,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Cancelar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.profileLabel,
              backgroundColor: AppColors.buttonSoftBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.logOutBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'La Sirena Pizza – S.I.V.PRO',
            style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Versión 2.1.4',
            style: GoogleFonts.poppins(color: AppColors.muted, fontSize: 11),
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.only(top: 9, bottom: 8),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: i == 4 ? null : () => navigateToBottomModule(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    size: 25,
                    color: i == 4 ? AppColors.red : AppColors.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4 ? AppColors.red : AppColors.muted,
                      fontSize: 10,
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
