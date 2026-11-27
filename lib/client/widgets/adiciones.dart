import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/formato.dart';
import '../../shared/mensaje_app.dart';
import '../../theme/paleta_app.dart';
import '../models/producto_catalogo.dart';

/// Bebidas elegidas como adición de UN producto. La comparten su detalle y la
/// pantalla "Bebidas", así que ambas muestran las mismas cantidades.
class AdicionesElegidas extends ChangeNotifier {
  final Map<String, int> _cantidades = {};

  String _clave(ProductoCatalogo bebida) => '${bebida.id ?? bebida.nombre}';

  int de(ProductoCatalogo bebida) => _cantidades[_clave(bebida)] ?? 0;

  void poner(ProductoCatalogo bebida, int cantidad) {
    _cantidades[_clave(bebida)] = cantidad;
    notifyListeners();
  }
}

/// Precio de la bebida, o por qué no se puede pedir.
String precioDeBebida(ProductoCatalogo bebida) => switch (bebida.estado) {
  EstadoMenu.disponible => formatCop(bebida.precioBase),
  EstadoMenu.agotado => 'Agotado',
  EstadoMenu.noDisponible => 'No disponible',
};

/// − cantidad + de una bebida, con su límite de stock.
class ContadorBebida extends StatelessWidget {
  const ContadorBebida({
    super.key,
    required this.bebida,
    required this.elegidas,
  });

  final ProductoCatalogo bebida;
  final AdicionesElegidas elegidas;

  @override
  Widget build(BuildContext context) {
    final stock = bebida.stock;
    return ContadorCantidad(
      value: elegidas.de(bebida),
      minValue: 0,
      maxValue: stock,
      habilitado: bebida.estado == EstadoMenu.disponible,
      tactil: 40,
      etiquetaQuitar: 'Quitar ${bebida.nombre}',
      etiquetaAgregar: 'Agregar ${bebida.nombre}',
      alLimite: stock == null
          ? null
          : () => ScaffoldMessenger.of(context).mostrarMensaje(
              'Máximo disponible: $stock. No hay más unidades de '
              '${bebida.nombre}',
              tipo: TipoMensaje.error,
              sobreBarraPanel: false,
            ),
      onChanged: (v) => elegidas.poner(bebida, v),
    );
  }
}

class ContadorCantidad extends StatefulWidget {
  const ContadorCantidad({
    super.key,
    required this.value,
    required this.minValue,
    required this.onChanged,
    this.maxValue,
    this.habilitado = true,
    this.alLimite,
    this.tactil = 26,
    this.etiquetaQuitar,
    this.etiquetaAgregar,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  /// Stock disponible; null = sin límite.
  final int? maxValue;
  final bool habilitado;

  /// Aviso al intentar pasar de [maxValue].
  final VoidCallback? alLimite;

  /// Lado de la zona táctil de − y + (el círculo visible mide 26).
  final double tactil;
  final String? etiquetaQuitar;
  final String? etiquetaAgregar;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  State<ContadorCantidad> createState() => _ContadorState();
}

class _ContadorState extends State<ContadorCantidad> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ContadorCantidad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _sincronizar();
  }

  bool get _enMaximo {
    final maximo = widget.maxValue;
    return maximo != null && widget.value >= maximo;
  }

  void _sincronizar() {
    final int? parsed = int.tryParse(_controller.text.trim());
    final bool valido = parsed != null && parsed >= widget.minValue;
    if (!valido || parsed == widget.value) {
      _controller.text = '${widget.value}';
      return;
    }
    final maximo = widget.maxValue;
    if (maximo != null && parsed > maximo) {
      widget.alLimite?.call();
      _controller.text = '$maximo';
      if (maximo != widget.value) widget.onChanged(maximo);
      return;
    }
    widget.onChanged(parsed);
  }

  void _onSubmitted(String value) {
    _sincronizar();
    _focusNode.unfocus();
  }

  void _sumar() {
    if (_enMaximo) {
      widget.alLimite?.call();
      return;
    }
    widget.onChanged(widget.value + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          icon: Icons.remove,
          etiqueta: widget.etiquetaQuitar,
          onTap: widget.habilitado && widget.value > widget.minValue
              ? () => widget.onChanged(widget.value - 1)
              : null,
        ),
        SizedBox(
          width: 28,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.habilitado,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: _onSubmitted,
          ),
        ),
        _stepButton(
          icon: Icons.add,
          etiqueta: widget.etiquetaAgregar,
          onTap: widget.habilitado ? _sumar : null,
          apagado: _enMaximo,
        ),
      ],
    );
  }

  /// [apagado]: se ve deshabilitado pero al tocarlo avisa el límite.
  Widget _stepButton({
    required IconData icon,
    String? etiqueta,
    VoidCallback? onTap,
    bool apagado = false,
  }) {
    final pal = context.pal;
    final inactivo = onTap == null || apagado;
    final boton = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: widget.tactil,
        height: widget.tactil,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: inactivo
                  ? pal.campo(Colors.black12)
                  : pal.rojoSuave(
                      ContadorCantidad.splashRojo.withValues(alpha: 0.15),
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15,
              color: inactivo
                  ? pal.atenuado(Colors.black38)
                  : pal.rojo(ContadorCantidad.splashRojo),
            ),
          ),
        ),
      ),
    );
    if (etiqueta == null) return boton;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: etiqueta,
      excludeSemantics: true,
      child: boton,
    );
  }
}
