import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../../shared/profile_body.dart';
import '../../theme/app_colors.dart';
import '../services/employee_profile_service.dart';

/// Perfil del Empleado (pestaña principal). El cuerpo visual es el widget
/// compartido [ProfileBody]; aquí solo van el header, la barra inferior y las
/// reglas propias del rol Empleado.
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validate() {
    final name = _nameController.text.trim();
    final doc = _documentController.text
        .trim()
        .replaceAll(RegExp(r'[\s\-]'), '');
    final email = _emailController.text.trim();
    final phone = _phoneController.text
        .trim()
        .replaceAll(RegExp(r'[\s\-]'), '');

    if (name.isEmpty || doc.isEmpty || email.isEmpty || phone.isEmpty) {
      return 'Todos los campos son obligatorios';
    }
    if (!_emailRegExp.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }
    if (!_digitsRegExp.hasMatch(doc)) {
      return 'El número de documento solo puede contener números';
    }
    if (!_digitsRegExp.hasMatch(phone)) {
      return 'El número de teléfono solo puede contener números';
    }
    return null;
  }

  void _saveProfile() {
    EmployeeProfileService.instance.update(
      fullName: _nameController.text,
      documentNumber: _documentController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
  }

  List<ProfileField> _buildFields() {
    return [
      ProfileField(
        icon: Icons.person_outline,
        label: 'Nombre completo',
        controller: _nameController,
        editable: true,
        keyboardType: TextInputType.text,
      ),
      ProfileField(
        icon: Icons.badge_outlined,
        label: 'Número de documento',
        controller: _documentController,
        editable: true,
        keyboardType: TextInputType.number,
        normalize: (value) => value.trim().replaceAll(RegExp(r'[\s\-]'), ''),
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
        normalize: (value) => value.trim().replaceAll(RegExp(r'[\s\-]'), ''),
      ),
    ];
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
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: getInitials(profile.fullName),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: ProfileBody(
                  name: profile.fullName,
                  roleLabel: 'Empleado',
                  subtitle: 'Tu información de contacto',
                  fields: _buildFields(),
                  validate: _validate,
                  onSave: _saveProfile,
                  onSignOut: () => confirmEmployeeSignOut(context),
                  onGoHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  successMessage: 'Perfil actualizado correctamente.',
                  footerLines: const [
                    'La Sirena Pizza',
                    'S.I.V.PRO — Aplicación Móvil',
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
                              style: GoogleFonts.dmSerifDisplay(
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