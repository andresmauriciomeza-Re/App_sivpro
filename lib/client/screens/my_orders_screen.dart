import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/client_notification_service.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/pedido.dart';
import '../models/producto_catalogo.dart';
import '../services/catalogo_repository.dart';
import '../services/horario_local.dart';
import '../services/pedidos_repository.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/estado_pedido.dart';
import '../widgets/imagen_producto.dart';
import 'menu_screen.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _MisPedidos());
}

/// "d/m/aaaa, 6:30 p. m." de una fecha del backend (hora de Bogotá).
String fechaPedidoTexto(DateTime fecha) =>
    '${fecha.day}/${fecha.month}/${fecha.year}, '
    '${HorarioLocal.texto(fecha.hour * 60 + fecha.minute)}';

/// Cuerpo de Mis pedidos, bajo [TemaCliente] para que `context.pal` vea su
/// tema.
class _MisPedidos extends StatefulWidget {
  const _MisPedidos();

  @override
  State<_MisPedidos> createState() => _MisPedidosState();
}

class _MisPedidosState extends State<_MisPedidos> {
  static const Color splashRojo = Color(0xE6C32828);

  final _repositorio = PedidosRepository.instance;
  bool _cargando = false;
  String? _error;

  /// Productos del catálogo por id, para las miniaturas.
  Map<int, ProductoCatalogo> _productos = const {};

  @override
  void initState() {
    super.initState();
    // Tras el primer cuadro: la barra de la pestaña anterior aún se construye.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ClientNotificationService.instance.markAllRead(),
    );
    _repositorio.addListener(_alCambiar);
    _cargar();
    _cargarImagenes();
  }

  @override
  void dispose() {
    _repositorio.removeListener(_alCambiar);
    super.dispose();
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _repositorio.listar(recargar: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (_repositorio.pedidos == null) {
        setState(() => _error = error.message);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarImagenes() async {
    try {
      final catalogo = await CatalogoRepository.instance.productos();
      if (!mounted) return;
      setState(
        () => _productos = {
          for (final p in catalogo)
            if (p.id != null) p.id!: p,
        },
      );
    } on ApiException {
      // Sin catálogo las tarjetas muestran el ícono de pizza.
    }
  }

  Future<void> _abrirDetalle(Pedido pedido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(pedido: pedido)),
    );
    ClientNotificationService.instance.markAllRead();
  }

  /// Contenido desplazable (para que siempre se pueda tirar y recargar).
  Widget _centrado(Widget hijo) => LayoutBuilder(
    builder: (context, restricciones) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: restricciones.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: hijo,
          ),
        ),
      ),
    ),
  );

  Widget _boton(String texto, VoidCallback alTocar) {
    final pal = context.pal;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: alTocar,
        style: ElevatedButton.styleFrom(
          backgroundColor: pal.rojoBoton(splashRojo),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          texto,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final pal = context.pal;
    return _centrado(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 90,
            color: pal.rojo(splashRojo).withValues(alpha: 0.35),
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes pedidos',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              color: pal.texto(Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando hagas tu primer pedido, lo verás aquí',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: pal.secundario(Colors.black54),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _boton(
            'Ir al menú',
            () => Navigator.pushReplacement(
              context,
              noAnimationRoute(const MenuScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String mensaje) {
    final pal = context.pal;
    return _centrado(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: pal.atenuado(Colors.black38),
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: pal.texto(Colors.black87),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _boton('Reintentar', _cargar),
        ],
      ),
    );
  }

  Widget _buildLista() {
    final pedidos = _repositorio.pedidos;
    final error = _error;
    if (pedidos == null) {
      if (error != null) return _buildError(error);
      return Center(
        child: CircularProgressIndicator(color: context.pal.rojo(splashRojo)),
      );
    }
    if (pedidos.isEmpty) return _buildEmptyState();
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: pedidos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return _OrderCard(
          pedido: pedido,
          productos: _productos,
          onTap: () => _abrirDetalle(pedido),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      backgroundColor: pal.fondo(const Color(0xFFFCF7F5)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Pedidos',
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  color: pal.texto(Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Revisa el estado de tus pedidos recientes y tu historial de compras',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: pal.texto(const Color(0xFF1A1A1A)),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                color: pal.rojo(splashRojo),
                onRefresh: () => _cargando ? Future.value() : _cargar(),
                child: _buildLista(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.pedido,
    required this.productos,
    required this.onTap,
  });

  final Pedido pedido;
  final Map<int, ProductoCatalogo> productos;
  final VoidCallback onTap;
  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final fecha = pedido.fecha;
    // Una miniatura por producto distinto (ícono si no está en el catálogo).
    final miniaturas = [
      for (final id in {for (final d in pedido.detalles) d.idProducto})
        productos[id],
    ];
    Widget respaldo(BuildContext context) => Container(
      width: 44,
      height: 44,
      color: pal.campo(Colors.grey.shade200),
      child: Icon(Icons.local_pizza, color: pal.rojo(splashRojo), size: 18),
    );
    return Material(
      color: pal.tarjeta(Colors.white),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: pal.oscuro
                ? Border.all(color: pal.borde(Colors.black12))
                : null,
            boxShadow: [
              BoxShadow(
                color: pal.sombra(Colors.black.withValues(alpha: 0.05)),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pedido #${pedido.id}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: EtiquetaEstadoPedido(
                      estadoCliente: pedido.estadoCliente,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if (fecha != null)
                    _Dato(
                      icono: Icons.calendar_today,
                      texto: fechaPedidoTexto(fecha),
                    ),
                  _Dato(
                    icono: Icons.restaurant_menu,
                    texto: pedido.articulos == 1
                        ? '1 artículo'
                        : '${pedido.articulos} artículos',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    for (final producto in miniaturas.take(2))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: producto == null
                              ? respaldo(context)
                              : ImagenProducto(
                                  producto: producto,
                                  width: 44,
                                  height: 44,
                                  respaldo: respaldo,
                                ),
                        ),
                      ),
                    if (miniaturas.length > 2)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: pal.campo(Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${miniaturas.length - 2}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: pal.secundario(Colors.black54),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: pal.atenuado(Colors.black45),
                          ),
                        ),
                        Text(
                          formatCop(pedido.monto),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: pal.texto(Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: pal.rojo(splashRojo),
                      side: BorderSide(color: pal.borde(Colors.black12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Ver detalles',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: pal.texto(Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final color = context.pal.atenuado(Colors.black45);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: color),
        const SizedBox(width: 6),
        Text(texto, style: GoogleFonts.poppins(fontSize: 13, color: color)),
      ],
    );
  }
}
