part of '../purchases_screen.dart';

/// Perfil del Administrador (pestaña principal). El cuerpo visual es el widget
/// compartido [ProfileBody]; aquí solo van el header, la barra inferior y las
/// reglas propias del rol Administrador.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Gloria Inés Vargas');
  final _emailController = TextEditingController(text: 'gloria@lasirena.com.co');
  final _phoneController = TextEditingController(text: '3001234567');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    _emailController.text = _emailController.text.trim();
    _phoneController.text = _phoneController.text.trim();
  }

  List<ProfileField> _buildFields() {
    return [
      ProfileField(
        icon: Icons.person_outline,
        label: 'Nombre completo',
        controller: _nameController,
        editable: false,
        note: 'Este campo no es editable',
      ),
      ProfileField(
        icon: Icons.mail_outline,
        label: 'Correo electrónico',
        controller: _emailController,
        editable: true,
        keyboardType: TextInputType.emailAddress,
      ),
      ProfileField(
        icon: Icons.phone_outlined,
        label: 'Número de teléfono',
        controller: _phoneController,
        editable: true,
        keyboardType: TextInputType.phone,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              initials: getInitials('Gloria Inés Vargas'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: ProfileBody(
                  name: 'Gloria Inés Vargas',
                  roleLabel: 'Administrador',
                  subtitle: 'Consulta y actualiza tu información de contacto',
                  fields: _buildFields(),
                  validate: () => null,
                  onSave: _saveProfile,
                  onSignOut: () => _confirmSignOut(context),
                  onGoHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  successMessage: 'Perfil actualizado correctamente.',
                  footerLines: const [
                    'La Sirena Pizza',
                    'S.I.V.PRO — Panel Administrativo',
                    '© 2026 La Sirena Pizza · Medellín, Colombia · Desde 1994',
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
      decoration: BoxDecoration(
        color: AppColors.page,
        border: Border(top: BorderSide(color: AppColors.headerDivider)),
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
                    size: 28,
                    color: i == 4 ? AppColors.red : AppColors.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4 ? AppColors.red : AppColors.muted,
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