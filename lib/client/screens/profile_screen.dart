import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import 'menu_screen.dart';
import '../../auth/login_screen.dart';
import '../../auth/auth_service.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  // Datos de la cuenta, tomados de la sesión real cuando existe.
  late final TextEditingController _nombreController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;

  bool _editando = false;

  @override
  void initState() {
    super.initState();
    final session = AuthService.instance;
    _nombreController = TextEditingController(
      text: session.currentName ?? 'Sebastián',
    );
    _correoController = TextEditingController(
      text: session.currentEmail ?? 'sebas@gmail.com',
    );
    _telefonoController = TextEditingController(text: '3109876543');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _cerrarSesion() {
    AuthService.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _regresarAlPanel() {
    AuthService.instance.endStoreSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi Perfil',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu información de cuenta',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ------------------------------------------------
              // Tarjeta de avatar + nombre
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: splashRojo,
                      child: Text(
                        _nombreController.text.isNotEmpty
                            ? getInitials(_nombreController.text)
                            : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _nombreController.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _editando = !_editando),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: Icon(
                                  _editando ? Icons.check : Icons.edit,
                                  size: 16,
                                ),
                                label: Text(
                                  _editando ? 'Listo' : 'Editar',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Cliente',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ------------------------------------------------
              // Datos de la cuenta
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campoLabel(Icons.person_outline, 'Nombre'),
                    const SizedBox(height: 6),
                    _campoEditable(_nombreController),
                    const SizedBox(height: 16),

                    _campoLabel(Icons.email_outlined, 'Correo electrónico'),
                    const SizedBox(height: 6),
                    _campoTexto(_correoController.text, habilitado: false),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Este campo no es editable',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: splashRojo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _campoLabel(Icons.phone_outlined, 'Teléfono'),
                    const SizedBox(height: 6),
                    _campoEditable(_telefonoController),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (AuthService.instance.fromPanel) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _regresarAlPanel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: splashRojo,
                      side: const BorderSide(color: splashRojo),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.dashboard_outlined, size: 16),
                    label: Text(
                      'Regresar al panel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          noAnimationRoute(const MenuScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(
                        'Volver al menú',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _cerrarSesion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 16),
                      label: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _campoLabel(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black),
        const SizedBox(width: 6),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _campoTexto(String valor, {required bool habilitado}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        valor,
        style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black54),
      ),
    );
  }

  Widget _campoEditable(TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: _editando,
      style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
