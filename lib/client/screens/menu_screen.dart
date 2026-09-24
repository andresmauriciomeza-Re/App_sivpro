import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/menu_item.dart';
import 'category_products_screen.dart';
import '../widgets/bottom_nav.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  // (el índice de la barra de navegación ahora lo maneja AppBottomNav)
  String _filtroActivo = 'Todas';
  final _searchController = TextEditingController();

  final List<String> _filtros = ['Todas', 'Pizzas', 'Lasañas', 'Favoritas'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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

  List<MapEntry<String, MenuItem>> get _resultadosBusqueda {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return [
      for (final entry in categoriasMenu.entries)
        for (final item in entry.value)
          if (item.nombre.toLowerCase().contains(query) ||
              item.descripcion.toLowerCase().contains(query))
            MapEntry(entry.key, item),
    ];
  }

  List<MapEntry<String, List<MenuItem>>> get _categoriasVisibles {
    if (_filtroActivo == 'Todas') return categoriasMenu.entries.toList();
    return categoriasMenu.entries.where((e) => e.key == _filtroActivo).toList();
  }

  void _abrirCategoria(String categoria, List<MenuItem> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CategoryProductsScreen(categoryName: categoria, items: items),
      ),
    );
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    setState(() {});
  }

  Widget _buildChips() {
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
              _abrirCategoria(filtro, categoriasMenu[filtro] ?? []);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activo ? splashRojo : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: activo ? null : Border.all(color: Colors.black12),
              ),
              child: Text(
                filtro,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSinResultados() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 56, color: Colors.black26),
          const SizedBox(height: 14),
          Text(
            'No encontramos pizzas con ese nombre',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
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
                color: splashRojo,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: splashRojo,
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
              onTap: () =>
                  _abrirCategoria(result.key, categoriasMenu[result.key] ?? []),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoClaro,
      body: SafeArea(
        child: ListView(
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
                      color: Colors.black87,
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige tu pizza favorita y personalízala a tu gusto',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar pizza...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black45),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _limpiarBusqueda,
                          tooltip: 'Limpiar búsqueda',
                          icon: const Icon(Icons.cancel, color: Colors.black45),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            if (!_buscando) _buildChips(),
            if (!_buscando) const SizedBox(height: 8),

            if (_buscando)
              _buildResultadosBusqueda()
            else
              for (final entry in _categoriasVisibles) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    entry.key,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      color: Colors.black87,
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
                    onTap: () => _abrirCategoria(entry.key, entry.value),
                    textoNegro: true,
                  ),
                ),
              ],
          ],
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

  final MenuItem item;
  final VoidCallback onTap;
  final bool textoNegro;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.asset(
                        item.imagen,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_pizza,
                            color: splashRojo,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34A853),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Disponible',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.descripcion,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ver todo',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textoNegro ? Colors.black : splashRojo,
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
