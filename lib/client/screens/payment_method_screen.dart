import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../services/cart_service.dart';
import '../services/catalogo_repository.dart';
import '../services/comprobantes.dart';
import '../services/horario_local.dart';
import '../services/pedidos_repository.dart';
import '../services/validacion_carrito.dart';
import '../widgets/pago_transferencia.dart';
import 'receipt_sent_screen.dart';
import '../../shared/mensaje_app.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemaCliente(child: _Pago());
}

/// Pedido confirmado: lo que muestra "Comprobante enviado".
class _Confirmado {
  const _Confirmado(this.pedido, this.lineas);

  final PedidoCreado pedido;
  final List<CartItem> lineas;
}

/// Cuerpo del pago, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Pago extends StatefulWidget {
  const _Pago();

  @override
  State<_Pago> createState() => _PagoState();
}

class _PagoState extends State<_Pago> {
  String? _metodoSeleccionado;
  bool _abriendoModal = false;

  /// Comprobante subido y el método con el que se subió: si el cliente
  /// cambia de método se descarta (como la web).
  ComprobanteSubido? _comprobante;
  String? _metodoComprobante;
  int? _hora;

  void _elegirMetodo(String metodo) {
    if (_comprobante != null && _metodoComprobante != metodo) {
      _comprobante = null;
      _metodoComprobante = null;
      ScaffoldMessenger.of(context).mostrarMensaje(
        'Cambiaste el método de pago. Quitamos el comprobante anterior. '
        'Sube el del nuevo método.',
        tipo: TipoMensaje.informacion,
        sobreBarraPanel: false,
      );
    }
    setState(() => _metodoSeleccionado = metodo);
    _abrirModalTransferencia(metodo);
  }

