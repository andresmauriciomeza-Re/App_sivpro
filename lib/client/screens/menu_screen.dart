import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/search.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/catalogo_repository.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/imagen_producto.dart';
import 'category_products_screen.dart';
import '../widgets/bottom_nav.dart';
import '../../shared/mensaje_app.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _Menu());
}

/// Cuerpo del menú, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Menu extends StatefulWidget {
  const _Menu();

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)
  String _filtroActivo = 'Todas';
  final _searchController = TextEditingController();

  final List<String> _filtros = [
    'Todas',
    seccionPizzas,
    seccionLasanas,
    seccionFavoritas,
  ];

  Map<String, List<ProductoCatalogo>>? _secciones;
  String? _error;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _cargar();
  }

  /// Carga el catálogo (o lo recarga al jalar para refrescar). Si falla y ya
  /// había productos, se conservan y solo se avisa.
  Future<void> _cargar({bool recargar = false}) async {
    try {
      final productos = await CatalogoRepository.instance.productos(
        recargar: recargar,
      );
      if (!mounted) return;
      setState(() {
        _secciones = seccionesMenu(productos);
        _error = null;
        _cargando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (_secciones != null) {
        ScaffoldMessenger.of(context).mostrarMensaje(
          error.message,
          tipo: TipoMensaje.error,
          sobreBarraPanel: false,
        );
      }
      setState(() {
        _error = error.message;
        _cargando = false;
      });
    }
  }

  void _reintentar() {
    setState(() {
      _cargando = true;
      _error = null;
    });
    _cargar(recargar: true);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool get _buscando => _searchController.text.trim().isNotEmpty;

  List<MapEntry<String, ProductoCatalogo>> get _resultadosBusqueda {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return [
      for (final entry in (_secciones ?? const {}).entries)
        for (final item in entry.value)
          if (item.nombre.toLowerCase().contains(query) ||
              (item.descripcion ?? '').toLowerCase().contains(query))
            MapEntry(entry.key, item),
    ];
  }

  List<MapEntry<String, List<ProductoCatalogo>>> get _categoriasVisibles => [
    for (final entry in (_secciones ?? const {}).entries)
      if (entry.value.isNotEmpty &&
          (_filtroActivo == 'Todas' || entry.key == _filtroActivo))
        entry,
  ];

  void _abrirCategoria(String categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CategoryProductsScreen.catalogo(categoryName: categoria),
      ),
    );
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    setState(() {});
  }

  Widget _buildChips() {
    final pal = context.pal;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filtros.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final filtro = _filtros[i];
          final activo = filtro == _filtroActivo;
          return GestureDetector(
            onTap: () {
              if (filtro == 'Todas') {
                setState(() => _filtroActivo = filtro);
                return;
              }
              _abrirCategoria(filtro);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activo
                    ? pal.rojoBoton(splashRojo)
                    : pal.tarjeta(Colors.white),
                borderRadius: BorderRadius.circular(30),
                border: activo
                    ? null
                    : Border.all(color: pal.borde(Colors.black12)),
              ),
              child: Text(
                filtro,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : pal.secundario(Colors.black54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSinResultados() {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 56, color: pal.atenuado(Colors.black26)),
          const SizedBox(height: 14),
          Text(
            'No encontramos pizzas con ese nombre',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: pal.secundario(Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _limpiarBusqueda,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              'Limpiar búsqueda',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: pal.rojo(splashRojo),
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: pal.rojo(splashRojo),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosBusqueda() {
    final resultados = _resultadosBusqueda;
    if (resultados.isEmpty) return _buildSinResultados();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final result in resultados)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _MenuCard(
              item: result.value,
              onTap: () => _abrirCategoria(result.key),
            ),
          ),
      ],
    );
  }

  /// Carga, error con "Reintentar" o catálogo vacío; null si hay productos.
  Widget? _buildEstado() {
    final pal = context.pal;
    if (_cargando) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: pal.rojo(splashRojo)),
        ),
      );
    }
    final error = _error;
    if (error != null && _secciones == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: pal.atenuado(Colors.black26),
            ),
            const SizedBox(height: 14),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: pal.secundario(Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reintentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: pal.rojoBoton(splashRojo),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    if (_categoriasVisibles.isEmpty && !_buscando) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Text(
          'No hay productos disponibles.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: pal.secundario(Colors.black54),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final estado = _buildEstado();
    return Scaffold(
      backgroundColor: pal.fondo(fondoClaro),
      body: SafeArea(
        child: RefreshIndicator(
          color: pal.rojo(splashRojo),
          onRefresh: () => _cargar(recargar: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Image.asset(
                        'assets/img/logo_blanc7.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'La Sirena',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuestro Menú',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Elige tu pizza favorita y personalízala a tu gusto',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: pal.texto(Colors.black),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppSearchField(
                  controller: _searchController,
                  hint: 'Buscar pizza...',
                  showClearButton: true,
                ),
              ),
              const SizedBox(height: 18),

              if (!_buscando) _buildChips(),
              if (!_buscando) const SizedBox(height: 8),

              if (estado != null)
                estado
              else if (_buscando)
                _buildResultadosBusqueda()
              else
                for (final entry in _categoriasVisibles) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      entry.key,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _MenuCard(
                      item: entry.value.first,
                      onTap: () => _abrirCategoria(entry.key),
                      textoNegro: true,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

// ============================================================
// Tarjeta destacada de cada categoría en el menú principal
// ============================================================
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
    required this.onTap,
    this.textoNegro = false,
  });

  final ProductoCatalogo item;
  final VoidCallback onTap;
  final bool textoNegro;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final descripcion = item.descripcion;
    final imagen = AspectRatio(
      aspectRatio: 16 / 10,
      child: ImagenProducto(
        producto: item,
        width: double.infinity,
        fit: BoxFit.cover,
        respaldo: (context) => Container(
          color: pal.campo(Colors.grey.shade200),
          alignment: Alignment.center,
          child: Icon(Icons.local_pizza, color: pal.rojo(splashRojo), size: 40),
        ),
      ),
    );
    return Material(
      color: pal.tarjeta(Colors.white),
      // En oscuro, borde fino en lugar de sombra.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: pal.oscuro
            ? const BorderSide(color: PaletaApp.bordeOscuro)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    // "No disponible": foto atenuada.
                    child: item.estado == EstadoMenu.noDisponible
                        ? Opacity(opacity: 0.5, child: imagen)
                        : imagen,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: EtiquetaEstado(estado: item.estado),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: pal.texto(const Color(0xFF1A1A1A)),
                      ),
                    ),
                    if (descripcion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: pal.secundario(Colors.black54),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Ver todo',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textoNegro
                            ? pal.texto(Colors.black)
                            : pal.rojo(splashRojo),
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
