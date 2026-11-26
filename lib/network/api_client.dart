import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

typedef TokenProvider = String? Function();
typedef SessionExpiredHandler = Future<void> Function(ApiException error);

/// Cliente HTTP único de la app.
///
/// Agrega el token Bearer, traduce los errores del backend a [ApiException]
/// y avisa cuando una petición autenticada pierde la sesión.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  http.Client _client = http.Client();

  /// Permite a las pruebas responder sin llamar al backend real.
  @visibleForTesting
  set clienteHttp(http.Client cliente) => _client = cliente;

  TokenProvider? tokenProvider;
  SessionExpiredHandler? onSessionExpired;

  Future<dynamic> get(String path, {bool auth = true}) {
    return _send('GET', path, auth: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) {
    return _send('PUT', path, body: body, auth: auth);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) {
    return _send('PATCH', path, body: body, auth: auth);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    final sentToken = _agregarToken(headers, auth);
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    return _enviar(request, path, sentToken, ApiConfig.timeout);
  }

  /// Sube un archivo como `multipart/form-data` (siempre con token). El
  /// [tipoContenido] del archivo debe ser el real: el backend lo compara con
  /// los primeros bytes.
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> campos,
    required String campoArchivo,
    required List<int> bytes,
    required String nombreArchivo,
    required String tipoContenido,
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final limite = 'sivpro-${DateTime.now().microsecondsSinceEpoch}';
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data; boundary=$limite',
    };
    final sentToken = _agregarToken(headers, true);
    // Nombre seguro para la cabecera (sin comillas ni caracteres raros).
    final nombre = nombreArchivo.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final cuerpo = BytesBuilder()
      ..add(
        utf8.encode(
          [
            for (final campo in campos.entries)
              '--$limite\r\n'
                  'Content-Disposition: form-data; name="${campo.key}"\r\n\r\n'
                  '${campo.value}\r\n',
            '--$limite\r\n'
                'Content-Disposition: form-data; name="$campoArchivo"; '
                'filename="$nombre"\r\n'
                'Content-Type: $tipoContenido\r\n\r\n',
          ].join(),
        ),
      )
      ..add(bytes)
      ..add(utf8.encode('\r\n--$limite--\r\n'));
    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..bodyBytes = cuerpo.takeBytes();
    return _enviar(request, path, sentToken, tiempoSubida);
  }

  /// Las subidas pesan más (hasta 5 MB): esperan más que el resto.
  static const Duration tiempoSubida = Duration(seconds: 60);

  bool _agregarToken(Map<String, String> headers, bool auth) {
    final token = tokenProvider?.call();
    final sentToken = auth && token != null && token.isNotEmpty;
    if (sentToken) {
      headers['Authorization'] = 'Bearer $token';
    }
    return sentToken;
  }

  Future<dynamic> _enviar(
    http.BaseRequest request,
    String path,
    bool sentToken,
    Duration tiempo,
  ) async {
    http.Response response;
    try {
      // Un solo límite para el envío y la lectura del cuerpo. Sin reintentos.
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(tiempo);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.',
      );
    }

    final data = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final error = _buildError(response.statusCode, data, path: path);
    // Solo una petición que llevaba token puede cerrar la sesión: el 401 de
    // /auth/login (sin token) únicamente se muestra como error.
    if (sentToken && path != '/auth/login' && error.isSessionExpired) {
      await onSessionExpired?.call(error);
    }
    throw error;
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// Forma esperada: `{ error: { message, statusCode, code? } }`. También se
  /// toleran `{ error: "texto" }` y `{ message: "texto" }`. El `message` del
  /// backend siempre tiene prioridad sobre los textos genéricos.
  ApiException _buildError(int statusCode, dynamic data, {String? path}) {
    String? message;
    String? code;
    Map<String, dynamic>? errorData;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        errorData = error;
        final texto = error['message'];
        if (texto is String) message = texto;
        final codigo = error['code'];
        if (codigo is String) code = codigo;
      } else if (error is String) {
        message = error;
      } else if (data['message'] is String) {
        message = data['message'] as String;
      }
    }
    if (message != null && message.trim().isEmpty) message = null;
    return ApiException(
      message ?? _fallbackMessage(statusCode, code: code, path: path),
      statusCode: statusCode,
      code: code,
      data: errorData,
    );
  }

  /// Textos de respaldo por ruta, solo cuando el backend no manda mensaje.
  static const Map<String, Map<int, String>> _respaldoPorRuta = {
    '/auth/recuperar/solicitar': {
      429: 'Espera un momento antes de pedir otro código.',
    },
    '/auth/recuperar/verificar': {400: 'El código es incorrecto o venció.'},
    '/auth/register': {
      400: 'Revisa los datos del formulario.',
      409: 'Este correo o documento ya está registrado.',
      429:
          'Alcanzaste el límite de registros desde esta conexión. '
          'Intenta de nuevo más tarde.',
      503: 'El servicio no está disponible. Inténtalo de nuevo más tarde.',
    },
    '/auth/verificacion/reenviar': {
      429: 'Espera un momento antes de pedir otro correo de confirmación.',
      503: 'El servicio no está disponible. Inténtalo de nuevo más tarde.',
    },
  };

  String _fallbackMessage(int statusCode, {String? code, String? path}) {
    final porRuta = _respaldoPorRuta[path]?[statusCode];
    if (porRuta != null) return porRuta;
    if (statusCode == 401) {
      if (path == '/auth/login') return 'Correo o contraseña incorrectos.';
      return ApiException.sessionMessageFor(code);
    }
    if (statusCode == 403 && path == '/auth/login') {
      return 'Tu cuenta aún no está activada. Revisa tu correo.';
    }
    if (statusCode == 429 && path == '/auth/login') {
      return 'Demasiados intentos de inicio de sesión. '
          'Inténtalo de nuevo en unos minutos.';
    }
    return switch (statusCode) {
      400 => 'La solicitud no es válida.',
      401 => 'Tu sesión ha expirado. Inicia sesión nuevamente.',
      403 => 'No tienes permiso para realizar esta acción.',
      404 => 'No se encontró la información solicitada.',
      409 => 'La operación entra en conflicto con los datos actuales.',
      429 => 'Demasiadas solicitudes. Inténtalo de nuevo más tarde.',
      >= 500 => 'Ocurrió un error en el servidor. Inténtalo de nuevo.',
      _ => 'No se pudo completar la solicitud.',
    };
  }
}
