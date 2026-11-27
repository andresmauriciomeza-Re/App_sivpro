import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/paleta_app.dart';

/// Tarjeta "Modo oscuro" del perfil (personal y cliente): toda la fila
/// alterna el modo.
class TarjetaModoOscuro extends StatelessWidget {
  const TarjetaModoOscuro({
    super.key,
    required this.oscuro,
    required this.onChanged,
    this.radio = 24,
    this.bordeEnClaro = true,
  });

  final bool oscuro;
  final ValueChanged<bool> onChanged;

  /// Radio de la tarjeta (el perfil del cliente usa el de sus tarjetas).
  final double radio;

  /// En oscuro siempre lleva borde fino; en claro, solo si se pide.
  final bool bordeEnClaro;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final esquinas = BorderRadius.circular(radio);
    final tarjeta = Semantics(
      label: 'Cambiar modo oscuro',
      toggled: oscuro,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: p.tarjeta(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: esquinas,
          side: bordeEnClaro || p.oscuro
              ? BorderSide(color: p.borde(AppColors.profileCardBorder))
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: esquinas,
          onTap: () => onChanged(!oscuro),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.rojoSuave(AppColors.red.withValues(alpha: 0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    oscuro
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: p.rojo(AppColors.red),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo oscuro',
                        style: GoogleFonts.poppins(
                          color: p.texto(AppColors.ink),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        oscuro ? 'Activado' : 'Desactivado',
                        style: GoogleFonts.poppins(
                          color: p.secundario(AppColors.muted),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: oscuro,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: p.rojoBoton(AppColors.red),
                  inactiveThumbColor: p.secundario(AppColors.muted),
                  inactiveTrackColor: p.campo(AppColors.buttonFill),
                  trackOutlineColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.transparent
                        : p.secundario(AppColors.fieldBorder),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return RepaintBoundary(child: tarjeta);
  }
}
