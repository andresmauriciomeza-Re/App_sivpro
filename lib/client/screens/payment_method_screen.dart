import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../models/order_model.dart';
import '../../shared/orders_repository.dart';
import 'receipt_sent_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  static const Color splashRojo = Color(0xE6C32828);

  String _metodoSeleccionado = 'Nequi';

  Future<void> _abrirModalTransferencia(String metodo) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalTransferencia(
        metodoNombre: metodo,
        total: CartService.instance.total,
      ),
    );
    if (resultado == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ReceiptSentScreen()),
        (route) => false,
      );
    }
  }

  void _confirmarPago() {
    _abrirModalTransferencia(_metodoSeleccionado);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Text(
                    'Método de pago',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.black87,
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
                  color: Colors.white,
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
                            color: Colors.black54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Ver detalles',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
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
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${formatoMiles(cart.total)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
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
                  color: Colors.black87,
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
                    onTap: () {
                      setState(() => _metodoSeleccionado = 'Nequi');
                      _abrirModalTransferencia('Nequi');
                    },
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
                    onTap: () {
                      setState(() => _metodoSeleccionado = 'Bancolombia');
                      _abrirModalTransferencia('Bancolombia');
                    },
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

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmarPago,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    'Continuar con la compra',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: splashRojo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? splashRojo : Colors.black12,
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
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: seleccionado ? splashRojo : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalTransferencia extends StatefulWidget {
  const _ModalTransferencia({required this.metodoNombre, required this.total});

  final String metodoNombre;
  final int total;

  @override
  State<_ModalTransferencia> createState() => _ModalTransferenciaState();
}

class _ModalTransferenciaState extends State<_ModalTransferencia> {
  static const Color splashRojo = Color(0xE6C32828);

  bool _comprobanteAdjunto = false;
  String? _nombreArchivoAdjunto;

  String get _numeroCuenta {
    switch (widget.metodoNombre) {
      case 'Bancolombia':
        return '000-000000-00';
      default:
        return '300 000 0000';
    }
  }

  String get _rutaQr {
    switch (widget.metodoNombre) {
      case 'Bancolombia':
        return 'assets/img/Bancolombia.png';
      default:
        return 'assets/img/Nequi.png';
    }
  }

  Future<void> _seleccionarComprobante() async {
    try {
      final FilePickerResult? resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (resultado != null && resultado.files.isNotEmpty) {
        setState(() {
          _nombreArchivoAdjunto = resultado.files.first.name;
          _comprobanteAdjunto = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el selector de archivos'),
        ),
      );
    }
  }

  void _enviarComprobante() {
    if (!_comprobanteAdjunto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: splashRojo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Adjunte su comprobante',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }
    final nuevoNumero = '#ORD-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final nuevoPedido = OrderModel(
      numero: nuevoNumero,
      fecha: DateTime.now(),
      articulos: CartService.instance.totalArticulos,
      total: CartService.instance.total,
      estado: OrderStatus.pagoPendiente,
      metodoPago: widget.metodoNombre,
      imagenes: CartService.instance.items.map((i) => i.imagen).toList(),
      nombresProductos: CartService.instance.items
          .map((i) => i.nombre)
          .toList(),
      productos: CartService.instance.items
          .map(
            (i) => OrderProductItem(
              nombre: i.nombre,
              imagen: i.imagen,
              cantidad: i.cantidad,
              precioUnitario: i.precioUnitario,
            ),
          )
          .toList(),
    );
    OrdersRepository.instance.add(nuevoPedido);
    CartService.instance.clear();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCF7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de cuenta destino',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF7F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _numeroCuenta,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(Icons.copy, size: 18, color: Colors.black45),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'O escanea el código QR',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF7F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Image.asset(
                        _rutaQr,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF2F2F2),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.qr_code_2,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Sube tu recibo',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Antes de continuar: 1) Haz la transferencia al número de arriba. 2) Toma una captura de pantalla de la confirmación de tu pago en Nequi o Bancolombia. 3) Toca el botón de abajo para adjuntar esa captura.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _seleccionarComprobante,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: splashRojo.withValues(alpha: 0.4),
                          style: BorderStyle.solid,
                        ),
                        color: splashRojo.withValues(alpha: 0.03),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _comprobanteAdjunto
                                ? Icons.check_circle
                                : Icons.cloud_upload_outlined,
                            color: _comprobanteAdjunto
                                ? const Color(0xFF34A853)
                                : splashRojo,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _comprobanteAdjunto && _nombreArchivoAdjunto != null
                                ? _nombreArchivoAdjunto!
                                : 'Toca para adjuntar tu comprobante de pago',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG o PDF (Máx. 5MB)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    'Total a enviar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${formatoMiles(widget.total)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enviarComprobante,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Enviar comprobante',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: splashRojo,
                  foregroundColor: Colors.white,
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
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: splashRojo,
                  side: const BorderSide(color: splashRojo),
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
