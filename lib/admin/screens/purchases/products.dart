part of '../purchases_screen.dart';

/// Insumo asignado a un producto dentro de su ficha técnica.
class _ProductFichaInsumo {
  const _ProductFichaInsumo({
    required this.insumoId,
    required this.name,
    required this.cantidad,
    required this.medida,
  });

  final String insumoId;
  final String name;
  final String cantidad;
  final String medida;
}

/// Ficha técnica del producto (versión 1).
class _ProductFichaTecnica {
  const _ProductFichaTecnica({
    required this.id,
    required this.prepTime,
    required this.porciones,
    required this.insumos,
    required this.pasos,
  });

  final String id;
  final String prepTime;
  final String porciones;
  final List<_ProductFichaInsumo> insumos;
  final List<String> pasos;

  factory _ProductFichaTecnica.fromApi(FichaProducto ficha) =>
      _ProductFichaTecnica(
        id: ficha.id.toString(),
        prepTime: ficha.tiempoPreparacion?.toString() ?? '—',
        porciones: ficha.porciones?.toString() ?? '—',
        insumos: ficha.insumos
            .map(
              (insumo) => _ProductFichaInsumo(
                insumoId: '',
                name: insumo.nombre,
                cantidad: insumo.cantidad.toString(),
                medida: insumo.medida,
              ),
            )
            .toList(growable: false),
        pasos: ficha.pasos,
      );
}

class _Product {
  const _Product({
    required this.id,
    required this.idCategoria,
    required this.name,
    required this.category,
    required this.type,
    required this.price,
    required this.largePrice,
    required this.imagePath,
    required this.hasImage,
    required this.estado,
    required this.unit,
    required this.stock,
    required this.stockParts,
    required this.availableMedium,
    required this.availableLarge,
    required this.content,
    required this.contentUnit,
    required this.purchaseUnit,
    required this.unitsPerPackage,
  });

  final String id;
  final int idCategoria;
  final String name;
  final String category;
  final String type;
  final double price;
  final double? largePrice;
  final String imagePath;
  final bool hasImage;
  final String estado;
  final String unit;
  final int? stock;
  final int? stockParts;
  final int? availableMedium;
  final int? availableLarge;
  final double? content;
  final String? contentUnit;
  final String? purchaseUnit;
  final int? unitsPerPackage;

  bool get isPizza =>
      category.toLowerCase().contains('pizza') ||
      stockParts != null ||
      availableMedium != null ||
      availableLarge != null;

  factory _Product.fromApi(ProductoGestion product) => _Product(
    id: product.idProducto.toString(),
    idCategoria: product.idCategoria,
    name: product.nombre,
    category: product.categoriaNombre ?? '',
    type: product.tipo,
    price: product.precioVenta,
    largePrice: product.precioGrande,
    imagePath: product.imagen ?? '',
    hasImage: product.tieneImagen,
    estado: product.estado,
    unit: product.unidadVenta,
    stock: product.stock,
    stockParts: product.stockPartes,
    availableMedium: product.disponiblesMediana,
    availableLarge: product.disponiblesGrande,
    content: product.contenido,
    contentUnit: product.contenidoUnidad,
    purchaseUnit: product.unidadCompra,
    unitsPerPackage: product.unidadesPorEmpaque,
  );
}

/// Producción › Productos › Editar: editar datos y cambiar estado.
bool _puedeEditarProductos() =>
    Permisos.puede('Producción', 'Productos', 'Editar');

bool _isNetworkImage(String path) {
  return path.startsWith('http://') || path.startsWith('https://');
}

Widget _productImageFallback(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return Container(
    color: const Color(0xFFE8B66A),
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported_outlined, color: Colors.white),
  );
}

Widget _productImage(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.isEmpty) {
    return Container(
      color: const Color(0xFFE8B66A),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white,
      ),
    );
  }
  return _isNetworkImage(path)
      ? Image.network(path, fit: fit, errorBuilder: _productImageFallback)
      : Image.asset(path, fit: fit, errorBuilder: _productImageFallback);
}

