/// Error uniforme devuelto por la capa de red.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  bool get isUnauthorized => statusCode == 401;

  bool get isSessionExpired =>
      statusCode == 401 &&
      (code == 'TOKEN_EXPIRADO' ||
          code == 'TOKEN_INVALIDO' ||
          code == 'SESION_INVALIDADA');

  @override
  String toString() => message;
}