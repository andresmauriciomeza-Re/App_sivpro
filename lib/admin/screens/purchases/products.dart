part of '../purchases_screen.dart';

class _Product {
  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String imagePath;
}

class _ProductManagementScreen extends StatefulWidget {
  const _ProductManagementScreen();

  @override
  State<_ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<_ProductManagementScreen> {
  final _searchController = TextEditingController();
  final _products = const [
    _Product(
      id: 'PROD-001',
      name: 'Margarita Clásica',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 24000,
      stock: 50,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-002',
      name: 'Pepperoni Premium',
      category: 'CAT-001 - Pizzas Clásicas',
      price: 28000,
      stock: 40,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-003',
      name: 'Cuatro Quesos',
      category: 'CAT-002 - Pizzas Especiales',
      price: 30000,
      stock: 30,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-004',
      name: 'Especial La Sirena',
      category: 'CAT-002 - Pizzas Especiales',
      price: 32000,
      stock: 25,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
    _Product(
      id: 'PROD-005',
      name: 'Veggie Mediterránea',
      category: 'CAT-003 - Pizzas Vegetarianas',
      price: 26000,
      stock: 20,
      imagePath: 'assets/images/products/pizza.jpg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredProducts = _products
        .where(
          (product) =>
              product.id.toLowerCase().contains(query) ||
              product.name.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
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
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_products.length} productos registrados',
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID, nombre o categoría...',
                        hintStyle: GoogleFonts.dmSerifDisplay(
                          color: const Color(0xFF6E7587),
                          fontSize: 18,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: PurchasesScreen.muted,
                          size: 30,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFFBFA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                          horizontal: 14,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE5BDB9)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: PurchasesScreen.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
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
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.black,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _productTag(product.id),
                        Text(
                          product.category,
                          style: GoogleFonts.dmSerifDisplay(
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
                style: GoogleFonts.dmSerifDisplay(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductDetailScreen(product: product),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: PurchasesScreen.muted,
                  size: 29,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductEditScreen(product: product),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: PurchasesScreen.muted,
                  size: 29,
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteProductDialog(product),
                icon: const Icon(
                  Icons.delete_outline,
                  color: PurchasesScreen.red,
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
                  style: GoogleFonts.dmSerifDisplay(
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
        style: GoogleFonts.dmSerifDisplay(
          color: PurchasesScreen.ink,
          fontSize: 13,
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

  Future<void> _showDeleteProductDialog(_Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: PurchasesScreen.page,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 28, 25, 26),
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD9D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: PurchasesScreen.red,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Eliminar producto',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.black,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.dmSerifDisplay(
                        color: PurchasesScreen.muted,
                        fontSize: 18,
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(
                          text: '¿Seguro que deseas eliminar el producto ',
                        ),
                        TextSpan(
                          text: '${product.id}?',
                          style: GoogleFonts.dmSerifDisplay(
                            color: PurchasesScreen.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(
                          text: ' Esta acción no se puede deshacer.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5BDB9)),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PurchasesScreen.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Sí, confirmar',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 68,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(
                          color: PurchasesScreen.muted,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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

    if (mounted && confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.id} eliminado correctamente.')),
      );
    }
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
                  Icon(
                    items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
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

class _ProductDetailScreen extends StatelessWidget {
  const _ProductDetailScreen({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
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
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '—',
                    style: GoogleFonts.dmSerifDisplay(
                      color: PurchasesScreen.muted,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.id,
                    style: GoogleFonts.dmSerifDisplay(
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
                        valueStyle: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _detailSection(
                        'NOMBRE',
                        product.name,
                        valueStyle: GoogleFonts.dmSerifDisplay(
                          color: PurchasesScreen.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
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
                        valueStyle: GoogleFonts.dmSerifDisplay(
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
                                'und',
                                GoogleFonts.dmSerifDisplay(
                                  color: PurchasesScreen.ink,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            _detailValueColumn(
                              'STOCK',
                              '${product.stock} und',
                              GoogleFonts.dmSerifDisplay(
                                color: PurchasesScreen.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              valueBackground: const Color(0xFFE9E7E6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 72,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productAppHeader(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.red,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
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
            style: GoogleFonts.dmSerifDisplay(
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
                      GoogleFonts.dmSerifDisplay(
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
          style: GoogleFonts.dmSerifDisplay(
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
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _category = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                              TextEditingController(
                                text: 'https://image...',
                              ),
                              hintText: 'URL de imagen',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.product.imagePath,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
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
                                  value: 'und',
                                  items: const ['und', 'kg', 'l'],
                                  onChanged: (_) {},
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
                                style: GoogleFonts.dmSerifDisplay(
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
                                style: GoogleFonts.dmSerifDisplay(
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
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.red,
              size: 25,
            ),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                color: AppColors.red,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.dmSerifDisplay(
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

  Widget _buildEditTitleHeader() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            'Editar',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.ink,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '—',
            style: GoogleFonts.dmSerifDisplay(
              color: PurchasesScreen.muted,
              fontSize: 23,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.product.id,
            style: GoogleFonts.dmSerifDisplay(
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
              style: GoogleFonts.dmSerifDisplay(
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
        style: GoogleFonts.dmSerifDisplay(
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
      style: GoogleFonts.dmSerifDisplay(
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
      style: GoogleFonts.dmSerifDisplay(
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

  void _saveProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.id} actualizado correctamente.'),
      ),
    );
    Navigator.of(context).pop();
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
                  Icon(
                    items[i].$1,
                    color: i == 2 ? PurchasesScreen.red : PurchasesScreen.muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.dmSerifDisplay(
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

