import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  final http.Client _client = http.Client();

  TokenProvider? tokenProvider;
  SessionExpiredHandler? onSessionExpired;

  Future<dynamic> get(String path, {bool auth = true}) {
    return _send('GET', path, auth: auth);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
  }) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool auth = true,
  }) {
    return _send('PUT', path, body: body, auth: auth);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool auth = true,
  }) {
    return _send('PATCH', path, body: body, auth: auth);
  }

  Future<dynamic> delete(String path, {bool auth = true}) {
    return _send('DELETE', path, auth: auth);
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

    final token = tokenProvider?.call();
    final sentToken = auth && token != null && token.isNotEmpty;
    if (sentToken) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamed = await _client.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
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

    final error = _buildError(response.statusCode, data);
    if (sentToken && error.isSessionExpired) {
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

  ApiException _buildError(int statusCode, dynamic data) {
    String? message;
    String? code;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        message = error['message'] as String?;
        code = error['code'] as String?;
      }
    }
    return ApiException(
      message ?? _fallbackMessage(statusCode),
      statusCode: statusCode,
      code: code,
    );
  }

  String _fallbackMessage(int statusCode) {
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