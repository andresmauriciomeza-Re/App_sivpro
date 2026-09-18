import 'package:flutter/material.dart';

//Mis importaciones
import 'bottom_nav.dart';
import 'menu_screen.dart';

// ============================================================
// PALETA Y CONSTANTES DE DISEÃ‘O
// Ajusta estos valores si tu marca usa otros tonos exactos.
// ============================================================
class AppColors {
  static const Color primaryRed = Color(0xFFE0472B);
  static const Color darkText = Color(0xFF1F1B1B);
  static const Color greyText = Color(0xFF8A8A8A);
  static const Color background = Color(0xFFF7F5F2);
  static const Color cardBackground = Colors.white;
  static const Color openGreen = Color(0xFF2E7D32);
  static const Color linkBlue = Color(0xFF2F6FE0);
}

// ============================================================
// MODELO SIMPLE PARA LOS PRODUCTOS DESTACADOS
// Reemplaza las rutas de imagen por tus assets reales cuando
// tengas las fotos de cada pizza en assets/img/
// ============================================================
class FeaturedItem {
  final String name;
  final String category;
  final String price;
  final String imageAsset; // ej: 'assets/img/pepperoni.png'

  const FeaturedItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imageAsset,
  });
}

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, this.userName = 'Sebastian'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  // (el Ã­ndice de la barra de navegaciÃ³n ahora lo maneja AppBottomNav)

  final List<String> _categories = const ['Pizzas', 'Lasañas', 'Bebidas'];

  final List<FeaturedItem> _featuredItems = const [
    FeaturedItem(
      name: 'Pepperoni Clasica',
      category: 'Pizzas',
      price: '\$14.000',
      imageAsset: 'assets/img/pizza_peperoni.png',
    ),
    FeaturedItem(
      name: 'Pizza Tocineta',
      category: 'Pizzas',
      price: '\$16.000',
      imageAsset: 'assets/img/pizza_tocineta.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MenuScreen()),
                  );
                },
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
                  const Icon(Icons.local_pizza, color: AppColors.primaryRed),
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
                color: AppColors.darkText,
              ),
            ),
            Text(
              'PIZZA · DESDE 1994',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Image.asset(
              'assets/img/Fondo2.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.darkText),
            ),
          ),
          // Degradado oscuro para que el texto blanco resalte
          Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
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
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white54, width: 0.6),
                  ),
                  child: const Text(
                    'TRADICIÃ“N ARTESANAL',
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
                      'Hola, ${widget.userName}',
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
    );
  }

  // ----------------------------------------------------------
  // ENCABEZADOS DE SECCIÃ“N CON "Ver todas â†’"
  // ----------------------------------------------------------
  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Ver todas →',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // LISTA HORIZONTAL DE PRODUCTOS DESTACADOS
  // ----------------------------------------------------------
  Widget _buildFeaturedList() {
    return SizedBox(
      height: 248,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _featuredItems[index];
          return _FeaturedCard(item: item);
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // CHIPS DE CATEGORÃAS (Pizzas / LasaÃ±as / Bebidas)
  // ----------------------------------------------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bool isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryRed
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkText,
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
  // TARJETA DE INFORMACIÃ“N DEL LOCAL
  // ----------------------------------------------------------
  Widget _buildRestaurantInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Text(
                'La Sirena Pizza',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.openGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: AppColors.openGreen),
                    SizedBox(width: 5),
                    Text(
                      'Abierto',
                      style: TextStyle(
                        color: AppColors.openGreen,
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
            'Mar–Dom · 12:00 – 21:00',
            color: AppColors.primaryRed,
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.location_on_outlined,
            'Cra 45 #72-30, Medellin, Antioquia',
            color: AppColors.primaryRed,
            textColor: AppColors.darkText,
          ),
          const SizedBox(height: 10),
          _infoRow(
            Icons.phone_outlined,
            '604 234 5678',
            color: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text, {
    required Color color,
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.5,
            color: textColor ?? AppColors.darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TARJETA DE PRODUCTO DESTACADO (usada en la lista horizontal)
// ============================================================
class _FeaturedCard extends StatelessWidget {
  final FeaturedItem item;

  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      },
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
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
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.local_pizza,
                            color: AppColors.primaryRed,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.category,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                );
              },
              child: const Text(
                'Ver todas →',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryRed,
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
