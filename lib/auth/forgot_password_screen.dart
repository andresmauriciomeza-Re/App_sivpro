// forgot_password_screen.dart
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../network/api_exception.dart';
import '../shared/page_transitions.dart';
import '../shared/validators.dart';
import 'auth_service.dart';
import 'verify_code_screen.dart';
import '../shared/mensaje_app.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color campoGris = Color(0xFFF2F2F2);
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message, [TipoMensaje tipo = TipoMensaje.error]) {
    ScaffoldMessenger.of(
      context,
    ).mostrarMensaje(message, tipo: tipo, sobreBarraPanel: false);
  }

  Future<void> _onEnviarCodigo() async {
    if (_loading) return;
    final correo = _emailController.text.trim().toLowerCase();
    if (correo.isEmpty) {
      _showMessage('Ingresa tu correo electrónico');
      return;
    }
    if (emailValidator(correo) != null) {
      _showMessage(correoInvalidoMensaje);
      return;
    }

    setState(() => _loading = true);
    try {
      final mensaje = await AuthService.instance.solicitarCodigoRecuperacion(
        correo,
      );
      if (!mounted) return;
      _showMessage(mensaje, TipoMensaje.informacion);
      Navigator.of(
        context,
      ).push(heroFadeRoute(VerifyCodeScreen(email: correo)));
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo completar la operación.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
                Text(
                  'Recuperar contraseña',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: splashRojo.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: splashRojo,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '¿Olvidaste tu contraseña?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.black87,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No te preocupes, ingresa tu correo y te enviaremos un código de verificación.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Correo electrónico',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Ingresa tu correo',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.black38,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: splashRojo,
                              ),
                              filled: true,
                              fillColor: campoGris,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: splashRojo,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _onEnviarCodigo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: splashRojo,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: splashRojo.withValues(
                                  alpha: 0.6,
                                ),
                                disabledForegroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : Text(
                                      'Enviar código',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
