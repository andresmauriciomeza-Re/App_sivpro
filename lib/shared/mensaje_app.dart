import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../admin/widgets/barra_navegacion_admin.dart';
import '../theme/app_colors.dart';

/// Tipo de mensaje: define el color, el ícono y cuánto dura.
enum TipoMensaje {
  exito(AppColors.bannerGreenFg, Icons.check_circle_outline, 3),
  informacion(Color(0xFF1565C0), Icons.info_outline, 3),

  /// Errores y advertencias.
  error(AppColors.red, Icons.warning_amber_rounded, 4);

  const TipoMensaje(this.color, this.icono, this.segundos);

  /// Fondo, igual en claro y oscuro: el texto siempre es blanco.
  final Color color;
  final IconData icono;
  final int segundos;
}

/// Mensajes de la app: flotantes, legibles y con ícono.
///
/// Se usa sobre el [ScaffoldMessengerState] para poder guardarlo antes de un
/// `await` y mostrar el mensaje después.
extension MensajesApp on ScaffoldMessengerState {
  /// [sobreBarraPanel]: las pantallas del panel llevan la barra inferior dentro
  /// del cuerpo, así que el mensaje se levanta para no taparla.
  void mostrarMensaje(
    String texto, {
    required TipoMensaje tipo,
    bool sobreBarraPanel = true,
  }) {
    // El Scaffold ya respeta el borde inferior del teléfono; falta el alto de
    // la barra y su separación mínima.
    final borde = MediaQuery.viewPaddingOf(context).bottom;
    final inferior = sobreBarraPanel
        ? BarraNavegacionAdmin.alto +
              math.max(BarraNavegacionAdmin.separacionMinima - borde, 0)
        : 12.0;
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tipo.color,
        duration: Duration(seconds: tipo.segundos),
        margin: EdgeInsets.fromLTRB(12, 0, 12, inferior),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        // Sin límite de líneas: un mensaje del backend nunca se corta.
        content: Row(
          children: [
            Icon(tipo.icono, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
