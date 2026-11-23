import 'package:material_ui/material_ui.dart';

import '../../auth/auth_service.dart';
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/producto_catalogo.dart';
import '../services/catalogo_repository.dart';
import '../services/horario_local.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/imagen_producto.dart';
import 'category_products_screen.dart';
import 'product_detail_screen.dart';

// Colores de Inicio en claro (en oscuro se usan los de la paleta).
const Color _rojoInicio = Color(0xFFE0472B);
const Color _textoInicio = Color(0xFF1F1B1B);
const Color _grisInicio = Color(0xFF8A8A8A);
const Color _fondoInicio = Color(0xFFF7F5F2);
const Color _verdeAbierto = Color(0xFF2E7D32);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _Inicio());
}

/// Cuerpo de Inicio, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Inicio extends StatefulWidget {
  const _Inicio();

  @override
  State<_Inicio> createState() => _InicioState();
}

class _InicioState extends State<_Inicio> {
  int _selectedCategoryIndex = 0;

  static const List<String> _categories = [
    seccionPizzas,
    seccionLasanas,
    seccionFavoritas,
  ];

  /// Las dos primeras Favoritas del catálogo real.
  List<ProductoCatalogo>? _destacadas;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool recargar = false}) async {
    try {
      final productos = await CatalogoRepository.instance.productos(
        recargar: recargar,
      );
      if (!mounted) return;
      setState(() {
        _destacadas = (seccionesMenu(productos)[seccionFavoritas] ?? const [])
            .take(2)
            .toList();
        _error = null;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  void _reintentar() {
    setState(() => _error = null);
    _cargar(recargar: true);
  }

  void _abrirSeccion(String seccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen.catalogo(categoryName: seccion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.fondo(_fondoInicio),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildTopBar(),
              const SizedBox(height: 16),
              _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Destacadas',
                onTap: () => _abrirSeccion(seccionFavoritas),
              ),
              const SizedBox(height: 12),
              _buildFeaturedList(),
              const SizedBox(height: 24),
              _buildSectionHeader('Categorías'),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildRestaurantInfoCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  // ----------------------------------------------------------
  // TOP BAR: logo circular + nombre + slogan
  // ----------------------------------------------------------
  Widget _buildTopBar() {
    final pal = context.pal;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset(
              'assets/img/logo_blanc7.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.local_pizza, color: _rojoInicio),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La Sirena',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: pal.texto(_textoInicio),
              ),
            ),
            Text(
              'PIZZA · DESDE 1994',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: pal.secundario(_grisInicio),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // BANNER PRINCIPAL: foto de fondo + saludo personalizado
  // ----------------------------------------------------------
  Widget _buildHeroBanner() {
    final nombre = AuthService.instance.currentName?.trim();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.pal.sombra(Colors.black.withValues(alpha: 0.05)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Capa 1: foto de fondo (degradado de respaldo si falla el asset)
            SizedBox(
              height: 190,
              width: double.infinity,
              child: Image.asset(
                'assets/img/pizza1.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: const Alignment(0.3, 0),
                cacheWidth: 736,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: _textoInicio),
              ),
            ),
            // Capa 2a: velo vertical (abajo -> arriba) para que el texto se lea
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Capa 2b: velo horizontal extra hacia la izquierda, donde va el texto
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Capa 3: etiqueta y saludo
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              top: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 0.6,
                      ),
                    ),
                    child: const Text(
                      'TRADICIÓN ARTESANAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre == null || nombre.isEmpty
                            ? 'Hola'
                            : 'Hola, $nombre',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Que vas a pedir hoy?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ENCABEZADOS DE SECCIÓN CON "Ver todas →"
  // ----------------------------------------------------------
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    final pal = context.pal;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: pal.texto(_textoInicio),
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Ver todas →',
              style: TextStyle(
                color: pal.rojo(_rojoInicio),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // DESTACADAS: las dos primeras Favoritas del catálogo real
  // ----------------------------------------------------------
  Widget _buildFeaturedList() {
    final pal = context.pal;
    final destacadas = _destacadas;
    final error = _error;
    if (destacadas == null && error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: pal.tarjeta(Colors.white),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: pal.texto(_textoInicio)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _reintentar,
              style: OutlinedButton.styleFrom(
                foregroundColor: pal.rojo(_rojoInicio),
                side: BorderSide(color: pal.rojo(_rojoInicio)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (destacadas == null) {
      return SizedBox(
        height: 248,
        child: Center(
          child: CircularProgressIndicator(color: pal.rojo(_rojoInicio)),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final producto in destacadas) ...[
            if (producto != destacadas.first) const SizedBox(width: 12),
            _FeaturedCard(
              producto: producto,
              alVerTodas: () => _abrirSeccion(seccionFavoritas),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CHIPS DE CATEGORÍAS (Pizzas / Lasañas / Favoritas)
  // ----------------------------------------------------------
  Widget _buildCategoryChips() {
    final pal = context.pal;
    final rojo = pal.rojo(_rojoInicio);
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              _abrirSeccion(_categories[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? rojo : pal.tarjeta(Colors.white),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? rojo : pal.borde(Colors.grey.shade300),
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : pal.texto(_textoInicio),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // TARJETA DE INFORMACIÓN DEL LOCAL (datos de la web)
  // ----------------------------------------------------------
  Widget _buildRestaurantInfoCard() {
    final pal = context.pal;
    final abierto = HorarioLocal.abierto();
    final colorEstado = abierto
        ? pal.exitoTexto(_verdeAbierto)
        : pal.errorTexto(_rojoInicio);
    final rojo = pal.rojo(_rojoInicio);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pal.sombra(Colors.black.withValues(alpha: 0.04)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'La Sirena Pizza',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: pal.texto(_textoInicio),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: colorEstado),
                    const SizedBox(width: 5),
                    Text(
                      abierto ? 'Abierto' : 'Cerrado',
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.access_time,
            'Jue–Dom · ${HorarioLocal.texto(HorarioLocal.apertura)} – '
            '${HorarioLocal.texto(HorarioLocal.cierre)}',
            color: rojo,
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, direccionLocal, color: rojo),
          const SizedBox(height: 10),
          _infoRow(Icons.phone_outlined, telefonoLocal, color: rojo),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: context.pal.texto(_textoInicio),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TARJETA DE PRODUCTO DESTACADO
// ============================================================
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.producto, required this.alVerTodas});

  final ProductoCatalogo producto;
  final VoidCallback alVerTodas;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    Widget respaldo(BuildContext context) => Container(
      color: pal.campo(Colors.grey.shade200),
      child: Icon(Icons.local_pizza, color: pal.rojo(_rojoInicio), size: 32),
    );
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(producto: producto),
        ),
      ),
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pal.tarjeta(Colors.white),
          borderRadius: BorderRadius.circular(18),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: pal.campo(Colors.grey.shade100),
                  child: ImagenProducto(producto: producto, respaldo: respaldo),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              producto.esPizza ? seccionPizzas : seccionLasanas,
              style: TextStyle(
                fontSize: 10,
                color: pal.secundario(_grisInicio),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              producto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: pal.texto(_textoInicio),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatCop(producto.precioBase),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pal.texto(_textoInicio),
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: alVerTodas,
              child: Text(
                'Ver todas →',
                style: TextStyle(
                  fontSize: 11,
                  color: pal.rojo(_rojoInicio),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
