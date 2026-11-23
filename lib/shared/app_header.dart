import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/paleta_app.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.initials,
    this.showAvatar = true,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final String? initials;
  final bool showAvatar;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
                size: 27,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 28),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: context.pal.texto(AppColors.ink),
                fontSize: 24,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showAvatar && initials != null)
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.pal.rojoBoton(AppColors.red),
                shape: BoxShape.circle,
              ),
              child: Text(
                initials!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
