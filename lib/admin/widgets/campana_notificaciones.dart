import 'package:material_ui/material_ui.dart';

import '../../theme/app_colors.dart';
import '../../theme/paleta_app.dart';
import '../notificaciones/notificaciones_repository.dart';
import '../screens/notificaciones_screen.dart';
import 'sales_pending_badge.dart';

/// Campana del encabezado del panel: abre Notificaciones y muestra cuántas
/// hay sin leer (hasta "9+").
class CampanaNotificaciones extends StatelessWidget {
  const CampanaNotificaciones({super.key, this.diametro = 40});

  /// Diámetro del círculo (la zona táctil es de al menos 44 × 44).
  final double diametro;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return ValueListenableBuilder<int>(
      valueListenable: NotificacionesRepository.instance.conteoNoLeidas,
      builder: (context, sinLeer, _) => Semantics(
        button: true,
        label: sinLeer == 0
            ? 'Notificaciones'
            : 'Notificaciones, $sinLeer sin leer',
        excludeSemantics: true,
        child: InkResponse(
          radius: 24,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
          ),
          child: SizedBox(
            width: diametro < 44 ? 44 : diametro,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: diametro,
                  height: diametro,
                  decoration: BoxDecoration(
                    color: pal.tarjeta(AppColors.page),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: pal.borde(AppColors.headerDivider),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    color: pal.texto(AppColors.ink),
                    size: diametro * 0.55,
                  ),
                ),
                if (sinLeer > 0)
                  Positioned(
                    top: 0,
                    right: -4,
                    child: SalesPendingBadge(count: sinLeer, tope: 9),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
