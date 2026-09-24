// forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/page_transitions.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color campoGris = Color(0xFFF2F2F2);
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEnviarCodigo() {
    Navigator.of(
      context,
    ).push(heroFadeRoute(VerifyCodeScreen(email: _emailController.text)));
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
                  style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.black87,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No te preocupes, ingresa tu correo y te enviaremos un código de verificación.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Correo electrónico',
                              style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'gloria@lasirena.com',
                              hintStyle: GoogleFonts.dmSerifDisplay(
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
                              onPressed: _onEnviarCodigo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: splashRojo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Enviar código',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Volver al inicio de sesión',
                              style: GoogleFonts.dmSerifDisplay(
                                color: Colors.black54,
                                fontSize: 14,
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