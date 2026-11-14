import 'package:flutter/foundation.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Motivos permitidos por línea de devolución.
const List<String> motivosDevolucion = [
  'Producto malo',
  'Producto incorrecto',
  'Cambio de sabor',
  'Otro',
];

class MotivoDevolucion {
  const MotivoDevolucion({required this.motivo, this.descripcion = ''});

  final String motivo;
  final String descripcion;

  bool get completo {
    final valor = motivo.trim();
    if (valor.isEmpty) return false;
    if (valor == 'Otro' && descripcion.trim().isEmpty) return false;
    return true;
  }

  String get resumen {
    final detalle = descripcion.trim();
    return detalle.isEmpty ? motivo : '$motivo: $detalle';
  }
}

/// Producto dentro de una venta devuelta.
class DevolucionLinea {
  const DevolucionLinea({
    required this.idDetalleVenta,
    required this.idProducto,
    required this.nombre,
    required this.imagen,
    required this.cantidad,
    required this.precio,
    required this.tamano,
    this.motivo,
    this.descripcionMotivo,
  });

  final int idDetalleVenta;
  final int idProducto;
  final String nombre;
  final String? imagen;
  final int cantidad;
  final int precio;
  final String? tamano;
  final String? motivo;
  final String? descripcionMotivo;

  int get subtotal => precio * cantidad;
  String get precioTexto => '\$${formatearMiles(precio)}';
  String get subtotalTexto => '\$${formatearMiles(subtotal)}';
  String get nombreCompleto =>
      tamano == null || tamano!.isEmpty ? nombre : '$nombre ($tamano)';

  factory DevolucionLinea.fromJson(
    Map<String, dynamic> row,
    Map<int, MotivoDevolucion> motivos,
  ) {
    final idDetalle = _asInt(row['id_detalle_venta']) ?? 0;
    final motivo = motivos[idDetalle];
    final nombre = _asString(row['nombre']);
    return DevolucionLinea(
      idDetalleVenta: idDetalle,
      idProducto: _asInt(row['id_producto']) ?? 0,
      nombre: nombre ?? 'Producto',
      imagen: _asString(row['imagen']),
      cantidad: _asInt(row['cantidad']) ?? 0,
      precio: _asInt(row['precio_unitario']) ?? 0,
      tamano: _asString(row['tamano']),
      motivo: motivo?.motivo,
      descripcionMotivo: motivo?.descripcion,
    );
  }
}

/// Devolución asociada a una venta (tb_devolucion + venta).
class DevolucionVenta {
  const DevolucionVenta({
    required this.idVenta,
    required this.customer,
    required this.fecha,
    required this.fechaDevolucion,
    required this.monto,
    required this.payment,
    required this.estado,
    required this.ventaLocal,
    required this.idDevolucion,
    required this.devolucionEstado,
    required this.devolucionTipo,
    required this.devolucionMonto,
    required this.devolucionNota,
    required this.idVentaReemplazo,
    required this.lineas,
  });

  final int idVenta;
  final String customer;
  final String fecha;
  final String? fechaDevolucion;
  final int monto;
  final String payment;
  final String estado;
  final bool ventaLocal;
  final int? idDevolucion;
  final String? devolucionEstado;
  final String? devolucionTipo;
  final int? devolucionMonto;
  final String? devolucionNota;
  final int? idVentaReemplazo;
  final List<DevolucionLinea> lineas;

  bool get resuelta => devolucionEstado == 'Resuelta';
  bool get esProducto => devolucionTipo == 'Producto';
  bool get esExcedente => devolucionTipo == 'Excedente';
  bool get esDinero => devolucionTipo == 'Dinero';
  String get fechaTexto => fechaDevolucion ?? fecha;
  String get montoTexto => '\$ ${formatearMiles(monto)}';
  String get tipoVentaTexto =>
      ventaLocal ? 'Venta en local' : 'Venta a domicilio';
  String get montoDevolucionTexto =>
      '\$ ${formatearMiles(devolucionMonto ?? 0)}';

  String get etiquetaResolucion {
    if (esProducto) return 'Canje';
    if (esExcedente) return 'Mixta';
    return 'Dinero';
  }

  String get descripcionResolucion {
    switch (devolucionTipo) {
      case 'Producto':
        return idVentaReemplazo == null
            ? 'Canje por producto'
            : 'Canje · venta #$idVentaReemplazo';
      case 'Excedente':
        return (devolucionMonto ?? 0) > 0
            ? 'Canje + reembolso $montoDevolucionTexto'
            : 'Canje + saldo';
      case 'Dinero':
        return 'Reembolso $montoDevolucionTexto';
      default:
        return resuelta ? 'Resuelta' : 'Pendiente';
    }
  }

