import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'models/usuario.dart';
import 'token_storage.dart';

export 'models/usuario.dart' show UserRole, Usuario, Permiso, RolAsignado;

/// Sesión activa respaldada por el backend.
///
/// Es la única fuente de verdad de identidad, rol y permisos. Conserva los
/// getters que ya usaban las pantallas (`currentName`, `currentEmail`,
/// `fromPanel`, etc.) para no romper la navegación existente.
class AuthService extends ChangeNotifier {
  AuthService._() {
    ApiClient.instance.tokenProvider = () => _token;
    ApiClient.instance.onSessionExpired = _manejarSesionExpirada;
  }

  static final AuthService instance = AuthService._();

  String? _token;
  Usuario? _usuario;
  bool _fromPanel = false;
  bool _manejandoExpiracion = false;

  /// Se invoca cuando el backend invalida una sesión que estaba activa.
  void Function(String message)? onSessionExpired;

  Usuario? get usuario => _usuario;
  String? get currentEmail => _usuario?.correo;
  String? get currentName => _usuario?.nombre;

  /// Primer nombre del usuario en sesión (para saludos). Vacío sin sesión.
  String get currentFirstName {
    final nombre = (_usuario?.nombre ?? '').trim();
    if (nombre.isEmpty) return '';
    return nombre.split(RegExp(r'\s+')).first;
  }
  UserRole? get rol => _usuario?.userRole;
  bool get isAuthenticated => _usuario != null && _token != null;

  /// La tienda fue abierta desde el panel del empleado (sin cerrar sesión).
  bool get fromPanel => _fromPanel;

  void startStoreSession() => _fromPanel = true;

  void endStoreSession() => _fromPanel = false;

  bool puedeVer(String modulo, String nombre, {String privilegio = 'Ver'}) {
    return _usuario?.puedeVer(modulo, nombre, privilegio: privilegio) ?? false;
  }

  bool puedeVerModulo(String modulo, {String privilegio = 'Ver'}) {
    return _usuario?.puedeVerModulo(modulo, privilegio: privilegio) ?? false;
  }

  Future<Usuario> login(String correo, String contrasena) async {
    final data = await ApiClient.instance.post(
      '/auth/login',
      auth: false,
      body: {'correo': correo.trim(), 'contrasena': contrasena},
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    final token = data['token'];
    final usuarioJson = data['usuario'];
    if (token is! String || usuarioJson is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }

    final usuario = Usuario.fromJson(usuarioJson);
    _token = token;
    _usuario = usuario;
    _fromPanel = false;
    try {
      await TokenStorage.instance.write(token);
    } catch (_) {
      // Si el almacenamiento seguro falla, la sesión sigue activa en memoria;
      // solo no se podrá restaurar al reabrir la app.
    }
    notifyListeners();
    return usuario;
  }

  /// Intenta reabrir la sesión guardada.
  ///
  /// Devuelve `false` cuando no hay token o el backend lo rechazó. Si falla la
  /// red lanza [ApiException] para que el arranque ofrezca reintentar.
  Future<bool> restoreSession() async {
    String? token;
    try {
      token = await TokenStorage.instance.read();
    } catch (_) {
      return false;
    }
    if (token == null || token.isEmpty) return false;

    _token = token;
    try {
      final data = await ApiClient.instance.get('/auth/me');
      _usuario = _usuarioDeRespuesta(data);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _limpiarSesion();
        return false;
      }
      rethrow;
    }
  }

  /// Guarda SOLO correo y teléfono contra `PUT /auth/perfil`.
  ///
  /// El backend devuelve el usuario actualizado completo; se reemplaza la
  /// sesión con esa respuesta sin tocar el token.
  Future<Usuario> actualizarPerfil({
    required String correo,
    required String telefono,
  }) async {
    final data = await ApiClient.instance.put(
      '/auth/perfil',
      body: {'correo': correo.trim(), 'telefono': telefono.trim()},
    );
    final usuario = _usuarioDeRespuesta(data);
    _usuario = usuario;
    notifyListeners();
    return usuario;
  }

  /// Refresca el usuario de la sesión con `GET /auth/me`.
  Future<Usuario> refrescarPerfil() async {
    final data = await ApiClient.instance.get('/auth/me');
    final usuario = _usuarioDeRespuesta(data);
    _usuario = usuario;
    notifyListeners();
    return usuario;
  }

  /// Pide un código de recuperación. No lleva token: el usuario no está
  /// autenticado. Devuelve el mensaje genérico del backend.
  Future<String> solicitarCodigoRecuperacion(String correo) async {
    final data = await ApiClient.instance.post(
      '/auth/recuperar/solicitar',
      auth: false,
      body: {'correo': correo.trim()},
    );
    return _mensajeDeRespuesta(
      data,
      'Si el correo está registrado, enviamos un código de verificación.',
    );
  }

  /// Verifica el código de 6 dígitos contra el backend. No lleva token.
  Future<void> verificarCodigoRecuperacion(String correo, String codigo) async {
    final data = await ApiClient.instance.post(
      '/auth/recuperar/verificar',
      auth: false,
      body: {'correo': correo.trim(), 'codigo': codigo},
    );
    if (data is Map<String, dynamic> && data['valido'] == false) {
      throw ApiException(
        _mensajeDeRespuesta(
          data,
          'El código no es válido o venció. Solicita uno nuevo.',
        ),
      );
    }
  }

  /// Aplica la contraseña nueva con el código ya verificado. No lleva token.
  Future<String> restablecerContrasena(
    String correo,
    String codigo,
    String contrasena,
  ) async {
    final data = await ApiClient.instance.post(
      '/auth/recuperar/restablecer',
      auth: false,
      body: {
        'correo': correo.trim(),
        'codigo': codigo,
        'contrasena': contrasena,
      },
    );
    return _mensajeDeRespuesta(
      data,
      'Tu contraseña fue actualizada correctamente.',
    );
  }

  Usuario _usuarioDeRespuesta(dynamic data) {
    dynamic json = data;
    if (data is Map<String, dynamic> &&
        data['usuario'] is Map<String, dynamic>) {
      json = data['usuario'];
    }
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Usuario.fromJson(json);
  }

  String _mensajeDeRespuesta(dynamic data, String porDefecto) {
    if (data is Map<String, dynamic>) {
      final mensaje = data['mensaje'];
      if (mensaje is String && mensaje.trim().isNotEmpty) return mensaje;
    }
    return porDefecto;
  }

  Future<void> logout() => _limpiarSesion();

  /// Cierre de sesión local: no existe endpoint de logout en el backend.
  ///
  /// Limpia primero la memoria (usuario y permisos) y siempre notifica, aunque
  /// falle el borrado del token, para que la app pueda volver al login.
  Future<void> _limpiarSesion() async {
    _token = null;
    _usuario = null;
    _fromPanel = false;
    try {
      await TokenStorage.instance.delete();
    } catch (_) {
      // El token en memoria ya se descartó; se reintenta en el próximo cierre.
    } finally {
      notifyListeners();
    }
  }

  Future<void> _manejarSesionExpirada(ApiException error) async {
    if (_usuario == null || _manejandoExpiracion) return;
    _manejandoExpiracion = true;
    // Con código de sesión conocido se muestra el texto del backend; un 401
    // sin código (p. ej. "Token no proporcionado.") usa el mensaje genérico.
    final mensaje = error.hasSessionCode && error.message.isNotEmpty
        ? error.message
        : ApiException.sessionMessageFor(error.code);
    try {
      await _limpiarSesion();
    } finally {
      _manejandoExpiracion = false;
    }
    onSessionExpired?.call(mensaje);
  }
}
