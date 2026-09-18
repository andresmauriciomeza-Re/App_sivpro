import 'package:flutter/material.dart';

//Mis Importaciones
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'page_transitions.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color splashRojo = Color(0xE6C32828); // #C32828 @ 90%
  static const Color campoGris = Color(0xFFF2F2F2);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _hasMinLength(String p) => p.length >= 6;
  bool _hasUpperCase(String p) => RegExp(r'[A-Z]').hasMatch(p);
  bool _hasNumber(String p) => RegExp(r'[0-9]').hasMatch(p);

  Widget _buildCheckItem(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: passed ? const Color(0xFF34A853) : Colors.black26,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: passed ? Colors.black87 : Colors.black45,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      filled: true,
      fillColor: campoGris,
      prefixIcon: Icon(icon, color: splashRojo, size: 22),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: splashRojo, width: 1.4),
      ),
    );
  }

  void _onLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _mostrarTerminosYContinuar() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Términos de uso y política de privacidad',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Antes de utilizar cualquiera de nuestros productos o servicios, lee atentamente y asegúrate de entender completamente los Términos de Uso y la Política de Privacidad. Al pulsar Aceptar y utilizar nuestros productos o servicios, afirmas que entiendes y aceptas todos los términos y condiciones de S.I.V.PRO y das tu consentimiento para compartir la información de tu cuenta con S.I.V.PRO.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente disponible')),
                    );
                  },
                  child: Text(
                    'Términos de uso y política de privacidad',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: splashRojo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          'Rechazar',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.black12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _onLogin();
                        },
                        child: Text(
                          'Aceptar',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: splashRojo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Hero(
                          tag: 'auth_logo',
                          flightShuttleBuilder:
                              (
                                flightContext,
                                animation,
                                direction,
                                fromCtx,
                                toCtx,
                              ) {
                                final hero =
                                    direction == HeroFlightDirection.push
                                    ? toCtx.widget as Hero
                                    : fromCtx.widget as Hero;
                                return ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.elasticOut,
                                  ),
                                  child: hero.child,
                                );
                              },
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.asset(
                              'assets/img/logo_blanc7.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/img/Logo.png',
                                    fit: BoxFit.contain,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Bienvenido a La Sirena',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.black87,
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tus datos para continuar',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      _fieldLabel('Correo electrónico'),
                      TextField(
                        controller: _emailController,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                          hint: 'tucorreo@ejemplo.com',
                          icon: Icons.mail_outline,
                        ),
                      ),
                      const SizedBox(height: 18),

                      _fieldLabel('Contraseña'),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _fieldDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black38,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckItem(
                              'Mínimo 6 caracteres',
                              _hasMinLength(password),
                            ),
                            _buildCheckItem(
                              'Al menos una mayúscula',
                              _hasUpperCase(password),
                            ),
                            _buildCheckItem(
                              'Al menos un número',
                              _hasNumber(password),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).push(heroFadeRoute(const ForgotPasswordScreen()));
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: GoogleFonts.poppins(
                              color: splashRojo,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      ElevatedButton(
                        onPressed: _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: splashRojo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Iniciar sesión',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'O continúa con',
                              style: GoogleFonts.poppins(
                                color: Colors.black45,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _mostrarTerminosYContinuar,
                              icon: SvgPicture.string(
                                _googleIconSvg,
                                width: 20,
                                height: 20,
                              ),
                              label: Text(
                                'Google',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _mostrarTerminosYContinuar,
                              icon: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 24,
                              ),
                              label: Text(
                                'Apple',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).push(heroFadeRoute(const RegisterScreen()));
                            },
                            child: Text(
                              'Regístrate aquí',
                              style: GoogleFonts.poppins(
                                color: splashRojo,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// SVG oficial del ícono de Google (4 colores), usado en el botón
/// "Continuar con Google".
const String _googleIconSvg = '''
<svg width="18" height="18" xmlns="http://www.w3.org/2000/svg">
<path fill="#4285F4" d="M17.64 9.2045c0-.6381-.0573-1.2518-.1636-1.8409H9v3.4814h4.8436c-.2086 1.125-.8427 2.0782-1.7959 2.7164v2.2582h2.9087c1.7018-1.5668 2.6836-3.8741 2.6836-6.6151z"/>
<path fill="#34A853" d="M9 18c2.43 0 4.4673-.8059 5.9564-2.1805l-2.9087-2.2582c-.8059.54-1.8368.8591-3.0477.8591-2.344 0-4.3282-1.5831-5.036-3.7104H.9575v2.3318C2.4382 15.9832 5.4818 18 9 18z"/>
<path fill="#FBBC05" d="M3.964 10.71c-.18-.54-.2822-1.1168-.2822-1.71s.1023-1.17.2823-1.71V4.9582H.9573A8.9965 8.9965 0 000 9c0 1.4523.3477 2.8268.9573 4.0418L3.964 10.71z"/>
<path fill="#EA4335" d="M9 3.5795c1.3214 0 2.5077.4541 3.4405 1.346l2.5813-2.5814C13.4632.8918 11.4259 0 9 0 5.4818 0 2.4382 2.0168.9573 4.9582L3.964 7.29C4.6718 5.1627 6.656 3.5795 9 3.5795z"/>
</svg>
''';
