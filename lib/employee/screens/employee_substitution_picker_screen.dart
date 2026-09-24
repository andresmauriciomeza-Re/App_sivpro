import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/initials.dart';
import '../../theme/app_colors.dart';
import '../../shared/menu_item.dart';

/// Menú compacto para escoger el producto de sustitución equivalente.
/// Reutiliza los datos del catálogo (MenuItem) y devuelve al confirmar
/// el nombre del producto elegido vía Navigator.pop.
class EmployeeSubstitutionPickerScreen extends StatefulWidget {
  const EmployeeSubstitutionPickerScreen({super.key});

  @override
  State<EmployeeSubstitutionPickerScreen> createState() =>
      _EmployeeSubstitutionPickerScreenState();
}

class _EmployeeSubstitutionPickerScreenState
    extends State<EmployeeSubstitutionPickerScreen> {
  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  int? _seleccionado;

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breadcrumb(),
                    const SizedBox(height: 22),
                    Text(
                      'Producto de sustitución',
                      style: GoogleFonts.montserrat(
                        color: ink,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige el producto de reemplazo equivalente que recibirá el cliente.',
                      style: GoogleFonts.poppins(color: muted, fontSize: 14),
                    ),
                    const SizedBox(height: 22),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _catalogoSustitucion.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        final item = _catalogoSustitucion[index];
                        final selected = _seleccionado == index;
                        return _SubstitutionCard(
                          item: item,
                          selected: selected,
                          onTap: () =>
                              setState(() => _seleccionado = index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _confirmBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.page,
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LA SIRENA PIZZA',
                style: GoogleFonts.montserrat(
                  color: red,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'S.I.V.PRO Mobile',
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              getInitials('María González'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text('Inicio', style: GoogleFonts.poppins(color: muted, fontSize: 16)),
        const SizedBox(width: 36),
        Text(
          'devoluciones',
          style: GoogleFonts.poppins(color: muted, fontSize: 16),
        ),
        const SizedBox(width: 36),
        Text(
          'canje',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _confirmBar() {
    final hasSelection = _seleccionado != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: hasSelection ? _confirmar : null,
          style: FilledButton.styleFrom(
            backgroundColor: red,
            disabledBackgroundColor: red.withValues(alpha: 0.15),
            disabledForegroundColor: red.withValues(alpha: 0.45),
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            'Confirmar sustitución',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmar() {
    if (_seleccionado == null) return;
    final item = _catalogoSustitucion[_seleccionado!];
    Navigator.of(context).pop(item.nombre);
  }

  Widget _bottomNavigation() {
    const items = [
      (Icons.home_outlined, 'Inicio'),
      (Icons.people_outline, 'Clientes'),
      (Icons.receipt_long, 'Ventas'),
      (Icons.sync_alt, 'Devoluciones'),
      (Icons.person_outline, 'Perfil'),
    ];
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].$1,
                            color: i == 3 ? red : const Color(0xFFA4AAB5),
                            size: 21,
                          ),
                          Text(
                            items[i].$2,
                            style: GoogleFonts.poppins(
                              color: i == 3 ? red : const Color(0xFFA4AAB5),
                              fontSize: 10,
                            ),
                          ),
                        ],
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

class _SubstitutionCard extends StatelessWidget {
  const _SubstitutionCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MenuItem item;
  final bool selected;
  final VoidCallback onTap;

  static const splashRojo = Color(0xFFC9151E);

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
            border: Border.all(
              color: selected ? splashRojo : const Color(0xFFE4E1DF),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: splashRojo.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF1F3F5),
                      child: Image.asset(
                        item.imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.local_pizza,
                              color: splashRojo,
                              size: 32,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.precioTexto,
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
              if (selected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: splashRojo,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Catálogo compacto para sustitución: reutiliza el modelo y el catálogo
/// del menú existente (menu_item.dart) con sus mismas imágenes.
const List<MenuItem> _catalogoSustitucion = [
  MenuItem(
    nombre: 'Pizza Cañon',
    descripcion: 'Salsa de tomate casera y mozzarella fresca.',
    imagen: 'assets/img/pizza_cañon.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pepperoni Carnes',
    descripcion: 'Masa madre con pepperoni y mozzarella.',
    imagen: 'assets/img/pizza_carnes.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pizza Pollo',
    descripcion: 'Nuestra pizza insignia con pollo.',
    imagen: 'assets/img/pizza_pollo.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pizza Tocineta',
    descripcion: 'Tocineta crujiente y mozzarella.',
    imagen: 'assets/img/pizza_tocineta.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pizza Peperoni',
    descripcion: 'Peperoni clásico sobre masa madre.',
    imagen: 'assets/img/pizza_peperoni.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pizza Maicitos',
    descripcion: 'Maíz dulce y mozzarella extra.',
    imagen: 'assets/img/pizza_maicitos.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Pizza Jamón con Queso',
    descripcion: 'Jamón y queso gratinado.',
    imagen: 'assets/img/pizza_jamon_queso.png',
    tamanos: [ProductSize(nombre: 'Grande', precio: 16000)],
  ),
  MenuItem(
    nombre: 'Lasaña de Carne',
    descripcion: 'Capas de pasta fresca y carne.',
    imagen: 'assets/img/lasaña_carne.png',
    tamanos: [ProductSize(nombre: 'Porción', precio: 18000)],
  ),
];