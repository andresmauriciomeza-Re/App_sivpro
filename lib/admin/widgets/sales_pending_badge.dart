import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paleta_app.dart';

/// Índice del ítem "Ventas" dentro del bottom nav del administrador.
const int adminSalesNavIndex = 3;

/// Badge numérico (tope 99+) con la cantidad de pedidos por verificar.
class SalesPendingBadge extends StatelessWidget {
  const SalesPendingBadge({
    super.key,
    required this.count,
    this.invertido = false,
  });

  final int count;

  /// Sobre la píldora roja del ítem activo: fondo blanco y número rojo.
  final bool invertido;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: invertido
            ? Colors.white
            : context.pal.rojoBoton(Color(0xFFC9151E)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.pal.borde(Color(0xFFFFFDFD)),
          width: 1.5,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: GoogleFonts.poppins(
          color: invertido ? const Color(0xFFC62828) : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
