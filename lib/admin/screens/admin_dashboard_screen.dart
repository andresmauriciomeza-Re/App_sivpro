import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';
import '../../auth/permisos.dart';
import '../../network/api_exception.dart';
import '../../shared/initials.dart';
import '../../shared/pending_sales_service.dart';
import '../../theme/app_colors.dart';
import '../services/indicators_service.dart';
import '../services/insumos_repository.dart';
import '../../shared/formato.dart';
import '../services/ventas_repository.dart';
import '../widgets/production_summary_card.dart';
import '../widgets/summary_cards_grid.dart';
import 'purchases_screen.dart';
import '../../theme/paleta_app.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const Color red = AppColors.red;
  static const Color ink = AppColors.ink;
  static const Color muted = AppColors.muted;
  static const Color page = AppColors.page;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Venta> _ventas = const [];
  bool _ventasLoading = false;
  String? _ventasError;

  List<Insumo> _insumos = const [];
  bool _insumosLoading = false;
  String? _insumosError;

  /// Cambia al refrescar para que la tarjeta de producción se vuelva a cargar.
  int _refreshTick = 0;

  Color get red => AdminDashboardScreen.red;
  Color get ink => AdminDashboardScreen.ink;
  Color get muted => AdminDashboardScreen.muted;
  Color get page => AdminDashboardScreen.page;

  bool get _puedeVentas => Permisos.ventas;
  bool get _puedeInsumos => Permisos.comprasInsumos;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() {
    return Future.wait([_loadVentas(), _loadInsumos()]);
  }

  Future<void> _refresh() async {
    setState(() => _refreshTick++);
    await _loadAll();
  }

  Future<void> _loadVentas() async {
    if (!_puedeVentas) return;
    setState(() {
      _ventasLoading = true;
      _ventasError = null;
    });
    try {
      final ventas = await VentasRepository.instance.listar();
      if (!mounted) return;
      PendingSalesService.instance.actualizarDesde(ventas);
      setState(() {
        _ventas = ventas;
        _ventasLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ventasLoading = false;
        _ventasError = error is ApiException
            ? error.message
            : 'No se pudieron cargar las ventas.';
      });
    }
  }

  Future<void> _loadInsumos() async {
    if (!_puedeInsumos) return;
    setState(() {
      _insumosLoading = true;
      _insumosError = null;
    });
    try {
      final insumos = await InsumosRepository.instance.listar(estado: true);
      if (!mounted) return;
      setState(() {
        _insumos = insumos;
        _insumosLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _insumosLoading = false;
        _insumosError = error is ApiException
            ? error.message
            : 'No se pudieron cargar los insumos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pal.fondo(page),
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _saludo(),
                        style: GoogleFonts.montserrat(
                          color: context.pal.texto(ink),
                          fontSize: 29,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Resumen del día — ${fechaLargaBogota()}',
                        style: GoogleFonts.poppins(
                          color: context.pal.secundario(muted),
                          fontSize: 15,
                        ),
                      ),
                      if (Permisos.indicadores) ...[
                        const SizedBox(height: 22),
                        _buildIndicatorsButton(),
                      ],
                      ..._buildSummarySection(),
                      // Solo con Producción › Orden de Producción › Ver: sin
                      // permiso no se monta la tarjeta ni se llama al backend.
                      if (Permisos.produccionOrdenes) ...[
                        const SizedBox(height: 34),
                        ProductionSummaryCard(key: ValueKey(_refreshTick)),
                      ],
                      ..._buildRecentSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Saludo con el primer nombre del usuario en sesión.
  String _saludo() {
    final nombre = AuthService.instance.currentFirstName;
    return nombre.isEmpty ? '¡Bienvenido! 👋' : '¡Bienvenido, $nombre! 👋';
  }

  /// Acceso a la pantalla de Indicadores.
  Widget _buildIndicatorsButton() => _buildAccesoButton(
    Icons.insights_outlined,
    'Ver indicadores',
    const IndicatorsScreen(),
  );

  /// Botón de acceso a una pantalla desde el Dashboard.
  Widget _buildAccesoButton(IconData icono, String texto, Widget destino) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => destino)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: context.pal.tarjeta(page),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.pal.borde(Color(0xFFE5BDB9))),
        ),
        child: Row(
          children: [
            Icon(icono, color: context.pal.rojo(red), size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: GoogleFonts.poppins(
                  color: context.pal.texto(ink),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.pal.secundario(muted),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.pal.borde(AppColors.headerDivider)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Text(
            'La Sirena Pizza',
            style: GoogleFonts.montserrat(
              color: context.pal.texto(ink),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: context.pal.rojoBoton(red),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              currentUserInitials(),
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

  // ------------------------------------------------------------ resumen

  /// Tarjetas con datos reales. Cada fuente solo aparece si el usuario tiene
  /// su permiso de lectura; no hay cifras de ejemplo.
  List<Widget> _buildSummarySection() {
    if (!_puedeVentas && !_puedeInsumos) return const [];

    final hoy = diaBogotaTexto();
    final completadasHoy = ventasCompletadas(
      _ventas,
    ).where((v) => fechaDeVenta(v) == hoy).toList();
    final totalHoy = completadasHoy.fold<double>(0, (s, v) => s + v.monto);
    final bajoMinimo = _insumos.where((i) => i.estado && i.bajoMinimo).length;

    final ventasListas = !_ventasLoading && _ventasError == null;
    final insumosListos = !_insumosLoading && _insumosError == null;

    // Tocar abre el módulo con el mismo mecanismo del menú. Ventas exige
    // Ventas › Ventas › Ver e Insumos, Compras › Insumos › Ver; sin permiso la
    // tarjeta queda sin efecto de toque.
    VoidCallback? abrirVentas(EstadoVenta estado) => Permisos.ventas
        ? () => openSalesManagement(context, estado: estado)
        : null;
    final VoidCallback? abrirInsumos = Permisos.comprasInsumos
        ? () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => insumosScreen()))
        : null;

    final cards = <Widget>[
      if (_puedeVentas) ...[
        SummaryCard(
          icon: Icons.attach_money,
          title: 'Ventas completadas hoy',
          value: ventasListas ? formatCop(totalHoy.round()) : '—',
          highlight: true,
          onTap: abrirVentas(EstadoVenta.completado),
        ),
        SummaryCard(
          icon: Icons.local_pizza_outlined,
          title: 'Pedidos completados hoy',
          value: ventasListas ? '${completadasHoy.length}' : '—',
          onTap: abrirVentas(EstadoVenta.completado),
        ),
        ValueListenableBuilder<int>(
          valueListenable: PendingSalesService.instance.count,
          builder: (context, count, _) => SummaryCard(
            icon: Icons.schedule_outlined,
            title: 'Ventas por verificar',
            value: '$count',
            onTap: abrirVentas(EstadoVenta.porVerificar),
          ),
        ),
      ],
      if (_puedeInsumos)
        SummaryCard(
          icon: Icons.inventory_2_outlined,
          title: 'Insumos en nivel mínimo',
          value: insumosListos ? '$bajoMinimo' : '—',
          warning: insumosListos && bajoMinimo > 0,
          onTap: abrirInsumos,
        ),
    ];

    return [
      const SizedBox(height: 28),
      if (_ventasError != null) _errorRow(_ventasError!, _loadVentas),
      if (_insumosError != null) _errorRow(_insumosError!, _loadInsumos),
      SummaryCardsGrid(cards: cards),
    ];
  }

  Widget _errorRow(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: context.pal.rojo(red),
                fontSize: 14,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  // --------------------------------------------------- actividad reciente

  /// Las 5 ventas más recientes (el backend las entrega de la más nueva a la
  /// más antigua). Solo con permiso de ventas.
  List<Widget> _buildRecentSection() {
    if (!_puedeVentas) return const [];
    final recientes = _ventas.take(5).toList();
    if (!_ventasLoading && _ventasError == null && recientes.isEmpty) {
      return const [];
    }
    return [
      const SizedBox(height: 34),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Actividad reciente',
            style: GoogleFonts.poppins(
              color: context.pal.texto(ink),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => openSalesManagement(context),
            child: Text(
              'Ver todos  →',
              style: GoogleFonts.poppins(
                color: context.pal.texto(ink),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (_ventasLoading && _ventas.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ...recientes.map(_buildRecentSale),
    ];
  }

  Widget _buildRecentSale(Venta sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.codigo,
                  style: GoogleFonts.poppins(
                    color: context.pal.texto(ink),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sale.clienteNombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: context.pal.secundario(muted),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCop(sale.monto.round()),
                style: GoogleFonts.poppins(
                  color: context.pal.texto(ink),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sale.estadoLabel,
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(muted),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 0);

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: context.pal.tarjeta(page),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.pal.borde(Color(0xFFE8DDDB))),
      boxShadow: [
        BoxShadow(
          color: context.pal.sombra(Color(0x0A000000)),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}
