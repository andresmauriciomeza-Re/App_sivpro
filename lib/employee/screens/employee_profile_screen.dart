import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../services/employee_profile_service.dart';
import '../../shared/page_transitions.dart';

/// Perfil del Empleado (estilo compacto similar al perfil del Cliente, con los
/// campos Nombre, Documento, Correo y Teléfono editables en modo edición).
class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _documentController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  String _savedName = '';
  String _savedDocument = '';
  String _savedEmail = '';
  String _savedPhone = '';
  bool _editing = false;

  static final _emailRegExp = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
  static final _digitsRegExp = RegExp(r'^[0-9]+$');

  @override
  void initState() {
    super.initState();
    final p = EmployeeProfileService.instance.profile;
    _nameController = TextEditingController(text: p.fullName);
    _documentController = TextEditingController(text: p.documentNumber);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _savedName = p.fullName;
    _savedDocument = p.documentNumber;
    _savedEmail = p.email;
    _savedPhone = p.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _savedName = _nameController.text;
      _savedDocument = _documentController.text;
      _savedEmail = _emailController.text;
      _savedPhone = _phoneController.text;
      _editing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _nameController.text = _savedName;
      _documentController.text = _savedDocument;
      _emailController.text = _savedEmail;
      _phoneController.text = _savedPhone;
      _editing = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final doc = _documentController.text
        .trim()
        .replaceAll(RegExp(r'[\s\-]'), '');
    final email = _emailController.text.trim();
    final phone = _phoneController.text
        .trim()
        .replaceAll(RegExp(r'[\s\-]'), '');

    if (name.isEmpty || doc.isEmpty || email.isEmpty || phone.isEmpty) {
      _showMessage('Todos los campos son obligatorios');
      return;
    }
    if (!_emailRegExp.hasMatch(email)) {
      _showMessage('Ingresa un correo electrónico válido');
      return;
    }
    if (!_digitsRegExp.hasMatch(doc)) {
      _showMessage('El número de documento solo puede contener números');
      return;
    }
    if (!_digitsRegExp.hasMatch(phone)) {
      _showMessage('El número de teléfono solo puede contener números');
      return;
    }

    EmployeeProfileService.instance.update(
      fullName: name,
      documentNumber: doc,
      email: email,
      phone: phone,
    );
    setState(() {
      _nameController.text = name;
      _documentController.text = doc;
      _emailController.text = email;
      _phoneController.text = phone;
      _savedName = name;
      _savedDocument = doc;
      _savedEmail = email;
      _savedPhone = phone;
      _editing = false;
    });
    _showMessage('Perfil actualizado correctamente');
  }

  @override
  Widget build(BuildContext context) {
    final profile = EmployeeProfileService.instance.profile;
    return Scaffold(
      backgroundColor: AppColors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(profile),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.dmSerifDisplay(
                        color: AppColors.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tu información de contacto',
                      style: GoogleFonts.dmSerifDisplay(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _headerCard(context, profile),
                    const SizedBox(height: 12),
                    _fieldsCard(context),
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

  Widget _header(EmployeeProfile profile) {
    return AppHeader(
      title: 'La Sirena Pizza',
      initials: getInitials(profile.fullName),
    );
  }

  Widget _headerCard(BuildContext context, EmployeeProfile profile) {
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
              getInitials(profile.fullName),
              style: GoogleFonts.dmSerifDisplay(
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
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Empleado',
                  style: GoogleFonts.dmSerifDisplay(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _editing ? _saveProfile : _startEditing,
            icon: Icon(_editing ? Icons.check : Icons.edit_outlined, size: 16),
            label: Text(_editing ? 'Guardar' : 'Editar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.pillBorder),
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: GoogleFonts.dmSerifDisplay(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldsCard(BuildContext context) {
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
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.badge_outlined,
            label: 'Número de documento',
            controller: _documentController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.mail_outline,
            label: 'Correo electrónico',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _field(
            icon: Icons.phone_outlined,
            label: 'Número de teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: AppColors.profileLabelIcon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.profileLabel,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: _editing,
          keyboardType: keyboardType,
          style: GoogleFonts.dmSerifDisplay(
            color: AppColors.ink,
            fontSize: 14.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                _editing ? AppColors.profileFieldFillActive : AppColors.profileFieldFill,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
          onPressed: _cancelEditing,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Cancelar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: GoogleFonts.dmSerifDisplay(
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
              textStyle: GoogleFonts.dmSerifDisplay(
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
            onPressed: () => confirmEmployeeSignOut(context),
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.logOutBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: GoogleFonts.dmSerifDisplay(
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
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Versión 2.1.4',
            style: GoogleFonts.dmSerifDisplay(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomNavigation(BuildContext context) {
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
                  top: BorderSide(color: AppColors.red, width: 1),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: InkWell(
                        onTap: index == 4
                            ? null
                            : () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].$1,
                              color: index == 4
                                  ? AppColors.red
                                  : const Color(0xFF756D6A),
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.poppins(
                                color: index == 4
                                    ? AppColors.red
                                    : const Color(0xFF756D6A),
                                fontSize: 10,
                                height: 1,
                                fontWeight: index == 4
                                    ? FontWeight.w700
                                    : FontWeight.w400,
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
}