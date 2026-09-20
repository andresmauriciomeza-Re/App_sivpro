/// Autenticación mock local (sin backend).
///
/// Única fuente de verdad de los usuarios y sus roles. Para agregar un
/// empleado (o admin), solo agrega su correo al mapa `_cuentas`.
/// Los correos se comparan sin distinguir mayúsculas/minúsculas y sin
/// espacios al inicio o final.
enum UserRole { admin, empleado, cliente }

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Correo de la sesión activa (null = sesión cerrada).
  String? _currentEmail;
  String? get currentEmail => _currentEmail;

  /// Cuentas locales (correo normalizado) -> rol.
  /// Cualquier correo que no esté aquí es tratado como cliente.
  static const Map<String, UserRole> _cuentas = {
    'gloria@lasirena.com': UserRole.admin,
    'maria.gonzalez@gmail.com': UserRole.empleado,
  };

  /// Contraseña mock de las cuentas locales (mismo valor que antes).
  static const String _passwordMock = '123456';

  UserRole roleFor(String email, String password) {
    if (password != _passwordMock) return UserRole.cliente;
    final normalized = email.trim().toLowerCase();
    _currentEmail = normalized;
    return _cuentas[normalized] ?? UserRole.cliente;
  }

  /// Cierra la sesión activa.
  void logout() => _currentEmail = null;
}