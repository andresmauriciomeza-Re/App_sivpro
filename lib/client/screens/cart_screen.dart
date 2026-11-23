import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/cart_service.dart';
import '../services/catalogo_repository.dart';
import '../services/validacion_carrito.dart';
import 'menu_screen.dart';
import 'payment_method_screen.dart';
import '../widgets/bottom_nav.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _Carrito());
}

/// Cuerpo del carrito, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Carrito extends StatefulWidget {
  const _Carrito();

  @override
  State<_Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<_Carrito> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  /// Catálogo recién cargado para revisar el carrito; null si aún no llega.
  List<ProductoCatalogo>? _catalogo;
  String? _errorCatalogo;
  bool _abriendoPago = false;

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)

  @override
  void initState() {
    super.initState();
    _revisar();
  }

  /// Recarga el catálogo (sin caché) para revisar disponibilidad y stock.
  Future<void> _revisar() async {
    try {
      final catalogo = await CatalogoRepository.instance.productos(
        recargar: true,
      );
      if (!mounted) return;
      setState(() {
        _catalogo = catalogo;
        _errorCatalogo = null;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _errorCatalogo = error.message);
    }
  }

  Map<String, EstadoLinea> _estados(CartService cart) {
    final catalogo = _catalogo;
    return catalogo == null ? const {} : validarCarrito(cart.items, catalogo);
  }

  /// Justo antes de pagar se vuelve a revisar el carrito. Si el catálogo no
  /// carga no se bloquea: el servidor valida igual al crear el pedido.
  Future<void> _irAPagar() async {
    if (_abriendoPago) return;
    setState(() => _abriendoPago = true);
    await _revisar();
    if (!mounted) return;
    setState(() => _abriendoPago = false);
    if (_estados(CartService.instance).values.any((e) => e.bloquea)) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cart = CartService.instance;

        return Scaffold(
          backgroundColor: context.pal.fondo(fondoClaro),
          body: SafeArea(
            child: cart.estaVacio
                ? _buildEmptyState(context)
                : _buildItemsState(context, cart),
          ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 2),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // Estado 1: carrito vacío
  // ----------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    final pal = context.pal;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'La Sirena',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              color: pal.texto(Colors.black87),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: pal.rojo(splashRojo).withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu carrito está vacío',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega algunas pizzas deliciosas para comenzar tu pedido',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: pal.secundario(Colors.black54),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          noAnimationRoute(const MenuScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pal.rojoBoton(splashRojo),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Ver el menú',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Aviso sobre la lista: catálogo que no cargó o líneas que bloquean.
  Widget _aviso({
    required String texto,
    required Color fondo,
    required Color color,
    VoidCallback? reintentar,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (reintentar != null)
              TextButton(
                onPressed: reintentar,
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Estado 2: carrito con productos
  // ----------------------------------------------------------
  Widget _buildItemsState(BuildContext context, CartService cart) {
    final pal = context.pal;
    final estados = _estados(cart);
    final bloqueado = estados.values.any((e) => e.bloquea);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 20, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: pal.texto(Colors.black87)),
              ),
              Text(
                'Carrito',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  color: pal.texto(const Color(0xFF1A1A1A)),
                ),
              ),
            ],
          ),
        ),
        if (_errorCatalogo != null)
          _aviso(
            texto: 'No pudimos revisar la disponibilidad. $_errorCatalogo',
            fondo: pal.avisoFondo(const Color(0xFFFFF4E5)),
            color: pal.avisoTexto(const Color(0xFF8A5A00)),
            reintentar: _revisar,
          ),
        if (bloqueado)
          _aviso(
            texto:
                'Algunos productos se agotaron o ya no tienen stock '
                'suficiente. Revisa tu carrito.',
            fondo: pal.errorFondo(const Color(0xFFFFEBEE)),
            color: pal.errorTexto(const Color(0xFFC62828)),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(
                item: item,
                estado: estados[item.id] ?? EstadoLinea.correcta,
                key: ValueKey(item.id),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: pal.tarjeta(Colors.white),
            border: Border(top: BorderSide(color: pal.borde(Colors.black12))),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: pal.secundario(Colors.black54),
                    ),
                  ),
                  Text(
                    formatCop(cart.subtotal),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: pal.secundario(Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  Text(
                    formatCop(cart.total),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bloqueado || _abriendoPago ? null : _irAPagar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pal.rojoBoton(splashRojo),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Ir a pagar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.estado, super.key});

  final CartItem item;
  final EstadoLinea estado;

  static const Color splashRojo = Color(0xE6C32828);

  bool get _esPizza =>
      item.tamanoNombre == 'Mediana' || item.tamanoNombre == 'Grande';

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final maximo = estado.maximo;
    final puedeSumar =
        !estado.noDisponible && (maximo == null || item.cantidad < maximo);
    final colorError = pal.errorTexto(const Color(0xFFC62828));
    final mensaje = estado.mensaje;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(16),
        // La línea que bloquea el pago se marca en rojo; en oscuro, borde
        // fino en lugar de sombra.
        border: estado.bloquea
            ? Border.all(color: colorError, width: 1.2)
            : pal.oscuro
            ? Border.all(color: PaletaApp.bordeOscuro)
            : null,
        boxShadow: [
          BoxShadow(
            color: pal.sombra(Colors.black.withValues(alpha: 0.05)),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagen,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: pal.campo(Colors.grey.shade200),
                child: Icon(
                  Icons.local_pizza,
                  color: pal.rojo(splashRojo),
                  size: 24,
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
                  item.nombre,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: pal.texto(Colors.black87),
                  ),
                ),
                const SizedBox(height: 2),
                if (item.tamanoNombre.isNotEmpty)
                  Text(
                    _esPizza
                        ? 'Tamaño: ${item.tamanoNombre} · '
                              '${item.cantidad == 1 ? '1 porción' : '${item.cantidad} porciones'}'
                        : 'Tamaño: ${item.tamanoNombre}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                if (item.adicionesTexto.isNotEmpty)
                  Text(
                    'Adiciones: ${item.adicionesTexto}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                if (mensaje != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      mensaje,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colorError,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stepButton(
                      context,
                      icon: Icons.remove,
                      etiqueta: 'Quitar uno de ${item.nombre}',
                      onTap: () => CartService.instance.updateQuantity(
                        item.id,
                        item.cantidad - 1,
                      ),
                    ),
                    _CartQuantityStepper(
                      itemId: item.id,
                      cantidad: item.cantidad,
                      maximo: estado.noDisponible ? item.cantidad : maximo,
                    ),
                    _stepButton(
                      context,
                      icon: Icons.add,
                      etiqueta: 'Agregar uno de ${item.nombre}',
                      onTap: puedeSumar
                          ? () => CartService.instance.updateQuantity(
                              item.id,
                              item.cantidad + 1,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => CartService.instance.removeItem(item.id),
                tooltip: 'Quitar del carrito',
                icon: Icon(
                  Icons.delete_outline,
                  color: pal.rojo(splashRojo),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 14),
              Text(
                formatCop(item.subtotal),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: pal.texto(Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(
    BuildContext context, {
    required IconData icon,
    required String etiqueta,
    VoidCallback? onTap,
  }) {
    final pal = context.pal;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: etiqueta,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: onTap == null
                ? pal.campo(Colors.black12)
                : pal.rojoSuave(splashRojo.withValues(alpha: 0.15)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: onTap == null
                ? pal.atenuado(Colors.black38)
                : pal.rojo(splashRojo),
          ),
        ),
      ),
    );
  }
}

class _CartQuantityStepper extends StatefulWidget {
  const _CartQuantityStepper({
    required this.itemId,
    required this.cantidad,
    required this.maximo,
  });

  final String itemId;
  final int cantidad;

  /// Tope al escribir la cantidad; null = sin límite.
  final int? maximo;

  @override
  State<_CartQuantityStepper> createState() => _CartQuantityStepperState();
}

class _CartQuantityStepperState extends State<_CartQuantityStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.cantidad}');
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_CartQuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cantidad != oldWidget.cantidad && !_focusNode.hasFocus) {
      _controller.text = '${widget.cantidad}';
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
    final bool valido = parsed != null && parsed >= 1;
    if (!valido || parsed == widget.cantidad) {
      _controller.text = '${widget.cantidad}';
      return;
    }
    // Escribiendo no se pasa del máximo (como la web: se ajusta sola).
    final maximo = widget.maximo;
    final cantidad = maximo != null && parsed > maximo
        ? (maximo < 1 ? widget.cantidad : maximo)
        : parsed;
    _controller.text = '$cantidad';
    if (cantidad != widget.cantidad) {
      CartService.instance.updateQuantity(widget.itemId, cantidad);
    }
  }

  void _onSubmitted(String value) {
    _sincronizar();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: _onSubmitted,
      ),
    );
  }
}
