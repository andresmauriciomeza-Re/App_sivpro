import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/auth_service.dart';
import '../../auth/permisos.dart';
import '../services/indicators_service.dart';
import '../services/insumos_repository.dart';
import '../services/ventas_repository.dart';
import 'notificacion.dart';

/// Fuente de las notificaciones del panel. Las pantallas solo usan esta
/// interfaz: en la fase 2 se cambia [instance] por la del backend.
abstract class NotificacionesRepository extends ChangeNotifier {
  /// Fuente activa (hoy, la local).
  static NotificacionesRepository instance = NotificacionesLocal.instance;

  /// De la más reciente a la más antigua.
  Future<List<Notificacion>> listar();

  ValueListenable<int> get conteoNoLeidas;

  Future<void> marcarLeida(String id);

  Future<void> marcarTodasLeidas();

  /// Quita una notificación; no vuelve mientras el dato no cambie.
  Future<void> eliminar(String id);

  Future<void> eliminarTodas();

  Future<void> refrescar();
}

/// Notificaciones guardadas en el teléfono, por usuario.
///
/// Se generan con los datos que ya consultan [PendingSalesService]
/// (`desdeVentas`) y [LowStockNotificationService] (`desdeInsumos`): no hace
/// peticiones propias. La primera vez de cada usuario solo crea resúmenes y
/// guarda la línea base; después avisa de lo nuevo.
class NotificacionesLocal extends NotificacionesRepository {
  NotificacionesLocal._();

  static final NotificacionesLocal instance = NotificacionesLocal._();

  static const int maximo = 50;

  /// Ventas ya vistas que se recuerdan (las más recientes).
  static const int _maximoVentasVistas = 500;

  /// Hora de Bogotá de las notificaciones nuevas; las pruebas la fijan.
  @visibleForTesting
  static DateTime Function() reloj = ahoraBogota;

  final ValueNotifier<int> _conteo = ValueNotifier<int>(0);
  List<Notificacion> _lista = const [];
  int? _usuario;
  Future<void>? _cargando;

  /// Ids de ventas por verificar ya vistas; null = sin línea base.
  Set<int>? _ventasVistas;

  /// Último estado de cada insumo activo; null = sin línea base.
  Map<int, String>? _estadosInsumos;

  bool _iniciado = false;

  @override
  ValueListenable<int> get conteoNoLeidas => _conteo;

  /// Se llama una vez en `main()`.
  void start() {
    if (_iniciado) return;
    _iniciado = true;
    AuthService.instance.addListener(_alCambiarSesion);
    AuthService.instance.addSessionClearedListener(limpiar);
    _alCambiarSesion();
  }

  bool get _personal {
    final rol = AuthService.instance.rol;
    return AuthService.instance.isAuthenticated &&
        (rol == UserRole.admin || rol == UserRole.empleado);
  }

  void _alCambiarSesion() {
    final id = _personal ? AuthService.instance.usuario?.id : null;
    if (id == null) {
      if (_usuario != null) limpiar();
      return;
    }
    if (id == _usuario) return;
    _usuario = id;
    _cargando = _cargar(id);
  }

  /// Al cerrar sesión (o iniciar otra): se vacía la memoria. Lo guardado de
  /// cada usuario se queda en su clave.
  void limpiar() {
    _usuario = null;
    _cargando = null;
    _lista = const [];
    _ventasVistas = null;
    _estadosInsumos = null;
    _conteo.value = 0;
    notifyListeners();
  }

  String _claveLista(int id) => 'notificaciones_panel_$id';
  String _claveBase(int id) => 'notificaciones_panel_base_$id';

