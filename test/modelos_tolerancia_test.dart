import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/admin/services/products_repository.dart';
import 'package:sivpro_app/admin/services/ventas_repository.dart';
import 'package:sivpro_app/auth/models/usuario.dart';
import 'package:sivpro_app/shared/formato.dart';
import 'package:sivpro_app/shared/venta_motivos.dart';

Map<String, dynamic> _producto(int id, {Object? imagen = 'foto.png'}) => {
  'id_producto': id,
  'id_categoria': 2,
  'nombre': 'Pizza $id',
  'tipo': 'Elaborado',
  'precio_venta': '28000.00',
  'unidad_venta': 'und',
  'estado': 'Disponible',
  'imagen': imagen,
};

void main() {
  test('Usuario.fromJson tolera tipos inesperados sin TypeError', () {
    final usuario = Usuario.fromJson({
      'id': '7',
      'nombre': 123,
      'correo': null,
      'rol': 45,
      'telefono': 3001234567,
      'permisos': [
        {
          'modulo': 1,
          'nombre': true,
          'privilegios': ['Ver'],
        },
      ],
      'roles': [
        {'id': 2, 'nombre': 99, 'permisos': []},
      ],
    });
    expect(usuario.id, 7);
    expect(usuario.nombre, '123');
    expect(usuario.correo, '');
    expect(usuario.rol, '45');
    expect(usuario.telefono, '3001234567');
    expect(usuario.permisos.single.modulo, '1');
    expect(usuario.roles.single.nombre, '99');
    expect(usuario.userRole, isNull);
  });

  test('Usuario.fromJson sigue reconociendo los roles', () {
    expect(Usuario.fromJson({'rol': 'Administrador'}).userRole, UserRole.admin);
    expect(Usuario.fromJson({'rol': 'empleado'}).userRole, UserRole.empleado);
  });

  test('un producto inválido se omite y no tumba la lista', () {
    final productos = productosGestionDesde([
      _producto(1),
      {'id_producto': 2}, // le faltan obligatorios
      'basura',
      _producto(3, imagen: {'url': 'x'}), // tipo inesperado en imagen
    ]);
    expect(productos.map((p) => p.idProducto), [1, 3]);
    expect(productos.first.precioVenta, 28000);
  });

  test('formatCop agrupa miles sin punto inicial', () {
    expect(formatCop(56000), r'$56.000');
    expect(formatCop(100000), r'$100.000');
    expect(formatCop(999), r'$999');
    expect(formatCop(-1500), r'$-1.500');
  });

  test('motivos y anulación de ventas', () {
    expect(
      motivoVentaParaEnviar('Otro', '  cliente se fue '),
      'Otro: cliente se fue',
    );
    expect(
      motivoVentaParaEnviar('Producto no disponible', 'x'),
      'Producto no disponible',
    );
    expect(ventaAnulable(EstadoVenta.porVerificar, 30), isTrue);
    expect(ventaAnulable(EstadoVenta.enEspera, 30), isTrue);
    expect(ventaAnulable(EstadoVenta.porEntregar, 30), isTrue);
    expect(ventaAnulable(EstadoVenta.porEntregar, 0), isFalse);
    expect(ventaAnulable(EstadoVenta.completado, 30), isFalse);
    expect(ventaAnulable(EstadoVenta.devolucion, 30), isFalse);
  });

  test('Devolucion sigue siendo un estado de venta de solo lectura', () {
    expect(EstadoVenta.desde('Devolucion'), EstadoVenta.devolucion);
    expect(EstadoVenta.devolucion.label, 'Devolución');
  });
}
