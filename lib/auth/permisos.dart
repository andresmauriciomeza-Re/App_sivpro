import '../shared/modulos_moviles.dart';
import 'auth_service.dart';

/// Claves de permiso del backend usadas para decidir qué módulos se muestran.
///
/// La autorización real siempre la valida el backend; estas comprobaciones
/// solo evitan ofrecer pantallas que responderían 403.
class Permisos {
  Permisos._();

  static AuthService get _auth => AuthService.instance;

  /// Consulta un privilegio concreto con los nombres exactos del backend.
  ///
  /// Ejemplos: `Permisos.puede('Ventas', 'Ventas', 'Editar')`,
  /// `Permisos.puede('Producción', 'Orden de Producción', 'Editar')`,
  /// `Permisos.puede('Compras', 'Compra', 'Ver')`. Lee `usuario.permisos` de la
  /// sesión (login o `/auth/me`); el super administrador siempre puede.
  /// Es solo una ayuda de interfaz: la autorización real es del backend.
  static bool puede(String modulo, String nombre, String privilegio) {
    return _auth.puedeVer(modulo, nombre, privilegio: privilegio);
  }

  /// Módulos visibles del menú (mismo menú para Administrador y Empleado).
  static List<ModuloMovil> get modulos => modulosMoviles(_auth.usuario);

  static bool get dashboard => modulos.contains(ModuloMovil.dashboard);

  /// Compras › Compra, Insumos o Proveedores (Ver).
  static bool get compras => modulos.contains(ModuloMovil.compras);

  /// Producción › Orden de Producción o Productos (Ver).
  static bool get produccion => modulos.contains(ModuloMovil.produccion);

  /// Ventas › Ventas o Clientes (Ver).
  static bool get moduloVentas => modulos.contains(ModuloMovil.ventas);

  /// Ventas › Ventas o Producción › Producto No Conforme (Ver).
  static bool get indicadores => modulos.contains(ModuloMovil.indicadores);

  static bool get comprasCompra => _auth.puedeVer('Compras', 'Compra');

  static bool get comprasInsumos => _auth.puedeVer('Compras', 'Insumos');

  static bool get comprasProveedores =>
      _auth.puedeVer('Compras', 'Proveedores');

  static bool get produccionOrdenes =>
      _auth.puedeVer('Producción', 'Orden de Producción');

  static bool get produccionProductos =>
      _auth.puedeVer('Producción', 'Productos');

  /// Solo para Indicadores (no conformes por semana); no tiene pantalla.
  static bool get produccionNoConformes =>
      _auth.puedeVer('Producción', 'Producto No Conforme');

  static bool get ventasClientes => _auth.puedeVer('Ventas', 'Clientes');

  static bool get ventas => _auth.puedeVer('Ventas', 'Ventas');
}
