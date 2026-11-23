import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/purchases_screen.dart' show PurchasesScreen;
import '../../theme/paleta_app.dart';

/// Tarjeta grande de módulo de los hubs (Compras, Producción e Inicio):
/// ícono en cuadro gris, cuarto de círculo rosado decorativo, título en
/// negrita y descripción en gris.
///
/// Mide 288 de alto como mínimo; si el texto no cabe (letra del sistema
/// ampliada o pantalla angosta) crece en lugar de desbordar.
class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  static const double altoMinimo = 288;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Container(
          constraints: const BoxConstraints(minHeight: altoMinimo),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 25, 18, 20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.pal.tarjeta(PurchasesScreen.page),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: context.pal.borde(Color(0xFFE8C7C4)),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -72,
                right: -58,
                child: Container(
                  width: 164,
                  height: 164,
                  decoration: BoxDecoration(
                    color: context.pal.rojoSuave(Color(0xFFF2C9CA)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.pal.campo(Color(0xFFEDE9E8)),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      color: context.pal.texto(Colors.black87),
                      size: 38,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: context.pal.secundario(PurchasesScreen.muted),
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
