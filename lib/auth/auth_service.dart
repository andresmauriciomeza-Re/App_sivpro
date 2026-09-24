/// Autenticación mock local (sin backend).
///
/// Única fuente de verdad de los usuarios y sus roles. Los correos se
/// comparan sin distinguir mayúsculas/minúsculas y sin espacios al inicio
/// o final. Si el correo no existe o la contraseña no coincide, el login falla.
enum UserRole { admin, empleado, cliente }

class _Cuenta {
  const _Cuenta(this.password, this.role);
  final String password;
  final UserRole role;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Correo de la sesión activa (null = sesión cerrada).
  String? _currentEmail;
  String? get currentEmail => _currentEmail;

  /// Nombres visibles por cuenta (identidad real mostrada en la tienda/cliente).
  static const Map<String, String> _nombres = {
    'gloria@lasirena.com': 'Gloria Inés Vargas',
    'maria.gonzalez@gmail.com': 'María González',
    'sebastianmorelo@gmail.com': 'Sebastián',
  };

  /// Nombre visible de la sesión activa (null = sesión cerrada).
  String? get currentName => _currentEmail == null ? null : _nombres[_currentEmail];

  /// La tienda fue abierta desde el panel del empleado (sin cerrar sesión).
  bool _fromPanel = false;
  bool get fromPanel => _fromPanel;

  /// Marca la tienda como abierta desde el panel, manteniendo la sesión.
  void startStoreSession() => _fromPanel = true;

  /// Limpia la bandera al volver al panel o al salir de la tienda.
  void endStoreSession() => _fromPanel = false;

  /// Cuentas locales: correo normalizado (en minúsculas) -> contraseña y rol.
  static const Map<String, _Cuenta> _cuentas = {
    'gloria@lasirena.com': _Cuenta('G123456', UserRole.admin),
    'maria.gonzalez@gmail.com': _Cuenta('M123456', UserRole.empleado),
    'sebastianmorelo@gmail.com': _Cuenta('S123456', UserRole.cliente),
  };

  /// Devuelve el rol si las credenciales son correctas; null si no lo son.
  UserRole? login(String email, String password) {
    final normalized = email.trim().toLowerCase();
    final cuenta = _cuentas[normalized];
    if (cuenta == null || cuenta.password != password) return null;
    _currentEmail = normalized;
    _fromPanel = false;
    return cuenta.role;
  }

  /// Cierra la sesión activa.
  void logout() {
    _currentEmail = null;
    _fromPanel = false;
  }
}
