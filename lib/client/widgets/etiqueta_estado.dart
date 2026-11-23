import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paleta_app.dart';
import '../models/producto_catalogo.dart';

/// Única etiqueta de estado de un producto del menú.
class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado({super.key, required this.estado});

  final EstadoMenu estado;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final (fondo, texto, etiqueta) = switch (estado) {
      EstadoMenu.disponible => (
        pal.exitoFondo(const Color(0xFF34A853)),
        pal.exitoTexto(Colors.white),
        'Disponible',
      ),
      EstadoMenu.agotado => (
        pal.errorFondo(const Color(0xFFD32F2F)),
        pal.errorTexto(Colors.white),
        'Agotado',
      ),
      EstadoMenu.noDisponible => (
        pal.campo(const Color(0xFF757575)),
        pal.secundario(Colors.white),
        'No disponible',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        etiqueta,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
      ),
    );
  }
}
