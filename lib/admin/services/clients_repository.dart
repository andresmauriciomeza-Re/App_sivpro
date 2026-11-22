import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Cliente tal como lo devuelve `GET /clientes` (solo lectura en el móvil).
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.pedidos,
    this.numeroDocumento,
    this.tipoDocumento,
    this.correo,
    this.telefono,
  });

  final int id;

  /// `id_usuario`: número de documento del cliente.
  final String? numeroDocumento;
  final String? tipoDocumento;
  final String nombre;
  final String? correo;
  final String? telefono;

  /// Activo si `cliente_estado && usuario_estado` (misma regla que la web).
  final bool activo;

  /// Ventas no anuladas del cliente.
  final int pedidos;

  /// Código visible: CLI-003.
  String get codigo => 'CLI-${id.toString().padLeft(3, '0')}';

  /// Tipo y número de documento juntos, por ejemplo "CC 1234567".
  String get documento {
    final partes = [
      tipoDocumento,
      numeroDocumento,
    ].whereType<String>().toList();
    return partes.join(' ');
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final id = _entero(json['id_cliente']);
    if (id == null) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Cliente(
      id: id,
      numeroDocumento: _texto(json['id_usuario']),
      tipoDocumento: _texto(json['tipo_documento']),
      nombre: _texto(json['nombre']) ?? 'Sin nombre',
      correo: _texto(json['correo']),
      telefono: _texto(json['telefono']),
      activo:
          _booleano(json['cliente_estado']) &&
          _booleano(json['usuario_estado']),
      pedidos: _entero(json['pedidos']) ?? 0,
    );
  }
}

class ClientsRepository {
  ClientsRepository._();

  static final ClientsRepository instance = ClientsRepository._();

  /// `GET /clientes` (permiso Ventas > Clientes > Ver). No hay detalle por id:
  /// el detalle se arma con los datos de la lista.
  Future<List<Cliente>> listar() async {
    final data = await ApiClient.instance.get('/clientes');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return Cliente.fromJson(item);
        })
        .toList(growable: false);
  }
}

int? _entero(dynamic valor) {
  if (valor is int) return valor;
  if (valor is num && valor.isFinite) return valor.toInt();
  if (valor is String) return int.tryParse(valor.trim());
  return null;
}

String? _texto(dynamic valor) {
  if (valor == null) return null;
  final texto = valor.toString().trim();
  return texto.isEmpty ? null : texto;
}

bool _booleano(dynamic valor) {
  if (valor is bool) return valor;
  if (valor is num) return valor != 0;
  if (valor is String) {
    final texto = valor.trim().toLowerCase();
    return texto == 'true' || texto == '1';
  }
  return false;
}
