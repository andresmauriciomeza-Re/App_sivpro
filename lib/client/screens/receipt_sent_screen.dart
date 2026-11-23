import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../services/cart_service.dart';
import '../services/horario_local.dart';
import '../services/pedidos_repository.dart';
import 'my_orders_screen.dart';

/// Pedido creado: muestra los datos que devolvió el servidor.
class ReceiptSentScreen extends StatelessWidget {
  const ReceiptSentScreen({
    super.key,
    required this.pedido,
    required this.lineas,
  });

  final PedidoCreado pedido;

  /// Líneas del carrito con las que se creó el pedido.
  final List<CartItem> lineas;

  @override
  Widget build(BuildContext context) => TemaCliente(
    child: _Enviado(pedido: pedido, lineas: lineas),
  );
}

class _Enviado extends StatelessWidget {
  const _Enviado({required this.pedido, required this.lineas});

  final PedidoCreado pedido;
  final List<CartItem> lineas;

  static const Color splashRojo = Color(0xE6C32828);

  String _detalleLinea(CartItem linea) {
    final partes = [
      if (linea.tamanoNombre != 'Normal') linea.tamanoNombre,
      if (linea.adiciones.isNotEmpty) linea.adicionesTexto,
    ];
    return partes.join(' · ');
  }

  Widget _fila(BuildContext context, String etiqueta, String valor) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: pal.secundario(Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pal.texto(Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final rojo = pal.rojo(splashRojo);
    return Scaffold(
      backgroundColor: pal.fondo(const Color(0xFFFCF7F5)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Comprobante enviado',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: pal.texto(Colors.black87),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: rojo.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_filled,
                          color: rojo,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Comprobante enviado!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          color: pal.texto(Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu pago está pendiente de aprobación. Te notificaremos cuando sea confirmado.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: pal.secundario(Colors.black54),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: pal.tarjeta(Colors.white),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fila(context, 'Pedido', '#${pedido.id}'),
                            _fila(
                              context,
                              'Recogida hoy',
                              HorarioLocal.textoDeHora(pedido.horaRecogida),
                            ),
                            _fila(context, 'Total', formatCop(pedido.monto)),
                            if (lineas.isNotEmpty) ...[
                              Divider(
                                height: 20,
                                color: pal.borde(Colors.black12),
                              ),
                              for (final linea in lineas)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${linea.cantidad} × ${linea.nombre}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_detalleLinea(linea).isNotEmpty)
                                          TextSpan(
                                            text: ' · ${_detalleLinea(linea)}',
                                          ),
                                      ],
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: pal.texto(Colors.black87),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const MyOrdersScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pal.rojoBoton(splashRojo),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Ver mi pedido',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
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
}
