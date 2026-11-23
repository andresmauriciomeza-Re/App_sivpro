import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Archivo elegido por el cliente para el comprobante de pago.
class ArchivoComprobante {
  const ArchivoComprobante({required this.nombre, required this.bytes});

  final String nombre;
  final Uint8List bytes;
}

/// Comprobante ya subido a `POST /uploads`.
class ComprobanteSubido {
  const ComprobanteSubido({required this.url, required this.nombre});

  final String url;
  final String nombre;
}

/// Comprobantes de pago: validación local, selección y subida.
abstract final class Comprobantes {
  static const int maximoBytes = 5 * 1024 * 1024;

  static const String tipoInvalido =
      'Usa una imagen JPG, PNG o WEBP, o un PDF.';
  static const String muyGrande = 'El archivo supera el máximo de 5 MB.';

  /// Selector del archivo (galería o archivos); las pruebas lo reemplazan.
  /// null = el cliente cerró el selector sin elegir.
  @visibleForTesting
  static Future<ArchivoComprobante?> Function() elegir = _elegirArchivo;

  static Future<ArchivoComprobante?> _elegirArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      withData: true,
    );
    final archivo = resultado?.files.firstOrNull;
    final bytes = archivo?.bytes;
    if (archivo == null || bytes == null) return null;
    return ArchivoComprobante(nombre: archivo.name, bytes: bytes);
  }

  /// Tipo real según los primeros bytes (igual que valida el backend):
  /// JPG, PNG, WEBP o PDF. null si no es ninguno de ellos.
  static String? tipoDe(Uint8List bytes) {
    bool empieza(List<int> firma, [int desde = 0]) =>
        bytes.length >= desde + firma.length &&
        listEquals(bytes.sublist(desde, desde + firma.length), firma);
    if (empieza([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
    if (empieza([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return 'image/png';
    }
    if (empieza('RIFF'.codeUnits) && empieza('WEBP'.codeUnits, 8)) {
      return 'image/webp';
    }
    if (empieza('%PDF-'.codeUnits)) return 'application/pdf';
    return null;
  }

  /// Error de validación local, o null si el archivo se puede subir.
  static String? validar(ArchivoComprobante archivo) {
    if (tipoDe(archivo.bytes) == null) return tipoInvalido;
    if (archivo.bytes.length > maximoBytes) return muyGrande;
    return null;
  }

  /// Abre el selector, valida y sube el archivo. null si el cliente no eligió
  /// nada; [alSubir] avisa cuando empieza la subida. Los errores llegan como
  /// [ApiException] con el mensaje para el cliente.
  static Future<ComprobanteSubido?> elegirYSubir({
    required VoidCallback alSubir,
  }) async {
    final ArchivoComprobante? archivo;
    try {
      archivo = await elegir();
    } catch (_) {
      throw const ApiException('No se pudo abrir el selector de archivos.');
    }
    if (archivo == null) return null;
    final invalido = validar(archivo);
    if (invalido != null) throw ApiException(invalido);
    alSubir();
    return subir(archivo);
  }

  /// Sube el comprobante (carpeta "comprobantes") y devuelve su URL. Los
  /// errores del backend (413, 415, 429) llegan como [ApiException].
  static Future<ComprobanteSubido> subir(ArchivoComprobante archivo) async {
    final tipo = tipoDe(archivo.bytes);
    if (tipo == null) throw const ApiException(tipoInvalido);
    final data = await ApiClient.instance.postMultipart(
      '/uploads',
      campos: const {'carpeta': 'comprobantes'},
      campoArchivo: 'archivo',
      bytes: archivo.bytes,
      nombreArchivo: archivo.nombre,
      tipoContenido: tipo,
    );
    final url = data is Map<String, dynamic> ? data['url'] : null;
    if (url is! String || url.isEmpty) {
      throw const ApiException('No se pudo subir el comprobante.');
    }
    return ComprobanteSubido(url: url, nombre: archivo.nombre);
  }
}
