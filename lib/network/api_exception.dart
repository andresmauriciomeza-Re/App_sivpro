/// Error uniforme devuelto por la capa de red.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code, this.data});

  final String message;
  final int? statusCode;
  final String? code;

  /// Objeto `error` completo del backend (por ejemplo, con `faltantes`).
  final Map<String, dynamic>? data;

  /// Códigos 401 con los que el backend informa de una sesión inservible.
  static const Set<String> sessionCodes = {
    'TOKEN_EXPIRADO',
    'TOKEN_INVALIDO',
    'SESION_INVALIDADA',
  };

  bool get hasSessionCode => sessionCodes.contains(code);

  /// Cualquier 401 es sesión caída. El cliente HTTP solo lo aplica a
  /// peticiones que llevaban token y que no son `/auth/login`.
  bool get isSessionExpired => statusCode == 401;

  /// Mensaje para mostrar en el login según el código de sesión.
  static String sessionMessageFor(String? code) {
    return switch (code) {
      'TOKEN_EXPIRADO' => 'Tu sesión expiró. Inicia sesión nuevamente.',
      'SESION_INVALIDADA' =>
        'Tu contraseña fue cambiada o tu sesión ya no es válida. '
            'Inicia sesión con tu nueva contraseña.',
      _ => 'Tu sesión ya no es válida. Inicia sesión nuevamente.',
    };
  }

  @override
  String toString() => message;
}