  factory DevolucionVenta.fromJson(Map<String, dynamic> row) {
    final motivos = <int, MotivoDevolucion>{};
    final lineasDevolucion = row['devolucion_lineas'];
    if (lineasDevolucion is List) {
      for (final item in lineasDevolucion) {
        if (item is! Map) continue;
        final map = item.cast<String, dynamic>();
        final idDetalle = _asInt(map['id_detalle_venta']);
        final motivo = _asString(map['motivo']);
        if (idDetalle == null || motivo == null) continue;
        motivos[idDetalle] = MotivoDevolucion(
          motivo: motivo,
          descripcion: _asString(map['descripcion_motivo']) ?? '',
        );
      }
    }

    final lineas = <DevolucionLinea>[];
    final detalles = row['detalles'];
    if (detalles is List) {
      for (final item in detalles) {
        if (item is! Map) continue;
        lineas.add(
          DevolucionLinea.fromJson(item.cast<String, dynamic>(), motivos),
        );
      }
    }

    var payment = '—';
    final pagos = row['pagos'];
    if (pagos is List && pagos.isNotEmpty && pagos.first is Map) {
      final tipo = _asString((pagos.first as Map)['tipo']);
      if (tipo != null) payment = tipo;
    }

    return DevolucionVenta(
      idVenta: _asInt(row['id_venta']) ?? 0,
      customer: _asString(row['cliente_nombre']) ?? 'Cliente',
      fecha: _fechaCorta(row['fecha']),
      fechaDevolucion: _fechaCortaOpcional(row['devolucion_fecha']),
      monto: _asInt(row['monto']) ?? 0,
      payment: payment,
      estado: _asString(row['estado']) ?? '',
      ventaLocal: row['venta_local'] == true,
      idDevolucion: _asInt(row['id_devolucion']),
      devolucionEstado: _asString(row['devolucion_estado']),
      devolucionTipo: _asString(row['devolucion_tipo']),
      devolucionMonto: _asInt(row['devolucion_monto']),
      devolucionNota: _asString(row['devolucion_nota']),
      idVentaReemplazo: _asInt(row['id_venta_reemplazo']),
      lineas: lineas,
    );
  }
}

/// Tamaño/precio disponible del catálogo real para un canje.
class CanjeTamano {
  const CanjeTamano({
    required this.label,
    required this.precio,
    this.limiteStock,
  });

  final String? label;
  final int precio;
  final int? limiteStock;

  bool get disponible => limiteStock == null || limiteStock! > 0;
  String get precioTexto => '\$${formatearMiles(precio)}';
}

/// Producto de `GET /productos` listo para el selector de canje.
class CanjeProducto {
  const CanjeProducto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.imagen,
    required this.estado,
    required this.tamanos,
  });

  final int id;
  final String nombre;
  final String categoria;
  final String? imagen;
  final String estado;
  final List<CanjeTamano> tamanos;

  bool get disponible =>
      estado == 'Disponible' && tamanos.any((t) => t.disponible);

  factory CanjeProducto.fromJson(Map<String, dynamic> row) {
    final categoria = _asString(row['categoria_nombre']) ?? '';
    final categoriaLower = categoria.toLowerCase();
    final esPizza = categoriaLower.contains('pizza');
    final esLasana =
        categoriaLower.contains('lasaña') || categoriaLower.contains('lasana');
    final precioVenta = _asInt(row['precio_venta']) ?? 0;
    final precioGrande = _asInt(row['precio_grande']);
    final stock = _asInt(row['stock']);
    final disponiblesMediana = _asInt(row['disponibles_mediana']);
    final disponiblesGrande = _asInt(row['disponibles_grande']);

    final tamanos = <CanjeTamano>[];
    if (esPizza) {
      tamanos.add(
        CanjeTamano(
          label: 'Mediana',
          precio: precioVenta,
          limiteStock: disponiblesMediana ?? stock,
        ),
      );
      if (precioGrande != null) {
        tamanos.add(
          CanjeTamano(
            label: 'Grande',
            precio: precioGrande,
            limiteStock: disponiblesGrande ?? stock,
          ),
        );
      }
    } else if (esLasana) {
      tamanos.add(
        CanjeTamano(label: 'Normal', precio: precioVenta, limiteStock: stock),
      );
    } else {
      tamanos.add(
        CanjeTamano(label: null, precio: precioVenta, limiteStock: stock),
      );
    }

    return CanjeProducto(
      id: _asInt(row['id_producto']) ?? 0,
      nombre: _asString(row['nombre']) ?? 'Producto',
      categoria: categoria.isEmpty ? 'Otros' : categoria,
      imagen: _asString(row['imagen']),
      estado: _asString(row['estado']) ?? '',
      tamanos: tamanos,
    );
  }
}

