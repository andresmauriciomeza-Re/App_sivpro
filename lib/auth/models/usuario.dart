enum UserRole { admin, empleado, cliente }

class Permiso {
  const Permiso({
    required this.modulo,
    required this.nombre,
    required this.privilegios,
  });

  final String modulo;
  final String nombre;
  final List<String> privilegios;

  factory Permiso.fromJson(Map<String, dynamic> json) {
    final crudos = json['privilegios'];
    return Permiso(
      modulo: json['modulo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      privilegios: crudos is List
          ? crudos.map((p) => p.toString()).toList(growable: false)
          : const [],
    );
  }

  bool tiene(String privilegio) {
    final buscado = privilegio.toLowerCase();
    return privilegios.any((p) => p.toLowerCase() == buscado);
  }
}

class RolAsignado {
  const RolAsignado({
    required this.id,
    required this.nombre,
    required this.permisos,
  });

  final int id;
  final String nombre;
  final List<Permiso> permisos;

  factory RolAsignado.fromJson(Map<String, dynamic> json) {
    final permisos = json['permisos'];
    return RolAsignado(
      id: _entero(json['id']),
      nombre: json['nombre'] as String? ?? '',
      permisos: permisos is List
          ? permisos
              .whereType<Map<String, dynamic>>()
              .map(Permiso.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.numeroDocumento,
    required this.tipoDocumento,
    required this.telefono,
    required this.rol,
    required this.esSuperAdmin,
    required this.permisos,
    required this.roles,
  });

  final int id;
  final String nombre;
  final String correo;
  final String numeroDocumento;
  final String tipoDocumento;
  final String telefono;
  final String rol;
  final bool esSuperAdmin;
  final List<Permiso> permisos;
  final List<RolAsignado> roles;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final permisos = json['permisos'];
    final roles = json['roles'];
    return Usuario(
      id: _entero(json['id']),
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      numeroDocumento: json['numeroDocumento']?.toString() ?? '',
      tipoDocumento: json['tipoDocumento'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      esSuperAdmin: json['esSuperAdmin'] == true,
      permisos: permisos is List
          ? permisos
              .whereType<Map<String, dynamic>>()
              .map(Permiso.fromJson)
              .toList(growable: false)
          : const [],
      roles: roles is List
          ? roles
              .whereType<Map<String, dynamic>>()
              .map(RolAsignado.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  UserRole? get userRole {
    return switch (_normalizar(rol)) {
      'administrador' => UserRole.admin,
      'empleado' => UserRole.empleado,
      'cliente' => UserRole.cliente,
      _ => null,
    };
  }

  bool puedeVer(
    String modulo,
    String nombre, {
    String privilegio = 'Ver',
  }) {
    if (esSuperAdmin) return true;
    return permisos.any(
      (p) =>
          p.modulo == modulo &&
          p.nombre == nombre &&
          p.tiene(privilegio),
    );
  }

  bool puedeVerModulo(String modulo, {String privilegio = 'Ver'}) {
    if (esSuperAdmin) return true;
    return permisos.any((p) => p.modulo == modulo && p.tiene(privilegio));
  }
}

int _entero(dynamic valor) {
  if (valor is int) return valor;
  return int.tryParse(valor?.toString() ?? '') ?? 0;
}

String _normalizar(String valor) {
  const conTilde = 'áéíóúÁÉÍÓÚñÑ';
  const sinTilde = 'aeiouAEIOUnn';
  final buffer = StringBuffer();
  for (final rune in valor.trim().toLowerCase().runes) {
    final caracter = String.fromCharCode(rune);
    final indice = conTilde.indexOf(caracter);
    buffer.write(indice >= 0 ? sinTilde[indice] : caracter);
  }
  return buffer.toString();
}