import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sivpro_app/network/api_client.dart';

/// Respuesta JSON en UTF-8 (para que las tildes lleguen bien).
http.Response respuesta(Object? cuerpo, [int estado = 200]) => http.Response(
  jsonEncode(cuerpo),
  estado,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Error con el formato del backend: {error: {message, statusCode, code?}}.
http.Response errorBackend(int estado, String mensaje, {String? code}) =>
    respuesta({
      'error': {'message': mensaje, 'statusCode': estado, 'code': ?code},
    }, estado);

Map<String, dynamic> usuarioJson({
  String rol = 'Cliente',
  List<Map<String, dynamic>> permisos = const [],
}) => {
  'id': 7,
  'nombre': 'Ana Pérez',
  'correo': 'ana@correo.com',
  'numeroDocumento': '1020304050',
  'tipoDocumento': 'CC',
  'telefono': '3001234567',
  'rol': rol,
  'permisos': permisos,
};

/// Sustituye el cliente HTTP de [ApiClient]: ninguna prueba llega al backend.
class BackendFalso {
  BackendFalso() {
    FlutterSecureStorage.setMockInitialValues({});
    ApiClient.instance.clienteHttp = MockClient((peticion) async {
      peticiones.add(peticion);
      for (final MapEntry(key: ruta, value: responder) in rutas.entries) {
        if (_coincide(peticion, ruta)) return await responder(peticion);
      }
      return errorBackend(
        404,
        'Ruta sin respuesta en la prueba: ${peticion.method} ${peticion.url.path}',
      );
    });
  }

  /// 'POST /auth/login' → respuesta (puede esperar, o lanzar
  /// [http.ClientException] para simular un corte de red).
  final Map<String, FutureOr<http.Response> Function(http.Request)> rutas = {};
  final List<http.Request> peticiones = [];

  /// 'POST /auth/login' coincide con POST a cualquier URL que termine así.
  static bool _coincide(http.Request peticion, String ruta) {
    final [metodo, camino] = ruta.split(' ');
    return peticion.method == metodo && peticion.url.path.endsWith(camino);
  }

  List<http.Request> a(String ruta) => [
    for (final p in peticiones)
      if (_coincide(p, ruta)) p,
  ];

  Map<String, dynamic> cuerpo(http.Request peticion) =>
      jsonDecode(peticion.body) as Map<String, dynamic>;

  void loginComo(String rol, {List<Map<String, dynamic>> permisos = const []}) {
    rutas['POST /auth/login'] = (_) => respuesta({
      'token': 'token-de-prueba',
      'usuario': usuarioJson(rol: rol, permisos: permisos),
    });
  }
}

/// Parte de un cuerpo `multipart/form-data` (`POST /uploads`).
class ParteMultipart {
  const ParteMultipart({
    required this.nombre,
    required this.bytes,
    this.archivo,
    this.tipo,
  });

  final String nombre;
  final String? archivo;
  final String? tipo;
  final Uint8List bytes;

  String get texto => utf8.decode(bytes);
}

/// Lee las partes de una petición multipart (por nombre de campo).
Map<String, ParteMultipart> partesMultipart(http.Request peticion) {
  final limite = RegExp(
    r'boundary=(.+)$',
  ).firstMatch(peticion.headers['Content-Type'] ?? '')!.group(1)!;
  // latin1 conserva cada byte tal cual: sirve para cortar el binario.
  final cuerpo = latin1.decode(peticion.bodyBytes);
  final partes = <String, ParteMultipart>{};
  for (final bloque in cuerpo.split('--$limite')) {
    final corte = bloque.indexOf('\r\n\r\n');
    if (corte < 0) continue;
    final cabeceras = bloque.substring(0, corte);
    var contenido = bloque.substring(corte + 4);
    if (contenido.endsWith('\r\n')) {
      contenido = contenido.substring(0, contenido.length - 2);
    }
    final nombre = RegExp(r'name="([^"]*)"').firstMatch(cabeceras)!.group(1)!;
    partes[nombre] = ParteMultipart(
      nombre: nombre,
      archivo: RegExp(r'filename="([^"]*)"').firstMatch(cabeceras)?.group(1),
      tipo: RegExp(
        r'Content-Type: (.+)',
      ).firstMatch(cabeceras)?.group(1)?.trim(),
      bytes: Uint8List.fromList(latin1.encode(contenido)),
    );
  }
  return partes;
}
