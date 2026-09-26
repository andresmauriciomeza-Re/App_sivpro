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
}

class _Product {
  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    this.estado = 'Activo',
    this.unit = 'und',
    this.fichaTecnica,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String imagePath;

  /// 'Activo' o 'Inactivo'.
  final String estado;

  /// Unidad de venta (und, kg, l).
  final String unit;

  /// Ficha técnica opcional del producto.
  final _ProductFichaTecnica? fichaTecnica;

  bool get isActive => estado == 'Activo';

  /// El stock no vive en el modelo: `ProductsRepository` es la fuente de verdad
  /// (lo actualiza la producción y también el campo "Stock disponible").
  int get stock => ProductsRepository.instance.stockOf(id);

  /// Copia con los datos editados desde "Editar Producto" (el stock se guarda
  /// aparte, en el repositorio).
  _Product copyWith({
    String? name,
    String? category,
    int? price,
    String? imagePath,
    String? estado,
    String? unit,
    _ProductFichaTecnica? fichaTecnica,
  }) => _Product(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    price: price ?? this.price,
    imagePath: imagePath ?? this.imagePath,
    estado: estado ?? this.estado,
    unit: unit ?? this.unit,
    fichaTecnica: fichaTecnica ?? this.fichaTecnica,
  );
}

/// Las imágenes pueden venir de un asset (datos mock) o de una URL pegada por el
/// usuario al crear el producto.
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
    child: const Text(
      'Pizza',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget _productImage(String path, {BoxFit fit = BoxFit.cover}) {
  return _isNetworkImage(path)
      ? Image.network(path, fit: fit, errorBuilder: _productImageFallback)
      : Image.asset(path, fit: fit, errorBuilder: _productImageFallback);
}

class _ProductManagementScreen extends StatefulWidget {
  const _ProductManagementScreen();

  @override
  State<_ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<_ProductManagementScreen> {
  String _query = '';
  final List<_Product> _products = [
    const _Product(
      id: 'PROD-001',
      name: 'Margarita Clásica',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 24000,
      imagePath: 'assets/images/products/pizza.jpg',
      estado: 'Activo',
      fichaTecnica: _ProductFichaTecnica(
        id: 'REC-001',
        prepTime: '12',
        porciones: '1',
        insumos: [
          _ProductFichaInsumo(
            insumoId: 'INS-004',
            name: 'Masa Pre-elaborada',
            cantidad: '1',
            medida: 'und',
          ),
          _ProductFichaInsumo(
            insumoId: 'INS-008',
            name: 'Salsa de tomate',
            cantidad: '150',
            medida: 'ml',
          ),
          _ProductFichaInsumo(
            insumoId: 'INS-007',
            name: 'Queso mozzarella',
            cantidad: '120',
            medida: 'g',
          ),
          _ProductFichaInsumo(
            insumoId: 'INS-010',
            name: 'Orégano seco',
            cantidad: '5',
            medida: 'g',
          ),
        ],
        pasos: [
          'Desengrasar la mesa y extender la masa pre-elaborada.',
          'Añadir la salsa de tomate dejando un borde de 2 cm.',
          'Distribuir el queso mozzarella y el orégano seco.',
          'Hornear a 400 °C durante 12 minutos.',
        ],
      ),
    ),
    const _Product(
      id: 'PROD-002',
      name: 'Pepperoni Premium',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 28000,
      imagePath: 'assets/images/products/pizza.jpg',
      estado: 'Activo',
    ),
    const _Product(
      id: 'PROD-003',
      name: 'Cuatro Quesos',
      category: 'CAT-002 - Pizzas Especiales',
      price: 30000,
      imagePath: 'assets/images/products/pizza.jpg',
      estado: 'Activo',
    ),
    const _Product(
      id: 'PROD-004',
      name: 'Especial La Sirena',
      category: 'CAT-002 - Pizzas Especiales',
      price: 32000,
      imagePath: 'assets/images/products/pizza.jpg',
      estado: 'Activo',
    ),
    const _Product(
      id: 'PROD-005',
      name: 'Veggie Mediterránea',
      category: 'CAT-003 - Pizzas Vegetarianas',
      price: 26000,
      imagePath: 'assets/images/products/pizza.jpg',
      estado: 'Inactivo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductsRepository.instance,
      builder: (context, _) => _buildProductList(context),
    );
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
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 26, 23, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión Producto',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_products.length} productos registrados',
                      style: GoogleFonts.poppins(
                        color: PurchasesScreen.muted,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppSearchField(
                      hint: 'Buscar por ID, nombre o categoría...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 26),
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

    final index = _products.indexWhere((item) => item.id == product.id);
    if (index >= 0) _products[index] = actualizado;
    setState(() {});
  }

  Future<void> _openEditProduct(_Product product) async {
    final actualizado = await Navigator.of(context).push<_Product>(
      MaterialPageRoute(builder: (_) => _ProductEditScreen(product: product)),
    );
    if (actualizado == null || !mounted) return;

    final index = _products.indexWhere((item) => item.id == product.id);
    if (index >= 0) _products[index] = actualizado;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.id} actualizado correctamente.')),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
    );
  }

  Widget _productCard(_Product product) {
    final isLowStock = product.stock <= 25;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 14),
      decoration: BoxDecoration(
        color: PurchasesScreen.page,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5BDB9)),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: _productImage(product.imagePath),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
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
                            color: PurchasesScreen.muted,
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE5BDB9), height: 1),
          ),
          Row(
            children: [
              Text(
                '\$${_formatPrice(product.price)}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _openDetailProduct(product),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                  size: 29,
                ),
              ),
              IconButton(
                onPressed: () => _openEditProduct(product),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: PurchasesScreen.muted,
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
                  color: isLowStock
                      ? PurchasesScreen.red
                      : const Color(0xFF167B27),
                  size: 21,
                ),
                const SizedBox(width: 6),
                Text(
                  'Stock: ${product.stock}',
                  style: GoogleFonts.poppins(
                    color: isLowStock
                        ? PurchasesScreen.red
                        : const Color(0xFF167B27),
                    fontSize: 17,
                  ),
                ),
              ],
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
        color: const Color(0xFFF0ECEB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: PurchasesScreen.ink,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Pill de estado: verde "Activo" / rojo "Inactivo".
  Widget _estadoBadge(_Product product) {
    final isActive = product.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F2E5) : const Color(0xFFFFE8EB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        product.estado,
        style: GoogleFonts.poppins(
          color: isActive ? const Color(0xFF3D824B) : PurchasesScreen.red,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.person_outline, 'Mi Perfil'),
    ];
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => navigateToBottomModule(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen({required this.product});

  final _Product product;

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  late _Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  /// Abre "Editar Producto" y refleja en el detalle lo que se guarde allí.
  Future<void> _openEdit() async {
    final actualizado = await Navigator.of(context).push<_Product>(
      MaterialPageRoute(builder: (_) => _ProductEditScreen(product: _product)),
    );
    if (actualizado == null || !mounted) return;
    setState(() => _product = actualizado);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final categoryParts = product.category.split(' - ');
    final categoryId = categoryParts.first;
    final categoryName = categoryParts.length > 1
        ? categoryParts.sublist(1).join(' - ')
        : product.category;

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
      body: SafeArea(
        child: Column(
          children: [
            _productAppHeader(context),
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Detalle',
                    style: GoogleFonts.montserrat(
                      color: PurchasesScreen.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '—',
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.muted,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.id,
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE5BDB9)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _detailSection(
                        'ID PRODUCTO',
                        product.id,
                        valueStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _detailSection(
                        'NOMBRE',
                        product.name,
                        valueStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 190,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _productImage(
                              product.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      _detailSection(
                        'ID CATEGORÍA',
                        '$categoryId  -  $categoryName',
                        icon: Icons.category_outlined,
                        valueColor: PurchasesScreen.red,
                      ),
                      _detailSection(
                        'PRECIO UNITARIO',
                        '\$${_formatPrice(product.price)}',
                        valueStyle: GoogleFonts.poppins(
                          color: PurchasesScreen.red,
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: const Color(0xFFF9F5F4),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _detailValueColumn(
                                'UNIDAD DE VENTA',
                                product.unit,
                                GoogleFonts.poppins(
                                  color: PurchasesScreen.ink,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            _detailValueColumn(
                              'STOCK',
                              '${product.stock} und',
                              GoogleFonts.poppins(
                                color: PurchasesScreen.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              valueBackground: const Color(0xFFE9E7E6),
                            ),
                          ],
                        ),
                      ),
                      _buildFichaTecnica(product.fichaTecnica),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 72,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(_product),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PurchasesScreen.red,
                          side: const BorderSide(
                            color: PurchasesScreen.red,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 72,
                      child: ElevatedButton.icon(
                        onPressed: _openEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'Editar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PurchasesScreen.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
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

  /// Ficha técnica del producto o el aviso de que todavía no tiene una.
  Widget _buildFichaTecnica(_ProductFichaTecnica? ficha) {
    if (ficha == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
        ),
        child: Text(
          'Sin ficha técnica registrada',
          style: GoogleFonts.poppins(
            color: PurchasesScreen.muted,
            fontSize: 17,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailSection(
          'FICHA TÉCNICA',
          ficha.id,
          icon: Icons.menu_book_outlined,
          valueStyle: GoogleFonts.poppins(
            color: PurchasesScreen.ink,
            fontSize: 18,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 23),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5BDB9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          if (items.isEmpty)
            Text(
              'Sin registros',
              style: GoogleFonts.poppins(
                color: PurchasesScreen.muted,
                fontSize: 17,
              ),
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.ink,
                    fontSize: 17,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _productAppHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('Gloria Inés Vargas'),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 23),
      decoration: BoxDecoration(
        color: backgroundColor ?? PurchasesScreen.page,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5BDB9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: PurchasesScreen.muted, size: 23),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ??
                      GoogleFonts.poppins(
                        color: valueColor ?? PurchasesScreen.ink,
                        fontSize: 20,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        Text(
          label,
          style: GoogleFonts.poppins(
            color: PurchasesScreen.muted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }
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
  late final TextEditingController _stockController;
  late String _category;
  late String _estado;
  late String _unit;
  late _ProductFichaTecnica? _ficha;

  static const _estados = ['Activo', 'Inactivo'];
  static const _unidades = ['und', 'kg', 'l'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _imageUrlController = TextEditingController(
      text: _isNetworkImage(widget.product.imagePath)
          ? widget.product.imagePath
          : '',
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _category = widget.product.category;
    _estado = widget.product.estado;
    _unit = widget.product.unit;
    _ficha = widget.product.fichaTecnica;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const categories = [
      'CAT-001 - Pizzas Clásicas',
      'CAT-002 - Pizzas Especiales',
      'CAT-003 - Pizzas Vegetarianas',
    ];

    return Scaffold(
      backgroundColor: PurchasesScreen.page,
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
                    color: PurchasesScreen.page,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE0D9D7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Nombre *'),
                      _textField(_nameController),
                      const SizedBox(height: 28),
                      _fieldLabel('Imagen del producto'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_outlined),
                              label: const Text('Subir archivo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.ink,
                                side: const BorderSide(
                                  color: Color(0xFFE5BDB9),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _textField(
                              _imageUrlController,
                              hintText: 'URL de imagen',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 190,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _productImage(
                                widget.product.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black87,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _fieldLabel('ID Categoría *'),
                      _dropdownField(
                        value: _category,
                        items: categories,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                      const SizedBox(height: 26),
                      _fieldLabel('Precio unitario (COP)'),
                      _textField(
                        _priceController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 26),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Unidad de venta'),
                                _dropdownField(
                                  value: _unit,
                                  items: _unidades,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _unit = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Stock disponible'),
                                _textField(
                                  _stockController,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      _fieldLabel('Estado del producto'),
                      _dropdownField(
                        value: _estado,
                        items: _estados,
                        onChanged: (value) {
                          if (value != null) setState(() => _estado = value);
                        },
                      ),
                      if (_ficha != null) ...[
                        const SizedBox(height: 30),
                        const Divider(color: Color(0xFFE5BDB9), height: 1),
                        const SizedBox(height: 24),
                        _fichaTitle(_ficha!.id),
                        const SizedBox(height: 18),
                        _ProductFichaTecnicaEditor(
                          ficha: _ficha!,
                          onChanged: (ficha) => setState(() => _ficha = ficha),
                        ),
                      ],
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: PurchasesScreen.red,
                                side: const BorderSide(
                                  color: PurchasesScreen.red,
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
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurchasesScreen.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                              ),
                              child: Text(
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
      initials: getInitials('Gloria Inés Vargas'),
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
              color: PurchasesScreen.ink,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '—',
            style: GoogleFonts.poppins(
              color: PurchasesScreen.muted,
              fontSize: 23,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.product.id,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.ink,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: PurchasesScreen.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
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
          color: PurchasesScreen.muted,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: PurchasesScreen.ink,
        fontSize: 21,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 17,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down),
      style: GoogleFonts.poppins(
        color: PurchasesScreen.ink,
        fontSize: 18,
      ),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xFFF7F8F9),
        contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 17),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
      ],
    );
  }

  Widget _fichaTitle(String fichaId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'FICHA TÉCNICA',
          style: GoogleFonts.poppins(
            color: PurchasesScreen.muted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            fichaId,
            style: GoogleFonts.poppins(
              color: PurchasesScreen.red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Guarda los cambios y devuelve el producto actualizado a la lista.
  void _saveProduct() {
    final nombre = _nameController.text.trim();
    if (nombre.isEmpty) {
      _avisar('El nombre del producto es obligatorio.');
      return;
    }

    // Ajuste manual del stock: la producción completada sigue sumando por
    // separado sobre este valor.
    final stock = int.tryParse(_stockController.text.trim());
    if (stock != null) {
      ProductsRepository.instance.setStock(widget.product.id, stock);
    }

    final url = _imageUrlController.text.trim();
    Navigator.of(context).pop(
      widget.product.copyWith(
        name: nombre,
        category: _category,
        price: int.tryParse(_priceController.text.trim()),
        imagePath: url.isEmpty ? null : url,
        estado: _estado,
        unit: _unit,
        fichaTecnica: _ficha,
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.shopping_cart_outlined, 'Compras'),
      (Icons.factory_outlined, 'Producción'),
      (Icons.receipt_long_outlined, 'Ventas'),
      (Icons.person_outline, 'Mi Perfil'),
    ];
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBCBC8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(
              onTap: () => navigateToBottomModule(context, i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminBottomNavIcon(
                    icon: items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                    showPendingBadge: i == adminSalesNavIndex,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 2
                          ? PurchasesScreen.red
                          : PurchasesScreen.muted,
                      fontSize: 12,
                      fontWeight: i == 2 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Editor de la ficha técnica de un producto (tiempo de preparación,
/// porciones, insumos y pasos de preparación).
///
/// Solo se muestra cuando el producto ya tiene una ficha técnica registrada y
/// avisa cada cambio al formulario de edición que lo contiene.
class _ProductFichaTecnicaEditor extends StatefulWidget {
  const _ProductFichaTecnicaEditor({
    required this.ficha,
    required this.onChanged,
  });

  final _ProductFichaTecnica ficha;
  final ValueChanged<_ProductFichaTecnica> onChanged;

  @override
  State<_ProductFichaTecnicaEditor> createState() =>
      _ProductFichaTecnicaEditorState();
}

class _ProductFichaTecnicaEditorState
    extends State<_ProductFichaTecnicaEditor> {
  static const _medidas = ['kg', 'g', 'l', 'ml', 'und'];

  late final TextEditingController _prepTimeController;
  late final TextEditingController _porcionesController;
  final _insumoSearchController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _pasoController = TextEditingController();
  final List<_ProductFichaInsumo> _insumos = [];
  final List<String> _pasos = [];
  String _medida = 'kg';
  String? _insumoSeleccionadoId;

  @override
  void initState() {
    super.initState();
    _prepTimeController = TextEditingController(text: widget.ficha.prepTime);
    _porcionesController = TextEditingController(text: widget.ficha.porciones);
    _insumos.addAll(widget.ficha.insumos);
    _pasos.addAll(widget.ficha.pasos);
  }

  @override
  void dispose() {
    _prepTimeController.dispose();
    _porcionesController.dispose();
    _insumoSearchController.dispose();
    _cantidadController.dispose();
    _pasoController.dispose();
    super.dispose();
  }

  /// Catálogo de insumos de la pantalla de Insumos (misma biblioteca).
  List<_Supply> get _insumosCatalogo => _SupplyManagementScreenState._supplies;

  List<_Supply> get _insumosCoincidentes {
    final query = _insumoSearchController.text;
    return _insumosCatalogo
        .where(
          (supply) => matchesSearchQuery(query, [
            supply.id,
            supply.categoryId,
            supply.name,
            supply.category,
          ]),
        )
        .toList();
  }

  bool get _mostrarResultadosInsumo =>
      _insumoSearchController.text.trim().isNotEmpty;

  _Supply? get _insumoSeleccionado {
    for (final supply in _insumosCatalogo) {
      if (supply.id == _insumoSeleccionadoId) return supply;
    }
    return null;
  }

  /// Propaga al formulario la ficha con los valores actuales.
  void _notificar() {
    widget.onChanged(
      _ProductFichaTecnica(
        id: widget.ficha.id,
        prepTime: _prepTimeController.text.trim(),
        porciones: _porcionesController.text.trim(),
        insumos: List.unmodifiable(_insumos),
        pasos: List.unmodifiable(_pasos),
      ),
    );
  }

  void _onInsumoSearchChanged(String value) {
    final resultados = _insumosCoincidentes;
    setState(() {
      _insumoSeleccionadoId = resultados.isEmpty ? null : resultados.first.id;
    });
  }

  void _seleccionarInsumo(_Supply supply) {
    setState(() {
      _insumoSeleccionadoId = supply.id;
      _medida = _medidas.contains(supply.unit) ? supply.unit : _medidas.first;
    });
  }

  void _agregarInsumo() {
    final insumo = _insumoSeleccionado;
    if (insumo == null) {
      _avisar('Busca y selecciona un insumo de la lista.');
      return;
    }
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;
    if (cantidad <= 0) {
      _avisar('Ingresa una cantidad válida para el insumo.');
      return;
    }
    setState(() {
      _insumos.add(
        _ProductFichaInsumo(
          insumoId: insumo.id,
          name: insumo.name,
          cantidad: '$cantidad',
          medida: _medida,
        ),
      );
      _cantidadController.clear();
    });
    _notificar();
  }

  void _eliminarInsumo(int index) {
    setState(() => _insumos.removeAt(index));
    _notificar();
  }

  void _agregarPaso() {
    final paso = _pasoController.text.trim();
    if (paso.isEmpty) {
      _avisar('Describe un paso de la elaboración.');
      return;
    }
    setState(() {
      _pasos.add(paso);
      _pasoController.clear();
    });
    _notificar();
  }

  void _eliminarPaso(int index) {
    setState(() => _pasos.removeAt(index));
    _notificar();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tiempo de preparación (min)'),
        _textField(
          _prepTimeController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _notificar(),
        ),
        const SizedBox(height: 20),
        _label('Porciones'),
        _textField(
          _porcionesController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _notificar(),
        ),
        const SizedBox(height: 20),
        _label('Insumos'),
        const SizedBox(height: 10),
        _buildInsumosList(),
        const SizedBox(height: 12),
        _buildInsumoAddRow(),
        const SizedBox(height: 20),
        _label('Preparación (pasos de elaboración)'),
        const SizedBox(height: 10),
        _buildPasosList(),
        const SizedBox(height: 12),
        _buildPasoAddRow(),
      ],
    );
  }

  Widget _buildInsumosList() {
    if (_insumos.isEmpty) {
      return _emptyHint('Sin insumos agregados');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _insumos.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5BDB9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_insumos[i].name} — ${_insumos[i].cantidad} '
                    '${_insumos[i].medida}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarInsumo(i),
                  icon: const Icon(
                    Icons.close,
                    color: PurchasesScreen.muted,
                    size: 20,
                  ),
                  tooltip: 'Quitar insumo',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInsumoAddRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          controller: _insumoSearchController,
          hint: 'Buscar insumo...',
          onChanged: _onInsumoSearchChanged,
          showClearButton: true,
        ),
        if (_mostrarResultadosInsumo) ...[
          const SizedBox(height: 8),
          _buildInsumoResults(),
        ],
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Cantidad'),
                  _textField(
                    _cantidadController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Medida'),
                  _dropdownField(
                    value: _medida,
                    items: _medidas,
                    onChanged: (value) {
                      if (value != null) setState(() => _medida = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _roundAddButton(_agregarInsumo),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsumoResults() {
    final resultados = _insumosCoincidentes;
    if (resultados.isEmpty) {
      return _emptyHint('No se encontraron insumos');
    }
    final visibles = resultados.take(4).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5BDB9)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < visibles.length; i++)
            InkWell(
              onTap: () => _seleccionarInsumo(visibles[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == visibles.length - 1
                          ? Colors.transparent
                          : const Color(0xFFF0E2E0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${visibles[i].id} · ${visibles[i].name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: PurchasesScreen.ink,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (visibles[i].id == _insumoSeleccionadoId)
                      const Icon(
                        Icons.check_circle,
                        color: PurchasesScreen.red,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasosList() {
    if (_pasos.isEmpty) {
      return _emptyHint('Sin pasos agregados');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _pasos.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5BDB9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}.',
                  style: GoogleFonts.poppins(
                    color: PurchasesScreen.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pasos[i],
                    style: GoogleFonts.poppins(
                      color: PurchasesScreen.ink,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarPaso(i),
                  icon: const Icon(
                    Icons.close,
                    color: PurchasesScreen.muted,
                    size: 20,
                  ),
                  tooltip: 'Quitar paso',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasoAddRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _textField(
            _pasoController,
            hintText: 'Describe un paso de la elaboración...',
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _roundAddButton(_agregarPaso),
        ),
      ],
    );
  }

  Widget _roundAddButton(VoidCallback onPressed) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: PurchasesScreen.red,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        tooltip: 'Agregar',
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5BDB9)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: PurchasesScreen.muted, fontSize: 14),
      ),
    );
  }

  Widget _label(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: PurchasesScreen.muted, fontSize: 15),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: PurchasesScreen.muted,
          fontSize: 15,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey<String?>('$value'),
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down),
      style: GoogleFonts.poppins(color: PurchasesScreen.ink, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDADADA), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: PurchasesScreen.red, width: 2),
        ),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