Widget _productImageFor(_Product product, {BoxFit fit = BoxFit.cover}) {
  if (product.hasImage) {
    final imageUrl = '${ApiConfig.baseUrl}/productos/${product.id}/imagen';
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: _productImageFallback,
    );
  }
  return _productImage(product.imagePath, fit: fit);
}

class _ProductManagementScreen extends StatefulWidget {
  const _ProductManagementScreen();

  @override
  State<_ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<_ProductManagementScreen> {
  String _query = '';
  List<_Product> _products = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }
    try {
      final products = await ProductsRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _products = products.map(_Product.fromApi).toList(growable: true);
        _loading = false;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'No se pudo completar la operación.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductList(context);
  }

  Widget _buildProductList(BuildContext context) {
    final filteredProducts = _products
        .where(
          (product) => matchesSearchQuery(_query, [
            product.id,
            product.name,
            product.category,
          ]),
        )
        .toList();

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(23, 26, 23, 28),
                  children: [
                    Text(
                      'Gestión Producto',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_products.length} productos registrados',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppSearchField(
                      hint: 'Buscar por ID, nombre o categoría...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 26),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: context.pal.rojo(PurchasesScreen.red),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadProducts,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    else if (filteredProducts.isEmpty)
                      Center(
                        child: Text(
                          'No hay productos para mostrar.',
                          style: GoogleFonts.poppins(
                            color: context.pal.secundario(
                              PurchasesScreen.muted,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final product in filteredProducts) ...[
                        _productCard(product),
                        const SizedBox(height: 22),
                      ],
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetailProduct(_Product product) async {
    final actualizado = await Navigator.of(context).push<_Product>(
      MaterialPageRoute(builder: (_) => _ProductDetailScreen(product: product)),
    );
    if (actualizado == null || !mounted) return;

    await _loadProducts();
  }

  Future<void> _openEditProduct(_Product product) async {
    final actualizado = await Navigator.of(context).push<_Product>(
      MaterialPageRoute(builder: (_) => _ProductEditScreen(product: product)),
    );
    if (actualizado == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).mostrarMensaje('Producto actualizado', tipo: TipoMensaje.exito);

    await _loadProducts();
  }

  bool _changingState = false;

  Future<void> _confirmChangeState(_Product product, String estado) async {
    if (_changingState) return;
    _changingState = true;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cambiar estado'),
          content: Text('¿Cambiar el estado de ${product.name} a "$estado"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cambiar'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      await _changeState(product, estado);
    } finally {
      _changingState = false;
    }
  }

  Future<void> _changeState(_Product product, String estado) async {
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ProductsRepository.instance.cambiarEstado(
        int.parse(product.id),
        estado,
      );
      if (!mounted) return;
      mensajes.mostrarMensaje(
        'Producto marcado como $estado',
        tipo: TipoMensaje.exito,
      );
      await _loadProducts();
    } on ApiException catch (error) {
      if (!mounted) return;
      mensajes.mostrarMensaje(error.message, tipo: TipoMensaje.error);
    } catch (_) {
      if (!mounted) return;
      mensajes.mostrarMensaje(
        'No se pudo completar la operación.',
        tipo: TipoMensaje.error,
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
    );
  }

  Widget _productCard(_Product product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 14),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(PurchasesScreen.page),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.pal.borde(Color(0xFFE5BDB9))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: _productImageFor(product),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        color: context.pal.texto(Colors.black),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _productTag(product.id),
                        _estadoBadge(product),
                        Text(
                          product.category,
                          style: GoogleFonts.poppins(
                            color: context.pal.secundario(
                              PurchasesScreen.muted,
                            ),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: context.pal.borde(Color(0xFFE5BDB9)),
              height: 1,
            ),
          ),
          Row(
            children: [
              // Los precios ocupan lo que dejan los íconos: si no caben, el
              // de Grande baja a otra línea.
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        product.price > 0
                            ? _formatPrice(product.price)
                            : 'Sin precio',
                        style: GoogleFonts.poppins(
                          color: context.pal.texto(Colors.black),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (product.largePrice != null)
                      Text(
                        product.largePrice! > 0
                            ? 'Grande ${_formatPrice(product.largePrice!)}'
                            : 'Grande sin precio',
                        style: GoogleFonts.poppins(
                          color: context.pal.secundario(PurchasesScreen.muted),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openDetailProduct(product),
                icon: Icon(
                  Icons.visibility_outlined,
                  color: context.pal.secundario(PurchasesScreen.muted),
                  size: 29,
                ),
              ),
              // Sin Producción > Productos > Editar el producto es de solo lectura.
              if (_puedeEditarProductos())
                IconButton(
                  onPressed: () => _openEditProduct(product),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: context.pal.secundario(PurchasesScreen.muted),
                    size: 29,
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: context.pal.secundario(PurchasesScreen.muted),
                  size: 21,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    product.isPizza
                        ? 'Stock: ${product.stockParts ?? '—'} partes'
                        : 'Stock: ${product.stock ?? '—'} ${product.unit}',
                    style: GoogleFonts.poppins(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (product.isPizza)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pizzas disponibles · Mediana: ${product.availableMedium ?? '—'} · Grande: ${product.availableLarge ?? '—'}',
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(PurchasesScreen.muted),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: context.pal.campo(Color(0xFFF0ECEB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: context.pal.texto(PurchasesScreen.ink),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _estadoBadge(_Product product) {
    final disponible = product.estado == 'Disponible';
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: disponible
            ? context.pal.exitoFondo(Color(0xFFE3F2E5))
            : context.pal.errorFondo(Color(0xFFFFE8EB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        product.estado,
        style: GoogleFonts.poppins(
          color: disponible
              ? context.pal.exitoTexto(Color(0xFF3D824B))
              : context.pal.rojo(PurchasesScreen.red),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    // Sin Producción > Productos > Editar la píldora solo informa.
    if (!Permisos.puede('Producción', 'Productos', 'Editar')) return pill;
    return MenuApp<String>(
      opciones: const ['Automático', 'Descontinuado'],
      etiqueta: (estado) => estado,
      valor: product.estado == 'Descontinuado' ? 'Descontinuado' : 'Automático',
      ancho: 200,
      onSelected: (estado) => _confirmChangeState(product, estado),
      child: pill,
    );
  }

  String _formatPrice(double price) => formatCop(price.round());

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 2);
}

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen({required this.product});

  final _Product product;

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  late _Product _product;
  _ProductFichaTecnica? _ficha;
  bool _loadingDetail = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadDetail();
  }

  Future<void> _loadDetail({bool showLoading = true}) async {
    if (mounted) {
      setState(() {
        _detailError = null;
        if (showLoading) _loadingDetail = true;
      });
    }
    try {
      final id = int.parse(_product.id);
      final products = await ProductsRepository.instance.listar();
      final product = products.where((item) => item.idProducto == id);
      if (product.isEmpty) {
        throw const ApiException('Producto no encontrado.');
      }
      final fichas = await ProductsRepository.instance.obtenerFichas(id);
      if (!mounted) return;
      final vigentes = fichas.where((item) => item.vigente).toList();
      final ficha = vigentes.isEmpty
          ? null
          : vigentes.reduce(
              (current, next) =>
                  next.version > current.version ? next : current,
            );
      setState(() {
        _product = _Product.fromApi(product.first);
        _ficha = ficha == null ? null : _ProductFichaTecnica.fromApi(ficha);
        _loadingDetail = false;
        _detailError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _detailError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _detailError = 'No se pudo completar la operación.';
      });
    }
  }

  /// Abre "Editar Producto" y refleja en el detalle lo que se guarde allí.
  Future<void> _openEdit() async {
    final actualizado = await Navigator.of(context).push<_Product>(
      MaterialPageRoute(builder: (_) => _ProductEditScreen(product: _product)),
    );
    if (actualizado == null || !mounted) return;
    setState(() => _product = actualizado);
    // El detalle no tiene barra inferior.
    ScaffoldMessenger.of(context).mostrarMensaje(
      'Producto actualizado',
      tipo: TipoMensaje.exito,
      sobreBarraPanel: false,
    );
    await _loadDetail(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        child: Column(
          children: [
            _productAppHeader(context),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Detalle',
                    style: GoogleFonts.montserrat(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '—',
                    style: GoogleFonts.poppins(
                      color: context.pal.secundario(PurchasesScreen.muted),
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.id,
                    style: GoogleFonts.poppins(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadDetail(showLoading: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  // Misma tarjeta que Gestión Compras (radio, borde y sombra).
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.pal.tarjeta(PurchasesScreen.page),
                      borderRadius: BorderRadius.circular(_radioTarjeta),
                      border: Border.all(
                        color: context.pal.borde(_bordeTarjeta),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.pal.sombra(Color(0x0A000000)),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _detailSection(
                          'ID PRODUCTO',
                          product.id,
                          valueStyle: GoogleFonts.poppins(
                            color: context.pal.texto(PurchasesScreen.ink),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _detailSection(
                          'NOMBRE',
                          product.name,
                          valueStyle: GoogleFonts.poppins(
                            color: context.pal.texto(PurchasesScreen.ink),
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 170,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _productImageFor(
                                product,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        _detailSection(
                          'ID CATEGORÍA',
                          '${product.idCategoria}  -  ${product.category}',
                          icon: Icons.category_outlined,
                          valueColor: context.pal.rojo(PurchasesScreen.red),
                        ),
                        _detailSection('TIPO', product.type),
                        _detailSection(
                          product.isPizza
                              ? 'PRECIO POR PORCIÓN MEDIANA'
                              : 'PRECIO UNITARIO',
                          product.price > 0
                              ? _formatPrice(product.price)
                              : 'Sin precio',
                          valueStyle: GoogleFonts.poppins(
                            color: context.pal.rojo(PurchasesScreen.red),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: context.pal.campo(Color(0xFFF9F5F4)),
                        ),
                        if (product.largePrice != null)
                          _detailSection(
                            'PRECIO POR PORCIÓN GRANDE',
                            product.largePrice! > 0
                                ? _formatPrice(product.largePrice!)
                                : 'Sin precio',
                          ),
                        _detailSection('ESTADO', product.estado),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _detailValueColumn(
                                  'UNIDAD DE VENTA',
                                  product.unit,
                                  GoogleFonts.poppins(
                                    color: context.pal.texto(
                                      PurchasesScreen.ink,
                                    ),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              _detailValueColumn(
                                product.isPizza ? 'STOCK EN PARTES' : 'STOCK',
                                product.isPizza
                                    ? '${product.stockParts ?? '—'}'
                                    : '${product.stock ?? '—'} ${product.unit}',
                                GoogleFonts.poppins(
                                  color: context.pal.texto(PurchasesScreen.ink),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                valueBackground: context.pal.campo(
                                  Color(0xFFE9E7E6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _divisor(),
                        if (product.isPizza) ...[
                          _detailSection(
                            'PIZZAS DISPONIBLES MEDIANA',
                            '${product.availableMedium ?? '—'}',
                          ),
                          _detailSection(
                            'PIZZAS DISPONIBLES GRANDE',
                            '${product.availableLarge ?? '—'}',
                          ),
                          _detailSection(
                            'CONVERSIÓN DE PIZZA',
                            '1 pizza = 24 partes · Mediana: 3 partes, 8 porciones · Grande: 4 partes, 6 porciones',
                          ),
                        ],
                        if (product.type == 'Reventa') ...[
                          _detailSection(
                            'CONTENIDO',
                            '${product.content ?? '—'} ${product.contentUnit ?? ''}',
                          ),
                          _detailSection(
                            'UNIDAD DE COMPRA',
                            product.purchaseUnit ?? '—',
                          ),
                          _detailSection(
                            'UNIDADES POR EMPAQUE',
                            '${product.unitsPerPackage ?? '—'}',
                          ),
                        ],
                        if (_loadingDetail)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          )
                        else if (_detailError != null)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  _detailError!,
                                  style: GoogleFonts.poppins(
                                    color: context.pal.rojo(
                                      PurchasesScreen.red,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadDetail,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        else
                          _buildFichaTecnica(_ficha),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(_product),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.pal.rojo(
                            PurchasesScreen.red,
                          ),
                          side: BorderSide(
                            color: context.pal.rojo(PurchasesScreen.red),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_puedeEditarProductos()) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _openEdit,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            'Editar',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.pal.rojoBoton(
                              PurchasesScreen.red,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFichaTecnica(_ProductFichaTecnica? ficha) {
    if (ficha == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailSection(
          'FICHA TÉCNICA',
          ficha.id,
          icon: Icons.menu_book_outlined,
          valueStyle: GoogleFonts.poppins(
            color: context.pal.texto(PurchasesScreen.ink),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        _detailSection('TIEMPO DE PREPARACIÓN', '${ficha.prepTime} min'),
        _detailSection('PORCIONES', ficha.porciones),
        _fichaListSection('INSUMOS', [
          for (final insumo in ficha.insumos)
            '${insumo.name} — ${insumo.cantidad} ${insumo.medida}',
        ]),
        _fichaListSection('PASOS DE PREPARACIÓN', [
          for (var i = 0; i < ficha.pasos.length; i++)
            '${i + 1}. ${ficha.pasos[i]}',
        ]),
      ],
    );
  }

  /// Lista de valores de la ficha técnica (insumos o pasos de preparación).
  Widget _fichaListSection(String label, List<String> items) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: _rellenoFila,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _estiloEtiqueta()),
              const SizedBox(height: 6),
              if (items.isEmpty)
                Text(
                  'Sin registros',
                  style: GoogleFonts.poppins(
                    color: context.pal.secundario(PurchasesScreen.muted),
                    fontSize: 14,
                  ),
                )
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 14,
                      ),
                    ),
                  ),
            ],
          ),
        ),
        _divisor(),
      ],
    );
  }

  /// Tarjeta y divisores con el mismo borde suave de Gestión Compras.
  static const double _radioTarjeta = 14;
  static const Color _bordeTarjeta = Color(0xFFE8DDDB);
  static const EdgeInsets _rellenoFila = EdgeInsets.fromLTRB(20, 14, 20, 14);

  /// Línea divisoria sutil con margen a ambos lados.
  Widget _divisor() => Divider(
    height: 1,
    thickness: 1,
    indent: 20,
    endIndent: 20,
    color: context.pal.borde(_bordeTarjeta),
  );

  TextStyle _estiloEtiqueta() => GoogleFonts.poppins(
    color: context.pal.secundario(PurchasesScreen.muted),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  Widget _productAppHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
    );
  }

  Widget _detailSection(
    String label,
    String value, {
    IconData? icon,
    TextStyle? valueStyle,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: _rellenoFila,
          color: backgroundColor ?? context.pal.tarjeta(PurchasesScreen.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _estiloEtiqueta()),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: context.pal.secundario(PurchasesScreen.muted),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style:
                          valueStyle ??
                          GoogleFonts.poppins(
                            color:
                                valueColor ??
                                context.pal.texto(PurchasesScreen.ink),
                            fontSize: 15,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _divisor(),
      ],
    );
  }

  Widget _detailValueColumn(
    String label,
    String value,
    TextStyle valueStyle, {
    Color? valueBackground,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _estiloEtiqueta()),
        const SizedBox(height: 6),
        Container(
          padding: valueBackground == null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: valueBackground == null
              ? null
              : BoxDecoration(
                  color: valueBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
          child: Text(value, style: valueStyle),
        ),
      ],
    );
  }

  String _formatPrice(double price) => formatCop(price.round());
}

class _ProductEditScreen extends StatefulWidget {
  const _ProductEditScreen({required this.product});

  final _Product product;

  @override
  State<_ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<_ProductEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _priceController;
  late final TextEditingController _largePriceController;
  late final TextEditingController _unitController;
  late final TextEditingController _contentController;
  late final TextEditingController _unitsPerPackageController;
  late String _category;
  String? _contentUnit;
  String? _purchaseUnit;
  List<CategoriaProductoOpcion> _categories = [];
  bool _loadingCategories = true;
  bool _saving = false;
  String? _categoryError;

  /// Errores de validación local por campo (clave del backend).
  Map<String, String> _errores = const {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _imageUrlController = TextEditingController(text: widget.product.imagePath);
    _priceController = TextEditingController(
      text: widget.product.price > 0
          ? textoInicialNumero(widget.product.price)
          : '',
    );
    _largePriceController = TextEditingController(
      text: textoInicialNumero(widget.product.largePrice),
    );
    _unitController = TextEditingController(text: widget.product.unit);
    _contentController = TextEditingController(
      text: textoInicialNumero(widget.product.content),
    );
    _unitsPerPackageController = TextEditingController(
      text: widget.product.unitsPerPackage?.toString() ?? '',
    );
    _category = widget.product.idCategoria.toString();
    // Un valor fuera de la lista dejaría el desplegable sin opción válida.
    _contentUnit =
        unidadesContenidoProducto.contains(widget.product.contentUnit)
        ? widget.product.contentUnit
        : null;
    _purchaseUnit = unidadesCompraProducto.contains(widget.product.purchaseUnit)
        ? widget.product.purchaseUnit
        : null;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ProductsRepository.instance.listarCategorias();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loadingCategories = false;
        _categoryError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _categoryError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _categoryError = 'No se pudo completar la operación.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _largePriceController.dispose();
    _unitController.dispose();
    _contentController.dispose();
    _unitsPerPackageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _productAppHeader(context),
            _buildEditTitleHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(27, 28, 27, 28),
                  decoration: BoxDecoration(
                    color: context.pal.tarjeta(PurchasesScreen.page),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: context.pal.borde(Color(0xFFE0D9D7)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.pal.sombra(Color(0x12000000)),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Nombre'),
                      _textField(
                        _nameController,
                        errorText: _errores['nombre'],
                      ),
                      const SizedBox(height: 22),
                      _fieldLabel('Tipo'),
                      Text(widget.product.type),
                      const SizedBox(height: 22),
                      _fieldLabel('Imagen'),
                      _textField(
                        _imageUrlController,
                        hintText: 'Imagen',
                        errorText: _errores['imagen'],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _productImageFor(
                            widget.product,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _fieldLabel('Categoría'),
                      if (_loadingCategories)
                        const Center(child: CircularProgressIndicator())
                      else if (_categoryError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categoryError!,
                              style: TextStyle(
                                color: context.pal.rojo(PurchasesScreen.red),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadCategories,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      else if (_categories.any(
                        (item) => item.idCategoria.toString() == _category,
                      ))
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          isExpanded: true,
                          decoration: InputDecoration(
                            errorText: _errores['id_categoria'],
                          ),
                          items: _categories
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.idCategoria.toString(),
                                  child: Text(item.nombre),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _category = value);
                            }
                          },
                        )
                      else
                        Text(widget.product.category),
                      const SizedBox(height: 22),
                      _fieldLabel('Unidad de venta'),
                      if (widget.product.type == 'Reventa')
                        Text(widget.product.unit)
                      else
                        _textField(
                          _unitController,
                          errorText: _errores['unidad_venta'],
                        ),
                      if (widget.product.type == 'Elaborado') ...[
                        const SizedBox(height: 22),
                        _fieldLabel(
                          widget.product.isPizza
                              ? 'Precio por porción Mediana (COP)'
                              : 'Precio de venta (COP)',
                        ),
                        _textField(
                          _priceController,
                          keyboardType: TextInputType.number,
                          errorText: _errores['precio_venta'],
                        ),
                        if (widget.product.isPizza) ...[
                          const SizedBox(height: 22),
                          _fieldLabel('Precio por porción Grande (COP)'),
                          _textField(
                            _largePriceController,
                            keyboardType: TextInputType.number,
                            errorText: _errores['precio_grande'],
                          ),
                        ],
                      ],
                      if (widget.product.type == 'Reventa') ...[
                        const SizedBox(height: 22),
                        _fieldLabel('Contenido'),
                        _textField(
                          _contentController,
                          keyboardType: TextInputType.number,
                          errorText: _errores['contenido'],
                        ),
                        const SizedBox(height: 22),
                        _fieldLabel('Unidad del contenido'),
                        _dropdownField(
                          value: _contentUnit,
                          items: unidadesContenidoProducto,
                          errorText: _errores['contenido_unidad'],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _contentUnit = value);
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        _fieldLabel('Unidad de compra'),
                        _dropdownField(
                          value: _purchaseUnit,
                          items: unidadesCompraProducto,
                          errorText: _errores['unidad_compra'],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _purchaseUnit = value);
                            }
                          },
                        ),
                        if (_purchaseUnit != null &&
                            _purchaseUnit != 'und') ...[
                          const SizedBox(height: 22),
                          _fieldLabel('Unidades por empaque'),
                          _textField(
                            _unitsPerPackageController,
                            keyboardType: TextInputType.number,
                            errorText: _errores['unidades_por_empaque'],
                          ),
                        ],
                      ],
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.pal.rojo(
                                  PurchasesScreen.red,
                                ),
                                side: BorderSide(
                                  color: context.pal.rojo(PurchasesScreen.red),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.pal.rojoBoton(
                                  PurchasesScreen.red,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Guardar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _productAppHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials(AuthService.instance.usuario?.nombre ?? ''),
    );
  }

  Widget _buildEditTitleHeader() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            'Editar',
            style: GoogleFonts.montserrat(
              color: context.pal.texto(PurchasesScreen.ink),
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '—',
            style: GoogleFonts.poppins(
              color: context.pal.secundario(PurchasesScreen.muted),
              fontSize: 23,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.product.id,
            style: GoogleFonts.poppins(
              color: context.pal.texto(PurchasesScreen.ink),
              fontSize: 17,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: context.pal.rojoBoton(PurchasesScreen.red),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials(AuthService.instance.usuario?.nombre ?? ''),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: context.pal.secundario(PurchasesScreen.muted),
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: context.pal.texto(PurchasesScreen.ink),
        fontSize: 21,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 3,
        filled: true,
        fillColor: context.pal.campo(Color(0xFFF7F8F9)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 17,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: context.pal.borde(Color(0xFFDADADA)),
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: context.pal.rojo(PurchasesScreen.red),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down),
      style: GoogleFonts.poppins(
        color: context.pal.texto(PurchasesScreen.ink),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        errorText: errorText,
        filled: true,
        fillColor: context.pal.campo(Color(0xFFF7F8F9)),
        contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 17),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: context.pal.borde(Color(0xFFDADADA)),
            width: 2,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: context.pal.rojo(PurchasesScreen.red),
            width: 2,
          ),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(value: item, child: Text(item)),
      ],
    );
  }

  void _avisar(String mensaje, [TipoMensaje tipo = TipoMensaje.error]) {
    ScaffoldMessenger.of(context).mostrarMensaje(mensaje, tipo: tipo);
  }

  Future<void> _saveProduct() async {
    if (_saving) return;
    // PUT parcial: imagen solo si cambió (un '' la borraría); la galería
    // (imagenes) nunca se envía desde la móvil.
    final p = widget.product;
    final edicion = construirEdicionProducto(
      original: ProductoOriginal(
        tipo: p.type,
        esPizza: p.isPizza,
        idCategoria: p.idCategoria,
        nombre: p.name,
        unidadVenta: p.unit,
        imagen: p.imagePath,
        precio: p.price,
        precioGrande: p.largePrice,
        contenido: p.content,
        contenidoUnidad: p.contentUnit,
        unidadCompra: p.purchaseUnit,
        unidadesPorEmpaque: p.unitsPerPackage,
      ),
      idCategoria: _category,
      nombre: _nameController.text,
      unidadVenta: _unitController.text,
      imagen: _imageUrlController.text,
      precio: _priceController.text,
      precioGrande: _largePriceController.text,
      contenido: _contentController.text,
      contenidoUnidad: _contentUnit,
      unidadCompra: _purchaseUnit,
      unidadesPorEmpaque: _unitsPerPackageController.text,
    );
    setState(() => _errores = edicion.errores);
    if (!edicion.valido) {
      _avisar(
        edicion.errores['_general'] ?? 'Revisa los campos marcados.',
        // "No hay cambios que guardar" es solo un aviso.
        edicion.errores.containsKey('_general')
            ? TipoMensaje.informacion
            : TipoMensaje.error,
      );
      return;
    }

    try {
      setState(() => _saving = true);
      final updated = await ProductsRepository.instance.actualizar(
        int.parse(widget.product.id),
        edicion.cuerpo,
      );
      if (!mounted) return;
      Navigator.of(context).pop(_Product.fromApi(updated));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _avisar(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _avisar('No se pudo completar la operación.');
    }
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 2);
}
