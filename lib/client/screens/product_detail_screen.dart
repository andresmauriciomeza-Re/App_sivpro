import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/cart_service.dart';
import '../services/catalogo_repository.dart';
import '../services/tipos_bebida.dart';
import '../widgets/adiciones.dart';
import '../widgets/imagen_producto.dart';
import 'drinks_screen.dart';
import '../../shared/mensaje_app.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.producto});

  final ProductoCatalogo producto;

  @override
  Widget build(BuildContext context) =>
      TemaCliente(child: _Detalle(producto: producto));
}

/// Cuerpo del detalle, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Detalle extends StatefulWidget {
  const _Detalle({required this.producto});

  final ProductoCatalogo producto;

  @override
  State<_Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<_Detalle> {
  static const Color splashRojo = Color(0xE6C32828);

  late int _tamanoSeleccionado;
  int _cantidad = 1;

  /// Cantidad de cada bebida (adición); se comparte con "Bebidas".
  final AdicionesElegidas _elegidas = AdicionesElegidas();
  List<ProductoCatalogo> _bebidas = const [];
  bool _cargandoBebidas = false;
  String? _errorBebidas;

  ProductoCatalogo get _producto => widget.producto;

  @override
  void initState() {
    super.initState();
    _tamanoSeleccionado = _tamanoInicial();
    _elegidas.addListener(_alElegirBebida);
    if (_producto.conAdiciones) {
      _cargandoBebidas = true;
      _cargarBebidas();
    }
  }

  void _alElegirBebida() => setState(() {});

  @override
  void dispose() {
    _elegidas.dispose();
    super.dispose();
  }

  /// Como hoy, con dos tamaños se propone el segundo (Grande), salvo que
  /// esté agotado.
  int _tamanoInicial() {
    final tamanos = _producto.tamanos;
    if (tamanos.length < 2) return 0;
    if (!tamanos[1].agotado) return 1;
    final libre = tamanos.indexWhere((t) => !t.agotado);
    return libre < 0 ? 1 : libre;
  }

  /// Las adiciones son las bebidas reales del catálogo.
  Future<void> _cargarBebidas() async {
    try {
      final productos = await CatalogoRepository.instance.productos();
      if (!mounted) return;
      setState(() {
        _bebidas = bebidasDe(productos);
        _cargandoBebidas = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorBebidas = error.message;
        _cargandoBebidas = false;
      });
    }
  }

  void _reintentarBebidas() {
    setState(() {
      _cargandoBebidas = true;
      _errorBebidas = null;
    });
    _cargarBebidas();
  }

  TamanoProducto? get _tamano =>
      _producto.tamanos.isEmpty ? null : _producto.tamanos[_tamanoSeleccionado];

  int get _precio => _tamano?.precio ?? _producto.precioBase;

  /// Máximo a pedir: el stock disponible (en pizza, porciones del tamaño).
  int? get _maximo => _producto.limiteDe(_tamano);

  bool get _sePuedePedir =>
      _producto.disponible &&
      !_producto.agotado &&
      !(_tamano?.agotado ?? false);

  /// (precio del tamaño × cantidad) + (cada adición × su cantidad).
  int get _total {
    var total = _precio * _cantidad;
    for (final bebida in _bebidas) {
      total += bebida.precioBase * _elegidas.de(bebida);
    }
    return total;
  }

  String _mensajeMaximo(int maximo) {
    final nombre = _producto.nombre;
    final tamano = _tamano?.nombre;
    if (_producto.esPizza) {
      return maximo == 1
          ? 'Solo queda 1 porción de $nombre $tamano disponible'
          : 'Solo quedan $maximo porciones de $nombre $tamano disponibles';
    }
    return 'Solo quedan $maximo $nombre${tamano == null ? '' : ' $tamano'} '
        'disponibles';
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).mostrarMensaje(mensaje, tipo: TipoMensaje.error, sobreBarraPanel: false);
  }

  void _elegirTamano(int i) {
    setState(() {
      _tamanoSeleccionado = i;
      final maximo = _maximo;
      if (maximo != null && maximo > 0 && _cantidad > maximo) {
        _cantidad = maximo;
      }
    });
  }

  String get _textoBoton {
    if (!_producto.disponible) return 'No disponible por ahora';
    if (!_sePuedePedir) return 'Agotado';
    if (_producto.esPizza) {
      return _cantidad == 1
          ? 'Agregar 1 porción al carrito'
          : 'Agregar $_cantidad porciones al carrito';
    }
    return 'Agregar al carrito';
  }

  /// "Quedan N porciones" / "Agotado" bajo cada tamaño, si hay stock.
  String? _detalleTamano(TamanoProducto tamano) {
    final disponibles = _producto.limiteDe(tamano);
    if (disponibles == null) return null;
    if (disponibles == 0) return 'Agotado';
    if (!_producto.esPizza) return 'Quedan $disponibles';
    return disponibles == 1
        ? 'Queda 1 porción'
        : 'Quedan $disponibles porciones';
  }

  void _agregarAlCarrito() {
    final adicionesSeleccionadas = [
      for (final bebida in _bebidas)
        if (_elegidas.de(bebida) > 0)
          CartAddition(
            nombre: bebida.nombre,
            precio: bebida.precioBase,
            cantidad: _elegidas.de(bebida),
            idProducto: bebida.id,
          ),
    ];

    CartService.instance.addItem(
      CartItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        idProducto: _producto.id,
        nombre: _producto.nombre,
        imagen: _producto.assetLocal ?? '',
        tamanoNombre: _tamano?.nombre ?? '',
        precioBase: _precio,
        adiciones: adicionesSeleccionadas,
        cantidad: _cantidad,
      ),
      maximo: _maximo,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF34A853),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Agregado al carrito',
                style: GoogleFonts.poppins(
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
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final item = _producto;
    final descripcion = item.descripcion;
    final maximo = _maximo;

    return Scaffold(
      backgroundColor: pal.fondo(const Color(0xFFFCF7F5)),
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
                      icon: Icon(
                        Icons.arrow_back,
                        color: pal.texto(Colors.black87),
                      ),
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
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'La Sirena',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: pal.texto(Colors.black87),
                            ),
                          ),
                          Text(
                            'Pizza · Desde 1994',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: pal.atenuado(Colors.black45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: ImagenProducto(
                  producto: item,
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  respaldo: (context) => Container(
                    height: 230,
                    color: pal.campo(Colors.grey.shade200),
                    child: Icon(
                      Icons.local_pizza,
                      color: pal.rojo(splashRojo),
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
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                    if (descripcion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: pal.texto(Colors.black87),
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),

                    if (item.tamanos.isNotEmpty) ...[
                      Text(
                        item.tamanos.length == 1 && !item.esPizza
                            ? 'Presentación'
                            : 'Elige el tamaño',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: pal.texto(Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < item.tamanos.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SizeOption(
                            nombre: item.tamanos[i].nombre,
                            precio: item.tamanos[i].precio,
                            porPorcion: item.esPizza,
                            detalle: _detalleTamano(item.tamanos[i]),
                            seleccionado: _tamanoSeleccionado == i,
                            habilitado: !item.tamanos[i].agotado,
                            onTap: () => _elegirTamano(i),
                          ),
                        ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.esPizza ? 'Porciones' : 'Cantidad',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: pal.texto(Colors.black87),
                          ),
                        ),
                        ContadorCantidad(
                          value: _cantidad,
                          minValue: 1,
                          maxValue: maximo,
                          habilitado: _sePuedePedir,
                          alLimite: maximo == null
                              ? null
                              : () => _avisar(_mensajeMaximo(maximo)),
                          onChanged: (v) => setState(() => _cantidad = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.conAdiciones) ..._buildAdiciones(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBarraTotal(),
    );
  }

  /// Total y botón fijos abajo: siempre visibles; solo se desplaza lo de
  /// arriba. Los avisos (SnackBar) aparecen por encima de esta barra.
  Widget _buildBarraTotal() {
    final pal = context.pal;
    return ColoredBox(
      color: pal.fondo(const Color(0xFFFCF7F5)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Total a pagar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: pal.texto(Colors.black87),
                          ),
                        ),
                      ),
                      Text(
                        formatCop(_total),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: pal.texto(Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sePuedePedir ? _agregarAlCarrito : null,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        _textoBoton,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pal.rojoBoton(splashRojo),
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
    );
  }

  /// "Adiciones (Bebidas)": las bebidas reales, con su precio y su stock.
  List<Widget> _buildAdiciones() {
    final pal = context.pal;
    final error = _errorBebidas;
    if (!_cargandoBebidas && error == null && _bebidas.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          'Adiciones (Bebidas)',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: pal.texto(Colors.black87),
          ),
        ),
      ),
      if (_cargandoBebidas)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: pal.rojo(splashRojo),
              ),
            ),
          ),
        )
      else if (error != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: pal.secundario(Colors.black54),
                  ),
                ),
              ),
              TextButton(
                onPressed: _reintentarBebidas,
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: pal.rojo(splashRojo),
                  ),
                ),
              ),
            ],
          ),
        )
      else
        ..._buildListaBebidas(),
      const SizedBox(height: 20),
    ];
  }

  /// Las cuatro destacadas, una debajo de otra, y el acceso a todas.
  List<Widget> _buildListaBebidas() {
    final pal = context.pal;
    final destacadas = bebidasDestacadas(_bebidas);
    return [
      for (final bebida in destacadas)
        Padding(
          key: ValueKey('bebida-${bebida.id ?? bebida.nombre}'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: _buildBebida(bebida),
        ),
      if (_bebidas.length > destacadas.length)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextButton(
            onPressed: _verMasBebidas,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: pal.rojo(splashRojo),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Ver más bebidas',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
    ];
  }

  void _verMasBebidas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BebidasScreen(
          bebidas: _bebidas,
          elegidas: _elegidas,
          nombreProducto: _producto.nombre,
        ),
      ),
    );
  }

  Widget _buildBebida(ProductoCatalogo bebida) {
    final pal = context.pal;
    final precio = precioDeBebida(bebida);
    final fila = Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.borde(Colors.black12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // Botellas altas y angostas: se ven completas.
            child: ImagenProducto(
              producto: bebida,
              width: 52,
              height: 52,
              fit: BoxFit.contain,
              respaldo: (context) => Container(
                width: 52,
                height: 52,
                color: pal.campo(Colors.grey.shade200),
                child: Icon(
                  Icons.local_drink,
                  color: pal.rojo(splashRojo),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bebida.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: pal.texto(Colors.black87),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  precio,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: pal.secundario(Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          ContadorBebida(bebida: bebida, elegidas: _elegidas),
        ],
      ),
    );
    return Semantics(
      container: true,
      label: '${bebida.nombre}, $precio, cantidad ${_elegidas.de(bebida)}',
      child: bebida.estado == EstadoMenu.disponible
          ? fila
          : Opacity(opacity: 0.5, child: fila),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.nombre,
    required this.precio,
    required this.porPorcion,
    required this.detalle,
    required this.seleccionado,
    required this.habilitado,
    required this.onTap,
  });

  final String nombre;
  final int precio;

  /// Pizza: el precio es por porción.
  final bool porPorcion;

  /// "Quedan N porciones" o "Agotado"; null si no hay dato de stock.
  final String? detalle;
  final bool seleccionado;
  final bool habilitado;
  final VoidCallback onTap;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final rojo = pal.rojo(splashRojo);
    final texto = seleccionado ? rojo : pal.texto(Colors.black87);
    final detalle = this.detalle;
    final opcion = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: habilitado ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? rojo : pal.borde(Colors.black12),
            width: seleccionado ? 1.6 : 1,
          ),
          color: seleccionado
              ? pal.rojoSuave(splashRojo.withValues(alpha: 0.05))
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, caja) => Row(
            children: [
              Icon(
                seleccionado
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: seleccionado ? rojo : pal.secundario(Colors.black38),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: texto,
                      ),
                    ),
                    if (detalle != null)
                      Text(
                        detalle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: habilitado
                              ? pal.secundario(Colors.black54)
                              : pal.errorTexto(const Color(0xFFD32F2F)),
                        ),
                      ),
                  ],
                ),
              ),
              // Con letra grande en pantallas angostas el precio se reduce
              // en vez de desbordar.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: caja.maxWidth * 0.55),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${formatCop(precio)}${porPorcion ? ' / porción' : ''}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: texto,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return habilitado ? opcion : Opacity(opacity: 0.6, child: opcion);
  }
}
