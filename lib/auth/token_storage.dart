import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token JWT fuera del almacenamiento plano de la app.
class TokenStorage {
  TokenStorage._();

  static final TokenStorage instance = TokenStorage._();

  static const _clave = 'sivpro_access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _clave);

  Future<void> write(String token) => _storage.write(key: _clave, value: token);

  Future<void> delete() => _storage.delete(key: _clave);
}