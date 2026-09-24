import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/menu_item.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.item});

  final MenuItem item;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color splashRojo = Color(0xE6C32828);

  late int _tamanoSeleccionado;
  int _cantidad = 1;
  late Map<String, int> _adicionesCantidad;

  @override
  void initState() {
    super.initState();
    _tamanoSeleccionado = widget.item.tamanos.length > 1 ? 1 : 0;
    _adicionesCantidad = {for (final a in widget.item.adiciones) a.nombre: 0};
  }

  int get _total {
    final size = widget.item.tamanos[_tamanoSeleccionado];
    int total = size.precio * _cantidad;
    for (final a in widget.item.adiciones) {
      total += a.precio * (_adicionesCantidad[a.nombre] ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: Image.asset(
                        'assets/img/logo_blanc7.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'La Sirena',
                          style: GoogleFonts.dmSerifDisplay(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Pizza · Desde 1994',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  item.imagen,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 230,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.local_pizza,
                      color: splashRojo,
                      size: 60,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.descripcion,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      'Elige el tamaño',
                      style: GoogleFonts.dmSerifDisplay(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (int i = 0; i < item.tamanos.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SizeOption(
                          nombre: item.tamanos[i].nombre,
                          precio: item.tamanos[i].precio,
                          seleccionado: _tamanoSeleccionado == i,
                          onTap: () => setState(() => _tamanoSeleccionado = i),
                        ),
                      ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cantidad',
                          style: GoogleFonts.dmSerifDisplay(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        _Stepper(
                          value: _cantidad,
                          minValue: 1,
                          onChanged: (v) => setState(() => _cantidad = v),
                        ),
                      ],
                    ),

                    if (item.adiciones.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Adiciones (Bebidas)',
                        style: GoogleFonts.dmSerifDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final a in item.adiciones)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  a.imagen,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 44,
                                        height: 44,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.local_drink,
                                          color: splashRojo,
                                          size: 20,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.nombre,
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${a.precio}',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 11,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _Stepper(
                                value: _adicionesCantidad[a.nombre] ?? 0,
                                minValue: 0,
                                onChanged: (v) => setState(
                                  () => _adicionesCantidad[a.nombre] = v,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a pagar',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${_formatoMiles(_total)}',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final adicionesSeleccionadas = item.adiciones
                              .where(
                                (a) => (_adicionesCantidad[a.nombre] ?? 0) > 0,
                              )
                              .map(
                                (a) => CartAddition(
                                  nombre: a.nombre,
                                  precio: a.precio,
                                  cantidad: _adicionesCantidad[a.nombre] ?? 0,
                                ),
                              )
                              .toList();

                          CartService.instance.addItem(
                            CartItem(
                              id: DateTime.now().microsecondsSinceEpoch
                                  .toString(),
                              nombre: item.nombre,
                              imagen: item.imagen,
                              tamanoNombre:
                                  item.tamanos[_tamanoSeleccionado].nombre,
                              precioBase:
                                  item.tamanos[_tamanoSeleccionado].precio,
                              adiciones: adicionesSeleccionadas,
                              cantidad: _cantidad,
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF34A853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              duration: const Duration(seconds: 2),
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Agregado al carrito',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: Text(
                          'Agregar al carrito',
                          style: GoogleFonts.dmSerifDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: splashRojo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.nombre,
    required this.precio,
    required this.seleccionado,
    required this.onTap,
  });

  final String nombre;
  final int precio;
  final bool seleccionado;
  final VoidCallback onTap;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? splashRojo : Colors.black12,
            width: seleccionado ? 1.6 : 1,
          ),
          color: seleccionado ? splashRojo.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: seleccionado ? splashRojo : Colors.black38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nombre,
                style: GoogleFonts.dmSerifDisplay(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: seleccionado ? splashRojo : Colors.black87,
                ),
              ),
            ),
            Text(
              '\$${_formatoMiles(precio)}',
              style: GoogleFonts.dmSerifDisplay(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: seleccionado ? splashRojo : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatefulWidget {
  const _Stepper({
    required this.value,
    required this.minValue,
    required this.onChanged,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  State<_Stepper> createState() => _StepperState();
}

class _StepperState extends State<_Stepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_Stepper oldWidget) {
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

  void _sincronizar() {
    final int? parsed = int.tryParse(_controller.text.trim());
    final bool valido = parsed != null && parsed >= widget.minValue;
    if (!valido || parsed == widget.value) {
      _controller.text = '${widget.value}';
      return;
    }
    widget.onChanged(parsed);
  }

  void _onSubmitted(String value) {
    _sincronizar();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          icon: Icons.remove,
          onTap: widget.value > widget.minValue
              ? () => widget.onChanged(widget.value - 1)
              : null,
        ),
        SizedBox(
          width: 28,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
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
          onTap: () => widget.onChanged(widget.value + 1),
        ),
      ],
    );
  }

  Widget _stepButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.black12
              : _Stepper.splashRojo.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: onTap == null ? Colors.black38 : _Stepper.splashRojo,
        ),
      ),
    );
  }
}

String _formatoMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}