/// Producto elegido para el canje, con su cantidad.
class CanjeSeleccion {
  const CanjeSeleccion({
    required this.idProducto,
    required this.nombre,
    required this.imagen,
    required this.tamano,
    required this.precio,
    required this.cantidad,
    this.limiteStock,
  });

  final int idProducto;
  final String nombre;
  final String? imagen;
  final String? tamano;
  final int precio;
  final int cantidad;
  final int? limiteStock;

  int get subtotal => precio * cantidad;
  String get nombreCompleto =>
      tamano == null || tamano!.isEmpty ? nombre : '$nombre ($tamano)';
  String get precioTexto => '\$${formatearMiles(precio)}';
  String get subtotalTexto => '\$${formatearMiles(subtotal)}';

  CanjeSeleccion copyWith({int? cantidad}) {
    return CanjeSeleccion(
      idProducto: idProducto,
      nombre: nombre,
      imagen: imagen,
      tamano: tamano,
      precio: precio,
      cantidad: cantidad ?? this.cantidad,
      limiteStock: limiteStock,
    );
  }
}

class ResolverLinea {
  const ResolverLinea({
    required this.idDetalleVenta,
    required this.cantidad,
    required this.motivo,
    required this.descripcionMotivo,
    required this.idProductoReemplazo,
    required this.cantidadReemplazo,
    required this.tamanoReemplazo,
  });

  final int idDetalleVenta;
  final int cantidad;
  final String motivo;
  final String? descripcionMotivo;
  final int? idProductoReemplazo;
  final int? cantidadReemplazo;
  final String? tamanoReemplazo;

  Map<String, dynamic> toJson() {
    return {
      'id_detalle_venta': idDetalleVenta,
      'cantidad': cantidad,
      'motivo': motivo,
      'descripcion_motivo': descripcionMotivo,
      'id_producto_reemplazo': idProductoReemplazo,
      'cantidad_reemplazo': cantidadReemplazo,
      'tamano_reemplazo': tamanoReemplazo,
    };
  }
}

class CanjeItem {
  const CanjeItem({
    required this.idProducto,
    required this.cantidad,
    required this.tamano,
  });

  final int idProducto;
  final int cantidad;
  final String? tamano;

  Map<String, dynamic> toJson() {
    return {'id_producto': idProducto, 'cantidad': cantidad, 'tamano': tamano};
  }
}

class ResolverDevolucionPayload {
  const ResolverDevolucionPayload({
    required this.tipo,
    required this.nota,
    required this.monto,
    required this.lineas,
    required this.canje,
  });

  final String tipo;
  final String nota;
  final int monto;
  final List<ResolverLinea> lineas;
  final List<CanjeItem> canje;

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nota': nota,
      'monto': monto,
      'lineas': lineas.map((linea) => linea.toJson()).toList(),
      'canje': canje.map((item) => item.toJson()).toList(),
    };
  }
}

/// Cálculos y armado del payload con las mismas reglas de la web.
class DevolucionCalculos {
  DevolucionCalculos._();

  static int valorDevuelto(
    List<DevolucionLinea> lineas,
    Map<int, int> devueltos,
  ) {
    var total = 0;
    for (final linea in lineas) {
      final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
      if (cantidad > 0) total += cantidad * linea.precio;
    }
    return total;
  }

  static int valorCanje(List<CanjeSeleccion> canje) {
    return canje.fold<int>(0, (total, item) => total + item.subtotal);
  }

  static int saldo(int valorDevuelto, int valorCanje) {
    return valorDevuelto - valorCanje;
  }

  static int dineroADar(int saldo) => saldo > 0 ? saldo : 0;

  static int dineroARecibir(int saldo) => saldo < 0 ? -saldo : 0;

  static String tipo({required bool hayCanje, required int saldo}) {
    if (!hayCanje) return 'Dinero';
    return (dineroADar(saldo) > 0 || dineroARecibir(saldo) > 0)
        ? 'Excedente'
        : 'Producto';
  }

  static int totalDevuelto(Map<int, int> devueltos) {
    var total = 0;
    for (final cantidad in devueltos.values) {
      if (cantidad > 0) total += cantidad;
    }
    return total;
  }

