part of '../purchases_screen.dart';

const _supplyTipos = <String>['Insumo', 'Producto insumo'];

/// Pantalla de Insumos para abrirla desde fuera de la biblioteca (por ejemplo
/// al tocar la notificación de stock mínimo).
Widget insumosScreen() => const _SupplyManagementScreen();

/// Insumos: consulta de existencias (solo lectura en el móvil).
class _SupplyManagementScreen extends StatefulWidget {
  const _SupplyManagementScreen();

  @override
  State<_SupplyManagementScreen> createState() =>
      _SupplyManagementScreenState();
}

class _SupplyManagementScreenState extends State<_SupplyManagementScreen> {
  String _query = '';
  String? _tipoFilter; // null = todos
  bool? _estadoFilter; // null = todos
  List<Insumo> _supplies = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final supplies = await InsumosRepository.instance.listar();
      unawaited(NotificacionesLocal.instance.desdeInsumos(supplies));
      if (!mounted) return;
      setState(() {
        _supplies = supplies;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'No se pudieron cargar los insumos.';
      if (silent && _supplies.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        setState(() {
          _loading = false;
          _error = message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emptyCount = _supplies.where((s) => s.agotado).length;
    final lowCount = _supplies.where((s) => s.bajoMinimo && !s.agotado).length;

    final filteredSupplies = _supplies.where((supply) {
      if (_tipoFilter != null && supply.tipo != _tipoFilter) return false;
      if (_estadoFilter != null && supply.estado != _estadoFilter) {
        return false;
      }
      return matchesSearchQuery(_query, [
        supply.codigo,
        supply.nombre,
        supply.categoriaNombre ?? '',
      ]);
    }).toList();

    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(silent: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(17, 20, 17, 24),
                  children: [
                    Text(
                      'Insumos',
                      style: GoogleFonts.montserrat(
                        color: context.pal.texto(PurchasesScreen.ink),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryChip(
                            '${_supplies.length}',
                            'Total insumos',
                            context.pal.borde(Color(0xFFE8C7C4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryChip(
                            '$lowCount',
                            'Bajo mínimo',
                            context.pal.avisoFondo(Color(0xFFF5D9A5)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _summaryChip(
                            '$emptyCount',
                            'Agotados',
                            context.pal.errorFondo(Color(0xFFF4C8CF)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppSearchField(
                      hint: 'Buscar por código, nombre o categoría...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 14),
                    _buildFilters(),
                    const SizedBox(height: 14),
                    const _StockBarLegend(),
                    const SizedBox(height: 16),
                    ..._buildContent(filteredSupplies),
                  ],
                ),
              ),
            ),
            _suppliesBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(List<Insumo> filtered) {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(PurchasesScreen.muted),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: context.pal.rojoBoton(PurchasesScreen.red),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ];
    }
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              'No se encontraron insumos',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      for (final supply in filtered) ...[
        _buildSupplyCard(context, supply),
        const SizedBox(height: 16),
      ],
    ];
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip(
              'Todos los tipos',
              _tipoFilter == null,
              () => setState(() => _tipoFilter = null),
            ),
            for (final tipo in _supplyTipos)
              _filterChip(
                tipo,
                _tipoFilter == tipo,
                () => setState(() => _tipoFilter = tipo),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip(
              'Todos',
              _estadoFilter == null,
              () => setState(() => _estadoFilter = null),
            ),
            _filterChip(
              'Activos',
              _estadoFilter == true,
              () => setState(() => _estadoFilter = true),
            ),
            _filterChip(
              'Inactivos',
              _estadoFilter == false,
              () => setState(() => _estadoFilter = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? context.pal.rojoBoton(PurchasesScreen.red)
              : context.pal.tarjeta(PurchasesScreen.page),
          border: Border.all(
            color: selected
                ? context.pal.rojo(PurchasesScreen.red)
                : context.pal.borde(AppColors.cardBorder),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected
                ? Colors.white
                : context.pal.texto(PurchasesScreen.ink),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _summaryChip(String count, String label, Color borderColor) {
    final isWarning = label == 'Bajo mínimo';
    final isEmpty = label == 'Agotados';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning
            ? context.pal.avisoFondo(Color(0xFFFFF3DF))
            : isEmpty
            ? context.pal.errorFondo(Color(0xFFFFE8EB))
            : context.pal.tarjeta(PurchasesScreen.page),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: isWarning
                ? context.pal.avisoTexto(Color(0xFFB65D0A))
                : isEmpty
                ? context.pal.rojo(PurchasesScreen.red)
                : context.pal.texto(PurchasesScreen.ink),
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: '$count ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyCard(BuildContext context, Insumo supply) {
    final level = _SupplyLevel.of(supply);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _SupplyDetailScreen(supply: supply)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: context.pal.tarjeta(Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.pal.borde(Color(0xFFE1D8D6))),
          boxShadow: [
            BoxShadow(
              color: context.pal.sombra(Color(0x0D000000)),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  supply.codigo,
                  style: GoogleFonts.poppins(
                    color: context.pal.secundario(PurchasesScreen.muted),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    supply.categoriaNombre ?? supply.tipo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: context.pal.secundario(PurchasesScreen.muted),
                      fontSize: 12,
                    ),
                  ),
                ),
                _SupplyLevelBadge(level: level),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              supply.nombre,
              style: GoogleFonts.poppins(
                color: context.pal.texto(PurchasesScreen.ink),
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${supply.tipo} • Unidad: ${supply.unidadMedida}'
              '${supply.estado ? '' : ' • Inactivo'}',
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _StockBar(supply: supply, level: level),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: GoogleFonts.poppins(
                  color: context.pal.secundario(PurchasesScreen.muted),
                  fontSize: 12,
                ),
                children: [
                  const TextSpan(text: 'Stock actual: '),
                  TextSpan(
                    text:
                        '${_formatAmount(supply.stockActual)} '
                        '${supply.unidadMedida}',
                    style: TextStyle(
                      color: level.colorEn(context.pal),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        '   Mín.: ${_formatAmount(supply.stockMinimo)}'
                        '   Máx.: ${_formatAmount(supply.stockMaximo)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nivel de existencias de un insumo frente a su mínimo y máximo.
enum _SupplyLevel {
  ok('OK', Color(0xFF3D824B), Color(0xFFE3F2E5)),
  low('Bajo mínimo', PurchasesScreen.red, Color(0xFFFFE8EB)),
  empty('Agotado', PurchasesScreen.red, Color(0xFFFFE8EB)),
  over('Sobre máximo', Color(0xFFB65D0A), Color(0xFFFFF3DF));

  const _SupplyLevel(this.label, this.color, this.background);

  final String label;
  final Color color;
  final Color background;

  /// Color del nivel según el tema (en claro, [color] tal cual).
  Color colorEn(PaletaApp p) => switch (this) {
    ok => p.exitoTexto(color),
    over => p.avisoTexto(color),
    low || empty => p.rojo(color),
  };

  /// Fondo del nivel según el tema (en claro, [background] tal cual).
  Color fondoEn(PaletaApp p) => switch (this) {
    ok => p.exitoFondo(background),
    over => p.avisoFondo(background),
    low || empty => p.errorFondo(background),
  };

  static _SupplyLevel of(Insumo supply) {
    if (supply.agotado) return _SupplyLevel.empty;
    if (supply.bajoMinimo) return _SupplyLevel.low;
    if (supply.sobreMaximo) return _SupplyLevel.over;
    return _SupplyLevel.ok;
  }
}

class _SupplyLevelBadge extends StatelessWidget {
  const _SupplyLevelBadge({required this.level});

  final _SupplyLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: level.fondoEn(context.pal),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        level.label,
        style: GoogleFonts.poppins(
          color: level.colorEn(context.pal),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Barra de existencias: relleno = stock actual sobre el máximo; la marca
/// vertical indica el stock mínimo.
class _StockBar extends StatelessWidget {
  const _StockBar({required this.supply, required this.level});

  final Insumo supply;
  final _SupplyLevel level;

  @override
  Widget build(BuildContext context) {
    final maximo = supply.stockMaximo > 0
        ? supply.stockMaximo
        : [
            supply.stockActual,
            supply.stockMinimo,
            1.0,
          ].reduce((a, b) => a > b ? a : b);
    final fill = (supply.stockActual / maximo).clamp(0.0, 1.0);
    final minMark = (supply.stockMinimo / maximo).clamp(0.0, 1.0);
    final unidad = supply.unidadMedida.isEmpty ? '' : ' ${supply.unidadMedida}';
    return Semantics(
      container: true,
      label:
          'Stock actual ${_formatAmount(supply.stockActual)}$unidad, '
          'mínimo ${_formatAmount(supply.stockMinimo)}$unidad',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return SizedBox(
            height: 12,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.pal.campo(Color(0xFFEFE9E8)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: width * fill,
                  height: 8,
                  decoration: BoxDecoration(
                    color: level.colorEn(context.pal),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Positioned(
                  left: (width * minMark - 1).clamp(0.0, width - 2),
                  child: const _MinimumMark(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Raya vertical del stock mínimo (en la barra y en su leyenda).
class _MinimumMark extends StatelessWidget {
  const _MinimumMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 2,
    height: 12,
    color: context.pal.texto(PurchasesScreen.ink),
  );
}

/// Explica la barra de existencias: la raya es el stock mínimo y el color
/// del relleno, el nivel frente a ese mínimo.
class _StockBarLegend extends StatelessWidget {
  const _StockBarLegend();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    Widget swatch(Color color) => Container(
      width: 14,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    Widget item(Widget marca, String texto) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marca,
        const SizedBox(width: 5),
        Text(
          texto,
          style: GoogleFonts.poppins(
            color: pal.secundario(PurchasesScreen.muted),
            fontSize: 11.5,
          ),
        ),
      ],
    );
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        item(const _MinimumMark(), 'Stock mínimo'),
        item(swatch(_SupplyLevel.ok.colorEn(pal)), 'Sobre el mínimo'),
        item(swatch(_SupplyLevel.low.colorEn(pal)), 'Bajo el mínimo'),
        item(swatch(pal.campo(Color(0xFFEFE9E8))), 'Agotado'),
      ],
    );
  }
}

Widget _suppliesBottomNavigation(BuildContext context) =>
    const ModuleBottomNav(selected: 1);

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// Detalle de solo lectura de un insumo.
class _SupplyDetailScreen extends StatefulWidget {
  const _SupplyDetailScreen({required this.supply});

  final Insumo supply;

  @override
  State<_SupplyDetailScreen> createState() => _SupplyDetailScreenState();
}

class _SupplyDetailScreenState extends State<_SupplyDetailScreen> {
  late Insumo _supply = widget.supply;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Muestra primero los datos de la lista y los reemplaza con `GET /:id`.
  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await InsumosRepository.instance.obtener(widget.supply.id);
      if (!mounted) return;
      setState(() {
        _supply = fresh;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException
            ? error.message
            : 'No se pudo actualizar el detalle.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _supply;
    final level = _SupplyLevel.of(s);
    final unidad = s.unidadMedida;
    return Scaffold(
      backgroundColor: context.pal.fondo(PurchasesScreen.page),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                  decoration: BoxDecoration(
                    color: context.pal.tarjeta(PurchasesScreen.page),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.pal.borde(Color(0xFFE1D8D6)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.pal.sombra(Color(0x0A000000)),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Detalle',
                            style: GoogleFonts.montserrat(
                              color: context.pal.texto(PurchasesScreen.ink),
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.codigo,
                              style: GoogleFonts.poppins(
                                color: context.pal.secundario(
                                  PurchasesScreen.muted,
                                ),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _SupplyLevelBadge(level: level),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  color: context.pal.rojo(PurchasesScreen.red),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      _StockBar(supply: s, level: level),
                      const SizedBox(height: 8),
                      const _StockBarLegend(),
                      const SizedBox(height: 4),
                      _supplyDetailRow('Código', s.codigo, mono: true),
                      _supplyDetailRow('Nombre', s.nombre),
                      _supplyDetailRow('Categoría', s.categoriaNombre ?? '—'),
                      _supplyDetailRow('Tipo', s.tipo),
                      _supplyDetailRow(
                        'Estado',
                        s.estado ? 'Activo' : 'Inactivo',
                      ),
                      _supplyDetailRow('Unidad de medida', unidad),
                      if (s.pesoMedida != null)
                        _supplyDetailRow(
                          'Peso / medida',
                          _formatAmount(s.pesoMedida!),
                        ),
                      _supplyDetailRow(
                        'Stock actual',
                        '${_formatAmount(s.stockActual)} $unidad',
                      ),
                      _supplyDetailRow(
                        'Stock mínimo',
                        '${_formatAmount(s.stockMinimo)} $unidad',
                      ),
                      _supplyDetailRow(
                        'Stock máximo',
                        '${_formatAmount(s.stockMaximo)} $unidad',
                      ),
                      if (s.costoUnitario != null)
                        _supplyDetailRow(
                          'Costo unitario',
                          formatCop(s.costoUnitario!.round()),
                        ),
                      if (s.costoMaximo != null)
                        _supplyDetailRow(
                          'Costo máximo',
                          formatCop(s.costoMaximo!.round()),
                        ),
                      if (s.iva != null)
                        _supplyDetailRow('IVA', '${_formatAmount(s.iva!)} %'),
                      if (s.tiempoPreparacion != null)
                        _supplyDetailRow(
                          'Tiempo de preparación',
                          '${_formatAmount(s.tiempoPreparacion!)} min',
                        ),
                      if (s.descripcion != null)
                        _supplyDetailRow('Descripción', s.descripcion!),
                      if (s.esProductoInsumo && s.fichaVigente != null)
                        ..._fichaVigente(s.fichaVigente!),
                    ],
                  ),
                ),
              ),
            ),
            _suppliesBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  /// Ficha vigente de un "Producto insumo": se muestra de forma genérica
  /// (valores simples y listas) porque su estructura la define el backend.
  List<Widget> _fichaVigente(Object ficha) {
    final widgets = <Widget>[
      const SizedBox(height: 22),
      Text(
        'FICHA VIGENTE',
        style: GoogleFonts.poppins(
          color: context.pal.secundario(PurchasesScreen.muted),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    ];
    if (ficha is Map) {
      ficha.forEach((key, value) {
        final label = _humanize(key.toString());
        if (key.toString().startsWith('id_') || value == null) return;
        if (value is List) {
          if (value.isEmpty) return;
          widgets.add(_supplyDetailRow(label, ''));
          for (var i = 0; i < value.length; i++) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${i + 1}. ${_fichaItem(value[i])}',
                  style: GoogleFonts.poppins(
                    color: context.pal.texto(PurchasesScreen.ink),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }
        } else if (value is! Map) {
          widgets.add(_supplyDetailRow(label, value.toString()));
        }
      });
    } else {
      widgets.add(_supplyDetailRow('Ficha', ficha.toString()));
    }
    return widgets;
  }

  String _fichaItem(Object? item) {
    if (item is Map) {
      final nombre = item['nombre'] ?? item['descripcion'] ?? item['paso'];
      final cantidad = item['cantidad'];
      final medida = item['medida'] ?? item['unidad'];
      if (nombre != null) {
        return [nombre, cantidad, medida].whereType<Object>().join(' ');
      }
      return item.values.whereType<Object>().join(' · ');
    }
    return item?.toString() ?? '';
  }

  String _humanize(String key) {
    final text = key.replaceAll('_', ' ').trim();
    return text.isEmpty ? key : text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: currentUserInitials(),
    );
  }

  Widget _supplyDetailRow(String label, String value, {bool mono = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.pal.borde(Color(0xFFE8E0DE))),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: context.pal.secundario(PurchasesScreen.muted),
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.poppins(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.poppins(
                      color: context.pal.texto(PurchasesScreen.ink),
                      fontSize: 17,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
