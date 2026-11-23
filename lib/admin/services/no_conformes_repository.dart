import '../../network/api_client.dart';
import '../../network/api_exception.dart';
import '../../shared/numeros.dart';

/// Registro de producto no conforme (`GET /productos-no-conformes`).
class ProductoNoConforme {
  const ProductoNoConforme({
    required this.fechaRegistro,
    required this.tipoNoConformidad,
    required this.cantidadAfectada,
    this.estado,
    this.nombre,
    this.motivo,
  });

  /// 'AAAA-MM-DD'.
  final String fechaRegistro;
  final String tipoNoConformidad;
  final double cantidadAfectada;
  final String? estado;
  final String? nombre;
  final String? motivo;

  factory ProductoNoConforme.fromJson(Map<String, dynamic> json) {
    final fecha = json['fecha_registro']?.toString().trim() ?? '';
    return ProductoNoConforme(
      // Solo la parte de fecha; si llegara con hora se descarta sin convertir.
      fechaRegistro: fecha.length >= 10 ? fecha.substring(0, 10) : fecha,
      tipoNoConformidad: _texto(json['tipo_no_conformidad']) ?? 'Sin tipo',
      cantidadAfectada: _numero(json['cantidad_afectada']) ?? 0,
      estado: _texto(json['estado']),
      nombre: _texto(json['nombre']),
      motivo: _texto(json['motivo']),
    );
  }
}

class NoConformesRepository {
  NoConformesRepository._();

  static final NoConformesRepository instance = NoConformesRepository._();

  /// Requiere Producción > Producto No Conforme > Ver.
  Future<List<ProductoNoConforme>> listar() async {
    final data = await ApiClient.instance.get('/productos-no-conformes');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return ProductoNoConforme.fromJson(item);
        })
        .toList(growable: false);
  }
}

/// Lectura tolerante (número o texto con punto/coma; ver numeros.dart).
double? _numero(dynamic valor) => numeroTolerante(valor);

String? _texto(dynamic valor) {
  if (valor == null) return null;
  final texto = valor.toString().trim();
  return texto.isEmpty ? null : texto;
}