  static List<String> faltan({
    required List<DevolucionLinea> lineas,
    required Map<int, int> devueltos,
    required Map<int, MotivoDevolucion> motivos,
    required List<CanjeSeleccion> canje,
  }) {
    final faltan = <String>[];
    if (totalDevuelto(devueltos) == 0) {
      faltan.add('Marca las unidades que devuelve el cliente.');
    }
    for (final linea in lineas) {
      final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
      if (cantidad <= 0) continue;
      final motivo = motivos[linea.idDetalleVenta];
      if (motivo == null || !motivo.completo) {
        faltan.add(
          'Indica el motivo de la devolución de "${linea.nombre}" (obligatorio).',
        );
      }
    }
    if (canje.isEmpty) {
      final cambioSabor = lineas.any((linea) {
        final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
        return cantidad > 0 &&
            motivos[linea.idDetalleVenta]?.motivo == 'Cambio de sabor';
      });
      if (cambioSabor) {
        faltan.add(
          'El motivo "Cambio de sabor" necesita un producto de canje: elige el sabor nuevo.',
        );
      }
    }
    return faltan;
  }

  static bool puedeConfirmar({
    required List<DevolucionLinea> lineas,
    required Map<int, int> devueltos,
    required Map<int, MotivoDevolucion> motivos,
    required List<CanjeSeleccion> canje,
  }) {
    if (totalDevuelto(devueltos) == 0) return false;
    for (final linea in lineas) {
      final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
      if (cantidad <= 0) continue;
      final motivo = motivos[linea.idDetalleVenta];
      if (motivo == null || !motivo.completo) return false;
      if (motivo.motivo == 'Cambio de sabor' && canje.isEmpty) return false;
    }
    return true;
  }

  static String construirNota({
    required List<DevolucionLinea> lineas,
    required Map<int, int> devueltos,
    required List<CanjeSeleccion> canje,
    required int saldo,
    required String nota,
  }) {
    final devueltosTexto = <String>[];
    for (final linea in lineas) {
      final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
      if (cantidad > 0) devueltosTexto.add('${cantidad}x ${linea.nombre}');
    }
    final canjeTexto = canje
        .map(
          (item) =>
              '${item.cantidad}x ${item.nombre}'
              '${item.tamano == null ? '' : ' (${item.tamano})'}',
        )
        .join(', ');

    final partes = <String>[
      if (devueltosTexto.isNotEmpty) 'Devolvió: ${devueltosTexto.join(', ')}',
      if (canjeTexto.isNotEmpty) 'Canje: $canjeTexto',
      if (dineroADar(saldo) > 0)
        'Dinero a devolver: ${formatearCop(dineroADar(saldo))}',
      if (dineroARecibir(saldo) > 0)
        'Extra a cobrar: ${formatearCop(dineroARecibir(saldo))}',
      if (nota.trim().isNotEmpty) 'Nota: ${nota.trim()}',
    ];
    return partes.join(' · ');
  }

  static ResolverDevolucionPayload construirPayload({
    required List<DevolucionLinea> lineas,
    required Map<int, int> devueltos,
    required Map<int, MotivoDevolucion> motivos,
    required List<CanjeSeleccion> canje,
    required String nota,
  }) {
    final valor = valorDevuelto(lineas, devueltos);
    final valorComp = valorCanje(canje);
    final saldoActual = saldo(valor, valorComp);
    final lineasDevueltas = lineas
        .where((linea) => (devueltos[linea.idDetalleVenta] ?? 0) > 0)
        .toList();
    final canjeUnico = lineasDevueltas.length == 1 && canje.length == 1
        ? canje.first
        : null;

    return ResolverDevolucionPayload(
      tipo: tipo(hayCanje: canje.isNotEmpty, saldo: saldoActual),
      nota: construirNota(
        lineas: lineas,
        devueltos: devueltos,
        canje: canje,
        saldo: saldoActual,
        nota: nota,
      ),
      monto: dineroADar(saldoActual),
      lineas: lineasDevueltas.map((linea) {
        final cantidad = devueltos[linea.idDetalleVenta] ?? 0;
        final motivo = motivos[linea.idDetalleVenta];
        final descripcion = motivo?.descripcion.trim() ?? '';
        return ResolverLinea(
          idDetalleVenta: linea.idDetalleVenta,
          cantidad: cantidad,
          motivo: motivo?.motivo ?? '',
          descripcionMotivo: descripcion.isEmpty ? null : descripcion,
          idProductoReemplazo: canjeUnico?.idProducto,
          cantidadReemplazo: canjeUnico?.cantidad,
          tamanoReemplazo: canjeUnico?.tamano,
        );
      }).toList(),
      canje: canje
          .map(
            (item) => CanjeItem(
              idProducto: item.idProducto,
              cantidad: item.cantidad,
              tamano: item.tamano,
            ),
          )
          .toList(),
    );
  }
}

