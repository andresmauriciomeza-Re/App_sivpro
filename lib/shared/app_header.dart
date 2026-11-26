import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../admin/widgets/campana_notificaciones.dart';
import '../theme/app_colors.dart';
import '../theme/paleta_app.dart';
import 'medidas_encabezado.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.initials,
    this.showAvatar = true,
    this.trailing,
    this.mostrarCampana = true,
  });

  final String title;
  final VoidCallback? onBack;
  final String? initials;
  final bool showAvatar;
  final Widget? trailing;

  /// Campana de notificaciones junto al círculo de iniciales (se oculta en
  /// la propia pantalla de Notificaciones).
  final bool mostrarCampana;

  @override
  Size get preferredSize => const Size.fromHeight(MedidasEncabezado.alto);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.only(
        left: onBack != null
            ? MedidasEncabezado.margenConFlecha
            : MedidasEncabezado.margen,
        right: MedidasEncabezado.margen,
      ),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(AppColors.page),
        border: Border(
          bottom: BorderSide(color: context.pal.borde(AppColors.headerDivider)),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                color: context.pal.texto(AppColors.ink),
                size: MedidasEncabezado.flecha,
              ),
              tooltip: 'Regresar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: MedidasEncabezado.zonaFlecha,
                height: MedidasEncabezado.zonaFlecha,
              ),
            ),
            const SizedBox(width: MedidasEncabezado.separacionFlecha),
          ],
          // El título nunca se corta ni pisa la campana: si no cabe (pantalla
          // muy angosta o letra grande), se reduce.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: GoogleFonts.montserrat(
                  color: context.pal.texto(AppColors.ink),
                  fontSize: MedidasEncabezado.letraTitulo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: MedidasEncabezado.separacionCampana),
          if (trailing != null)
            trailing!
          else if (showAvatar && initials != null) ...[
            if (mostrarCampana) ...[
              const CampanaNotificaciones(),
              const SizedBox(width: MedidasEncabezado.separacionCampana),
            ],
            Container(
              width: MedidasEncabezado.avatar,
              height: MedidasEncabezado.avatar,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.pal.rojoBoton(AppColors.red),
                shape: BoxShape.circle,
              ),
              child: Text(
                initials!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: MedidasEncabezado.letraAvatar,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
