// register_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String _tipoDocumento = 'CC';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<Map<String, String>> _tiposDocumento = [
    {'code': 'CC', 'label': 'Cédula de Ciudadanía'},
    {'code': 'CE', 'label': 'Cédula de Extranjería'},
    {'code': 'PPT', 'label': 'Permiso por Protección Temporal'},
    {'code': 'PEP', 'label': 'Permiso Especial de Permanencia'},
    {'code': 'PAS', 'label': 'Pasaporte'},
    {'code': 'NIT', 'label': 'Número de Identificación Tributaria'},
    {'code': 'RC', 'label': 'Registro Civil'},
    {'code': 'DNI', 'label': 'Documento Nacional de Identidad'},
  ];

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

  void _onCrearCuenta() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // TODO: conectar con el backend real.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Creando cuenta...')));
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
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _tipoDocumento = value);
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
                                controller: _documentoController,
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Este campo es obligatorio';
                                  }
                                  return null;
                                },
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
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Nombre completo',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Correo electrónico'),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Correo electrónico',
                        icon: Icons.mail_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Teléfono'),
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _fieldDecoration(
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration:
                          _fieldDecoration(
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                          ).copyWith(
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Confirmar contraseña'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration:
                          _fieldDecoration(
                            label: 'Confirmar contraseña',
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              ElevatedButton(
                onPressed: _onCrearCuenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: splashRojo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
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