/// Estado de las devoluciones respaldado por el backend.
class ReturnService extends ChangeNotifier {
  ReturnService._();
  static final ReturnService instance = ReturnService._();

  final List<DevolucionVenta> _ventas = [];
  bool _isLoading = false;
  String? _error;
  Future<void>? _cargaEnCurso;
  List<CanjeProducto>? _catalogo;

  List<DevolucionVenta> get ventas => List.unmodifiable(_ventas);

  List<DevolucionVenta> get pendientes =>
      _ventas.where((venta) => !venta.resuelta).toList();

  List<DevolucionVenta> get resueltas =>
      _ventas.where((venta) => venta.resuelta).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargar({bool silencioso = false}) {
    final enCurso = _cargaEnCurso;
    if (enCurso != null) return enCurso;
    final future = _cargar(silencioso: silencioso);
    _cargaEnCurso = future;
    return future.whenComplete(() => _cargaEnCurso = null);
  }

  Future<void> _cargar({required bool silencioso}) async {
    _isLoading = true;
    if (!silencioso) _error = null;
    notifyListeners();
    try {
      final data = await ApiClient.instance.get('/ventas');
      final rows = data is List ? data : const [];
      final ventas = <DevolucionVenta>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final map = row.cast<String, dynamic>();
        if (map['estado'] != 'Devolucion') continue;
        ventas.add(DevolucionVenta.fromJson(map));
      }
      _ventas
        ..clear()
        ..addAll(ventas);
      _error = null;
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'No se pudieron cargar las devoluciones.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DevolucionVenta> detalle(int idVenta) async {
    final data = await ApiClient.instance.get('/ventas/$idVenta');
    if (data is! Map) {
      throw const ApiException('No se encontró la venta.');
    }
    return DevolucionVenta.fromJson(data.cast<String, dynamic>());
  }

  /// Marca la venta como devolución y devuelve el id de tb_devolucion.
  /// Es idempotente en el backend.
  Future<int> iniciarDevolucion(int idVenta) async {
    final data = await ApiClient.instance.patch('/ventas/$idVenta/devolucion');
    final map = data is Map
        ? data.cast<String, dynamic>()
        : const <String, dynamic>{};
    final idDevolucion = _asInt(map['id_devolucion']);
    if (idDevolucion == null) {
      throw const ApiException(
        'La devolución no tiene registro en el servidor.',
      );
    }
    await cargar(silencioso: true);
    return idDevolucion;
  }

  Future<int> asegurarDevolucion(DevolucionVenta venta) async {
    final idDevolucion = venta.idDevolucion;
    if (idDevolucion != null) return idDevolucion;
    return iniciarDevolucion(venta.idVenta);
  }

  Future<int?> resolver(
    int idDevolucion,
    ResolverDevolucionPayload payload,
  ) async {
    final data = await ApiClient.instance.patch(
      '/devoluciones/$idDevolucion/resolver',
      body: payload.toJson(),
    );
    final map = data is Map
        ? data.cast<String, dynamic>()
        : const <String, dynamic>{};
    final idVentaReemplazo = _asInt(map['id_venta_reemplazo']);
    await cargar(silencioso: true);
    return idVentaReemplazo;
  }

  Future<List<CanjeProducto>> cargarCatalogoCanje({bool forzar = false}) async {
    if (!forzar && _catalogo != null) return _catalogo!;
    final data = await ApiClient.instance.get('/productos', auth: false);
    final rows = data is List ? data : const [];
    final productos = <CanjeProducto>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final producto = CanjeProducto.fromJson(row.cast<String, dynamic>());
      if (producto.disponible) productos.add(producto);
    }
    productos.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    _catalogo = productos;
    return productos;
  }
}

String formatearMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    if (i > 0 && (texto.length - i) % 3 == 0) buffer.write('.');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}

String formatearCop(int valor) => '\$ ${formatearMiles(valor)}';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final texto = value.toString().trim();
  return texto.isEmpty ? null : texto;
}

String _fechaCorta(dynamic value) {
  final texto = _asString(value);
  if (texto == null) return '';
  final indice = texto.indexOf('T');
  return indice > 0 ? texto.substring(0, indice) : texto;
}

String? _fechaCortaOpcional(dynamic value) {
  final texto = _fechaCorta(value);
  return texto.isEmpty ? null : texto;
}
