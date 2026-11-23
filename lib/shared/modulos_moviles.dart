import '../auth/models/usuario.dart';
import 'permission_helper.dart';

/// Módulos de la app móvil para Administrador y Empleado (alcance de la
/// ficha: consultar, actualizar y cambiar estados).
///
/// Ambos roles ven el MISMO menú: cada módulo aparece solo si el backend le
/// dio al usuario el permiso 'Ver' de alguna de sus pantallas, nunca por el
/// nombre del rol. La autorización real siempre la valida el backend.
enum ModuloMovil { dashboard, compras, produccion, ventas, indicadores }

/// Pantallas de cada módulo: (módulo del backend, nombre del permiso).
const Map<ModuloMovil, List<(String, String)>> pantallasPorModulo = {
  ModuloMovil.dashboard: [('Dashboard', 'Dashboard')],
  ModuloMovil.compras: [
    ('Compras', 'Compra'),
    ('Compras', 'Insumos'),
    ('Compras', 'Proveedores'),
  ],
  ModuloMovil.produccion: [
    ('Producción', 'Orden de Producción'),
    ('Producción', 'Productos'),
  ],
  ModuloMovil.ventas: [('Ventas', 'Ventas'), ('Ventas', 'Clientes')],
  ModuloMovil.indicadores: [
    ('Ventas', 'Ventas'),
    ('Producción', 'Producto No Conforme'),
  ],
};

/// Función pura: módulos visibles para [usuario], en orden de menú.
List<ModuloMovil> modulosMoviles(Usuario? usuario) {
  return [
    for (final modulo in ModuloMovil.values)
      if (pantallasPorModulo[modulo]!.any(
        (p) => tienePermiso(usuario, p.$1, p.$2, 'Ver'),
      ))
        modulo,
  ];
}
