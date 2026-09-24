part of '../purchases_screen.dart';

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  static const _red = AppColors.red;
  static const _ink = AppColors.ink;
  static const _muted = AppColors.muted;
  static const _page = AppColors.page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Más opciones',
                      style: GoogleFonts.montserrat(
                        color: PurchasesScreen.ink,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 38),
                    _optionsCard(context),
                    const SizedBox(height: 48),
                    Center(
                      child: Text(
                        'La Sirena Pizza – S.I.V.PRO',
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Versión 2.1.4',
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.headerDivider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.red, size: 29),
          ),
          Expanded(
            child: Text(
              'La Sirena Pizza',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: _red,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.only(right: 14),
            decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              getInitials('Gloria Inés Vargas'),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _page,
        border: Border.all(color: const Color(0xFFE5BDB9)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 38, 24, 34),
            child: Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: _red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getInitials('Gloria Inés Vargas'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gloria Inés Vargas',
                        style: GoogleFonts.poppins(
                          color: _ink,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Administrador',
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E2E1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'S.I.V.PRO',
                          style: GoogleFonts.poppins(
                            color: _muted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _optionTile(
            icon: Icons.person_outline,
            title: 'Perfil',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          InkWell(
            onTap: () => _confirmSignOut(context),
            child: Container(
              height: 84,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: _red, size: 31),
                  const SizedBox(width: 25),
                  Text(
                    'Cerrar sesión',
                    style: GoogleFonts.poppins(color: _red, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5BDB9))),
        ),
        child: Row(
          children: [
            Icon(icon, color: _muted, size: 29),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(color: _ink, fontSize: 20),
              ),
            ),
            const Icon(Icons.chevron_right, color: _muted, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
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
                    size: 27,
                    color: i == 4 ? _red : _muted,
                  ),
                  Text(
                    items[i].$2,
                    style: GoogleFonts.poppins(
                      color: i == 4 ? _red : _muted,
                      fontSize: 11,
                      fontWeight: i == 4 ? FontWeight.w700 : FontWeight.w400,
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

