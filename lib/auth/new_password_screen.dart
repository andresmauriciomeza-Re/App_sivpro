// new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/page_transitions.dart';
import 'password_updated_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color campoGris = Color(0xFFF2F2F2);

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onCambiar() {
    Navigator.of(context).push(heroFadeRoute(const PasswordUpdatedScreen()));
  }

  bool _hasMinLength(String p) => p.length >= 6;
  bool _hasUpperCase(String p) => RegExp(r'[A-Z]').hasMatch(p);
  bool _hasNumber(String p) => RegExp(r'[0-9]').hasMatch(p);

  InputDecoration _dec(String hint, VoidCallback toggle, bool obscure) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSerifDisplay(color: Colors.black38),
      filled: true,
      fillColor: campoGris,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: splashRojo, width: 1.4),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.black38,
        ),
        onPressed: toggle,
      ),
    );
  }

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
            style: GoogleFonts.dmSerifDisplay(
              color: passed ? Colors.black87 : Colors.black45,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;

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
                  'Nueva contraseña',
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
                              Icons.lock_reset,
                              color: splashRojo,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nueva contraseña',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.black87,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Crea una contraseña segura para tu cuenta.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 36),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Nueva contraseña',
                              style: GoogleFonts.dmSerifDisplay(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure1,
                            style: GoogleFonts.dmSerifDisplay(color: Colors.black87),
                            decoration: _dec(
                              'Mínimo 6 caracteres',
                              () => setState(() => _obscure1 = !_obscure1),
                              _obscure1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Confirmar contraseña',
                              style: GoogleFonts.dmSerifDisplay(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _confirmController,
                            obscureText: _obscure2,
                            style: GoogleFonts.dmSerifDisplay(color: Colors.black87),
                            decoration: _dec(
                              'Repite tu contraseña',
                              () => setState(() => _obscure2 = !_obscure2),
                              _obscure2,
                            ),
                          ),
                          const SizedBox(height: 20),

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
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onCambiar,
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
                                'Cambiar contraseña',
                                style: GoogleFonts.dmSerifDisplay(
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
