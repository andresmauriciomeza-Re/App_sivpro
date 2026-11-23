part of '../purchases_screen.dart';

enum _SalesPeriod { diario, mensual, anual }

/// Indicadores de gestión del admin. Los datos se calculan en el móvil con
/// `indicators_service.dart` a partir de GET /ventas y
/// GET /productos-no-conformes; esta pantalla solo los dibuja.
class IndicatorsScreen extends StatefulWidget {
  const IndicatorsScreen({super.key});

  @override
  State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends State<IndicatorsScreen> {
  static const double _fs = 16; // tamaño mínimo de texto
  static const Color _green = Color(0xFF2E7D32);
  static const Color _blue = Color(0xFF2A5FA8);

  late int _year;
  late int _month;
  _SalesPeriod _period = _SalesPeriod.diario;

  List<Venta>? _ventas;
  String? _ventasError;
  bool _ventasLoading = true;

  List<ProductoNoConforme>? _noConformes;
  String? _noConformesError;
  bool _noConformesLoading = true;

  @override
  void initState() {
    super.initState();
    final now = ahoraBogota();
    _year = now.year;
    _month = now.month;
    _loadAll();
  }

  Future<void> _loadAll() => Future.wait([_loadVentas(), _loadNoConformes()]);

  static const String _sinPermiso =
      'No tienes permiso para ver esta información.';

  /// Solo con Ventas › Ventas › Ver; sin él no se llama al backend.
  Future<void> _loadVentas() async {
    if (!Permisos.ventas) {
      setState(() {
        _ventasLoading = false;
        _ventasError = _sinPermiso;
      });
      return;
    }
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

  /// Solo con Producción › Producto No Conforme › Ver; sin él no se llama
  /// al backend.
  Future<void> _loadNoConformes() async {
    if (!Permisos.produccionNoConformes) {
      setState(() {
        _noConformesLoading = false;
        _noConformesError = _sinPermiso;
      });
      return;
    }
    setState(() {
      _noConformesLoading = true;
      _noConformesError = null;
    });
    try {
      final registros = await NoConformesRepository.instance.listar();
      if (!mounted) return;
      setState(() {
        _noConformes = registros;
        _noConformesLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _noConformesLoading = false;
        _noConformesError = error is ApiException
            ? error.message
            : 'No se pudieron cargar los productos no conformes.';
      });
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final completadas = ventasCompletadas(_ventas ?? const []);
    final delMes = ventasDelMes(completadas, _year, _month);

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'La Sirena Pizza',
              onBack: () => Navigator.of(context).pop(),
              initials: currentUserInitials(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                  children: [
                    Text(
                      'Indicadores',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Medición y desempeño de la gestión administrativa',
                      style: GoogleFonts.poppins(
                        color: context.pal.secundario(PurchasesScreen.muted),
                        fontSize: _fs,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPeriodSelector(),
                    const SizedBox(height: 18),
                    _buildClientsSection(delMes),
                    _buildProductsSection(delMes),
                    _buildSalesSection(completadas),
                    _buildNoConformesSection(),
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

  // --------------------------------------------------------------- selector

  List<int> get _years {
    final now = ahoraBogota().year;
    var first = now - 4;
    for (final venta in _ventas ?? const <Venta>[]) {
      final dia = fechaDeVenta(venta);
      final anio = dia == null ? null : int.tryParse(dia.substring(0, 4));
      if (anio != null && anio < first) first = anio;
    }
    return [for (var y = now; y >= first; y--) y];
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SelectorPeriodo<int>(
            valor: _month,
            opciones: [for (var m = 1; m <= 12; m++) m],
            etiqueta: (m) =>
                nombresMes[m - 1][0].toUpperCase() +
                nombresMes[m - 1].substring(1),
            alturaMaxima: 320,
            onSelected: (value) => setState(() => _month = value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SelectorPeriodo<int>(
            valor: _year,
            opciones: _years,
            etiqueta: (y) => '$y',
            onSelected: (value) => setState(() => _year = value),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- sections

  Widget _section({
    required String title,
    String? subtitle,
    required bool loading,
    required String? error,
    required VoidCallback onRetry,
    required bool empty,
    required List<Widget> children,
    Widget? header,
  }) {
    Widget body;
    if (loading) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (error != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error,
              style: GoogleFonts.poppins(
                color: context.pal.rojo(PurchasesScreen.red),
                fontSize: _fs,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: context.pal.rojoBoton(PurchasesScreen.red),
                minimumSize: const Size(0, 48),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar', style: TextStyle(fontSize: _fs)),
            ),
          ],
        ),
      );
    } else if (empty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Sin datos en este periodo',
          style: GoogleFonts.poppins(
            color: context.pal.secundario(PurchasesScreen.muted),
            fontSize: _fs,
          ),
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(PurchasesScreen.page),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.pal.borde(Color(0xFFE5BDB9))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              color: context.pal.texto(PurchasesScreen.ink),
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: _fs,
              ),
            ),
          ],
          if (header != null) ...[const SizedBox(height: 12), header],
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }

  String get _monthLabel => '${nombresMes[_month - 1]} de $_year';

  /// 1. Clientes más frecuentes vs mayores consumidores.
  Widget _buildClientsSection(List<Venta> delMes) {
    final clientes = topClientes(delMes);
    final maxPedidos = clientes.fold<int>(
      0,
      (m, c) => c.pedidos > m ? c.pedidos : m,
    );
    final maxValor = clientes.fold<double>(
      0,
      (m, c) => c.valor > m ? c.valor : m,
    );
    return _section(
      title: 'Clientes: frecuentes y mayores consumidores',
      subtitle: 'Ventas completadas en $_monthLabel',
      loading: _ventasLoading,
      error: _ventasError,
      onRetry: _loadVentas,
      empty: clientes.isEmpty,
      children: [
        for (final cliente in clientes) ...[
          Text(
            cliente.nombre,
            style: GoogleFonts.poppins(
              color: context.pal.texto(PurchasesScreen.ink),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _bar(
            label: 'Pedidos',
            value: '${cliente.pedidos}',
            fraction: maxPedidos == 0 ? 0 : cliente.pedidos / maxPedidos,
            color: context.pal.graficoRojo(PurchasesScreen.red),
          ),
          const SizedBox(height: 6),
          _bar(
            label: 'Consumo',
            value: formatCop(cliente.valor.round()),
            fraction: maxValor == 0 ? 0 : cliente.valor / maxValor,
            color: context.pal.graficoVerde(_green),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  /// 2. Productos más vendidos.
  Widget _buildProductsSection(List<Venta> delMes) {
    final productos = topProductos(delMes);
    final maxTotal = productos.isEmpty ? 0.0 : productos.first.total;
    return _section(
      title: 'Productos más vendidos',
      subtitle: 'Ventas completadas en $_monthLabel',
      loading: _ventasLoading,
      error: _ventasError,
      onRetry: _loadVentas,
      empty: productos.isEmpty,
      children: [
        for (var i = 0; i < productos.length; i++) ...[
          _bar(
            label: '${i + 1}. ${productos[i].nombre}',
            value: _purchaseQuantity(productos[i].total),
            fraction: maxTotal == 0 ? 0 : productos[i].total / maxTotal,
            color: context.pal.infoTexto(_blue),
            detail: _productDetail(productos[i]),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  String? _productDetail(TopProducto p) {
    final partes = <String>[
      if (p.unidades > 0) 'Unidades: ${_purchaseQuantity(p.unidades)}',
      if (p.medianas > 0) 'Medianas: ${_purchaseQuantity(p.medianas)}',
      if (p.grandes > 0) 'Grandes: ${_purchaseQuantity(p.grandes)}',
    ];
    // Solo se muestra el desglose cuando hay porciones por tamaño.
    if (p.medianas == 0 && p.grandes == 0) return null;
    return partes.join(' · ');
  }

  /// 3. Ventas diarias, mensuales y anuales.
  Widget _buildSalesSection(List<Venta> completadas) {
    final List<PuntoVentas> puntos;
    final String subtitle;
    switch (_period) {
      case _SalesPeriod.diario:
        puntos = ventasPorDia(completadas, _year, _month);
        subtitle = 'Total por día en $_monthLabel';
      case _SalesPeriod.mensual:
        puntos = ventasPorMes(completadas, _year);
        subtitle = 'Total por mes en $_year';
      case _SalesPeriod.anual:
        puntos = ventasPorAnio(completadas);
        subtitle = 'Total por año';
    }
    final maxMonto = puntos.fold<double>(
      0,
      (m, p) => p.monto > m ? p.monto : m,
    );
    final totalMonto = puntos.fold<double>(0, (s, p) => s + p.monto);
    final totalVentas = puntos.fold<int>(0, (s, p) => s + p.cantidad);

    return _section(
      title: 'Comportamiento de las ventas',
      subtitle: subtitle,
      loading: _ventasLoading,
      error: _ventasError,
      onRetry: _loadVentas,
      empty: puntos.every((p) => p.cantidad == 0),
      header: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _periodChip('Diario', _SalesPeriod.diario),
          _periodChip('Mensual', _SalesPeriod.mensual),
          _periodChip('Anual', _SalesPeriod.anual),
        ],
      ),
      children: [
        Text(
          'Total: ${formatCop(totalMonto.round())} · $totalVentas '
          'venta${totalVentas == 1 ? '' : 's'}',
          style: GoogleFonts.poppins(
            color: context.pal.texto(PurchasesScreen.ink),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        for (final punto in puntos) ...[
          _bar(
            label: punto.etiqueta,
            value: formatCop(punto.monto.round()),
            fraction: maxMonto == 0 ? 0 : punto.monto / maxMonto,
            color: context.pal.graficoRojo(PurchasesScreen.red),
            detail: '${punto.cantidad} venta${punto.cantidad == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _periodChip(String label, _SalesPeriod value) {
    final selected = _period == value;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => setState(() => _period = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? context.pal.rojoBoton(PurchasesScreen.red)
              : context.pal.tarjeta(PurchasesScreen.page),
          border: Border.all(
            color: selected
                ? context.pal.rojo(PurchasesScreen.red)
                : context.pal.borde(AppColors.cardBorder),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected
                ? Colors.white
                : context.pal.texto(PurchasesScreen.ink),
            fontSize: _fs,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 4. Productos no conformes por semana del mes.
  Widget _buildNoConformesSection() {
    final semanas = noConformesPorSemana(
      _noConformes ?? const [],
      _year,
      _month,
    );
    final maxRegistros = semanas.fold<int>(
      0,
      (m, s) => s.registros > m ? s.registros : m,
    );
    return _section(
      title: 'Productos no conformes por semana',
      subtitle: 'Registros en $_monthLabel',
      loading: _noConformesLoading,
      error: _noConformesError,
      onRetry: _loadNoConformes,
      empty: maxRegistros == 0,
      children: [
        for (final semana in semanas) ...[
          _bar(
            label: 'Semana ${semana.semana}',
            value:
                '${semana.registros} registro${semana.registros == 1 ? '' : 's'}',
            fraction: maxRegistros == 0 ? 0 : semana.registros / maxRegistros,
            color: context.pal.avisoTexto(Color(0xFFB65D0A)),
            detail: semana.porTipo.isEmpty
                ? null
                : semana.porTipo.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join(' · '),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          'Semana 1: días 1 al 7 · 2: 8 al 14 · 3: 15 al 21 · 4: 22 al 28 · '
          '5: del 29 en adelante',
          style: GoogleFonts.poppins(
            color: context.pal.secundario(PurchasesScreen.muted),
            fontSize: _fs,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- bars

  /// Barra horizontal con su valor siempre visible.
  Widget _bar({
    required String label,
    required String value,
    required double fraction,
    required Color color,
    String? detail,
  }) {
    final ancho = fraction.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: context.pal.texto(PurchasesScreen.ink),
                  fontSize: _fs,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: context.pal.texto(PurchasesScreen.ink),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.pal.pistaGrafico(Color(0xFFEFE9E8)),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                Container(
                  height: 14,
                  width: constraints.maxWidth * ancho,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            );
          },
        ),
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(
            detail,
            style: GoogleFonts.poppins(
              color: context.pal.secundario(PurchasesScreen.muted),
              fontSize: _fs,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) =>
      const ModuleBottomNav(selected: 0);
}
