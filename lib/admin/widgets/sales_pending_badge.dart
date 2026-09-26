import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sales_repository.dart';

/// Índice del ítem "Ventas" dentro del bottom nav del administrador.
const int adminSalesNavIndex = 3;

/// Badge numérico (tope 99+) con la cantidad de pedidos por verificar.
class SalesPendingBadge extends StatelessWidget {
  const SalesPendingBadge({
    super.key,
    required this.count,
    this.color = const Color(0xFFC9151E),
    this.fontSize = 11,
    this.borderColor = const Color(0xFFFFFDFD),
  });

  final int count;
  final Color color;
  final double fontSize;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Ícono de un ítem del bottom nav del administrador.
///
/// Cuando [showPendingBadge] es true y hay pedidos "Por verificar", muestra
/// un badge numérico sobre el ícono y se actualiza solo cuando el
/// [SalesRepository] notifica cambios.
class AdminBottomNavIcon extends StatelessWidget {
  const AdminBottomNavIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size,
    this.showPendingBadge = false,
  });

  final IconData icon;
  final Color color;
  final double? size;
  final bool showPendingBadge;

  @override
  Widget build(BuildContext context) {
    if (!showPendingBadge) {
      return Icon(icon, color: color, size: size);
    }

    return ListenableBuilder(
      listenable: SalesRepository.instance,
      builder: (context, _) {
        final iconWidget = Icon(icon, color: color, size: size);
        final count = SalesRepository.instance.pendingVerificationCount;

        if (count <= 0) return iconWidget;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            Positioned(
              top: -8,
              right: -11,
              child: SalesPendingBadge(count: count),
            ),
          ],
        );
      },
    );
  }
}
