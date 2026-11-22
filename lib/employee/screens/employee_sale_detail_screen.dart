import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin/services/ventas_repository.dart';
import '../../network/api_exception.dart';
import '../../shared/app_header.dart';
import '../../shared/initials.dart';
import '../../shared/page_transitions.dart';
import '../../shared/periodic_refresh.dart';
import '../../shared/permission_helper.dart';

class EmployeeSaleDetailScreen extends StatefulWidget {
  const EmployeeSaleDetailScreen({required this.idVenta, super.key});

  static const red = Color(0xFFC9151E);
  static const ink = Color(0xFF17243A);
  static const muted = Color(0xFF6D7B91);
  static const page = Color(0xFFF8FAFC);

  final int idVenta;

  @override
  State<EmployeeSaleDetailScreen> createState() =>
      _EmployeeSaleDetailScreenState();
}

class _EmployeeSaleDetailScreenState extends State<EmployeeSaleDetailScreen>
    with PeriodicRefreshMixin<EmployeeSaleDetailScreen> {
  static const red = EmployeeSaleDetailScreen.red;
  static const ink = EmployeeSaleDetailScreen.ink;
  static const muted = EmployeeSaleDetailScreen.muted;
  static const page = EmployeeSaleDetailScreen.page;

  Venta? _venta;
  bool _cargando = true;
  bool _recargando = false;
  String? _error;

  ResumenPagos? _resumen;
  String? _resumenError;
  bool _cargandoResumen = false;
  DateTime _fetchedAt = DateTime.now();

  bool get _puedeEditar => PermissionHelper.puedeEditarVentas;

  bool get _enVerificacion =>
      _venta?.estado == EstadoVenta.porVerificar ||
      _venta?.estado == EstadoVenta.enEspera;

  int get _segundosRestantesAnulacion {
    final venta = _venta;
    if (venta == null) return 0;
    final transcurridos = DateTime.now().difference(_fetchedAt).inSeconds;
    final restantes = venta.segundosRestantesAnulacion - transcurridos;
    return restantes > 0 ? restantes : 0;
  }

  bool get _puedeAnular =>
      _venta?.estado == EstadoVenta.porEntregar &&
      _segundosRestantesAnulacion > 0;

  bool get _accionesDisponibles =>
      _enVerificacion || _venta?.estado == EstadoVenta.porEntregar;

  @override
  void initState() {
    super.initState();
    _cargar();
    iniciarRefrescoPeriodico();
  }

  @override
  Future<void> refrescarPeriodico() => _cargar(silencioso: true);

  Future<void> _cargar({bool silencioso = false}) async {
    if (_recargando) return;
    setState(() {
      _recargando = true;
      if (!silencioso) _cargando = _venta == null;
      if (!silencioso) _error = null;
    });
    try {
      final venta = await VentasRepository.instance.obtener(widget.idVenta);
      if (!mounted) return;
      setState(() {
        _venta = venta;
        _fetchedAt = DateTime.now();
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar el detalle de la venta.');
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
          _recargando = false;
        });
      }
    }
    if (_venta != null) await _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    if (!mounted) return;
    final venta = _venta;
    if (venta == null || _cargandoResumen) return;
    setState(() {
      _cargandoResumen = true;
      _resumenError = null;
    });
    try {
      final resumen = await VentasRepository.instance.resumenPagos(venta.id);
      if (!mounted) return;
      setState(() {
        _resumen = resumen;
        _resumenError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _resumenError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _resumenError = 'No se pudo cargar el resumen de pagos.');
    } finally {
      if (mounted) setState(() => _cargandoResumen = false);
    }
  }

  Future<void> _despuesDeAccion({bool resumen = true}) async {
    try {
      final fresh = await VentasRepository.instance.obtener(widget.idVenta);
      if (!mounted) return;
      setState(() {
        _venta = fresh;
        _fetchedAt = DateTime.now();
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'La acción se realizó, pero no se pudo actualizar el detalle. '
              'Vuelve a intentarlo.';
        });
      }
    }
    if (resumen) await _cargarResumen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      bottomNavigationBar: _bottomNavigation(context),
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
                color: red,
                onRefresh: () => _cargar(silencioso: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: _contenido(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    final venta = _venta;

    if (_cargando && venta == null) {
      return const SizedBox(
        height: 420,
        child: Center(child: CircularProgressIndicator(color: red)),
      );
    }

    if (_error != null && venta == null) {
      return _errorBlock(_error!);
    }

    if (venta == null) {
      return _emptyBlock('No se encontró la venta.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recargando) ...[
          const LinearProgressIndicator(
            color: red,
            backgroundColor: Color(0xFFF3E9E7),
          ),
          const SizedBox(height: 14),
        ],
        if (_error != null) ...[
          _errorBanner(_error!),
          const SizedBox(height: 14),
        ],
        _titulo(venta),
        if (_puedeEditar && _accionesDisponibles) ...[
          const SizedBox(height: 20),
          _card('ACCIONES', _acciones()),
        ],
        const SizedBox(height: 24),
        _card('INFORMACIÓN', _informacion(venta)),
        const SizedBox(height: 24),
        _card('PRODUCTOS DEL PEDIDO', _productos(venta)),
        const SizedBox(height: 24),
        _card('PAGOS', _pagos(venta)),
      ],
    );
  }

  Widget _titulo(Venta venta) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalle de venta',
                style: GoogleFonts.montserrat(color: ink, fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(
                venta.codigo,
                style: GoogleFonts.poppins(color: muted, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _EstadoBadge(estado: venta.estado, label: venta.estadoLabel),
      ],
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE6E8EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17243A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _informacion(Venta venta) {
    return Column(
      children: [
        _fila('Código', venta.codigo),
        _fila('Fecha', formatFechaHoraVenta(venta.fecha)),
        _fila('Hora de recogida', formatHoraVenta(venta.horaRecogida)),
        _fila('Cliente', venta.clienteNombre),
        _fila('Monto', _formatearMonto(venta.monto)),
        _fila('Estado', venta.estadoLabel),
        if (venta.motivoRechazo != null)
          _fila('Motivo de rechazo', venta.motivoRechazo!),
        if (venta.anuladoPor != null) _fila('Anulado por', venta.anuladoPor!),
      ],
    );
  }

  Widget _fila(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(color: muted, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productos(Venta venta) {
    if (venta.detalles.isEmpty) {
      return Text(
        'Sin productos registrados.',
        style: GoogleFonts.poppins(color: muted, fontSize: 14),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < venta.detalles.length; i++) ...[
          if (i > 0) const Divider(height: 22, color: Color(0xFFEDEDED)),
          _lineaProducto(venta.detalles[i]),
        ],
        const Divider(height: 26, color: Color(0xFFEDEDED)),
        Row(
          children: [
            Text(
              'Total',
              style: GoogleFonts.poppins(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              _formatearMonto(venta.monto),
              style: GoogleFonts.poppins(
                color: red,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lineaProducto(VentaLinea linea) {
    final tamano = linea.tamano == null ? '' : ' · ${linea.tamano}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                linea.nombre,
                style: GoogleFonts.poppins(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Cantidad: ${_formatearCantidad(linea.cantidad)}$tamano',
                style: GoogleFonts.poppins(color: muted, fontSize: 13),
              ),
              Text(
                'Precio unitario: ${_formatearMonto(linea.precioUnitario)}',
                style: GoogleFonts.poppins(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatearMonto(linea.subTotal),
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _pagos(Venta venta) {
    final resumen = _resumen;
    if (_cargandoResumen && resumen == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator(color: red)),
      );
    }
    if (_resumenError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _resumenError!,
            style: GoogleFonts.poppins(color: red, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _cargandoResumen ? null : _cargarResumen,
            child: Text(
              'Reintentar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          if (venta.pagos.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFEDEDED)),
            for (var i = 0; i < venta.pagos.length; i++) ...[
              if (i > 0) const Divider(height: 26, color: Color(0xFFEDEDED)),
              _pago(venta.pagos[i]),
            ],
          ],
        ],
      );
    }
    if (resumen == null) {
      return Text(
        'Sin pagos registrados.',
        style: GoogleFonts.poppins(color: muted, fontSize: 14),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fila('Total', _formatearMonto(resumen.total)),
        _fila('Recibido', _formatearMonto(resumen.recibido)),
        _fila('En revisión', _formatearMonto(resumen.enRevision)),
        _fila('Falta', _formatearMonto(resumen.falta)),
        if (resumen.saldoAFavor > 0)
          _fila('Saldo a favor', _formatearMonto(resumen.saldoAFavor)),
        if (resumen.pagos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Sin pagos registrados.',
              style: GoogleFonts.poppins(color: muted, fontSize: 14),
            ),
          ),
        for (final pago in resumen.pagos) ...[
          const Divider(height: 26, color: Color(0xFFEDEDED)),
          _pagoResumen(pago),
        ],
      ],
    );
  }

  Widget _pago(VentaPago pago) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pago #${pago.id}',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        if (pago.tipo != null) _fila('Tipo', pago.tipo!),
        if (pago.estado != null) _fila('Estado', pago.estado!),
        if (pago.fecha != null)
          _fila('Fecha', formatFechaHoraVenta(pago.fecha)),
        if (pago.cantidadPagar != null)
          _fila('Monto declarado', _formatearMonto(pago.cantidadPagar!)),
        if (pago.depositado != null)
          _fila('Monto depositado', _formatearMonto(pago.depositado!)),
        if (pago.faltante != null)
          _fila('Faltante', _formatearMonto(pago.faltante!)),
        if (pago.tieneComprobante && pago.comprobante != null) ...[
          const SizedBox(height: 12),
          Text(
            'Comprobante',
            style: GoogleFonts.poppins(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _ComprobantePago(value: pago.comprobante),
        ],
      ],
    );
  }

  Widget _pagoResumen(PagoResumen pago) {
    final pagoVenta = _buscarPagoVenta(pago.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pago #${pago.id}',
          style: GoogleFonts.poppins(
            color: ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _fila('ID de pago', '${pago.id}'),
        if (pago.tipo != null) _fila('Tipo', pago.tipo!),
        if (pago.estado != null) _fila('Estado', pago.estado!),
        _fila(
          'Monto declarado',
          pago.montoDeclarado == null
              ? 'Sin declarar'
              : _formatearMonto(pago.montoDeclarado!),
        ),
        _fila(
          'Monto confirmado',
          pago.montoConfirmado == null
              ? 'Sin confirmar'
              : _formatearMonto(pago.montoConfirmado!),
        ),
        if (pagoVenta != null &&
            pagoVenta.tieneComprobante &&
            pagoVenta.comprobante != null) ...[
          const SizedBox(height: 12),
          Text(
            'Comprobante',
            style: GoogleFonts.poppins(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _ComprobantePago(value: pagoVenta.comprobante),
        ],
        if (_puedeEditar &&
            _enVerificacion &&
            pago.pendienteDeConfirmar) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _botonAccion(
              'Confirmar pago',
              Icons.payments_outlined,
              () => _confirmarPago(pago),
              compact: true,
            ),
          ),
        ],
      ],
    );
  }

  VentaPago? _buscarPagoVenta(int idPago) {
    for (final pago in _venta?.pagos ?? const <VentaPago>[]) {
      if (pago.id == idPago) return pago;
    }
    return null;
  }

  Widget _acciones() {
    final resumen = _resumen;
    final puedeAceptar = resumen != null && resumen.falta <= 0;
    final faltaMonto = resumen != null && resumen.falta > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_enVerificacion) ...[
          if (resumen != null && !puedeAceptar) ...[
            Text(
              'Faltan ${_formatearMonto(resumen.falta)} por recibir. '
              'Confirma los pagos para poder aceptar la venta.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8A5600),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
          ],
          _botonAccion(
            'Aceptar venta',
            Icons.check_circle_outline,
            puedeAceptar ? _aceptar : null,
            filled: true,
          ),
          if (faltaMonto) ...[
            const SizedBox(height: 10),
            _botonAccion(
              'Pedir monto faltante',
              Icons.mark_email_unread_outlined,
              _pedirMontoFaltante,
            ),
          ],
          const SizedBox(height: 10),
          _botonAccion(
            'Rechazar',
            Icons.cancel_outlined,
            _rechazar,
            destructive: true,
          ),
        ],
        if (_venta?.estado == EstadoVenta.porEntregar) ...[
          if (_enVerificacion) const SizedBox(height: 10),
          _botonAccion(
            'Marcar como lista',
            Icons.done_all,
            _marcarListo,
            filled: true,
          ),
        ],
        if (_puedeAnular) ...[
          const SizedBox(height: 10),
          _botonAccion(
            'Anular venta',
            Icons.block,
            _anular,
            destructive: true,
          ),
        ],
      ],
    );
  }

  Widget _botonAccion(
    String label,
    IconData icon,
    VoidCallback? onPressed, {
    bool filled = false,
    bool destructive = false,
    bool compact = false,
  }) {
    final color = destructive ? red : ink;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(compact ? 20 : 25),
    );
    final child = Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: compact ? 13 : 15,
        fontWeight: FontWeight.w700,
      ),
    );
    final button = filled
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 19),
            label: child,
            style: FilledButton.styleFrom(
              backgroundColor: red,
              shape: shape,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 19),
            label: child,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(
                color: onPressed == null ? const Color(0xFFD8D0CE) : color,
              ),
              shape: shape,
            ),
          );
    if (compact) return button;
    return SizedBox(width: double.infinity, height: 48, child: button);
  }

  static const List<String> _motivosRechazo = [
    'Comprobante falso',
    'La imagen no corresponde a un comprobante',
    'Comprobante borroso',
  ];

  static const List<String> _motivosAnulacion = [
    'Cliente canceló el pedido',
    'Error al registrar el pedido',
    'Producto no disponible',
  ];

  Future<void> _ejecutar({
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(String? motivo, int? monto) accion,
    required String exito,
    List<String>? motivos,
    String? warning,
    String? amountLabel,
    int? initialAmount,
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SaleActionDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        motivos: motivos,
        warning: warning,
        amountLabel: amountLabel,
        initialAmount: initialAmount,
        destructive: destructive,
        onSubmit: accion,
      ),
    );
    if (ok != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito)));
  }

  Future<void> _aceptar() => _ejecutar(
    title: 'Aceptar venta ${_venta?.codigo ?? ''}',
    message:
        'La venta pasará a "Por entregar" y se creará la orden de producción.',
    confirmLabel: 'Aceptar venta',
    exito: 'Venta aceptada.',
    accion: (_, _) async {
      await VentasRepository.instance.aceptar(widget.idVenta);
      await _despuesDeAccion();
    },
  );

  Future<void> _pedirMontoFaltante() => _ejecutar(
    title: 'Pedir monto faltante',
    message:
        'La venta pasará a "En espera" y el cliente recibirá un correo '
        'indicando el monto que falta.',
    confirmLabel: 'Pedir monto faltante',
    exito: 'Se pidió el monto faltante al cliente.',
    accion: (_, _) async {
      await VentasRepository.instance.pedirMontoFaltante(widget.idVenta);
      await _despuesDeAccion();
    },
  );

  Future<void> _rechazar() => _ejecutar(
    title: 'Rechazar venta ${_venta?.codigo ?? ''}',
    message: 'La venta pasará a "Anulado". Elige el motivo del rechazo.',
    confirmLabel: 'Rechazar venta',
    motivos: _motivosRechazo,
    destructive: true,
    exito: 'Venta rechazada.',
    accion: (motivo, _) async {
      await VentasRepository.instance.rechazar(widget.idVenta, motivo!);
      await _despuesDeAccion();
    },
  );

  Future<void> _marcarListo() => _ejecutar(
    title: 'Marcar como lista',
    message: '¿Confirmas que el pedido ${_venta?.codigo ?? ''} está listo?',
    confirmLabel: 'Marcar como lista',
    exito: 'Venta marcada como lista.',
    accion: (_, _) async {
      await VentasRepository.instance.marcarListo(widget.idVenta);
      await _despuesDeAccion(resumen: false);
    },
  );

  Future<void> _anular() => _ejecutar(
    title: 'Anular venta ${_venta?.codigo ?? ''}',
    message: 'Elige el motivo de la anulación.',
    warning:
        'Con "Cliente canceló el pedido" se reembolsa el 80 % del monto; con '
        'los demás motivos, el 100 %.',
    confirmLabel: 'Anular venta',
    motivos: _motivosAnulacion,
    destructive: true,
    exito: 'Venta anulada.',
    accion: (motivo, _) async {
      await VentasRepository.instance.anular(widget.idVenta, motivo!);
      await _despuesDeAccion();
    },
  );

  Future<void> _confirmarPago(PagoResumen pago) => _ejecutar(
    title: 'Confirmar pago',
    message:
        'Indica el monto recibido en pesos para el pago '
        '${pago.tipo ?? '#${pago.id}'}.',
    confirmLabel: 'Confirmar pago',
    amountLabel: 'Monto confirmado (COP)',
    initialAmount: pago.montoDeclarado?.round(),
    exito: 'Pago confirmado.',
    accion: (_, monto) async {
      final resumen = await VentasRepository.instance.confirmarPago(
        widget.idVenta,
        pago.id,
        monto!,
      );
      if (mounted) setState(() => _resumen = resumen);
      await _despuesDeAccion(resumen: false);
    },
  );

  Widget _errorBlock(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5E4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: muted, size: 42),
          const SizedBox(height: 14),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: ink, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _recargando ? null : _cargar,
            style: FilledButton.styleFrom(backgroundColor: red),
            child: Text(
              'Reintentar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
            onPressed: _recargando ? null : _cargar,
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

  Widget _emptyBlock(String mensaje) {
    return SizedBox(
      height: 360,
      child: Center(
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: muted, fontSize: 15),
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
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
                  top: BorderSide(color: Color(0xFFE6E8EC)),
                  left: BorderSide(color: Color(0xFFE6E8EC)),
                  right: BorderSide(color: Color(0xFFE6E8EC)),
                ),
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
                              color: items[i].index == 2
                                  ? red
                                  : const Color(0xFF9AA6B7),
                              size: 22,
                            ),
                            Text(
                              items[i].label,
                              style: GoogleFonts.poppins(
                                color: items[i].index == 2
                                    ? red
                                    : const Color(0xFF9AA6B7),
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
}

class _SaleActionDialog extends StatefulWidget {
  const _SaleActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onSubmit,
    this.motivos,
    this.warning,
    this.amountLabel,
    this.initialAmount,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final List<String>? motivos;
  final String? warning;
  final String? amountLabel;
  final int? initialAmount;
  final bool destructive;
  final Future<void> Function(String? motivo, int? monto) onSubmit;

  @override
  State<_SaleActionDialog> createState() => _SaleActionDialogState();
}

class _SaleActionDialogState extends State<_SaleActionDialog> {
  static const String _otro = 'Otro';
  static const int _maxOtro = 80;

  late final TextEditingController _otroController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController(
    text: widget.initialAmount?.toString() ?? '',
  );
  String? _selected;
  bool _saving = false;
  String? _error;
  List<FaltanteStock> _faltantes = const [];

  @override
  void dispose() {
    _otroController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    String? motivo;
    int? monto;

    if (widget.motivos != null) {
      if (_selected == null) {
        setState(() => _error = 'Elige un motivo.');
        return;
      }
      if (_selected == _otro) {
        final detalle = _otroController.text.trim();
        if (detalle.isEmpty) {
          setState(() => _error = 'Escribe el detalle del motivo.');
          return;
        }
        motivo = 'Otro: $detalle';
      } else {
        motivo = _selected;
      }
    }
    if (widget.amountLabel != null) {
      monto = int.tryParse(_amountController.text.trim());
      if (monto == null || monto <= 0) {
        setState(() => _error = 'Ingresa un monto entero mayor a 0.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
      _faltantes = const [];
    });
    try {
      await widget.onSubmit(motivo, monto);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _faltantes = FaltanteStock.desde(error);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo completar la acción.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final motivos = widget.motivos;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            if (widget.warning != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.warning!,
                style: const TextStyle(
                  color: Color(0xFF8A5600),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (motivos != null) ...[
              const SizedBox(height: 12),
              for (final opcion in [...motivos, _otro])
                InkWell(
                  onTap: _saving
                      ? null
                      : () => setState(() => _selected = opcion),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _selected == opcion
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: _selected == opcion
                              ? EmployeeSaleDetailScreen.red
                              : EmployeeSaleDetailScreen.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(opcion)),
                      ],
                    ),
                  ),
                ),
              if (_selected == _otro) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _otroController,
                  enabled: !_saving,
                  maxLength: _maxOtro,
                  decoration: const InputDecoration(
                    labelText: 'Detalle del motivo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
            if (widget.amountLabel != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: widget.amountLabel,
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: EmployeeSaleDetailScreen.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_faltantes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Existencias insuficientes:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final f in _faltantes)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '• ${f.nombre}: requerido ${_qty(f.requerido, f.unidad)}, '
                    'stock ${_qty(f.stock, f.unidad)}, '
                    'falta ${_qty(f.falta, f.unidad)}'
                    '${f.motivo != null ? ' (${f.motivo})' : ''}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: widget.destructive
                ? EmployeeSaleDetailScreen.red
                : EmployeeSaleDetailScreen.ink,
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

String _qty(double? value, String? unit) {
  if (value == null) return '-';
  final texto = _formatearCantidad(value);
  return unit == null ? texto : '$texto $unit';
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

String _formatearCantidad(double valor) {
  if (valor == valor.roundToDouble()) return valor.toInt().toString();
  return valor.toString().replaceAll('.', ',');
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado, required this.label});

  final EstadoVenta? estado;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colores = _estadoColors(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colores.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colores.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: colores.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

({Color background, Color border, Color foreground}) _estadoColors(
  EstadoVenta? estado,
) {
  return switch (estado) {
    EstadoVenta.porVerificar => (
      background: const Color(0xFFFFFBF0),
      border: const Color(0xFFFFDA70),
      foreground: const Color(0xFFB45B00),
    ),
    EstadoVenta.enEspera => (
      background: const Color(0xFFEEF0FF),
      border: const Color(0xFFC7CEFF),
      foreground: const Color(0xFF3B4BA8),
    ),
    EstadoVenta.porEntregar => (
      background: const Color(0xFFD8EAFF),
      border: const Color(0xFFB6D4FF),
      foreground: const Color(0xFF2861B7),
    ),
    EstadoVenta.completado => (
      background: const Color(0xFFE0F5E9),
      border: const Color(0xFF9BD5B0),
      foreground: const Color(0xFF19733B),
    ),
    EstadoVenta.devolucion => (
      background: const Color(0xFFFFEBCF),
      border: const Color(0xFFFFC477),
      foreground: const Color(0xFFB44A00),
    ),
    EstadoVenta.anulado => (
      background: const Color(0xFFFDE8E8),
      border: const Color(0xFFF5B5B5),
      foreground: const Color(0xFFA11D1D),
    ),
    null => (
      background: const Color(0xFFEFF2F5),
      border: const Color(0xFFC9D2DB),
      foreground: const Color(0xFF6D7B91),
    ),
  };
}

class _ComprobantePago extends StatelessWidget {
  const _ComprobantePago({required this.value});

  final Object? value;

  static final RegExp _base64 = RegExp(r'^[A-Za-z0-9+/=\s_-]+$');

  @override
  Widget build(BuildContext context) {
    final raw = value;
    if (raw is! String || raw.trim().isEmpty) {
      return _mensaje('Formato de comprobante no reconocido.');
    }
    final texto = raw.trim();

    Widget image;
    if (texto.startsWith('http://') || texto.startsWith('https://')) {
      image = Image.network(
        texto,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(
                    color: EmployeeSaleDetailScreen.red,
                  ),
                ),
              ),
        errorBuilder: (_, _, _) =>
            _mensaje('No se pudo cargar el comprobante.'),
      );
    } else {
      final bytes = _decodeBytes(texto);
      if (bytes == null) {
        return _mensaje('Formato de comprobante no reconocido.');
      }
      image = Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            _mensaje('No se pudo mostrar el comprobante.'),
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
  }

  Uint8List? _decodeBytes(String text) {
    var data = text;
    if (data.startsWith('data:')) {
      final coma = data.indexOf(',');
      if (coma < 0) return null;
      data = data.substring(coma + 1);
    } else if (data.length < 100 || !_base64.hasMatch(data)) {
      return null;
    }
    try {
      return base64Decode(base64.normalize(data.replaceAll(RegExp(r'\s'), '')));
    } catch (_) {
      return null;
    }
  }

  Widget _mensaje(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          color: EmployeeSaleDetailScreen.muted,
          fontSize: 13,
        ),
      ),
    );
  }
}
