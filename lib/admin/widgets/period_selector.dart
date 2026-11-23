import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/purchases_screen.dart' show PurchasesScreen;
import '../../theme/paleta_app.dart';

const Color _borde = Color(0xFFE5BDB9);

/// Menú desplegable con el estilo de la app: fondo blanco, esquinas de 16,
/// borde fino, sombra suave y la opción elegida resaltada en rojo de marca
/// con un check. Se abre debajo de [child] con el ancho [ancho].
class MenuApp<T> extends StatelessWidget {
  const MenuApp({
    super.key,
    required this.opciones,
    required this.etiqueta,
    required this.onSelected,
    required this.ancho,
    required this.child,
    this.valor,
    this.alturaMaxima,
    this.onOpened,
    this.onCanceled,
  });

  final List<T> opciones;
  final String Function(T) etiqueta;
  final ValueChanged<T> onSelected;
  final double ancho;
  final Widget child;

  /// Opción resaltada como elegida (null = ninguna).
  final T? valor;

  /// Alto máximo del menú; si las opciones no caben, el menú se desplaza.
  final double? alturaMaxima;
  final VoidCallback? onOpened;
  final VoidCallback? onCanceled;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Sin el gris por defecto en la opción elegida.
      data: Theme.of(context).copyWith(highlightColor: Colors.transparent),
      child: PopupMenuButton<T>(
        initialValue: valor,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        constraints: BoxConstraints(
          minWidth: ancho,
          maxWidth: ancho,
          maxHeight: alturaMaxima ?? double.infinity,
        ),
        color: context.pal.superficie(Colors.white),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: context.pal.sombra(Colors.black.withValues(alpha: 0.25)),
        menuPadding: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.pal.borde(_borde)),
        ),
        onOpened: onOpened,
        onCanceled: onCanceled,
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final opcion in opciones)
            PopupMenuItem<T>(
              value: opcion,
              height: 48,
              padding: EdgeInsets.zero,
              child: _opcion(context, opcion, opcion == valor),
            ),
        ],
        child: child,
      ),
    );
  }

  Widget _opcion(BuildContext context, T opcion, bool elegida) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: elegida
          ? context.pal.rojoSuave(PurchasesScreen.red.withValues(alpha: 0.09))
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiqueta(opcion),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: elegida
                    ? context.pal.rojo(PurchasesScreen.red)
                    : context.pal.texto(PurchasesScreen.ink),
                fontSize: 15,
                fontWeight: elegida ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (elegida)
            Icon(
              Icons.check_rounded,
              color: context.pal.rojo(PurchasesScreen.red),
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// Selector de periodo (Mes, Año): campo blanco con borde suave y [MenuApp]
/// del mismo ancho que el campo.
class SelectorPeriodo<T> extends StatefulWidget {
  const SelectorPeriodo({
    super.key,
    required this.valor,
    required this.opciones,
    required this.etiqueta,
    required this.onSelected,
    this.alturaMaxima,
  });

  final T valor;
  final List<T> opciones;
  final String Function(T) etiqueta;
  final ValueChanged<T> onSelected;

  /// Alto máximo del menú; si las opciones no caben, el menú se desplaza.
  final double? alturaMaxima;

  @override
  State<SelectorPeriodo<T>> createState() => _SelectorPeriodoState<T>();
}

class _SelectorPeriodoState<T> extends State<SelectorPeriodo<T>> {
  bool _abierto = false;

  void _cerrado() => setState(() => _abierto = false);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) => MenuApp<T>(
        valor: widget.valor,
        opciones: widget.opciones,
        etiqueta: widget.etiqueta,
        ancho: restricciones.maxWidth,
        alturaMaxima: widget.alturaMaxima,
        onOpened: () => setState(() => _abierto = true),
        onCanceled: _cerrado,
        onSelected: (valor) {
          _cerrado();
          widget.onSelected(valor);
        },
        child: _campo(),
      ),
    );
  }

  Widget _campo() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.pal.borde(_borde)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.etiqueta(widget.valor),
                style: GoogleFonts.poppins(
                  color: context.pal.texto(PurchasesScreen.ink),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          AnimatedRotation(
            turns: _abierto ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: context.pal.secundario(PurchasesScreen.muted),
            ),
          ),
        ],
      ),
    );
  }
}
