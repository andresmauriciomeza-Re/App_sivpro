import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paleta_app.dart';
import '../services/comprobantes.dart';

const Color _splashRojo = Color(0xE6C32828);
const Color _fondoClaro = Color(0xFFFCF7F5);

/// Cuentas de la pizzería a las que el cliente transfiere.
abstract final class CuentasPago {
  static const List<String> metodos = ['Nequi', 'Bancolombia'];

  static String numero(String metodo) =>
      metodo == 'Bancolombia' ? '000-000000-00' : '300 000 0000';

  static String qr(String metodo) => metodo == 'Bancolombia'
      ? 'assets/img/Bancolombia.png'
      : 'assets/img/Nequi.png';
}

/// Tarjeta blanca (o de la paleta oscura) de los pasos de pago.
class TarjetaPago extends StatelessWidget {
  const TarjetaPago({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// Número de cuenta y QR del método elegido.
class TarjetaCuentaDestino extends StatelessWidget {
  const TarjetaCuentaDestino({super.key, required this.metodo});

  final String metodo;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return TarjetaPago(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Número de cuenta destino',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: pal.texto(Colors.black87),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: pal.campo(_fondoClaro),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CuentasPago.numero(metodo),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1,
                    color: pal.texto(Colors.black),
                  ),
                ),
                Icon(Icons.copy, size: 18, color: pal.atenuado(Colors.black45)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'O escanea el código QR',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: pal.texto(Colors.black87),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 180,
              height: 180,
              clipBehavior: Clip.antiAlias,
              // En oscuro el QR queda sobre blanco para escanearlo.
              decoration: BoxDecoration(
                color: pal.oscuro ? Colors.white : _fondoClaro,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Image.asset(
                CuentasPago.qr(metodo),
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
    );
  }
}

/// "Sube tu recibo": adjuntar, ver el avance de la subida y quitarlo.
class TarjetaComprobante extends StatelessWidget {
  const TarjetaComprobante({
    super.key,
    required this.comprobante,
    required this.subiendo,
    required this.bloqueado,
    required this.alElegir,
    required this.alQuitar,
  });

  final ComprobanteSubido? comprobante;
  final bool subiendo;

  /// Mientras se envía el pedido no se puede cambiar el comprobante.
  final bool bloqueado;
  final VoidCallback alElegir;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final rojo = pal.rojo(_splashRojo);
    final comprobante = this.comprobante;
    return TarjetaPago(
      child: Column(
        children: [
          Text(
            'Sube tu recibo',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: pal.texto(Colors.black87),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Antes de continuar: 1) Haz la transferencia al número de arriba. 2) Toma una captura de pantalla del comprobante. 3) Súbela aquí para que verifiquemos tu pago.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: pal.secundario(Colors.black54),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: subiendo || bloqueado ? null : alElegir,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: rojo.withValues(alpha: 0.4)),
                color: rojo.withValues(alpha: 0.03),
              ),
              child: Column(
                children: [
                  if (subiendo)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: rojo,
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Icon(
                      comprobante != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      color: comprobante != null
                          ? pal.exitoTexto(const Color(0xFF34A853))
                          : rojo,
                      size: 32,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    subiendo
                        ? 'Subiendo comprobante…'
                        : comprobante?.nombre ??
                              'Toca para adjuntar tu comprobante de pago',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: pal.texto(Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG, WEBP o PDF (Máx. 5MB)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: pal.atenuado(Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (comprobante != null && !subiendo)
            TextButton(
              onPressed: bloqueado ? null : alQuitar,
              child: Text(
                'Quitar comprobante',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: rojo,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
