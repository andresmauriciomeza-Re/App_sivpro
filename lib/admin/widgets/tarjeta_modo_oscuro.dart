import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/paleta_app.dart';

/// Tarjeta "Modo oscuro" del perfil: toda la fila alterna el modo.
class TarjetaModoOscuro extends StatelessWidget {
  const TarjetaModoOscuro({
    super.key,
    required this.oscuro,
    required this.onChanged,
  });

  final bool oscuro;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final radio = BorderRadius.circular(24);
    return Semantics(
      label: 'Cambiar modo oscuro',
      toggled: oscuro,
      button: true,
      excludeSemantics: true,
      child: Material(
        color: p.tarjeta(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: radio,
          side: BorderSide(color: p.borde(AppColors.profileCardBorder)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radio,
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
  }
}
