// register_screen.dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../network/api_exception.dart';
import '../shared/page_transitions.dart';
import '../shared/validators.dart';
import 'auth_service.dart';
import 'aviso_auth.dart';
import 'check_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color splashRojo = Color(0xE6C32828); // #C32828 @ 90%
  static const Color campoGris = Color(0xFFF2F2F2);

  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _documentoKey = GlobalKey<FormFieldState<String>>();

  String _tipoDocumento = 'CC';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _enviando = false;

  /// Error del backend ligado a un campo (correo o documento duplicado, dato
  /// rechazado); se deja de mostrar en cuanto ese campo cambia.
  ({String campo, String valor, String mensaje})? _errorBackend;

  final List<Map<String, String>> _tiposDocumento = [
    {'code': 'CC', 'label': 'Cédula de Ciudadanía'},
    {'code': 'CE', 'label': 'Cédula de Extranjería'},
    {'code': 'PP', 'label': 'Pasaporte'},
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nombreController,
      _documentoController,
      _correoController,
      _telefonoController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  bool get _isFormValid =>
      nameValidator(_nombreController.text) == null &&
      documentValidator(_documentoController.text, _tipoDocumento) == null &&
      emailValidator(_correoController.text) == null &&
      phoneValidator(_telefonoController.text) == null &&
      passwordValidator(_passwordController.text) == null &&
      confirmPasswordValidator(
            _confirmPasswordController.text,
            _passwordController.text,
          ) ==
          null;

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  InputDecoration _fieldDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      hintText: label,
      hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      filled: true,
      fillColor: campoGris,
      prefixIcon: icon != null ? Icon(icon, color: splashRojo, size: 22) : null,
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

  TextEditingController? _controladorDe(String campo) => switch (campo) {
    'documento' => _documentoController,
    'nombre' => _nombreController,
    'correo' => _correoController,
    'telefono' => _telefonoController,
    'contrasena' => _passwordController,
    _ => null,
  };

  /// Campo al que se refiere un mensaje 400 o 409 del backend.
  static String? _campoDelError(String mensaje) {
    final texto = mensaje.toLowerCase();
    if (texto.contains('correo')) return 'correo';
    if (texto.contains('número de documento') ||
        texto.contains('documento ya')) {
      return 'documento';
    }
    if (texto.contains('nombre')) return 'nombre';
    if (texto.contains('teléfono')) return 'telefono';
    if (texto.contains('contraseña')) return 'contrasena';
    return null;
  }

  String? _errorDe(String campo) {
    final error = _errorBackend;
    if (error == null || error.campo != campo) return null;
    return _controladorDe(campo)?.text == error.valor ? error.mensaje : null;
  }

  static const String _sinConexion =
      'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.';

  Future<void> _onCrearCuenta() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _errorBackend = null;
    });
    try {
      final cuenta = await AuthService.instance.registrar(
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _documentoController.text,
        nombre: _nombreController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        contrasena: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        heroFadeRoute(
          CheckEmailScreen(
            correo: cuenta.correo,
            correoEnviado: cuenta.correoEnviado,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      // Sin código HTTP: no hubo respuesta (sin red o tiempo agotado).
      if (error.statusCode == null) {
        mostrarAvisoAuth(context, _sinConexion);
        return;
      }
      final campo = error.statusCode == 400 || error.statusCode == 409
          ? _campoDelError(error.message)
          : null;
      final controlador = campo == null ? null : _controladorDe(campo);
      if (campo != null && controlador != null) {
        _errorBackend = (
          campo: campo,
          valor: controlador.text,
          mensaje: error.message,
        );
      }
      mostrarAvisoAuth(context, error.message);
    } catch (_) {
      if (mounted) mostrarAvisoAuth(context, _sinConexion);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Barra superior: flecha + título de la pantalla ----
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
                    'Crear cuenta',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Center(
                child: Hero(
                  tag: 'auth_logo',
                  flightShuttleBuilder:
                      (flightContext, animation, direction, fromCtx, toCtx) {
                        final hero = direction == HeroFlightDirection.push
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
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: splashRojo.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: splashRojo.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: splashRojo,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Crear cuenta',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa todos tus datos para registrarte',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Tipo doc.'),
                              DropdownButtonFormField<String>(
                                initialValue: _tipoDocumento,
                                dropdownColor: Colors.white,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black54,
                                  size: 28,
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                isExpanded: true,
                                itemHeight: null,
                                decoration: _fieldDecoration(
                                  label: 'Tipo doc.',
                                ),
                                selectedItemBuilder: (context) {
                                  return _tiposDocumento
                                      .map(
                                        (tipo) => Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            tipo['code']!,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                                items: _tiposDocumento
                                    .map(
                                      (tipo) => DropdownMenuItem(
                                        value: tipo['code'],
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tipo['code']!,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  color: splashRojo,
                                                ),
                                              ),
                                              Text(
                                                tipo['label']!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _enviando
                                    ? null
                                    : (value) {
                                        if (value == null) return;
                                        setState(() => _tipoDocumento = value);
                                        // Los límites cambian con el tipo.
                                        if (_documentoController
                                            .text
                                            .isNotEmpty) {
                                          _documentoKey.currentState
                                              ?.validate();
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Número de documento'),
                              TextFormField(
                                key: _documentoKey,
                                controller: _documentoController,
                                enabled: !_enviando,
                                forceErrorText: _errorDe('documento'),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _fieldDecoration(
                                  label: 'Número de documento',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) =>
                                    documentValidator(value, _tipoDocumento),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    limitesDocumento[_tipoDocumento]!.$2,
                                  ),
                                ],
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Nombre completo'),
                    TextFormField(
                      controller: _nombreController,
                      enabled: !_enviando,
                      forceErrorText: _errorDe('nombre'),
                      inputFormatters: [NameInputFormatter()],
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Nombre completo',
                        icon: Icons.person_outline,
                      ),
                      validator: nameValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Correo electrónico'),
                    TextFormField(
                      controller: _correoController,
                      enabled: !_enviando,
                      forceErrorText: _errorDe('correo'),
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [EmailInputFormatter()],
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Correo electrónico',
                        icon: Icons.mail_outline,
                      ),
                      validator: emailValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Teléfono'),
                    TextFormField(
                      controller: _telefonoController,
                      enabled: !_enviando,
                      forceErrorText: _errorDe('telefono'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                      ),
                      validator: phoneValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_enviando,
                      forceErrorText: _errorDe('contrasena'),
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration:
                          _fieldDecoration(
                            label: 'Mínimo 8 caracteres',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            helperText:
                                'Entre 8 y 72 caracteres, con mayúscula, '
                                'minúscula y número, sin espacios.',
                            helperMaxLines: 2,
                            helperStyle: GoogleFonts.poppins(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
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
                      validator: passwordValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Confirmar contraseña'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_enviando,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration:
                          _fieldDecoration(
                            label: 'Repite tu contraseña',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black38,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                            ),
                          ),
                      validator: (value) => confirmPasswordValidator(
                        value,
                        _passwordController.text,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed: _isFormValid && !_enviando ? _onCrearCuenta : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: splashRojo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _enviando
                      ? splashRojo.withValues(alpha: 0.6)
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Text(
                        'Crear cuenta',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Ingresar',
                      style: GoogleFonts.poppins(
                        color: splashRojo,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
