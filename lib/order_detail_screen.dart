import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'order_model.dart';
import 'cart_service.dart';
import 'bottom_nav.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderModel order;
  static const Color splashRojo = Color(0xE6C32828);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const Color splashRojo = Color(0xE6C32828);

  // Pasos del ciclo de vida de un pedido, en orden.
  static const List<_TimelineStep> _pasos = [
    _TimelineStep('Pedido realizado', Icons.receipt_long),
    _TimelineStep('Pago en aprobación', Icons.payments_outlined),
    _TimelineStep('En preparación', Icons.local_fire_department),
    _TimelineStep('Listo para recoger', Icons.check_circle_outline),
    _TimelineStep('Recogido', Icons.storefront_outlined),
  ];

  static const String direccionLocal =
      'Cl. 98C # 38C-8, Moscú II, Medellín, Popular, Medellín, Antioquia';

  double? _lat;
  double? _lng;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _geocodificar();
  }

  /// Geocodifica [direccionLocal] vía Nominatim y guarda las coordenadas
  /// reales en el estado. Si falla, el mapa muestra el fallback de ícono gris.
  Future<void> _geocodificar() async {
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(direccionLocal)}&format=json&limit=1');
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': 'SIVPRO-App'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        if (mounted) setState(() => _cargando = false);
        return;
      }
      final datos = jsonDecode(resp.body) as List;
      if (datos.isEmpty) {
        if (mounted) setState(() => _cargando = false);
        return;
      }
      final resultado = datos.first as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _lat = double.parse(resultado['lat'] as String);
          _lng = double.parse(resultado['lon'] as String);
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Cuántos pasos de la línea de tiempo ya se completaron,
  /// según el estado actual del pedido.
  int get _pasoActual {
    switch (widget.order.estado) {
      case OrderStatus.pagoPendiente:
        return 1; // "Pedido realizado" completo, "Pago en aprobación" activo
      case OrderStatus.enPreparacion:
        return 2; // Pedido realizado + Pago aprobado + En preparación (activo)
      case OrderStatus.listoParaRecoger:
        return 3; // Hasta "Listo para recoger" (activo)
      case OrderStatus.cancelada:
        return 0; // Solo "Pedido realizado", luego cancelado
    }
  }

  IconData get _iconoMetodoPago {
    return widget.order.metodoPago.toLowerCase() == 'bancolombia'
        ? Icons.account_balance
        : Icons.smartphone;
  }

  @override
  Widget build(BuildContext context) {
    final cancelado = widget.order.estado == OrderStatus.cancelada;

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
                    icon: const Icon(Icons.arrow_back, color: splashRojo),
                  ),
                  Expanded(
                    child: Text(
                      'Pedido ${widget.order.numero}',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ----------------------------------------------------
              // Estado + fecha/hora
              // ----------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.order.estado.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.order.estado.icono,
                          size: 14,
                          color: widget.order.estado.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cancelado ? 'Cancelada' : 'Aprobado',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.order.estado.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _fechaTexto(widget.order.fecha),
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        _horaTexto(widget.order.fecha),
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ----------------------------------------------------
              // Línea de tiempo del pedido
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _pasos.length; i++)
                      _buildPasoTimeline(i, cancelado),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------
              // Productos
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productos',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final producto in widget.order.productos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                producto.imagen,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 44,
                                  height: 44,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.local_pizza,
                                    color: splashRojo,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
Text(
                              'Cant: ${producto.cantidad} x \$${formatoMiles(producto.precioUnitario)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${formatoMiles(producto.subtotal)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '\$${formatoMiles(widget.order.total)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------
              // Método de pago
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de Pago',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: splashRojo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _iconoMetodoPago,
                            size: 18,
                            color: splashRojo,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Transferencia',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: splashRojo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ----------------------------------------------------
              // Ubicación del local
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicación del Local',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _lat == null
                                  ? (_cargando
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: splashRojo,
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.map_outlined,
                                            color: splashRojo,
                                            size: 40,
                                          ),
                                        ))
                                  : GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _abrirMapa,
                                      child: FlutterMap(
                                        options: MapOptions(
                                          initialCenter:
                                              LatLng(_lat!, _lng!),
                                          initialZoom: 16,
                                          interactionOptions:
                                              const InteractionOptions(
                                            flags: InteractiveFlag.none,
                                          ),
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate:
                                                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                            userAgentPackageName:
                                                'com.sivpro.app',
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point:
                                                    LatLng(_lat!, _lng!),
                                                child: const Icon(
                                                  Icons.location_on,
                                                  color: splashRojo,
                                                  size: 36,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            if (_lat != null)
                              Positioned(
                                bottom: 4,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Esri, Maxar, Earthstar Geographics',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: splashRojo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Future<void> _abrirMapa() async {
    if (_lat == null || _lng == null) return;
    final geoUri = Uri.parse('geo:0,0?q=$_lat,$_lng(La Sirena Pizza)');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }
    // Fallback: si no hay app de mapas instalada, usar Google Maps web.
    final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildPasoTimeline(int index, bool cancelado) {
    final paso = _pasos[index];
    final completado = cancelado ? index == 0 : index < _pasoActual;
    final activo = !cancelado && index == _pasoActual;
    final pendiente = !completado && !activo;

    final Color color = completado
        ? const Color(0xFF34A853)
        : activo
        ? const Color(0xFFE68A00)
        : Colors.black26;

    final horaPaso = (completado || activo)
        ? widget.order.fecha.add(Duration(minutes: index * 5))
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                completado
                    ? Icons.check_circle
                    : activo
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: color,
                size: 20,
              ),
              if (index != _pasos.length - 1)
                Container(width: 2, height: 24, color: Colors.black12),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paso.titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pendiente ? Colors.black38 : Colors.black87,
                  ),
                ),
                if (horaPaso != null)
                  Text(
                    '${_fechaTexto(horaPaso)}, ${_horaTexto(horaPaso)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: activo ? const Color(0xFFE68A00) : Colors.black45,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fechaTexto(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  String _horaTexto(DateTime f) =>
      '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
}

class _TimelineStep {
  final String titulo;
  final IconData icono;
  const _TimelineStep(this.titulo, this.icono);
}
