import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../network/api_exception.dart';
import '../../shared/formato.dart';
import '../../theme/paleta_app.dart';
import '../../theme/tema_panel.dart';
import '../models/pedido.dart';
import '../models/producto_catalogo.dart';
import '../services/catalogo_repository.dart';
import '../services/comprobantes.dart';
import '../services/horario_local.dart';
import '../services/pedidos_repository.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/estado_pedido.dart';
import '../widgets/imagen_producto.dart';
import '../widgets/pago_transferencia.dart';
import 'my_orders_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.pedido});

  final Pedido pedido;

  /// Coordenadas de una dirección (Nominatim); las pruebas lo reemplazan.
  @visibleForTesting
  static Future<LatLng?> Function(String direccion) geocodificar = _nominatim;

  static Future<LatLng?> _nominatim(String direccion) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(direccion)}&format=json&limit=1',
    );
    try {
      final resp = await http
          .get(uri, headers: {'User-Agent': 'SIVPRO-App'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final datos = jsonDecode(resp.body);
      if (datos is! List || datos.isEmpty) return null;
      final resultado = datos.first as Map<String, dynamic>;
      return LatLng(
        double.parse(resultado['lat'] as String),
        double.parse(resultado['lon'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) =>
      TemaCliente(child: _Detalle(pedido: pedido));
}

/// Cuerpo del detalle, bajo [TemaCliente] para que `context.pal` vea su tema.
class _Detalle extends StatefulWidget {
  const _Detalle({required this.pedido});

  final Pedido pedido;

  @override
  State<_Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<_Detalle> {
  static const Color splashRojo = Color(0xE6C32828);

  final _repositorio = PedidosRepository.instance;
  late Pedido _pedido = widget.pedido;
  ResumenPagos? _resumen;
  Map<int, ProductoCatalogo> _productos = const {};

  /// Segundos que quedan para cancelar (cuenta regresiva local).
  int _restantes = 0;
  Timer? _contador;
  bool _cancelando = false;

  LatLng? _ubicacion;
  bool _buscandoUbicacion = true;

  @override
  void initState() {
    super.initState();
    _iniciarCuenta(_pedido.segundosRestantesAnulacion);
    _recargar();
    _cargarImagenes();
    _ubicar();
  }

  @override
  void dispose() {
    _contador?.cancel();
    super.dispose();
  }

  void _iniciarCuenta(int segundos) {
    _contador?.cancel();
    _restantes = segundos;
    if (segundos <= 0) return;
    _contador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _restantes--);
      if (_restantes <= 0) timer.cancel();
    });
  }

  bool get _puedeCancelar => _pedido.estadoCancelable && _restantes > 0;

  bool get _puedeCompletarPago {
    final resumen = _resumen;
    return _pedido.estado == 'En espera' &&
        resumen != null &&
        resumen.falta > 0 &&
        !resumen.hayComprobanteEnRevision;
  }

  Future<void> _recargar() async {
    final id = _pedido.id;
    await Future.wait([
      _repositorio
          .obtener(id)
          .then((pedido) {
            if (!mounted) return;
            setState(() {
              _pedido = pedido;
              _iniciarCuenta(pedido.segundosRestantesAnulacion);
            });
          })
          .catchError((Object error) {
            if (error is ApiException) _avisar(error.message);
          }),
      _repositorio
          .resumenPagos(id)
          .then((resumen) {
            if (mounted) setState(() => _resumen = resumen);
          })
          .catchError((Object _) {}),
    ]);
  }

  Future<void> _cargarImagenes() async {
    try {
      final catalogo = await CatalogoRepository.instance.productos();
      if (!mounted) return;
      setState(
        () => _productos = {
          for (final p in catalogo)
            if (p.id != null) p.id!: p,
        },
      );
    } on ApiException {
      // Sin catálogo cada línea muestra el ícono de pizza.
    }
  }

  Future<void> _ubicar() async {
    final ubicacion = await OrderDetailScreen.geocodificar(_direccion);
    if (!mounted) return;
    setState(() {
      _ubicacion = ubicacion;
      _buscandoUbicacion = false;
    });
  }

  String get _direccion => _pedido.direccionRecogida ?? direccionLocal;

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _refrescarLista() {
    unawaited(
      _repositorio.listar(recargar: true).then<void>((_) {}, onError: (_) {}),
    );
  }

  Future<void> _confirmarCancelacion() async {
    if (_cancelando) return;
    final pal = context.pal;
    final tema = Theme.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => Theme(
        data: tema,
        child: _DialogoCancelar(pedido: _pedido, pal: pal),
      ),
    );
    if (confirmado != true || !mounted || _cancelando) return;
    setState(() => _cancelando = true);
    try {
      await _repositorio.cancelar(_pedido.id);
      _avisar(
        'Pedido #${_pedido.id} cancelado. Te devolvemos el 80 % del valor.',
      );
      _iniciarCuenta(0);
      _refrescarLista();
      await _recargar();
    } on ApiException catch (error) {
      _avisar(error.message);
    } finally {
      if (mounted) setState(() => _cancelando = false);
    }
  }

  Future<void> _completarPago() async {
    final resumen = _resumen;
    if (resumen == null) return;
    final tema = Theme.of(context);
    final enviado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Theme(
        data: tema,
        child: _CompletarPago(pedido: _pedido, resumen: resumen),
      ),
    );
    if (enviado != true || !mounted) return;
    _avisar('Recibimos tu comprobante, lo estamos verificando');
    _refrescarLista();
    await _recargar();
  }

  Future<void> _abrirEnlace(String url) async {
    try {
      final abierta = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!abierta) _avisar('No se pudo abrir el archivo.');
    } catch (_) {
      _avisar('No se pudo abrir el archivo.');
    }
  }

  static bool _esPdf(String url) =>
      Uri.tryParse(url)?.path.toLowerCase().endsWith('.pdf') ?? false;

  // ---------------------------------------------------------------- vistas

  Widget _tarjeta({required Widget child}) {
    final pal = context.pal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.tarjeta(Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      texto,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: context.pal.texto(Colors.black87),
      ),
    ),
  );

  TextStyle _texto({
    double size = 13,
    FontWeight peso = FontWeight.w400,
    Color? color,
  }) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: peso,
    color: color ?? context.pal.texto(Colors.black87),
  );

  /// Aviso de color (cancelar, rechazo, devolución, pagos).
  Widget _aviso({
    required Color fondo,
    required Color color,
    required IconData icono,
    required List<Widget> hijos,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: hijos,
          ),
        ),
      ],
    ),
  );

  Widget _buildCancelar() {
    final pal = context.pal;
    final rojo = pal.errorTexto(const Color(0xFFB71C1C));
    return _aviso(
      fondo: pal.errorFondo(const Color(0xFFFDECEA)),
      color: rojo,
      icono: Icons.warning_amber_rounded,
      hijos: [
        Text(
          '¿Te arrepentiste del pedido?',
          style: _texto(peso: FontWeight.w700, color: rojo),
        ),
        const SizedBox(height: 2),
        Text(
          'Puedes cancelarlo dentro de los primeros 10 minutos. Te devolvemos '
          'el 80 % del valor (${formatCop(_pedido.valorADevolver)}).',
          style: _texto(color: rojo),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _cancelando ? null : _confirmarCancelacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(
              0xFFDC2626,
            ).withValues(alpha: 0.6),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _cancelando ? 'Cancelando…' : 'Cancelar pedido ($_restantes s)',
            style: _texto(peso: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Rechazo o anulación: motivo, valor a devolver y su comprobante.
  Widget _buildAnulado() {
    final pal = context.pal;
    final rojo = pal.errorTexto(const Color(0xFFB71C1C));
    final motivo = _pedido.motivoRechazo;
    final esAnulacion = _pedido.montoReembolso != null;
    final mensaje = switch (motivo) {
      'Dinero faltante' =>
        'Rechazado: el valor recibido no cubría el total y el dinero fue '
            'devuelto.',
      'Comprobante falso' => 'Rechazado: el comprobante de pago no fue válido.',
      null => 'Rechazado: el pedido fue anulado por el administrador.',
      _ =>
        esAnulacion
            ? 'Pedido anulado por la pizzería: $motivo.'
            : 'Rechazado por la pizzería: $motivo.',
    };
    final comprobante = _pedido.comprobanteAnulacion;
    return _aviso(
      fondo: pal.errorFondo(const Color(0xFFFDECEA)),
      color: rojo,
      icono: Icons.warning_amber_rounded,
      hijos: [
        Text(mensaje, style: _texto(color: rojo)),
        if (esAnulacion) ...[
          const SizedBox(height: 6),
          Text(
            'Valor a devolver: ${formatCop(_pedido.montoReembolso!)}',
            style: _texto(peso: FontWeight.w700, color: rojo),
          ),
        ],
        if (comprobante != null)
          TextButton.icon(
            onPressed: () => _abrirEnlace(comprobante),
            style: TextButton.styleFrom(
              foregroundColor: rojo,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: Text(
              _esPdf(comprobante)
                  ? 'Ver comprobante de devolución (PDF)'
                  : 'Ver comprobante de devolución',
              style: _texto(size: 12, peso: FontWeight.w600, color: rojo),
            ),
          ),
      ],
    );
  }

  Widget _buildDevolucion() {
    final pal = context.pal;
    final naranja = pal.avisoTexto(const Color(0xFF9A3412));
    final tipo = switch (_pedido.devolucionTipo) {
      'Producto' => 'Cambio de producto',
      'Excedente' => 'Cambio de producto y devolución de dinero',
      _ => 'Devolución de dinero',
    };
    final reemplazo = _pedido.idVentaReemplazo;
    return _aviso(
      fondo: pal.avisoFondo(const Color(0xFFFFF1E6)),
      color: naranja,
      icono: Icons.replay,
      hijos: [
        Text(
          _pedido.devolucionResuelta
              ? (reemplazo != null ? '$tipo · nuevo pedido #$reemplazo' : tipo)
              : 'Devolución en gestión',
          style: _texto(peso: FontWeight.w700, color: naranja),
        ),
        if (_pedido.devolucionResuelta && _pedido.devolucionNota != null)
          Text(_pedido.devolucionNota!, style: _texto(color: naranja)),
      ],
    );
  }

  Widget _buildPagos() {
    final pal = context.pal;
    final resumen = _resumen;
    final violeta = pal.infoTexto(const Color(0xFF5B21B6));
    final pagoCompleto =
        resumen?.falta == 0 &&
        (_pedido.estado == 'En espera' || _pedido.estado == 'Por verificar');
    final enRevision = resumen?.hayComprobanteEnRevision ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resumen == null
              ? 'Resumen de pagos no disponible'
              : 'Recibido: ${formatCop(resumen.recibido)} · En revisión: '
                    '${formatCop(resumen.enRevision)} · Falta: '
                    '${formatCop(resumen.falta)}',
          style: _texto(size: 12, color: pal.secundario(Colors.black54)),
        ),
        if (enRevision || pagoCompleto || _puedeCompletarPago) ...[
          const SizedBox(height: 10),
          _aviso(
            fondo: pal.infoFondo(const Color(0xFFF3EEFF)),
            color: violeta,
            icono: Icons.payments_outlined,
            hijos: [
              if (enRevision)
                Text(
                  'Estamos revisando tu último comprobante',
                  style: _texto(color: violeta),
                ),
              if (pagoCompleto)
                Text(
                  'Pago completo. Estamos revisando tu pedido.',
                  style: _texto(color: violeta),
                ),
              if (_puedeCompletarPago)
                ElevatedButton(
                  onPressed: _completarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Enviar dinero faltante',
                    style: _texto(peso: FontWeight.w600, color: Colors.white),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProducto(LineaPedido linea) {
    final pal = context.pal;
    final producto = _productos[linea.idProducto];
    Widget respaldo(BuildContext context) => Container(
      width: 44,
      height: 44,
      color: pal.campo(Colors.grey.shade200),
      child: Icon(Icons.local_pizza, color: pal.rojo(splashRojo), size: 20),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: producto == null
                ? respaldo(context)
                : ImagenProducto(
                    producto: producto,
                    width: 44,
                    height: 44,
                    respaldo: respaldo,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linea.nombre,
                  style: _texto(size: 13.5, peso: FontWeight.w600),
                ),
                Text(
                  linea.esPizza
                      ? '${linea.cantidad} '
                            '${linea.cantidad == 1 ? 'porción' : 'porciones'}'
                            ' — ${linea.tamano}'
                      : '${linea.cantidad} × ${formatCop(linea.precioUnitario)}',
                  style: _texto(size: 12),
                ),
                if (linea.esPizza)
                  Text(
                    'Precio por porción: ${formatCop(linea.precioUnitario)}',
                    style: _texto(
                      size: 11.5,
                      color: pal.atenuado(Colors.black45),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatCop(linea.subtotal), style: _texto(peso: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildComprobantePago(String url) {
    final pal = context.pal;
    if (_esPdf(url)) {
      return TextButton.icon(
        onPressed: () => _abrirEnlace(url),
        style: TextButton.styleFrom(
          foregroundColor: pal.rojo(splashRojo),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: Text(
          'Abrir comprobante (PDF)',
          style: _texto(peso: FontWeight.w600, color: pal.rojo(splashRojo)),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _abrirEnlace(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 224),
          color: pal.campo(const Color(0xFFF2F2F2)),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            semanticLabel: 'Comprobante de pago',
            errorBuilder: (context, error, stackTrace) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudo mostrar el comprobante. Toca para abrirlo.',
                textAlign: TextAlign.center,
                style: _texto(size: 12, color: pal.secundario(Colors.black54)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapa() {
    final pal = context.pal;
    final rojo = pal.rojo(splashRojo);
    final ubicacion = _ubicacion;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _elegirMapa,
                child: ubicacion == null
                    ? (_buscandoUbicacion
                          ? Center(
                              child: CircularProgressIndicator(color: rojo),
                            )
                          : Container(
                              color: pal.campo(Colors.grey.shade200),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.map_outlined,
                                color: rojo,
                                size: 40,
                              ),
                            ))
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: ubicacion,
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                            userAgentPackageName: 'com.sivpro.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: ubicacion,
                                child: Icon(
                                  Icons.location_on,
                                  color: rojo,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            if (ubicacion != null)
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
                    style: TextStyle(color: Colors.white, fontSize: 8),
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
                child: Icon(Icons.open_in_new, size: 14, color: rojo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final pedido = _pedido;
    final mensaje = mensajeEstadoPedido(pedido);
    final fecha = pedido.fecha;
    final comprobante = pedido.comprobantePago;
    final metodo = pedido.metodoPago;
    return Scaffold(
      backgroundColor: pal.fondo(const Color(0xFFFCF7F5)),
      body: SafeArea(
        child: RefreshIndicator(
          color: pal.rojo(splashRojo),
          onRefresh: _recargar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: pal.texto(Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Pedido #${pedido.id}',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: pal.texto(Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: EtiquetaEstadoPedido(
                        estadoCliente: pedido.estadoCliente,
                        grande: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (fecha != null)
                      Expanded(
                        child: Text(
                          fechaPedidoTexto(fecha),
                          textAlign: TextAlign.right,
                          style: _texto(
                            size: 11.5,
                            color: pal.atenuado(Colors.black45),
                          ),
                        ),
                      ),
                  ],
                ),
                if (mensaje != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    mensaje,
                    style: _texto(color: pal.secundario(Colors.black54)),
                  ),
                ],
                if (pedido.direccionRecogida != null &&
                    pedido.estadoCliente == 'Por entregar') ...[
                  const SizedBox(height: 10),
                  _aviso(
                    fondo: pal.infoFondo(const Color(0xFFEFF6FF)),
                    color: pal.infoTexto(const Color(0xFF1E3A8A)),
                    icono: Icons.storefront_outlined,
                    hijos: [
                      Text(
                        pedido.direccionRecogida!,
                        style: _texto(
                          color: pal.infoTexto(const Color(0xFF1E3A8A)),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_puedeCancelar) ...[
                  const SizedBox(height: 14),
                  _buildCancelar(),
                ],
                if (pedido.estado == 'Anulado') ...[
                  const SizedBox(height: 14),
                  _buildAnulado(),
                ],
                if (pedido.estado == 'Devolucion') ...[
                  const SizedBox(height: 14),
                  _buildDevolucion(),
                ],
                if (ProgresoPedido.pasoDe(pedido.estadoCliente) >= 0) ...[
                  const SizedBox(height: 20),
                  _tarjeta(
                    child: ProgresoPedido(estadoCliente: pedido.estadoCliente),
                  ),
                ],
                const SizedBox(height: 16),
                _tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titulo('Productos'),
                      for (final linea in pedido.detalles)
                        _buildProducto(linea),
                      const SizedBox(height: 6),
                      Divider(color: pal.borde(Colors.black12)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: _texto(size: 15, peso: FontWeight.w700),
                          ),
                          Text(
                            formatCop(pedido.monto),
                            style: _texto(size: 18, peso: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPagos(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titulo('Método de Pago'),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: pal.tarjeta(Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: pal.borde(Colors.black12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              metodo == 'Bancolombia'
                                  ? Icons.account_balance
                                  : Icons.smartphone,
                              size: 18,
                              color: pal.texto(Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              metodo == null
                                  ? 'Transferencia'
                                  : 'Transferencia · $metodo',
                              style: _texto(size: 13.5, peso: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (pedido.horaRecogida != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 18,
                              color: pal.secundario(Colors.black54),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hora de recogida: '
                                '${HorarioLocal.textoDeHora(pedido.horaRecogida)}',
                                style: _texto(size: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (comprobante != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Comprobante de pago',
                          style: _texto(size: 12, peso: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _buildComprobantePago(comprobante),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titulo('Ubicación del Local'),
                      Text(
                        'La Sirena Pizza · $_direccion',
                        style: _texto(
                          size: 12.5,
                          color: pal.secundario(Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMapa(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  /// Abre el bottom sheet para elegir con qué app abrir la ubicación.
  Future<void> _elegirMapa() async {
    final pal = context.pal;
    final app = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: pal.tarjeta(Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: pal.borde(Colors.black26),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Abrir ubicación con',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: pal.texto(Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              _opcionMapa(
                pal: pal,
                icono: Icons.map,
                nombre: 'Google Maps',
                onTap: () => Navigator.of(sheetContext).pop('google_maps'),
              ),
              _opcionMapa(
                pal: pal,
                icono: Icons.navigation,
                nombre: 'Waze',
                onTap: () => Navigator.of(sheetContext).pop('waze'),
              ),
            ],
          ),
        );
      },
    );
    if (app == null || !mounted) return;
    await _abrirMapa(app);
  }

  Widget _opcionMapa({
    required PaletaApp pal,
    required IconData icono,
    required String nombre,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Icon(icono, color: pal.rojo(splashRojo), size: 22),
            const SizedBox(width: 14),
            Text(
              nombre,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pal.texto(Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre Google Maps o Waze con la ubicación (o la dirección si no se
  /// encontraron coordenadas).
  Future<void> _abrirMapa(String app) async {
    final ubicacion = _ubicacion;
    final destino = ubicacion != null
        ? '${ubicacion.latitude},${ubicacion.longitude}'
        : Uri.encodeComponent(_direccion);
    final uri = app == 'waze'
        ? Uri.parse(
            ubicacion != null
                ? 'https://waze.com/ul?ll=$destino&navigate=yes'
                : 'https://waze.com/ul?q=$destino&navigate=yes',
          )
        : Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$destino'
            '&travelmode=driving',
          );
    try {
      final abierta = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!abierta) _avisar('No se pudo abrir la app de mapas');
    } catch (_) {
      _avisar('No se pudo abrir la app de mapas');
    }
  }
}

/// Confirmación de la cancelación (textos de la web).
class _DialogoCancelar extends StatelessWidget {
  const _DialogoCancelar({required this.pedido, required this.pal});

  final Pedido pedido;
  final PaletaApp pal;

  @override
  Widget build(BuildContext context) {
    TextStyle estilo({FontWeight peso = FontWeight.w400, Color? color}) =>
        GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: peso,
          color: color ?? pal.texto(Colors.black87),
        );
    Widget fila(String etiqueta, String valor, {Color? color}) => Row(
      children: [
        Expanded(child: Text(etiqueta, style: estilo())),
        Text(
          valor,
          style: estilo(peso: FontWeight.w700, color: color),
        ),
      ],
    );
    return AlertDialog(
      backgroundColor: pal.tarjeta(Colors.white),
      title: Text(
        'Cancelar pedido #${pedido.id}',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          color: pal.texto(Colors.black87),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'El pedido quedará cancelado y te devolvemos el 80 % del valor '
            'pagado. Esta acción no se puede deshacer.',
            style: estilo(color: pal.secundario(Colors.black54)),
          ),
          const SizedBox(height: 14),
          fila('Total del pedido', formatCop(pedido.monto)),
          const SizedBox(height: 6),
          fila(
            'Valor a devolver (80 %)',
            formatCop(pedido.valorADevolver),
            color: pal.errorTexto(const Color(0xFFDC2626)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Volver', style: estilo(peso: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Sí, cancelar pedido',
            style: estilo(peso: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// "Completar pago": enviar el comprobante del dinero que falta.
class _CompletarPago extends StatefulWidget {
  const _CompletarPago({required this.pedido, required this.resumen});

  final Pedido pedido;
  final ResumenPagos resumen;

  @override
  State<_CompletarPago> createState() => _CompletarPagoState();
}

class _CompletarPagoState extends State<_CompletarPago> {
  static const Color splashRojo = Color(0xE6C32828);

  late final TextEditingController _monto = TextEditingController(
    text: '${widget.resumen.falta}',
  );
  String? _metodo;
  ComprobanteSubido? _comprobante;
  bool _subiendo = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  /// Monto en pesos (solo dígitos, mayor que 0) o null si no es válido.
  int? get _montoDeclarado {
    final texto = _monto.text.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(texto)) return null;
    final valor = int.tryParse(texto);
    return valor != null && valor > 0 ? valor : null;
  }

  void _elegirMetodo(String metodo) {
    if (_enviando || _subiendo || metodo == _metodo) return;
    setState(() {
      if (_comprobante != null) {
        _comprobante = null;
        _error =
            'Cambiaste el método de pago. Quitamos el comprobante anterior. '
            'Sube el del nuevo método.';
      }
      _metodo = metodo;
    });
  }

  Future<void> _subir() async {
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
      if (subido != null && mounted) setState(() => _comprobante = subido);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _enviar() async {
    final metodo = _metodo;
    final comprobante = _comprobante;
    final monto = _montoDeclarado;
    if (_enviando ||
        _subiendo ||
        metodo == null ||
        comprobante == null ||
        monto == null) {
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await PedidosRepository.instance.enviarComprobante(
        widget.pedido.id,
        tipo: metodo,
        comprobante: comprobante.url,
        montoDeclarado: monto,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _monto3(String etiqueta, int valor, {bool resaltar = false}) {
    final pal = context.pal;
    final color = resaltar
        ? pal.infoTexto(const Color(0xFF5B21B6))
        : pal.texto(Colors.black87);
    return Row(
      children: [
        Expanded(
          child: Text(
            etiqueta,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: pal.secundario(Colors.black54),
            ),
          ),
        ),
        Text(
          formatCop(valor),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final rojo = pal.rojo(splashRojo);
    final resumen = widget.resumen;
    final metodo = _metodo;
    final monto = _montoDeclarado;
    final textoMonto = _monto.text.isNotEmpty && monto == null
        ? 'Ingresa un monto en pesos mayor que 0, solo con números.'
        : monto != null && monto > resumen.falta
        ? 'Estás enviando más de lo que falta'
        : null;
    final listo =
        metodo != null &&
        _comprobante != null &&
        monto != null &&
        !_subiendo &&
        !_enviando;
    final error = _error;
    return Container(
      decoration: BoxDecoration(
        color: pal.fondo(const Color(0xFFFCF7F5)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
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
            const SizedBox(height: 14),
            Text(
              'Completar pago',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                color: pal.texto(Colors.black87),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Revisamos tu comprobante y el valor recibido no cubre el total '
              'del pedido. Para continuar, envía el valor faltante.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: pal.secundario(Colors.black54),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TarjetaPago(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _monto3('Total del pedido', resumen.total),
                  const SizedBox(height: 6),
                  _monto3('Pagado', resumen.recibido),
                  const SizedBox(height: 6),
                  _monto3('Faltante', resumen.falta, resaltar: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Elige el método para enviar el faltante',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pal.texto(Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final opcion in CuentasPago.metodos) ...[
                  if (opcion != CuentasPago.metodos.first)
                    const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _elegirMetodo(opcion),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: pal.tarjeta(Colors.white),
                        foregroundColor: pal.texto(Colors.black87),
                        side: BorderSide(
                          color: opcion == metodo
                              ? rojo
                              : pal.borde(Colors.black12),
                          width: opcion == metodo ? 1.6 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        opcion,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (metodo != null) ...[
              const SizedBox(height: 16),
              TarjetaCuentaDestino(metodo: metodo),
              const SizedBox(height: 16),
              TarjetaComprobante(
                comprobante: _comprobante,
                subiendo: _subiendo,
                bloqueado: _enviando,
                alElegir: _subir,
                alQuitar: () => setState(() => _comprobante = null),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Cuánto enviaste?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: pal.texto(Colors.black87),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _monto,
                enabled: !_enviando,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.poppins(color: pal.texto(Colors.black87)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: pal.campo(Colors.white),
                  prefixText: r'$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: pal.borde(Colors.black12)),
                  ),
                ),
              ),
              if (textoMonto != null) ...[
                const SizedBox(height: 6),
                Text(
                  textoMonto,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: pal.avisoTexto(const Color(0xFF92400E)),
                  ),
                ),
              ],
            ],
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
              child: ElevatedButton(
                onPressed: listo ? _enviar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pal.rojoBoton(splashRojo),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: pal
                      .rojoBoton(splashRojo)
                      .withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _enviando ? 'Enviando…' : 'Enviar comprobante',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _enviando || _subiendo
                    ? null
                    : () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: rojo,
                  side: BorderSide(color: rojo),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Volver',
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
