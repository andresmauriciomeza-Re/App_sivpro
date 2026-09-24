import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../services/employee_profile_service.dart';
import '../../shared/page_transitions.dart';

/// Perfil del Empleado (réplica del perfil del Administrador, con los campos
/// Nombre, Documento, Correo y Teléfono editables en modo edición).
class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);

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
      backgroundColor: const Color(0xFFFFFBFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context, profile),
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
                        Text('Mi perfil', style: _crumb(ink)),
                      ],
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Mi Perfil',
                      style: GoogleFonts.montserrat(
                        color: ink,
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
                    _profileCard(context, profile),
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

  Widget _header(BuildContext context, EmployeeProfile profile) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 29),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('La Sirena Pizza',
                    style: GoogleFonts.montserrat(
                        color: red,
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
                color: red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(getInitials(profile.fullName),
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, EmployeeProfile profile) {
    final editButton = FilledButton.icon(
      onPressed: _editing ? _saveProfile : _startEditing,
      icon: Icon(_editing ? Icons.check : Icons.edit_outlined, size: 18),
      label: Text(_editing ? 'Guardar' : 'Editar'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFD5262D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DFDD)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xFFD5262D),
                  child: Text(
                    getInitials(profile.fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              profile.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: ink,
                                fontSize: 21,
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
                          'Empleado',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFAD2525),
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
          const Divider(height: 1, color: Color(0xFFEDE8E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 18, 36, 28),
            child: Column(
              children: [
                _field(
                  icon: Icons.person_outline,
                  label: 'Nombre completo',
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 25),
                _field(
                  icon: Icons.badge_outlined,
                  label: 'Número de documento',
                  controller: _documentController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 25),
                _field(
                  icon: Icons.mail_outline,
                  label: 'Correo electrónico',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                _field(
                  icon: Icons.phone_outlined,
                  label: 'Número de teléfono',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
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
                        foregroundColor: ink,
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
                      onPressed: () =>
                          Navigator.of(context).popUntil((route) => route.isFirst),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al inicio'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5B514F),
                        backgroundColor: const Color(0xFFF7F6F6),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => confirmEmployeeSignOut(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC9151E),
                        side: const BorderSide(color: Color(0xFFFFBFC2)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
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
          Icon(icon, color: const Color(0xFF968D8B), size: 25),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFF5B514F),
              fontSize: 18,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: _editing,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            color: const Color(0xFF211616),
            fontSize: 18,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                _editing ? const Color(0xFFFFFEFE) : const Color(0xFFF8F5F4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE5DFDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE5DFDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFD5262D), width: 2),
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
                        onTap: index == 4
                            ? null
                            : () => handleEmployeeBottomNav(context, index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].$1,
                              color: index == 4
                                  ? red
                                  : const Color(0xFF756D6A),
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].$2,
                              style: GoogleFonts.poppins(
                                color: index == 4
                                    ? red
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