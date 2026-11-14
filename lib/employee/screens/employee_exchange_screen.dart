import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import 'employee_substitution_picker_screen.dart';
import '../../shared/page_transitions.dart';
import '../services/return_service.dart';

class EmployeeExchangeScreen extends StatefulWidget {
  const EmployeeExchangeScreen({super.key, required this.record});

  final DevolucionVenta record;

  @override
  State<EmployeeExchangeScreen> createState() => _EmployeeExchangeScreenState();
}

class _EmployeeExchangeScreenState extends State<EmployeeExchangeScreen> {
  static const red = Color(0xFFC9151E);
  static const blue = Color(0xFF2563EB);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final Map<int, int> _devueltos = {};
  final Map<int, MotivoDevolucion> _motivos = {};
  final List<CanjeSeleccion> _canje = [];
  final _noteController = TextEditingController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    for (final linea in widget.record.lineas) {
      _devueltos[linea.idDetalleVenta] = 0;
      if (linea.motivo != null) {
        _motivos[linea.idDetalleVenta] = MotivoDevolucion(
          motivo: linea.motivo!,
          descripcion: linea.descripcionMotivo ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int get _totalDevuelto => DevolucionCalculos.totalDevuelto(_devueltos);
  int get _totalCanje =>
      _canje.fold<int>(0, (total, item) => total + item.cantidad);
  int get _valorDevuelto =>
      DevolucionCalculos.valorDevuelto(widget.record.lineas, _devueltos);
  int get _valorCanje => DevolucionCalculos.valorCanje(_canje);
  int get _saldo => DevolucionCalculos.saldo(_valorDevuelto, _valorCanje);
  String get _tipo =>
      DevolucionCalculos.tipo(hayCanje: _canje.isNotEmpty, saldo: _saldo);
  List<String> get _faltan => DevolucionCalculos.faltan(
    lineas: widget.record.lineas,
    devueltos: _devueltos,
    motivos: _motivos,
    canje: _canje,
  );
  bool get _puedeConfirmar => DevolucionCalculos.puedeConfirmar(
    lineas: widget.record.lineas,
    devueltos: _devueltos,
    motivos: _motivos,
    canje: _canje,
  );

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
                    Text(
                      'Canje por producto',
                      style: GoogleFonts.montserrat(color: ink, fontSize: 34),
                    ),
                    const SizedBox(height: 22),
                    _saleSummary(),
                    const SizedBox(height: 24),
                    _sectionTitle('PRODUCTOS QUE DEVUELVE EL CLIENTE'),
                    const SizedBox(height: 12),
                    for (final linea in widget.record.lineas)
                      _lineaDevolucion(linea),
                    const SizedBox(height: 12),
                    _sectionTitle('PRODUCTOS DE CANJE'),
                    const SizedBox(height: 12),
                    _canjeSection(),
                    const SizedBox(height: 22),
                    _balanceCard(),
                    const SizedBox(height: 18),
                    _noteField(),
                    if (_faltan.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _faltanBox(),
                    ],
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
    return AppHeader(
      title: 'La Sirena Pizza',
      onBack: () => Navigator.of(context).pop(),
      initials: getInitials('María González'),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFFA49A97),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: .6,
      ),
    );
  }

