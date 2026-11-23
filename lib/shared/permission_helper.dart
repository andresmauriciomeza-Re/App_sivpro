import '../auth/auth_service.dart';

/// `true` si [usuario] tiene [privilegio] en [modulo] > [nombre].
///
/// Función pura (sin sesión), reutilizada por el menú por permisos y por las
/// pruebas. El super administrador siempre puede. La autorización real
/// siempre la valida el backend.
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
