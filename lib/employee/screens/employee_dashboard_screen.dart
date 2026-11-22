import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin/services/indicators_service.dart';
import '../../admin/services/ventas_repository.dart';
import '../../network/api_exception.dart';
import '../../shared/initials.dart';
import '../../shared/permission_helper.dart';
import '../../theme/app_colors.dart';
import 'employee_sales_management_screen.dart';
import 'employee_clients_screen.dart';
import 'employee_sale_detail_screen.dart';
import '../../shared/page_transitions.dart';
import '../../shared/periodic_refresh.dart';
import '../../auth/auth_service.dart';
import '../../client/screens/home_screen.dart' hide AppColors;
import '../services/return_service.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF8C8583);
  static const Color page = Color(0xFFFCF9F8);

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen>
    with PeriodicRefreshMixin<EmployeeDashboardScreen> {
  static const Color red = EmployeeDashboardScreen.red;
  static const Color ink = EmployeeDashboardScreen.ink;
  static const Color muted = EmployeeDashboardScreen.muted;
  static const Color page = EmployeeDashboardScreen.page;

  List<Venta> _ventas = const [];
  bool _cargandoVentas = true;
  bool _recargando = false;
  String? _errorVentas;

  bool get _puedeVerVentas => PermissionHelper.puedeVerVentas;

  bool get _puedeVerClientes => PermissionHelper.puedeVerClientes;

  @override
  void initState() {
    super.initState();
    if (_puedeVerVentas) {
      _cargarVentas();
      iniciarRefrescoPeriodico();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ReturnService.instance.cargar();
      });
    } else {
      _cargandoVentas = false;
    }
  }

  @override
  Future<void> refrescarPeriodico() async {
    if (_puedeVerVentas) await _recargarTodo();
  }

  Future<void> _cargarVentas({bool silencioso = false}) async {
    if (_recargando) return;
    setState(() {
      _recargando = true;
      if (!silencioso) _cargandoVentas = _ventas.isEmpty;
      if (!silencioso) _errorVentas = null;
    });
    try {
      final ventas = await VentasRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _ventas = ventas;
        _errorVentas = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorVentas = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorVentas = 'No se pudieron cargar las ventas.');
    } finally {
      if (mounted) {
        setState(() {
          _cargandoVentas = false;
          _recargando = false;
        });
      }
    }
  }

  Future<void> _recargarTodo() async {
    if (_puedeVerVentas) {
      await _cargarVentas(silencioso: true);
      await ReturnService.instance.cargar();
    }
  }

  List<Venta> get _ventasDeHoy {
    final hoy = diaBogotaTexto();
    return ventasCompletadas(
      _ventas,
    ).where((venta) => fechaDeVenta(venta) == hoy).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: red,
                onRefresh: _recargarTodo,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _saludo(),
                        style: GoogleFonts.montserrat(color: ink, fontSize: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _fechaHoy(),
                        style: GoogleFonts.poppins(color: muted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      if (_errorVentas != null) ...[
                        _errorBanner(_errorVentas!),
                        const SizedBox(height: 14),
                      ],
                      _buildSalesSummary(),
                      const SizedBox(height: 16),
                      Text(
                        'ACCESOS RÁPIDOS',
                        style: GoogleFonts.poppins(
                          color: muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_puedeVerVentas || _puedeVerClientes) ...[
                        Row(
                          children: [
                            if (_puedeVerVentas)
                              Expanded(
                                child: _QuickAccessCard(
                                  icon: Icons.point_of_sale_outlined,
                                  label: 'Ventas',
                                  subtitle: 'Cobrar orden',
                                  onTap: () => _openSalesManagement(context),
                                ),
                              ),
                            if (_puedeVerVentas && _puedeVerClientes)
                              const SizedBox(width: 12),
                            if (_puedeVerClientes)
                              Expanded(
                                child: _QuickAccessCard(
                                  icon: Icons.people_outline,
                                  label: 'Clientes',
                                  subtitle: 'Directorio',
                                  onTap: () => _openClients(context),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Últimas ventas',
                            style: GoogleFonts.poppins(
                              color: ink,
                              fontSize: 22,
                            ),
                          ),
                          if (_puedeVerVentas)
                            TextButton(
                              onPressed: () =>
                                  _openSalesManagement(context),
                              child: Text(
                                'Ver todos  →',
                                style: GoogleFonts.poppins(
                                  color: red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ..._ultimasVentas(),
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
    return nombre.isEmpty ? '¡Buenos días! 👋' : '¡Buenos días, $nombre! 👋';
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
                'La Sirena',
                style: GoogleFonts.montserrat(color: red, fontSize: 19),
              ),
              Text(
                'S.I.V.PRO',
                style: GoogleFonts.poppins(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _goToStore(context),
            tooltip: 'Ir a la tienda',
            color: red,
            icon: const Icon(Icons.storefront, size: 26),
          ),
          const SizedBox(width: 6),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
            child: Text(
              currentUserInitials(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToStore(BuildContext context) {
    AuthService.instance.startStoreSession();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  String _fechaHoy() {
    final texto = fechaLargaBogota();
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  Widget _buildSalesSummary() {
    final ventasHoy = _ventasDeHoy;
    final totalHoy = ventasHoy.fold<double>(0, (suma, v) => suma + v.monto);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CompactStatCard(
            icon: Icons.shopping_bag_outlined,
            iconBg: AppColors.salesIconBg,
            iconColor: AppColors.salesIconFg,
            value: _cargandoVentas && _ventas.isEmpty
                ? '—'
                : '${ventasHoy.length}',
            label: 'Ventas hoy',
            subtext: _cargandoVentas && _ventas.isEmpty
                ? 'Cargando...'
                : 'Total ${_formatearMonto(totalHoy)}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ListenableBuilder(
            listenable: ReturnService.instance,
            builder: (context, _) {
              final pendientes = ReturnService.instance.pendientes.length;
              return _CompactStatCard(
                icon: Icons.assignment_return_outlined,
                iconBg: AppColors.returnIconBg,
                iconColor: AppColors.returnIconFg,
                value: '$pendientes',
                label: 'Devoluciones',
                subtext: pendientes == 1
                    ? 'pendiente por atender'
                    : 'pendientes por atender',
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _ultimasVentas() {
    if (!_puedeVerVentas) {
      return [
        _mensajeVentas('No tienes permiso para ver las ventas.'),
      ];
    }
    if (_cargandoVentas && _ventas.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: red)),
        ),
      ];
    }
    if (_ventas.isEmpty) {
      return [_mensajeVentas('Aún no hay ventas registradas.')];
    }
    return [
      for (final venta in _ventas.take(5))
        _SaleCard(
          venta: venta,
          onTap: () => _abrirVenta(venta),
        ),
    ];
  }

  Widget _mensajeVentas(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: muted, fontSize: 14),
        ),
      ),
    );
  }

  Widget _errorBanner(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9B4610), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            onPressed: _recargando ? null : _cargarVentas,
            child: Text(
              'Reintentar',
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B4610),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirVenta(Venta venta) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EmployeeSaleDetailScreen(idVenta: venta.id),
      ),
    );
    if (mounted) await _cargarVentas(silencioso: true);
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final items = employeeNavItems();

    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: red, width: 1),
                  left: BorderSide(color: Color(0xFFEDE6E4)),
                  right: BorderSide(color: Color(0xFFEDE6E4)),
                ),
              ),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: InkWell(
                        onTap: items[index].index == 0
                            ? null
                            : () => handleEmployeeBottomNav(
                                context,
                                items[index].index,
                              ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].index == 0
                                  ? items[index].activeIcon ?? items[index].icon
                                  : items[index].icon,
                              color: items[index].index == 0
                                  ? red
                                  : const Color(0xFF756D6A),
                              size: 19,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              items[index].label,
                              style: GoogleFonts.poppins(
                                color: items[index].index == 0
                                    ? red
                                    : const Color(0xFF756D6A),
                                fontSize: 10,
                                height: 1,
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

  void _openSalesManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: kVentasModulesRoute),
        builder: (_) => const EmployeeSalesManagementScreen(),
      ),
    );
  }

  void _openClients(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: kClientesRoute),
        builder: (_) => const EmployeeClientsScreen(),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFECE6E4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: EmployeeDashboardScreen.red, size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: EmployeeDashboardScreen.ink,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: EmployeeDashboardScreen.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.subtext,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFECE6E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.poppins(
                color: EmployeeDashboardScreen.ink,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: EmployeeDashboardScreen.muted,
              fontSize: 13,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppColors.cardSubtext,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.venta, required this.onTap});

  final Venta venta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _estadoColor(venta.estado);
    final pago = venta.pagos.isEmpty
        ? 'Sin pago'
        : venta.pagos.length == 1
        ? venta.pagos.first.tipo ?? 'Pago'
        : '${venta.pagos.length} pagos';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECE6E4)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  venta.codigo,
                  style: GoogleFonts.poppins(
                    color: EmployeeDashboardScreen.muted,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  venta.estadoLabel,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    venta.clienteNombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatearMonto(venta.monto),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: EmployeeDashboardScreen.muted,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  pago,
                  style: GoogleFonts.poppins(
                    color: EmployeeDashboardScreen.muted,
                    fontSize: 12,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '·',
                    style: TextStyle(color: Color(0xFFBDB5B3)),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: EmployeeDashboardScreen.muted,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  formatFechaHoraVenta(venta.fecha),
                  style: GoogleFonts.poppins(
                    color: EmployeeDashboardScreen.muted,
                    fontSize: 12,
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

Color _estadoColor(EstadoVenta? estado) {
  return switch (estado) {
    EstadoVenta.porVerificar => const Color(0xFFB45B00),
    EstadoVenta.enEspera => const Color(0xFF3B4BA8),
    EstadoVenta.porEntregar => const Color(0xFF2861B7),
    EstadoVenta.completado => const Color(0xFF008C5A),
    EstadoVenta.devolucion => const Color(0xFFB44A00),
    EstadoVenta.anulado => const Color(0xFFA11D1D),
    null => EmployeeDashboardScreen.muted,
  };
}

String _formatearMonto(double valor) {
  final redondeado = valor.round();
  final texto = redondeado.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return '\$${redondeado < 0 ? '-' : ''}$buffer';
}