  Widget _saleSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD55A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF5CC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF9B4610),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${widget.record.idVenta}  ${widget.record.customer}',
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.record.fechaTexto,
                      style: GoogleFonts.poppins(color: muted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted,
                  side: const BorderSide(color: Color(0xFFE0E4E9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFF1EBD6)),
          ),
          _summaryRow('Monto', widget.record.montoTexto),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Método de pago',
                style: GoogleFonts.poppins(color: muted, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.record.payment == 'Nequi'
                      ? const Color(0xFFF0E3FF)
                      : const Color(0xFFFFF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.record.payment,
                  style: GoogleFonts.poppins(
                    color: widget.record.payment == 'Nequi'
                        ? const Color(0xFF6E1DCB)
                        : const Color(0xFF8B3F11),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _summaryRow('Tipo de venta', widget.record.tipoVentaTexto),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(color: muted, fontSize: 15)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineaDevolucion(DevolucionLinea linea) {
    final cantidad = _devueltos[linea.idDetalleVenta] ?? 0;
    final motivo = _motivos[linea.idDetalleVenta];
    final activo = cantidad > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: activo ? red : const Color(0xFFE4E1DF),
          width: activo ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _productImage(linea.imagen, size: 54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      linea.nombreCompleto,
                      style: GoogleFonts.poppins(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${linea.precioTexto} · Original: ${linea.cantidad}',
                      style: GoogleFonts.poppins(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _stepper(
                cantidad: cantidad,
                onMenos: cantidad == 0
                    ? null
                    : () => _cambiarDevuelto(linea, -1),
                onMas: cantidad >= linea.cantidad
                    ? null
                    : () => _cambiarDevuelto(linea, 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: activo ? () => _editarMotivo(linea) : null,
                  icon: const Icon(Icons.description_outlined, size: 17),
                  label: Text(
                    motivo?.motivo ?? 'Motivo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: activo ? const Color(0xFF7A2B0C) : muted,
                    side: BorderSide(
                      color: activo
                          ? const Color(0xFFFFC51C)
                          : const Color(0xFFE0E4E9),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (motivo?.descripcion.trim().isNotEmpty == true) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    motivo!.descripcion.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9B4610),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required int cantidad,
    required VoidCallback? onMenos,
    required VoidCallback? onMas,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(icon: Icons.remove, onTap: onMenos),
        Container(
          width: 34,
          alignment: Alignment.center,
          child: Text(
            '$cantidad',
            style: GoogleFonts.poppins(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _stepperButton(icon: Icons.add, onTap: onMas),
      ],
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final activo = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? const Color(0xFFF3F4F6) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E4E9)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: activo ? ink : const Color(0xFFC7CCD4),
        ),
      ),
    );
  }

  void _cambiarDevuelto(DevolucionLinea linea, int delta) {
    final actual = _devueltos[linea.idDetalleVenta] ?? 0;
    final nuevo = (actual + delta).clamp(0, linea.cantidad);
    if (nuevo == actual) return;
    setState(() {
      _devueltos[linea.idDetalleVenta] = nuevo;
      _ajustarCanjeAlTotal(_totalDevuelto);
    });
  }

  void _ajustarCanjeAlTotal(int totalDevuelto) {
    var totalCanje = _canje.fold<int>(
      0,
      (total, item) => total + item.cantidad,
    );
    while (totalCanje > totalDevuelto && _canje.isNotEmpty) {
      final ultimo = _canje.last;
      if (ultimo.cantidad > 1) {
        _canje[_canje.length - 1] = ultimo.copyWith(
          cantidad: ultimo.cantidad - 1,
        );
        totalCanje--;
      } else {
        _canje.removeLast();
        totalCanje--;
      }
    }
  }

  Future<void> _editarMotivo(DevolucionLinea linea) async {
    final inicial = _motivos[linea.idDetalleVenta];
    final resultado = await showDialog<MotivoDevolucion>(
      context: context,
      builder: (_) => _MotivoDialog(linea: linea, inicial: inicial),
    );
    if (resultado == null || !mounted) return;
    setState(() => _motivos[linea.idDetalleVenta] = resultado);
  }

  Widget _canjeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_canje.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E1DF)),
            ),
            child: Text(
              'Sin productos de canje. Si no agregas ninguno, la devolución se registra como reembolso en dinero.',
              style: GoogleFonts.poppins(
                color: muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          )
        else
          for (var i = 0; i < _canje.length; i++) _canjeTile(i),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _agregarCanje,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar producto de canje'),
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              side: const BorderSide(color: Color(0xFFB8D2FF)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _canjeTile(int index) {
    final item = _canje[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8D2FF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _productImage(item.imagen, size: 44),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreCompleto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.precioTexto} · ${item.subtotalTexto}',
                  style: GoogleFonts.poppins(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _stepper(
            cantidad: item.cantidad,
            onMenos: () => _cambiarCantidadCanje(index, -1),
            onMas: () => _cambiarCantidadCanje(index, 1),
          ),
          IconButton(
            onPressed: () => setState(() => _canje.removeAt(index)),
            icon: const Icon(Icons.close, size: 18),
            color: muted,
            tooltip: 'Quitar',
          ),
        ],
      ),
    );
  }

  Future<void> _agregarCanje() async {
    if (_totalDevuelto == 0) {
      _mostrarMensaje('Marca primero cuántas unidades devuelve el cliente.');
      return;
    }
    final seleccion = await Navigator.of(context).push<CanjeSeleccion>(
      MaterialPageRoute<CanjeSeleccion>(
        builder: (_) => const EmployeeSubstitutionPickerScreen(),
      ),
    );
    if (seleccion == null || !mounted) return;

    final existente = _canje.indexWhere(
      (item) =>
          item.idProducto == seleccion.idProducto &&
          (item.tamano ?? '') == (seleccion.tamano ?? ''),
    );
    final cantidadActual = existente >= 0 ? _canje[existente].cantidad : 0;
    if (_totalCanje + 1 > _totalDevuelto) {
      _mostrarMensaje('El canje no puede superar las unidades devueltas.');
      return;
    }
    final otrasDelTamano = _canje
        .where(
          (item) =>
              item.idProducto == seleccion.idProducto &&
              (item.tamano ?? '') != (seleccion.tamano ?? ''),
        )
        .fold<int>(0, (total, item) => total + item.cantidad);
    final limite = seleccion.limiteStock;
    final maximo = limite == null
        ? _totalDevuelto
        : (limite - otrasDelTamano).clamp(0, _totalDevuelto);
    if (cantidadActual + 1 > maximo) {
      _mostrarMensaje('No hay stock suficiente para ese producto.');
      return;
    }

    setState(() {
      if (existente >= 0) {
        _canje[existente] = _canje[existente].copyWith(
          cantidad: _canje[existente].cantidad + 1,
        );
      } else {
        _canje.add(seleccion);
      }
    });
  }

  void _cambiarCantidadCanje(int index, int delta) {
    final item = _canje[index];
    final nueva = item.cantidad + delta;
    if (nueva <= 0) {
      setState(() => _canje.removeAt(index));
      return;
    }
    if (delta > 0 && _totalCanje + 1 > _totalDevuelto) {
      _mostrarMensaje('El canje no puede superar las unidades devueltas.');
      return;
    }
    if (delta > 0) {
      final otrasDelTamano = _canje
          .where(
            (otro) =>
                otro.idProducto == item.idProducto &&
                (otro.tamano ?? '') != (item.tamano ?? ''),
          )
          .fold<int>(0, (total, otro) => total + otro.cantidad);
      final limite = item.limiteStock;
      final maximo = limite == null
          ? _totalDevuelto
          : (limite - otrasDelTamano).clamp(0, _totalDevuelto);
      if (nueva > maximo) {
        _mostrarMensaje('No hay stock suficiente para ese producto.');
        return;
      }
    }
    setState(() {
      _canje[index] = item.copyWith(cantidad: nueva);
    });
  }

  Widget _balanceCard() {
    final aFavorCliente = _saldo >= 0;
    final etiqueta = _saldo == 0
        ? 'Sin diferencia de dinero'
        : aFavorCliente
        ? 'A favor del cliente'
        : 'A favor de La Sirena';
    final monto = formatearCop(_saldo.abs());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9BD5B0)),
      ),
      child: Column(
        children: [
          _balanceRow('Valor devuelto', formatearCop(_valorDevuelto)),
          const SizedBox(height: 8),
          _balanceRow('Valor del canje', formatearCop(_valorCanje)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE8F2EC)),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  etiqueta,
                  style: GoogleFonts.poppins(
                    color: aFavorCliente
                        ? const Color(0xFF19733B)
                        : const Color(0xFFB45309),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                monto,
                style: GoogleFonts.poppins(
                  color: aFavorCliente
                      ? const Color(0xFF19733B)
                      : const Color(0xFFB45309),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: GoogleFonts.poppins(color: muted, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota (opcional)',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ej: el cliente prefiere recoger mañana...',
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _faltanBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD55A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final mensaje in _faltan)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $mensaje',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9B4610),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _confirmBar() {
    final activo = _puedeConfirmar && !_enviando;
    final label = switch (_tipo) {
      'Producto' => 'Confirmar canje',
      'Excedente' => 'Confirmar devolución mixta',
      _ => 'Confirmar reembolso',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EBEF))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: activo ? _confirmar : null,
          style: FilledButton.styleFrom(
            backgroundColor: red,
            disabledBackgroundColor: red.withValues(alpha: 0.15),
            disabledForegroundColor: red.withValues(alpha: 0.45),
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _enviando
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _confirmar() async {
    if (!_puedeConfirmar || _enviando) return;
    setState(() => _enviando = true);
    try {
      final idDevolucion = await ReturnService.instance.asegurarDevolucion(
        widget.record,
      );
      final payload = DevolucionCalculos.construirPayload(
        lineas: widget.record.lineas,
        devueltos: _devueltos,
        motivos: _motivos,
        canje: _canje,
        nota: _noteController.text,
      );
      await ReturnService.instance.resolver(idDevolucion, payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget _bottomNavigation() {
    final items = employeeNavItems();
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
                      child: InkWell(
                        onTap: () =>
                            handleEmployeeBottomNav(context, items[i].index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[i].icon,
                              color: items[i].index == 3
                                  ? red
                                  : const Color(0xFFA4AAB5),
                              size: 21,
                            ),
                            Text(
                              items[i].label,
                              style: GoogleFonts.poppins(
                                color: items[i].index == 3
                                    ? red
                                    : const Color(0xFFA4AAB5),
                                fontSize: 10,
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
}

class _MotivoDialog extends StatefulWidget {
  const _MotivoDialog({required this.linea, required this.inicial});

  final DevolucionLinea linea;
  final MotivoDevolucion? inicial;

  @override
  State<_MotivoDialog> createState() => _MotivoDialogState();
}

class _MotivoDialogState extends State<_MotivoDialog> {
  late String _motivo;
  late final TextEditingController _descripcion;

  @override
  void initState() {
    super.initState();
    _motivo = widget.inicial?.motivo ?? '';
    _descripcion = TextEditingController(
      text: widget.inicial?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  bool get _puedeGuardar {
    if (_motivo.isEmpty) return false;
    if (_motivo == 'Otro' && _descripcion.text.trim().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '¿Por qué devuelve este producto?',
        style: GoogleFonts.montserrat(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.linea.nombreCompleto,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6D7B91),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final motivo in motivosDevolucion)
                  ChoiceChip(
                    label: Text(
                      motivo,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    selected: _motivo == motivo,
                    onSelected: (_) => setState(() => _motivo = motivo),
                    selectedColor: const Color(0xFFFFE8D6),
                    side: BorderSide(
                      color: _motivo == motivo
                          ? const Color(0xFFFFC51C)
                          : const Color(0xFFE0E4E9),
                    ),
                  ),
              ],
            ),
            if (_motivo == 'Otro') ...[
              const SizedBox(height: 14),
              TextField(
                controller: _descripcion,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Descripción *',
                  hintText: 'Explica el motivo',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _puedeGuardar
              ? () => Navigator.of(context).pop(
                  MotivoDevolucion(
                    motivo: _motivo,
                    descripcion: _descripcion.text.trim(),
                  ),
                )
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC9151E),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

Widget _productImage(String? path, {double size = 52}) {
  final placeholder = Container(
    width: size,
    height: size,
    color: const Color(0xFFF1F3F5),
    alignment: Alignment.center,
    child: const Icon(Icons.local_pizza, color: Color(0xFFC9151E), size: 24),
  );
  if (path == null || path.isEmpty) return placeholder;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
  return Image.asset(
    path,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => placeholder,
  );
}
