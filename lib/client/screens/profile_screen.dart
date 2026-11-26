import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';
import '../../network/api_exception.dart';
import '../../shared/initials.dart';
import '../../shared/modo_oscuro_controller.dart';
import '../../shared/tarjeta_modo_oscuro.dart';
import '../../shared/validators.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import 'menu_screen.dart';
import '../../auth/login_screen.dart';
import '../widgets/bottom_nav.dart';
import '../../shared/mensaje_app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _Perfil());
}

/// Cuerpo del perfil, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Perfil extends StatefulWidget {
  const _Perfil();

  @override
  State<_Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<_Perfil> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  late final TextEditingController _nombreController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;

  Usuario? _usuario;
  bool _editando = false;
  bool _guardando = false;
  String _correoGuardado = '';
  String _telefonoGuardado = '';

  @override
  void initState() {
    super.initState();
    final usuario = AuthService.instance.usuario;
    _usuario = usuario;
    _nombreController = TextEditingController(text: usuario?.nombre ?? '');
    _correoController = TextEditingController(text: usuario?.correo ?? '');
    _telefonoController = TextEditingController(text: usuario?.telefono ?? '');
    _correoGuardado = _correoController.text;
    _telefonoGuardado = _telefonoController.text;
    _refrescarPerfil();
  }

  Future<void> _refrescarPerfil() async {
    try {
      final usuario = await AuthService.instance.refrescarPerfil();
      if (!mounted || _editando) return;
      setState(() => _actualizarCampos(usuario));
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _actualizarCampos(Usuario usuario) {
    _usuario = usuario;
    _nombreController.text = usuario.nombre;
    _correoController.text = usuario.correo;
    _telefonoController.text = usuario.telefono;
    _correoGuardado = usuario.correo;
    _telefonoGuardado = usuario.telefono;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).mostrarMensaje(message, tipo: TipoMensaje.error, sobreBarraPanel: false);
  }

  void _iniciarEdicion() {
    setState(() => _editando = true);
  }

  void _cancelarEdicion() {
    setState(() {
      _correoController.text = _correoGuardado;
      _telefonoController.text = _telefonoGuardado;
      _editando = false;
    });
  }

  Future<void> _guardarPerfil() async {
    if (_guardando) return;
    FocusScope.of(context).unfocus();
    final correo = _correoController.text.trim().toLowerCase();
    final telefono = _telefonoController.text.trim();
    // Mismas reglas que PUT /auth/perfil: correo de hasta 60 caracteres con
    // el formato del backend y teléfono de 7 a 15 dígitos.
    final errorContacto = correo.isEmpty
        ? 'El correo es obligatorio'
        : telefono.isEmpty
        ? 'El teléfono es obligatorio'
        : emailValidator(correo) ?? phoneValidator(telefono);
    if (errorContacto != null) {
      _showMessage(errorContacto);
      return;
    }
    setState(() => _guardando = true);
    try {
      final usuario = await AuthService.instance.actualizarPerfil(
        correo: correo,
        telefono: telefono,
      );
      if (!mounted) return;
      setState(() {
        _actualizarCampos(usuario);
        _editando = false;
      });
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    await AuthService.instance.logout();
    if (!mounted) return;
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
      backgroundColor: context.pal.fondo(fondoClaro),
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
                  color: context.pal.texto(Colors.black87),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu información de cuenta',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: context.pal.texto(Colors.black),
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
                  color: context.pal.tarjeta(Colors.white),
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
                                    color: context.pal.texto(Colors.black87),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _guardando
                                    ? null
                                    : (_editando
                                          ? _guardarPerfil
                                          : _iniciarEdicion),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.pal.texto(
                                    Colors.black,
                                  ),
                                  side: BorderSide(
                                    color: context.pal.borde(Colors.black12),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: Icon(
                                  _guardando
                                      ? Icons.hourglass_top
                                      : (_editando ? Icons.check : Icons.edit),
                                  size: 16,
                                ),
                                label: Text(
                                  _guardando
                                      ? 'Guardando'
                                      : (_editando ? 'Guardar' : 'Editar'),
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
                              color: context.pal.campo(Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _usuario?.rol ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.pal.texto(Colors.black),
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
                  color: context.pal.tarjeta(Colors.white),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campoLabel(Icons.person_outline, 'Nombre'),
                    const SizedBox(height: 6),
                    _campoTexto(_nombreController.text),
                    const SizedBox(height: 16),
                    _campoLabel(Icons.badge_outlined, 'Tipo de documento'),
                    const SizedBox(height: 6),
                    _campoTexto(_usuario?.tipoDocumento ?? ''),
                    const SizedBox(height: 16),

                    _campoLabel(Icons.badge_outlined, 'Número de documento'),
                    const SizedBox(height: 6),
                    _campoTexto(_usuario?.numeroDocumento ?? ''),
                    const SizedBox(height: 16),

                    _campoLabel(Icons.email_outlined, 'Correo electrónico'),
                    const SizedBox(height: 6),
                    _campoEditable(
                      _correoController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 60,
                    ),
                    const SizedBox(height: 16),

                    _campoLabel(Icons.phone_outlined, 'Teléfono'),
                    const SizedBox(height: 6),
                    _campoEditable(
                      _telefonoController,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: ModoOscuroController.instance.oscuro,
                builder: (context, oscuro, _) => TarjetaModoOscuro(
                  oscuro: oscuro,
                  onChanged: ModoOscuroController.instance.cambiar,
                  radio: 16,
                  bordeEnClaro: false,
                ),
              ),
              const SizedBox(height: 20),

              if (_editando) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _guardando ? null : _cancelarEdicion,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (AuthService.instance.fromPanel) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _regresarAlPanel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.pal.rojo(splashRojo),
                      side: BorderSide(color: context.pal.rojo(splashRojo)),
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
                        foregroundColor: context.pal.texto(Colors.black87),
                        side: BorderSide(
                          color: context.pal.borde(Colors.black12),
                        ),
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
                        foregroundColor: context.pal.texto(Colors.black),
                        side: BorderSide(
                          color: context.pal.borde(Colors.black12),
                        ),
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
        Icon(icon, size: 14, color: context.pal.texto(Colors.black)),
        const SizedBox(width: 6),
        Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.pal.secundario(Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _campoTexto(String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.pal.campo(const Color(0xFFF2F2F2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        valor,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          color: context.pal.secundario(Colors.black54),
        ),
      ),
    );
  }

  Widget _campoEditable(
    TextEditingController controller, {
    required TextInputType keyboardType,
    required int maxLength,
    List<TextInputFormatter> inputFormatters = const [],
  }) {
    return TextField(
      controller: controller,
      enabled: _editando,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        fontSize: 13.5,
        color: context.pal.texto(Colors.black87),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.pal.campo(const Color(0xFFF2F2F2)),
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
