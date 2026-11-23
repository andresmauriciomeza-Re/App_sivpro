import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/paleta_app.dart';

/// Rejilla de 2 columnas con las tarjetas de resumen del inicio.
///
/// La altura de celda ya no sale solo del ancho (antes `childAspectRatio:
/// 1.45`, que desbordaba con títulos de 2 líneas o letra ampliada): es el
/// mayor entre ese alto de siempre y el alto que necesita el contenido con
/// la escala de texto del sistema. Todas las tarjetas quedan iguales.
class SummaryCardsGrid extends StatelessWidget {
  const SummaryCardsGrid({super.key, required this.cards});

  final List<Widget> cards;

  static const double _espacio = 16;
  static const double _proporcion = 1.45;

  @override
  Widget build(BuildContext context) {
    final necesario = SummaryCard.altoNecesario(
      MediaQuery.textScalerOf(context),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoCelda = (constraints.maxWidth - _espacio) / 2;
        final alto = math.max(anchoCelda / _proporcion, necesario);
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: _espacio,
            mainAxisSpacing: _espacio,
            mainAxisExtent: alto,
          ),
          children: cards,
        );
      },
    );
  }
}

/// Tarjeta de resumen: ícono, título (máx. 2 líneas) y valor que se reduce
/// para caber. Con [onTap] es un botón con efecto de toque.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
    this.warning = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool highlight;
  final bool warning;
  final VoidCallback? onTap;

  static const double _radio = 14;
  static const EdgeInsets _relleno = EdgeInsets.fromLTRB(16, 14, 10, 12);
  static const double _icono = 36;
  static const double _tituloFuente = 13;
  static const double _valorFuente = 18;

  /// Alto de línea de Poppins (≈1.5 em) con margen de seguridad.
  static const double _altoLinea = 1.6;

  /// Alto mínimo para que ícono, 2 líneas de título y el valor quepan con la
  /// escala de texto dada (incluye relleno, borde y un respiro de 6 px).
  static double altoNecesario(TextScaler escala) {
    final titulo = escala.scale(_tituloFuente) * _altoLinea * 2;
    final valor = escala.scale(_valorFuente) * _altoLinea;
    return _relleno.vertical + 2 + _icono + 6 + titulo + valor;
  }

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(
      padding: _relleno,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _icono,
            height: _icono,
            decoration: BoxDecoration(
              color: highlight
                  ? context.pal.rojoBoton(AppColors.red)
                  : context.pal.campo(Color(0xFFF2EEED)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: highlight ? Colors.white : context.pal.rojo(AppColors.red),
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: context.pal.secundario(AppColors.muted),
              fontSize: _tituloFuente,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.poppins(
                color: highlight || warning
                    ? context.pal.rojo(AppColors.red)
                    : context.pal.texto(Colors.black),
                fontSize: _valorFuente,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radio),
      side: BorderSide(color: context.pal.borde(Color(0xFFE8DDDB))),
    );
    return Semantics(
      button: onTap != null,
      label: '$title: $value',
      excludeSemantics: true,
      child: Material(
        color: context.pal.tarjeta(AppColors.page),
        shape: forma,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? contenido
            : InkWell(customBorder: forma, onTap: onTap, child: contenido),
      ),
    );
  }
}
