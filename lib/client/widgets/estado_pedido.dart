import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/paleta_app.dart';
import '../models/pedido.dart';
import '../services/horario_local.dart';

/// Etiqueta, color, ícono y mensaje de un `estado_cliente` (tabla ESTADO de
/// la web). Un estado desconocido se muestra tal cual, en gris y sin mensaje.
class EstiloEstadoPedido {
  const EstiloEstadoPedido._(
    this.etiqueta,
    this.color,
    this.icono,
    this.mensaje,
  );

  factory EstiloEstadoPedido.de(String estadoCliente) =>
      switch (estadoCliente) {
        'Pendiente' || 'Por verificar' => const EstiloEstadoPedido._(
          'Pendiente',
          Color(0xFFE6A400),
          Icons.hourglass_top,
          'Estamos verificando tu pago.',
        ),
        'En espera' => const EstiloEstadoPedido._(
          'En espera',
          Color(0xFF7C3AED),
          Icons.payments_outlined,
          'Falta parte del pago.',
        ),
        'Aceptado' => const EstiloEstadoPedido._(
          'Aceptado',
          Color(0xFF0284C7),
          Icons.thumb_up_alt_outlined,
          'Pago aceptado, tu pedido entra a cocina.',
        ),
        'En proceso' => const EstiloEstadoPedido._(
          'En preparación',
          Color(0xFFE68A00),
          Icons.local_fire_department,
          'Tu pedido ya está en preparación.',
        ),
        'Por entregar' => const EstiloEstadoPedido._(
          'Por entregar',
          Color(0xFF2563EB),
          Icons.storefront_outlined,
          'Tu pedido está listo para recoger.',
        ),
        'Completado' => const EstiloEstadoPedido._(
          'Completado',
          Color(0xFF34A853),
          Icons.check_circle,
          '¡Gracias por tu compra!',
        ),
        'Rechazado' => const EstiloEstadoPedido._(
          'Rechazado',
          Color(0xFFE0472B),
          Icons.cancel,
          'El comprobante de este pedido fue rechazado.',
        ),
        'Anulado' => const EstiloEstadoPedido._(
          'Anulado',
          Color(0xFFE0472B),
          Icons.cancel,
          'Este pedido fue anulado por la pizzería.',
        ),
        'Devolución' || 'Devolucion' => const EstiloEstadoPedido._(
          'Devolución',
          Color(0xFFEA580C),
          Icons.replay,
          'Este pedido tiene una devolución registrada.',
        ),
        _ => EstiloEstadoPedido._(
          estadoCliente,
          const Color(0xFF757575),
          Icons.help_outline,
          null,
        ),
      };

  final String etiqueta;
  final Color color;
  final IconData icono;
  final String? mensaje;

  /// Color del texto: en oscuro, el mismo tono aclarado para que se lea.
  Color texto(PaletaApp pal) =>
      pal.oscuro ? Color.lerp(color, Colors.white, 0.45)! : color;

  Color fondo(PaletaApp pal) =>
      color.withValues(alpha: pal.oscuro ? 0.22 : 0.12);
}

/// Mensaje del estado para el cliente (con la hora si ya está listo).
String? mensajeEstadoPedido(Pedido pedido) {
  if (pedido.estadoCliente == 'Por entregar' && pedido.horaRecogida != null) {
    // "6:30 p. m." ya termina en punto.
    return 'Tu pedido está listo para recoger a las '
        '${HorarioLocal.textoDeHora(pedido.horaRecogida)}';
  }
  return EstiloEstadoPedido.de(pedido.estadoCliente).mensaje;
}

/// Píldora con el estado del pedido.
class EtiquetaEstadoPedido extends StatelessWidget {
  const EtiquetaEstadoPedido({
    super.key,
    required this.estadoCliente,
    this.grande = false,
  });

  final String estadoCliente;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final estilo = EstiloEstadoPedido.de(estadoCliente);
    final color = estilo.texto(pal);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: grande ? 12 : 10,
        vertical: grande ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: estilo.fondo(pal),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estilo.icono, size: grande ? 14 : 13, color: color),
          SizedBox(width: grande ? 6 : 5),
          Flexible(
            child: Text(
              estilo.etiqueta,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: grande ? 12 : 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pasos del pedido (como la barra de progreso de la web). No se muestra en
/// estados fuera del flujo normal (rechazado, anulado, devolución…).
class ProgresoPedido extends StatelessWidget {
  const ProgresoPedido({super.key, required this.estadoCliente});

  final String estadoCliente;

  static const List<String> pasos = [
    'Pendiente',
    'Aceptado',
    'En proceso',
    'Por entregar',
    'Completado',
  ];

  /// Índice del paso actual, o -1 si el estado no está en el flujo.
  static int pasoDe(String estadoCliente) => pasos.indexOf(
    estadoCliente == 'En espera' || estadoCliente == 'Por verificar'
        ? 'Pendiente'
        : estadoCliente,
  );

  @override
  Widget build(BuildContext context) {
    final actual = pasoDe(estadoCliente);
    if (actual < 0) return const SizedBox.shrink();
    final pal = context.pal;
    const verde = Color(0xFF34A853);
    final naranja = pal.oscuro
        ? pal.avisoTexto(verde)
        : const Color(0xFFE68A00);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < pasos.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == pasos.length - 1 ? 0 : 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      i < actual
                          ? Icons.check_circle
                          : i == actual
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: i < actual
                          ? pal.exitoTexto(verde)
                          : i == actual
                          ? naranja
                          : pal.atenuado(Colors.black26),
                    ),
                    if (i != pasos.length - 1)
                      Container(
                        width: 2,
                        height: 18,
                        color: pal.borde(Colors.black12),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    EstiloEstadoPedido.de(pasos[i]).etiqueta,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: i == actual
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: i > actual
                          ? pal.atenuado(Colors.black38)
                          : pal.texto(Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
