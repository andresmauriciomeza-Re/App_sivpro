import 'auth_service.dart';

/// Claves de permiso del backend usadas para decidir qué módulos se muestran.
///
/// La autorización real siempre la valida el backend; estas comprobaciones
/// solo evitan ofrecer pantallas que responderían 403.
class Permisos {
  Permisos._();

  static AuthService get _auth => AuthService.instance;

  static bool get dashboard => _auth.puedeVer('Dashboard', 'Dashboard');

  static bool get comprasCompra => _auth.puedeVer('Compras', 'Compra');

  static bool get comprasInsumos => _auth.puedeVer('Compras', 'Insumos');

  static bool get comprasProveedores =>
      _auth.puedeVer('Compras', 'Proveedores');

  static bool get comprasOrdenCompra =>
      _auth.puedeVer('Compras', 'Orden de Compra');

  static bool get compras =>
      comprasCompra ||
      comprasInsumos ||
      comprasProveedores ||
      comprasOrdenCompra;

  static bool get produccionOrdenes =>
      _auth.puedeVer('Producción', 'Orden de Producción');

  static bool get produccionProductos =>
      _auth.puedeVer('Producción', 'Productos');

  static bool get produccionCategorias =>
      _auth.puedeVer('Producción', 'Categoría de Producto');

  static bool get produccionNoConformes =>
      _auth.puedeVer('Producción', 'Producto No Conforme');

  static bool get produccionEmpleados =>
      _auth.puedeVer('Producción', 'Empleados');

  static bool get produccion =>
      produccionOrdenes ||
      produccionProductos ||
      produccionCategorias ||
      produccionNoConformes ||
      produccionEmpleados;

  static bool get ventasClientes => _auth.puedeVer('Ventas', 'Clientes');

  static bool get ventas => _auth.puedeVer('Ventas', 'Ventas');

  static bool get ventasDevoluciones =>
      _auth.puedeVer('Ventas', 'Devoluciones');

  /// Pestaña de Ventas del administrador: el móvil solo tiene pantallas para
  /// clientes y ventas; devoluciones se gestiona desde el rol Empleado.
  static bool get ventasAdministracion => ventasClientes || ventas;

  static bool get ventasEmpleado =>
      ventasClientes || ventas || ventasDevoluciones;
}