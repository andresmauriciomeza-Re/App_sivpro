import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge rojo con el contador de pedidos pendientes por verificar.
///
/// Muestra el número tal cual y aplica el tope visual "99+" cuando el
/// contador supera 99. Si el contador es 0 o menor no pinta nada.
class PendingSalesBadge extends StatelessWidget {
  const PendingSalesBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSerifDisplay(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}