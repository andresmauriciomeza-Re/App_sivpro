import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aviso_auth.dart';
import 'boton_reenviar_confirmacion.dart';
import 'login_screen.dart';

/// Tras registrarse: la cuenta queda pendiente hasta abrir el enlace del
/// correo (se confirma en el navegador, no en la app).
class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({
    super.key,
    required this.correo,
    required this.correoEnviado,
  });

  final String correo;

  /// false si el backend creó la cuenta pero no pudo enviar el correo.
  final bool correoEnviado;

  static const Color splashRojo = Color(0xE6C32828);

  void _irAlLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: splashRojo.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: splashRojo,
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Revisa tu correo',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Te enviamos un enlace de confirmación a ',
                          ),
                          TextSpan(
                            text: correo,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '. Ábrelo para activar tu cuenta. '
                                'El enlace vence en 24 horas.',
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    if (!correoEnviado) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: splashRojo.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'No pudimos enviar el correo. Pulsa Reenviar para '
                          'intentarlo de nuevo.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: splashRojo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                    BotonReenviarConfirmacion(
                      correo: () => correo,
                      alMensaje: (mensaje) =>
                          mostrarAvisoAuth(context, mensaje, error: false),
                      alError: (mensaje) => mostrarAvisoAuth(context, mensaje),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => _irAlLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: splashRojo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Ir a iniciar sesión',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
    );
  }
}
