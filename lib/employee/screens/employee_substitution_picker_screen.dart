import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../services/return_service.dart';

/// Selector del producto de canje con el catálogo real del backend
/// (`GET /productos`). Devuelve un [CanjeSeleccion] de una unidad.
class EmployeeSubstitutionPickerScreen extends StatefulWidget {
  const EmployeeSubstitutionPickerScreen({super.key});

  @override
  State<EmployeeSubstitutionPickerScreen> createState() =>
      _EmployeeSubstitutionPickerScreenState();
}

class _EmployeeSubstitutionPickerScreenState
    extends State<EmployeeSubstitutionPickerScreen> {
  static const red = Color(0xFFC9151E);
  static const blue = Color(0xFF2563EB);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final _buscaController = TextEditingController();
  List<CanjeProducto>? _productos;
  bool _cargando = true;
  String? _error;
  String _categoria = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final productos = await ReturnService.instance.cargarCatalogoCanje();
      if (!mounted) return;
      setState(() => _productos = productos);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar el catálogo.');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<String> get _categorias {
    final productos = _productos ?? const <CanjeProducto>[];
    final categorias = <String>{};
    for (final producto in productos) {
      categorias.add(producto.categoria);
    }
    final ordenadas = categorias.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['Todas', ...ordenadas];
  }

  List<CanjeProducto> get _filtrados {
    final productos = _productos ?? const <CanjeProducto>[];
    final porCategoria = _categoria == 'Todas'
        ? productos
        : productos.where((p) => p.categoria == _categoria).toList();
    final base = porCategoria.isEmpty ? productos : porCategoria;
    final termino = _buscaController.text.trim().toLowerCase();
    if (termino.isEmpty) return base;
    return base.where((p) => p.nombre.toLowerCase().contains(termino)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _bottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('María González'),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: red, size: 44),
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(backgroundColor: red),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Producto de sustitución',
            style: GoogleFonts.montserrat(color: ink, fontSize: 34),
          ),
          const SizedBox(height: 6),
          Text(
            'Elige el producto de reemplazo equivalente que recibirá el cliente.',
            style: GoogleFonts.poppins(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.black38,
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: muted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: blue, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categorias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                final activa = categoria == _categoria;
                return ChoiceChip(
                  label: Text(
                    categoria,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activa ? Colors.white : muted,
                    ),
                  ),
                  selected: activa,
                  showCheckmark: false,
                  selectedColor: red,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: activa ? red : const Color(0xFFE0E4E9),
                  ),
                  onSelected: (_) => setState(() => _categoria = categoria),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          if (_filtrados.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE4E1DF)),
              ),
              child: Text(
                'No hay productos disponibles para el canje.',
                style: GoogleFonts.poppins(color: muted, fontSize: 13),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtrados.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final producto = _filtrados[index];
                return _SubstitutionCard(
                  producto: producto,
                  onTap: () => _elegir(producto),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _elegir(CanjeProducto producto) async {
    final disponibles = producto.tamanos.where((t) => t.disponible).toList();
    if (disponibles.isEmpty) {
      _mostrarMensaje('No hay stock disponible de este producto.');
      return;
    }
    if (disponibles.length == 1) {
      _confirmar(producto, disponibles.first);
      return;
    }
    final tamano = await showModalBottomSheet<CanjeTamano>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TamanoSheet(producto: producto),
    );
    if (tamano == null || !mounted) return;
    _confirmar(producto, tamano);
  }

  void _confirmar(CanjeProducto producto, CanjeTamano tamano) {
    Navigator.of(context).pop(
      CanjeSeleccion(
        idProducto: producto.id,
        nombre: producto.nombre,
        imagen: producto.imagen,
        tamano: tamano.label,
        precio: tamano.precio,
        cantidad: 1,
        limiteStock: tamano.limiteStock,
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget _bottomNavigation() {
    final items = employeeNavItems();
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            handleEmployeeBottomNav(context, items[i].index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].icon,
                              color: items[i].index == 3
                                  ? red
                                  : const Color(0xFFA4AAB5),
                              size: 21,
                            ),
                            Text(
                              items[i].label,
                              style: GoogleFonts.poppins(
                                color: items[i].index == 3
                                    ? red
                                    : const Color(0xFFA4AAB5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TamanoSheet extends StatelessWidget {
  const _TamanoSheet({required this.producto});

  final CanjeProducto producto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto.nombre,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF17243A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Elige el tamaño del canje',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6D7B91),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            for (final tamano in producto.tamanos)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TamanoTile(
                  tamano: tamano,
                  onTap: tamano.disponible
                      ? () => Navigator.of(context).pop(tamano)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TamanoTile extends StatelessWidget {
  const _TamanoTile({required this.tamano, required this.onTap});

  final CanjeTamano tamano;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disponible = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: disponible ? Colors.white : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E4E9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tamano.label ?? 'Único',
                style: GoogleFonts.poppins(
                  color: disponible
                      ? const Color(0xFF17243A)
                      : const Color(0xFFA4AAB5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tamano.precioTexto,
                  style: GoogleFonts.poppins(
                    color: disponible
                        ? const Color(0xFF17243A)
                        : const Color(0xFFA4AAB5),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!disponible)
                  Text(
                    'Sin stock',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFC9151E),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubstitutionCard extends StatelessWidget {
  const _SubstitutionCard({required this.producto, required this.onTap});

  final CanjeProducto producto;
  final VoidCallback onTap;

  String get _precio {
    if (producto.tamanos.isEmpty) return '';
    if (producto.tamanos.length == 1) {
      return producto.tamanos.first.precioTexto;
    }
    final precios = producto.tamanos.map((t) => t.precio).toList()..sort();
    return 'Desde \$${formatearMiles(precios.first)}';
  }

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
            border: Border.all(color: const Color(0xFFE4E1DF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF1F3F5),
                    child: _productImage(producto.imagen, iconSize: 32),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      producto.categoria,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF6D7B91),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _precio,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
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

Widget _productImage(String? path, {double iconSize = 24}) {
  final placeholder = Container(
    alignment: Alignment.center,
    color: const Color(0xFFF1F3F5),
    child: Icon(
      Icons.local_pizza,
      color: const Color(0xFFC9151E),
      size: iconSize,
    ),
  );
  if (path == null || path.isEmpty) return placeholder;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => placeholder,
  );
}
