import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../network/api_exception.dart';
import 'auth_service.dart';

/// Botón "Reenviar correo de confirmación" de una cuenta pendiente.
///
/// Bloquea el doble toque mientras envía y, tras enviar (o ante un 429),
/// queda deshabilitado [espera] con cuenta regresiva.
class BotonReenviarConfirmacion extends StatefulWidget {
  const BotonReenviarConfirmacion({
    super.key,
    required this.correo,
    required this.alMensaje,
    required this.alError,
  });

  static const Duration espera = Duration(seconds: 60);

  /// Correo al que se reenvía; se lee al pulsar.
  final String Function() correo;

  /// Mensaje del backend cuando el reenvío se aceptó.
  final ValueChanged<String> alMensaje;
  final ValueChanged<String> alError;

  @override
  State<BotonReenviarConfirmacion> createState() =>
      _BotonReenviarConfirmacionState();
}

class _BotonReenviarConfirmacionState extends State<BotonReenviarConfirmacion> {
  static const Color splashRojo = Color(0xE6C32828);

  bool _enviando = false;
  int _restantes = 0;
  Timer? _cuenta;

  @override
  void dispose() {
    _cuenta?.cancel();
    super.dispose();
  }

  void _iniciarEspera() {
    _cuenta?.cancel();
    setState(() => _restantes = BotonReenviarConfirmacion.espera.inSeconds);
    _cuenta = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restantes <= 1) timer.cancel();
      setState(() => _restantes--);
    });
  }

  Future<void> _reenviar() async {
    if (_enviando || _restantes > 0) return;
    final correo = widget.correo().trim();
    if (correo.isEmpty) {
      widget.alError('Ingresa tu correo');
      return;
    }
    setState(() => _enviando = true);
    try {
      final mensaje = await AuthService.instance.reenviarVerificacion(correo);
      if (!mounted) return;
      widget.alMensaje(mensaje);
      _iniciarEspera();
    } on ApiException catch (error) {
      if (!mounted) return;
      widget.alError(error.message);
      if (error.statusCode == 429) _iniciarEspera();
    } catch (_) {
      if (mounted) {
        widget.alError('No se pudo reenviar el correo. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activo = !_enviando && _restantes == 0;
    return OutlinedButton(
      onPressed: activo ? _reenviar : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: splashRojo,
        disabledForegroundColor: Colors.black38,
        side: BorderSide(
          color: activo ? splashRojo : Colors.black12,
          width: 1.4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _enviando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: splashRojo,
                strokeWidth: 2.2,
              ),
            )
          : Text(
              _restantes > 0
                  ? 'Reenviar en $_restantes s'
                  : 'Reenviar correo de confirmación',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
    );
  }
}
