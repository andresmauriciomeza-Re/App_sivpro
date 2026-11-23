import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/auth/models/usuario.dart';
import 'package:sivpro_app/shared/modulos_moviles.dart';

Usuario _usuario({
  String rol = 'Empleado',
  bool superAdmin = false,
  List<Permiso> permisos = const [],
}) {
  return Usuario(
    id: 1,
    nombre: 'Prueba',
    correo: 'prueba@lasirena.com',
    numeroDocumento: '123',
    tipoDocumento: 'CC',
    telefono: '3000000000',
    rol: rol,
    esSuperAdmin: superAdmin,
    permisos: permisos,
    roles: const [],
  );
}

Permiso _ver(String modulo, String nombre) =>
    Permiso(modulo: modulo, nombre: nombre, privilegios: const ['Ver']);

void main() {
  test('empleado con solo Ventas › Ventas › Ver: Ventas e Indicadores', () {
    final modulos = modulosMoviles(
      _usuario(permisos: [_ver('Ventas', 'Ventas')]),
    );
    expect(modulos, [ModuloMovil.ventas, ModuloMovil.indicadores]);
  });

  test('empleado con Insumos y Orden de Producción: Compras y Producción', () {
    final modulos = modulosMoviles(
      _usuario(
        permisos: [
          _ver('Compras', 'Insumos'),
          _ver('Producción', 'Orden de Producción'),
        ],
      ),
    );
    expect(modulos, [ModuloMovil.compras, ModuloMovil.produccion]);
  });

  test('usuario sin permisos: ningún módulo', () {
    expect(modulosMoviles(_usuario()), isEmpty);
    expect(modulosMoviles(null), isEmpty);
  });

  test(
    'el rol no decide: admin y empleado con iguales permisos ven lo mismo',
    () {
      final permisos = [_ver('Compras', 'Proveedores')];
      expect(
        modulosMoviles(_usuario(rol: 'Administrador', permisos: permisos)),
        modulosMoviles(_usuario(rol: 'Empleado', permisos: permisos)),
      );
    },
  );

  test('permisos fuera de la ficha no abren ningún módulo', () {
    final modulos = modulosMoviles(
      _usuario(
        permisos: [
          _ver('Producción', 'Categoría de Producto'),
          _ver('Producción', 'Empleados'),
          _ver('Compras', 'Orden de Compra'),
          _ver('Ventas', 'Devoluciones'),
          _ver('Configuración', 'Roles'),
          _ver('Configuración', 'Usuarios'),
        ],
      ),
    );
    expect(modulos, isEmpty);
  });

  test('Producto No Conforme solo habilita Indicadores', () {
    final modulos = modulosMoviles(
      _usuario(permisos: [_ver('Producción', 'Producto No Conforme')]),
    );
    expect(modulos, [ModuloMovil.indicadores]);
  });

  test('privilegio distinto de Ver no habilita el módulo', () {
    final modulos = modulosMoviles(
      _usuario(
        permisos: const [
          Permiso(modulo: 'Ventas', nombre: 'Ventas', privilegios: ['Editar']),
        ],
      ),
    );
    expect(modulos, isEmpty);
  });

  test('super administrador ve todos los módulos', () {
    expect(modulosMoviles(_usuario(superAdmin: true)), ModuloMovil.values);
  });
}
