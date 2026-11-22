import '../auth/auth_service.dart';

/// Comprobaciones de permisos sobre el usuario ya cargado por [AuthService].
///
/// La autorización real siempre la valida el backend; esto solo decide qué
/// acciones se ofrecen en la interfaz.
class PermissionHelper {
  const PermissionHelper._();

  /// `true` si el usuario en sesión tiene [privilegio] en [modulo] > [nombre].
  static bool can(String modulo, String nombre, String privilegio) {
    return tienePermiso(
      AuthService.instance.usuario,
      modulo,
      nombre,
      privilegio,
    );
  }

  static bool get puedeVerVentas => can('Ventas', 'Ventas', 'Ver');

  static bool get puedeEditarVentas => can('Ventas', 'Ventas', 'Editar');

  static bool get puedeVerClientes => can('Ventas', 'Clientes', 'Ver');

  static bool get puedeVerDevoluciones =>
      can('Ventas', 'Devoluciones', 'Ver');
}

/// Variante pura (sin sesión) para pruebas y reutilización.
bool tienePermiso(
  Usuario? usuario,
  String modulo,
  String nombre,
  String privilegio,
) {
  if (usuario == null) return false;
  if (usuario.esSuperAdmin) return true;
  return usuario.permisos.any(
    (permiso) =>
        permiso.modulo == modulo &&
        permiso.nombre == nombre &&
        permiso.tiene(privilegio),
  );
}
