import 'package:material_ui/material_ui.dart';

//Mis Importaciones
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'aviso_auth.dart';
import 'boton_reenviar_confirmacion.dart';
import '../theme/tema_panel.dart';
import '../network/api_exception.dart';
import '../shared/page_transitions.dart';
import '../shared/validators.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../client/screens/home_screen.dart';
import '../admin/screens/purchases_screen.dart' show adminHomeScreen;

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
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;

  /// Correo con el que el backend respondió "cuenta no activada" (403); el
  /// botón de reenvío se muestra mientras el campo conserve ese correo.
  String? _correoPendiente;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _emailController.addListener(_alEditarCorreo);
  }

  void _alEditarCorreo() {
    if (_correoPendiente != null && _emailController.text != _correoPendiente) {
      setState(() => _correoPendiente = null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  /// Valida las credenciales contra el backend. Si fallan muestra el mensaje
  /// del servidor y NO navega; si son correctas lleva al panel según el rol.
  Future<void> _onLogin() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final usuario = await AuthService.instance.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _correoPendiente = null);

      switch (usuario.userRole) {
        case UserRole.admin:
        case UserRole.empleado:
          // Administrador y Empleado comparten el menú por permisos.
          Navigator.of(
            context,
          ).pushReplacement(heroFadeRoute(adminHomeScreen()));
          break;
        case UserRole.cliente:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          break;
        case null:
          // Sin rol reconocido no se deja una sesión abierta a medias.
          await AuthService.instance.logout();
          if (mounted) _mostrarError('Tu cuenta no tiene un rol habilitado.');
          break;
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 403) {
        setState(() => _correoPendiente = _emailController.text);
      }
      _mostrarError(error.message);
    } catch (_) {
      if (mounted) {
        _mostrarError('No se pudo iniciar sesión. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostrarError(String mensaje) => mostrarAvisoAuth(context, mensaje);

  void _mostrarAviso(String mensaje) =>
      mostrarAvisoAuth(context, mensaje, error: false);

  @override
  Widget build(BuildContext context) {
    return TemaSiempreClaro(
      child: Scaffold(
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
                                // Sin fallback: assets/img/Logo.png no existe.
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
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

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fieldLabel('Correo electrónico'),
                              TextFormField(
                                controller: _emailController,
                                validator: loginEmailValidator,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
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
                              TextFormField(
                                controller: _passwordController,
                                validator: loginPasswordValidator,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _onLogin(),
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
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                heroFadeRoute(const ForgotPasswordScreen()),
                              );
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
                          onPressed: _loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: splashRojo,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: splashRojo.withValues(
                              alpha: 0.6,
                            ),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
                                  'Iniciar sesión',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                        ),
                        if (_correoPendiente != null) ...[
                          const SizedBox(height: 12),
                          BotonReenviarConfirmacion(
                            correo: () => _emailController.text,
                            alMensaje: _mostrarAviso,
                            alError: _mostrarError,
                          ),
                        ],

                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
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
      ),
    );
  }
}