  Future<void> _abrirModalTransferencia(String metodo) async {
    if (_abriendoModal) return;
    _abriendoModal = true;
    // La hoja se abre sobre el navegador raíz: lleva el tema de esta pantalla.
    final tema = Theme.of(context);
    try {
      final resultado = await showModalBottomSheet<_Confirmado>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Theme(
          data: tema,
          child: _ModalTransferencia(
            metodoNombre: metodo,
            total: CartService.instance.total,
            comprobante: _comprobante,
            hora: _hora,
            alCambiarComprobante: (comprobante) {
              _comprobante = comprobante;
              _metodoComprobante = comprobante == null ? null : metodo;
            },
            alCambiarHora: (hora) => _hora = hora,
          ),
        ),
      );
      if (resultado != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ReceiptSentScreen(
              pedido: resultado.pedido,
              lineas: resultado.lineas,
            ),
          ),
          (route) => false,
        );
      }
    } finally {
      _abriendoModal = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final pal = context.pal;

    return Scaffold(
      backgroundColor: pal.fondo(const Color(0xFFFCF7F5)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  Text(
                    'Método de pago',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pal.tarjeta(Colors.white),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cart.totalArticulos} artículos',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: pal.secundario(Colors.black54),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Ver detalles',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: pal.texto(Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a pagar',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: pal.texto(Colors.black87),
                          ),
                        ),
                        Text(
                          formatCop(cart.total),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: pal.texto(Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Elige tu método de pago',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: pal.texto(Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _PaymentOption(
                    nombre: 'Nequi',
                    seleccionado: _metodoSeleccionado == 'Nequi',
                    onTap: () => _elegirMetodo('Nequi'),
                    icono: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    nombre: 'Bancolombia',
                    seleccionado: _metodoSeleccionado == 'Bancolombia',
                    onTap: () => _elegirMetodo('Bancolombia'),
                    icono: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
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

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.nombre,
    required this.seleccionado,
    required this.onTap,
    required this.icono,
  });

  final String nombre;
  final bool seleccionado;
  final VoidCallback onTap;
  final Widget icono;

  static const Color splashRojo = Color(0xE6C32828);

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: pal.tarjeta(Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? pal.rojo(splashRojo)
                : pal.borde(Colors.black12),
            width: seleccionado ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            icono,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                nombre,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: pal.texto(Colors.black87),
                ),
              ),
            ),
            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: seleccionado
                  ? pal.rojo(splashRojo)
                  : pal.secundario(Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalTransferencia extends StatefulWidget {
  const _ModalTransferencia({
    required this.metodoNombre,
    required this.total,
    required this.comprobante,
    required this.hora,
    required this.alCambiarComprobante,
    required this.alCambiarHora,
  });

  final String metodoNombre;
  final int total;
  final ComprobanteSubido? comprobante;
  final int? hora;
  final ValueChanged<ComprobanteSubido?> alCambiarComprobante;
  final ValueChanged<int?> alCambiarHora;

  @override
  State<_ModalTransferencia> createState() => _ModalTransferenciaState();
}

class _ModalTransferenciaState extends State<_ModalTransferencia> {
  static const Color splashRojo = Color(0xE6C32828);
  static const Color fondoClaro = Color(0xFFFCF7F5);

  late ComprobanteSubido? _comprobante = widget.comprobante;
  late int? _hora = widget.hora;
  bool _subiendo = false;
  bool _enviando = false;
  String? _error;
  Timer? _revisionHora;

  @override
  void initState() {
    super.initState();
    _validarHora();
    // Si la hora elegida queda atrás mientras se revisa, se limpia.
    _revisionHora = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(_validarHora),
    );
  }

  @override
  void dispose() {
    _revisionHora?.cancel();
    super.dispose();
  }

  /// Limpia la hora elegida si ya pasó (como la web). Devuelve si la limpió.
  bool _validarHora() {
    final hora = _hora;
    if (hora == null || HorarioLocal.horariosRecogida().contains(hora)) {
      return false;
    }
    _hora = null;
    widget.alCambiarHora(null);
    _error = 'Esta hora no está disponible porque ya pasó.';
    return true;
  }

  void _ponerComprobante(ComprobanteSubido? comprobante) {
    _comprobante = comprobante;
    widget.alCambiarComprobante(comprobante);
  }

  Future<void> _seleccionarComprobante() async {
    if (_subiendo || _enviando) return;
    try {
      final subido = await Comprobantes.elegirYSubir(
        alSubir: () {
          if (mounted) {
            setState(() {
              _subiendo = true;
              _error = null;
            });
          }
        },
      );
      if (subido != null && mounted) setState(() => _ponerComprobante(subido));
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  String? _validar() {
    final horarios = HorarioLocal.horariosRecogida();
    if (_subiendo) return 'Espera a que termine de subir el comprobante.';
    if (_comprobante == null) return 'Sube el comprobante de pago.';
    if (horarios.isEmpty) return 'Ya no hay horarios disponibles para hoy.';
    if (_validarHora()) return _error;
    if (_hora == null) return 'Selecciona la hora de recogida.';
    return null;
  }

  Future<void> _confirmar() async {
    if (_enviando) return;
    final error = _validar();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      // Justo antes de pagar se revisa el carrito contra el catálogo; si el
      // catálogo no carga se sigue: el servidor valida al crear el pedido.
      try {
        final catalogo = await CatalogoRepository.instance.productos(
          recargar: true,
        );
        final bloquea = validarCarrito(
          CartService.instance.items,
          catalogo,
        ).values.any((e) => e.bloquea);
        if (bloquea) {
          if (mounted) {
            setState(
              () => _error =
                  'Algunos productos se agotaron o ya no tienen stock '
                  'suficiente. Revisa tu carrito.',
            );
          }
          return;
        }
      } on ApiException catch (error) {
        if (error.statusCode == 401) rethrow;
      }
      final lineas = [...CartService.instance.items];
      final Map<String, dynamic> cuerpo;
      try {
        cuerpo = cuerpoPedido(
          items: lineas,
          horaRecogida: HorarioLocal.paraEnviar(_hora!),
          metodoPago: widget.metodoNombre,
          comprobante: _comprobante!.url,
        );
      } on ApiException catch (error) {
        if (mounted) setState(() => _error = error.message);
        return;
      }
      final creado = await PedidosRepository.instance.crear(cuerpo);
      CartService.instance.clear();
      unawaited(_refrescarPedidos());
      if (mounted) Navigator.of(context).pop(_Confirmado(creado, lineas));
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == null) {
        // Sin respuesta: el pedido pudo crearse igual. No se reintenta.
        setState(
          () => _error =
              'No pudimos confirmar si tu pedido se registró. Revisa Mis '
              'pedidos antes de intentarlo otra vez.',
        );
        unawaited(_refrescarPedidos());
      } else {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _refrescarPedidos() async {
    try {
      await PedidosRepository.instance.listar(recargar: true);
    } on ApiException {
      // Mis pedidos lo vuelve a intentar al abrirse.
    }
  }

  Widget _buildHora() {
    final pal = context.pal;
    final horarios = HorarioLocal.horariosRecogida();
    return TarjetaPago(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hora de recogida',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: pal.texto(Colors.black87),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (horarios.isEmpty)
            Text(
              'Ya no hay horarios disponibles para hoy.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: pal.errorTexto(const Color(0xFFC62828)),
              ),
            )
          else
            DropdownButtonFormField<int>(
              key: ValueKey(_hora),
              initialValue: _hora,
              isExpanded: true,
              hint: Text(
                'Elige la hora (hoy)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: pal.atenuado(Colors.black45),
                ),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: pal.campo(fondoClaro),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                for (final minutos in horarios)
                  DropdownMenuItem(
                    value: minutos,
                    child: Text(
                      HorarioLocal.texto(minutos),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: pal.texto(Colors.black87),
                      ),
                    ),
                  ),
              ],
              onChanged: _enviando
                  ? null
                  : (minutos) {
                      setState(() {
                        _hora = minutos;
                        _error = null;
                      });
                      widget.alCambiarHora(minutos);
                    },
            ),
          const SizedBox(height: 6),
          Text(
            'Recogida hoy entre ${HorarioLocal.texto(HorarioLocal.apertura)} '
            'y ${HorarioLocal.texto(HorarioLocal.ultimaRecogida)}.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: pal.atenuado(Colors.black38),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final error = _error;
    return Container(
      decoration: BoxDecoration(
        color: pal.fondo(fondoClaro),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + viewInsets),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: pal.borde(Colors.black12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            TarjetaCuentaDestino(metodo: widget.metodoNombre),

            const SizedBox(height: 22),
            _buildHora(),

            const SizedBox(height: 22),
            TarjetaComprobante(
              comprobante: _comprobante,
              subiendo: _subiendo,
              bloqueado: _enviando,
              alElegir: _seleccionarComprobante,
              alQuitar: () => setState(() => _ponerComprobante(null)),
            ),

            const SizedBox(height: 20),
            TarjetaPago(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                children: [
                  Text(
                    'Total a enviar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: pal.secundario(Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCop(widget.total),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            if (error != null) ...[
              const SizedBox(height: 14),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: pal.errorTexto(const Color(0xFFC62828)),
                ),
              ),
            ],

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enviando || _subiendo ? null : _confirmar,
                icon: _enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  'Confirmar pedido',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pal.rojoBoton(splashRojo),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: pal
                      .rojoBoton(splashRojo)
                      .withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _enviando ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pal.rojo(splashRojo),
                  side: BorderSide(color: pal.rojo(splashRojo)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Volver al carrito',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
