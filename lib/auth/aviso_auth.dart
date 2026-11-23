import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// SnackBar de las pantallas de acceso: rojo con icono de error, o verde
/// para avisos de éxito (por ejemplo, correo de confirmación reenviado).
void mostrarAvisoAuth(
  BuildContext context,
  String mensaje, {
  bool error = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error
          ? const Color(0xE6C32828)
          : const Color(0xFF34A853),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.mark_email_read_outlined,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
