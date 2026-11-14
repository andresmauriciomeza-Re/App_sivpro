import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../services/return_service.dart';

class EmployeeRefundScreen extends StatefulWidget {
  const EmployeeRefundScreen({super.key, required this.record});

  final DevolucionVenta record;

  @override
  State<EmployeeRefundScreen> createState() => _EmployeeRefundScreenState();
}

class _EmployeeRefundScreenState extends State<EmployeeRefundScreen> {
  static const red = Color(0xFFC9151E);
  static const green = Color(0xFF15B98A);
  static const greenDark = Color(0xFF19733B);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final Map<int, int> _devueltos = {};
  final Map<int, MotivoDevolucion> _motivos = {};
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final linea in widget.record.lineas) {
      _devueltos[linea.idDetalleVenta] = linea.cantidad;
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

  int get _valorDevuelto =>
      DevolucionCalculos.valorDevuelto(widget.record.lineas, _devueltos);
  List<String> get _faltan => DevolucionCalculos.faltan(
    lineas: widget.record.lineas,
    devueltos: _devueltos,
    motivos: _motivos,
    canje: const [],
  );
  bool get _puedeConfirmar => DevolucionCalculos.puedeConfirmar(
    lineas: widget.record.lineas,
    devueltos: _devueltos,
    motivos: _motivos,
    canje: const [],
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
                    _title(),
                    const SizedBox(height: 22),
                    _saleSummary(),
                    const SizedBox(height: 22),
                    _sectionTitle('PRODUCTOS QUE DEVUELVE EL CLIENTE'),
                    const SizedBox(height: 12),
                    for (final linea in widget.record.lineas)
                      _lineaDevolucion(linea),
                    const SizedBox(height: 22),
                    _refundAmountCard(),
                    const SizedBox(height: 22),
                    _noteField(),
                    if (_faltan.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _faltanBox(),
                    ],
                    const SizedBox(height: 16),
                    _warningBox(),
                    const SizedBox(height: 26),
                    _confirmButton(),
                    const SizedBox(height: 12),
                    _cancelButton(),
                  ],
                ),
              ),
            ),
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

  Widget _title() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFC9F7E5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.attach_money, color: greenDark, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Reembolso en dinero',
            style: GoogleFonts.montserrat(color: ink, fontSize: 30),
          ),
        ),
      ],
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
          color: activo ? green : const Color(0xFFE4E1DF),
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
                    foregroundColor: activo ? greenDark : muted,
                    side: BorderSide(
                      color: activo
                          ? const Color(0xFF9BD5B0)
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
                      color: greenDark,
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
    setState(() => _devueltos[linea.idDetalleVenta] = nuevo);
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

  Widget _refundAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9BD5B0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_exchange, color: greenDark, size: 22),
              const SizedBox(width: 10),
              Text(
                'MONTO A REEMBOLSAR',
                style: GoogleFonts.poppins(
                  color: greenDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            formatearCop(_valorDevuelto),
            style: GoogleFonts.poppins(
              color: greenDark,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A favor del cliente',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C6E4F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Método original: ${widget.record.payment}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2C6E4F),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nota del reembolso (opcional)',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: Transferido por Nequi el 10/09...',
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: green, width: 1.5),
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

  Widget _warningBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9BD5B0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, color: greenDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Asegúrate de haber realizado la transferencia antes de confirmar. Esta acción no se puede deshacer.',
              style: GoogleFonts.poppins(
                color: greenDark,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    final activo = _puedeConfirmar && !_isSubmitting;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: activo ? _confirmarReembolso : null,
        style: FilledButton.styleFrom(
          backgroundColor: green,
          disabledBackgroundColor: green.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Confirmar reembolso',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: muted,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          'Cancelar y volver',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _confirmarReembolso() async {
    if (!_puedeConfirmar || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final idDevolucion = await ReturnService.instance.asegurarDevolucion(
        widget.record,
      );
      final payload = DevolucionCalculos.construirPayload(
        lineas: widget.record.lineas,
        devueltos: _devueltos,
        motivos: _motivos,
        canje: const [],
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
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                    selectedColor: const Color(0xFFE0F5E9),
                    side: BorderSide(
                      color: _motivo == motivo
                          ? const Color(0xFF9BD5B0)
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
            backgroundColor: const Color(0xFF15B98A),
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
