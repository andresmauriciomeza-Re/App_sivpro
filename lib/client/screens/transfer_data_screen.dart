import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../models/order_model.dart';
import 'receipt_sent_screen.dart';

class TransferDataScreen extends StatefulWidget {
  const TransferDataScreen({
    super.key,
    required this.metodoNombre,
    required this.total,
  });

  final String metodoNombre;
  final int total;

  @override
  State<TransferDataScreen> createState() => _TransferDataScreenState();
}

class _TransferDataScreenState extends State<TransferDataScreen> {
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

  Widget get _iconoMetodo {
    final esNequi = widget.metodoNombre == 'Nequi';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: esNequi ? Colors.black : const Color(0xFFFFCC00),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: esNequi
          ? const Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : const Icon(Icons.account_balance, color: Colors.black, size: 20),
    );
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
                  style: GoogleFonts.dmSerifDisplay(
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
    mockOrders.insert(0, nuevoPedido);
    CartService.instance.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ReceiptSentScreen()),
      (route) => false,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Text(
                    'Datos de transferencia',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
                    Row(
                      children: [
                        _iconoMetodo,
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Método seleccionado',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                            Text(
                              widget.metodoNombre,
                              style: GoogleFonts.dmSerifDisplay(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Número de cuenta destino',
                      style: GoogleFonts.dmSerifDisplay(
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
                            style: GoogleFonts.dmSerifDisplay(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          Icon(Icons.copy, size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 15,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Por favor, realiza la transferencia a este número antes de confirmar el pedido.',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 11.5,
                              color: Colors.black45,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'O escanea el código QR',
                      style: GoogleFonts.dmSerifDisplay(
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                      style: GoogleFonts.dmSerifDisplay(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Antes de continuar: 1) Haz la transferencia al número de arriba. 2) Toma una captura de pantalla de la confirmación de tu pago en Nequi o Bancolombia. 3) Toca el botón de abajo para adjuntar esa captura.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
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
                              _comprobanteAdjunto &&
                                      _nombreArchivoAdjunto != null
                                  ? _nombreArchivoAdjunto!
                                  : 'Toca para adjuntar tu comprobante de pago',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSerifDisplay(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG, PNG o PDF (Máx. 5MB)',
                              style: GoogleFonts.dmSerifDisplay(
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
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${formatoMiles(widget.total)}',
                      style: GoogleFonts.dmSerifDisplay(
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
                    style: GoogleFonts.dmSerifDisplay(
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
                    style: GoogleFonts.dmSerifDisplay(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