  Future<void> _cargar(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usuario != id) return;
      final lista = jsonDecode(prefs.getString(_claveLista(id)) ?? '[]');
      final base = jsonDecode(prefs.getString(_claveBase(id)) ?? '{}');
      _lista = [
        if (lista is List)
          for (final item in lista) ?Notificacion.fromJson(item),
      ]..sort((a, b) => b.fecha.compareTo(a.fecha));
      if (base is Map) {
        final ventas = base['ventas'];
        final insumos = base['insumos'];
        if (ventas is List) {
          _ventasVistas = {
            for (final v in ventas)
              if (v is int) v,
          };
        }
        if (insumos is Map) {
          _estadosInsumos = {
            for (final MapEntry(:key, :value) in insumos.entries)
              if (int.tryParse('$key') != null && value is String)
                int.parse('$key'): value,
          };
        }
      }
    } catch (_) {
      // Sin almacenamiento legible: se empieza de cero (con línea base).
    }
    if (_usuario != id) return;
    _publicar();
  }

  Future<void> _guardar() async {
    final id = _usuario;
    if (id == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _claveLista(id),
        jsonEncode([for (final n in _lista) n.toJson()]),
      );
      await prefs.setString(
        _claveBase(id),
        jsonEncode({
          'ventas': ?_ventasVistas?.toList(),
          'insumos': ?_estadosInsumos?.map((k, v) => MapEntry('$k', v)),
        }),
      );
    } catch (_) {
      // Solo se pierde lo nuevo al reabrir la app.
    }
  }

  void _publicar() {
    _conteo.value = _lista.where((n) => !n.leida).length;
    notifyListeners();
  }

  /// Agrega (o reemplaza por id, como nueva) y recorta a [maximo]:
  /// primero salen las leídas más viejas.
  void _agregar(List<Notificacion> nuevas) {
    if (nuevas.isEmpty) return;
    final ids = {for (final n in nuevas) n.id};
    final lista = [...nuevas, ..._lista.where((n) => !ids.contains(n.id))]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    while (lista.length > maximo) {
      final leida = lista.lastIndexWhere((n) => n.leida);
      lista.removeAt(leida >= 0 ? leida : lista.length - 1);
    }
    _lista = lista;
  }

  /// Ventas cargadas por [PendingSalesService] o por una pantalla de ventas.
  Future<void> desdeVentas(List<Venta> ventas) async {
    final cargando = _cargando;
    if (cargando == null) return;
    await cargando;
    if (_usuario == null || !Permisos.puede('Ventas', 'Ventas', 'Ver')) return;
    final porVerificar = [
      for (final v in ventas)
        if (v.estado == EstadoVenta.porVerificar) v,
    ];
    final vistas = _ventasVistas;
    final ahora = reloj();
    if (vistas == null) {
      final n = porVerificar.length;
      if (n > 0) {
        _agregar([
          Notificacion(
            id: 'resumen:ventas',
            tipo: TipoNotificacion.resumenVentasPorVerificar,
            titulo: n == 1
                ? 'Tienes 1 venta por verificar'
                : 'Tienes $n ventas por verificar',
            mensaje: 'Revísalas en Ventas.',
            fecha: ahora,
            destino: DestinoNotificacion.ventas,
          ),
        ]);
      }
    } else {
      _agregar([
        for (final v in porVerificar)
          if (!vistas.contains(v.id))
            Notificacion(
              id: 'venta:${v.id}',
              tipo: TipoNotificacion.ventaPorVerificar,
              titulo: 'Nueva venta por verificar',
              mensaje: '${v.codigo} · ${v.clienteNombre}',
              fecha: ahora,
              destino: DestinoNotificacion.ventas,
              referencia: '${v.id}',
            ),
      ]);
    }
    final todas = [...?vistas, ...porVerificar.map((v) => v.id)];
    _ventasVistas = todas
        .skip(
          todas.length > _maximoVentasVistas
              ? todas.length - _maximoVentasVistas
              : 0,
        )
        .toSet();
    _publicar();
    await _guardar();
  }

  static String _estadoDe(Insumo insumo) => insumo.agotado
      ? 'agotado'
      : insumo.bajoMinimo
      ? 'bajo'
      : 'ok';

  static const Map<String, int> _gravedad = {'ok': 0, 'bajo': 1, 'agotado': 2};

  /// Insumos cargados por [LowStockNotificationService] o por Insumos.
  Future<void> desdeInsumos(List<Insumo> insumos) async {
    final cargando = _cargando;
    if (cargando == null) return;
    await cargando;
    if (_usuario == null || !Permisos.puede('Compras', 'Insumos', 'Ver')) {
      return;
    }
    final activos = insumos.where((i) => i.estado);
    final anteriores = _estadosInsumos;
    final ahora = reloj();
    final actuales = {for (final i in activos) i.id: _estadoDe(i)};
    if (anteriores == null) {
      final n = actuales.values.where((e) => e != 'ok').length;
      if (n > 0) {
        _agregar([
          Notificacion(
            id: 'resumen:insumos',
            tipo: TipoNotificacion.resumenInsumosBajoMinimo,
            titulo: n == 1
                ? '1 insumo en nivel mínimo'
                : '$n insumos en nivel mínimo',
            mensaje: 'Revísalos en Insumos.',
            fecha: ahora,
            destino: DestinoNotificacion.insumos,
          ),
        ]);
      }
    } else {
      _agregar([
        for (final insumo in activos)
          if (_gravedad[actuales[insumo.id]]! >
              _gravedad[anteriores[insumo.id] ?? 'ok']!)
            _deInsumo(insumo, actuales[insumo.id]!, ahora),
      ]);
    }
    // Los inactivos conservan su último estado conocido.
    _estadosInsumos = {...?anteriores, ...actuales};
    _publicar();
    await _guardar();
  }

  static Notificacion _deInsumo(Insumo insumo, String estado, DateTime fecha) {
    final agotado = estado == 'agotado';
    final unidad = insumo.unidadMedida.isEmpty ? '' : ' ${insumo.unidadMedida}';
    return Notificacion(
      id: 'insumo:${insumo.id}:$estado',
      tipo: agotado
          ? TipoNotificacion.insumoAgotado
          : TipoNotificacion.insumoBajoMinimo,
      titulo: agotado ? 'Insumo agotado' : 'Insumo bajo mínimo',
      mensaje: agotado
          ? '${insumo.nombre} se agotó.'
          : '${insumo.nombre}: ${_cantidad(insumo.stockActual)}$unidad '
                '(mínimo ${_cantidad(insumo.stockMinimo)}$unidad).',
      fecha: fecha,
      destino: DestinoNotificacion.insumos,
      referencia: '${insumo.id}',
    );
  }

  static String _cantidad(double valor) => valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');

  @override
  Future<List<Notificacion>> listar() async {
    await _cargando;
    return List.unmodifiable(_lista);
  }

  @override
  Future<void> marcarLeida(String id) async {
    await _cargando;
    if (!_lista.any((n) => n.id == id && !n.leida)) return;
    _lista = [for (final n in _lista) n.id == id ? n.copyWith(leida: true) : n];
    _publicar();
    await _guardar();
  }

  @override
  Future<void> marcarTodasLeidas() async {
    await _cargando;
    if (_lista.every((n) => n.leida)) return;
    _lista = [for (final n in _lista) n.copyWith(leida: true)];
    _publicar();
    await _guardar();
  }

  // Al eliminar solo se toca la lista: la línea base (ventas vistas y estado
  // de cada insumo) se conserva, así que lo eliminado no se vuelve a crear.
  @override
  Future<void> eliminar(String id) async {
    await _cargando;
    if (!_lista.any((n) => n.id == id)) return;
    _lista = [
      for (final n in _lista)
        if (n.id != id) n,
    ];
    _publicar();
    await _guardar();
  }

  @override
  Future<void> eliminarTodas() async {
    await _cargando;
    if (_lista.isEmpty) return;
    _lista = const [];
    _publicar();
    await _guardar();
  }

  /// Hoy solo relee lo guardado del usuario en sesión.
  @override
  Future<void> refrescar() async {
    final id = _usuario;
    if (id == null) return;
    _cargando = _cargar(id);
    await _cargando;
  }
}
