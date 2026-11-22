import '../../network/api_client.dart';
import '../../network/api_exception.dart';

/// Proveedor tal como lo devuelve `/proveedores`.
///
/// Conserva el objeto completo del backend ([raw]) porque `PUT /proveedores/:id`
/// vuelve a validar todo el registro: al actualizar se parte de esa copia y solo
/// se cambian los campos editables.
class Proveedor {
  const Proveedor({
    required this.id,
    required this.tipoPersona,
    required this.nombre,
    required this.estado,
    required this.raw,
    this.nit,
    this.dv,
    this.nombreComercial,
    this.tipoDocumento,
    this.numeroDocumento,
    this.tipoSociedad,
    this.camaraComercio,
    this.fechaExpCamara,
    this.repLegalNombre,
    this.repLegalTipoDoc,
    this.repLegalNumDoc,
    this.repLegalTelefono,
    this.repLegalEmail,
    this.asesorComercial,
    this.telefono,
    this.telefonoFijo,
    this.email,
    this.direccion,
  });

  final int id;
  final String tipoPersona;
  final String nombre;
  final bool estado;
  final Map<String, dynamic> raw;
  final String? nit;
  final String? dv;
  final String? nombreComercial;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? tipoSociedad;
  final String? camaraComercio;
  final String? fechaExpCamara;
  final String? repLegalNombre;
  final String? repLegalTipoDoc;
  final String? repLegalNumDoc;
  final String? repLegalTelefono;
  final String? repLegalEmail;
  final String? asesorComercial;
  final String? telefono;
  final String? telefonoFijo;
  final String? email;
  final String? direccion;

  bool get esJuridica => tipoPersona.toLowerCase().startsWith('jur');

  /// Código visible: PROV-001.
  String get codigo => 'PROV-${id.toString().padLeft(3, '0')}';

  /// NIT con dígito de verificación (jurídica) o documento (natural).
  String get identificacion {
    final nitTexto = nit;
    if (nitTexto != null) {
      final digito = dv;
      return digito == null ? nitTexto : '$nitTexto-$digito';
    }
    final numero = numeroDocumento;
    if (numero == null) return '';
    final tipo = tipoDocumento;
    return tipo == null ? numero : '$tipo $numero';
  }

  Proveedor conEstado(bool nuevo) {
    final copia = Map<String, dynamic>.of(raw)..['estado'] = nuevo;
    return Proveedor.fromJson(copia);
  }

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    final id = _entero(json['id_proveedor']);
    final nombre = _texto(json['nombre']);
    if (id == null || nombre == null) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Proveedor(
      id: id,
      tipoPersona: _texto(json['tipo_persona']) ?? '',
      nombre: nombre,
      estado: _booleano(json['estado']),
      raw: Map<String, dynamic>.of(json),
      nit: _texto(json['nit']),
      dv: _texto(json['dv']),
      nombreComercial: _texto(json['nombre_comercial']),
      tipoDocumento: _texto(json['tipo_documento']),
      numeroDocumento: _texto(json['numero_documento']),
      tipoSociedad: _texto(json['tipo_sociedad']),
      camaraComercio: _texto(json['camara_comercio']),
      fechaExpCamara: _fecha(json['fecha_exp_camara']),
      repLegalNombre: _texto(json['rep_legal_nombre']),
      repLegalTipoDoc: _texto(json['rep_legal_tipo_doc']),
      repLegalNumDoc: _texto(json['rep_legal_num_doc']),
      repLegalTelefono: _texto(json['rep_legal_telefono']),
      repLegalEmail: _texto(json['rep_legal_email']),
      asesorComercial: _texto(json['asesor_comercial']),
      telefono: _texto(json['telefono']),
      telefonoFijo: _texto(json['contacto_telefono_fijo']),
      email: _texto(json['email']),
      direccion: _texto(json['direccion']),
    );
  }
}

/// Campos que solo existen para personas Jurídicas.
const Set<String> _soloJuridica = {
  'nombre_comercial',
  'contacto_telefono_fijo',
  'tipo_sociedad',
  'camara_comercio',
  'fecha_exp_camara',
  'rep_legal_nombre',
  'rep_legal_tipo_doc',
  'rep_legal_num_doc',
  'rep_legal_telefono',
  'rep_legal_email',
};

class ProvidersRepository {
  ProvidersRepository._();

  static final ProvidersRepository instance = ProvidersRepository._();

  /// `estado` opcional: true = activos, false = inactivos, null = todos.
  Future<List<Proveedor>> listar({bool? estado}) async {
    final consulta = estado == null ? '' : '?estado=$estado';
    final data = await ApiClient.instance.get('/proveedores$consulta');
    if (data is! List) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException('Respuesta inesperada del servidor.');
          }
          return Proveedor.fromJson(item);
        })
        .toList(growable: false);
  }

  Future<Proveedor> obtener(int id) async {
    final data = await ApiClient.instance.get('/proveedores/$id');
    return _proveedorDeRespuesta(data);
  }

  /// Actualiza solo los campos de [cambios]. El backend valida el objeto
  /// completo, así que se vuelve a leer el proveedor, se mezclan los cambios y
  /// se envía el registro entero. Los valores nulos o vacíos se omiten para no
  /// mandar campos que no aplican al tipo de persona.
  Future<Proveedor> actualizar(int id, Map<String, String?> cambios) async {
    final actual = await obtener(id);
    final cuerpo = Map<String, dynamic>.of(actual.raw)..remove('id_proveedor');
    final fecha = _fecha(cuerpo['fecha_exp_camara']);
    if (fecha != null) cuerpo['fecha_exp_camara'] = fecha;
    // El backend rechaza (400) estos campos en una persona Natural y no admite
    // tipo_documento/numero_documento en una Jurídica.
    if (actual.esJuridica) {
      cuerpo.remove('tipo_documento');
      cuerpo.remove('numero_documento');
    } else {
      cuerpo.removeWhere((clave, _) => _soloJuridica.contains(clave));
    }
    cambios.forEach((clave, valor) {
      if (actual.esJuridica || !_soloJuridica.contains(clave)) {
        cuerpo[clave] = valor;
      }
    });
    // Se omiten nulos y vacíos; los obligatorios ya se validaron en el
    // formulario, así que un campo obligatorio con valor nunca llega vacío.
    cuerpo.removeWhere(
      (_, valor) => valor == null || (valor is String && valor.trim().isEmpty),
    );

    final data = await ApiClient.instance.put('/proveedores/$id', body: cuerpo);
    return _proveedorDeRespuesta(data);
  }

  /// `PATCH /proveedores/:id/estado` con `estado` booleano.
  Future<void> cambiarEstado(int id, bool activo) async {
    await ApiClient.instance.patch(
      '/proveedores/$id/estado',
      body: {'estado': activo},
    );
  }

  Proveedor _proveedorDeRespuesta(dynamic data) {
    final json = data is Map<String, dynamic> && data['proveedor'] is Map
        ? data['proveedor']
        : data;
    if (json is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    return Proveedor.fromJson(json);
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

/// Deja la fecha como YYYY-MM-DD aunque llegue con hora.
String? _fecha(dynamic valor) {
  final texto = _texto(valor);
  if (texto == null) return null;
  final indice = texto.indexOf('T');
  return indice > 0 ? texto.substring(0, indice) : texto;
}

bool _booleano(dynamic valor) {
  if (valor is bool) return valor;
  if (valor is num) return valor != 0;
  if (valor is String) {
    final texto = valor.trim().toLowerCase();
    return texto == 'true' || texto == '1' || texto == 'activo';
  }
  return false;
}
