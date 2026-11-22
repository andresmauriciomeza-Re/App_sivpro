import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/admin/services/clients_repository.dart';
import 'package:sivpro_app/admin/services/ventas_repository.dart';
import 'package:sivpro_app/auth/auth_service.dart';
import 'package:sivpro_app/shared/permission_helper.dart';

Usuario usuario({
  bool superAdmin = false,
  List<Permiso> permisos = const [],
}) {
  return Usuario(
    id: 1,
    nombre: 'Empleado',
    correo: 'empleado@sivpro.test',
    numeroDocumento: '123',
    tipoDocumento: 'CC',
    telefono: '3000000000',
    rol: 'Empleado',
    esSuperAdmin: superAdmin,
    permisos: permisos,
    roles: const [],
  );
}

void main() {
  test('Venta.fromJson lee campos, estado y pagos reales', () {
    final venta = Venta.fromJson({
      'id_venta': 7,
      'id_cliente': 3,
      'id_usuario': '10203040',
      'tipo_documento': 'CC',
      'cliente_nombre': 'Ana Rodríguez',
      'correo': 'ana@example.com',
      'telefono': '3001234567',
      'fecha': '2026-11-21T18:30:00',
      'hora_recogida': '19:00',
      'monto': 45000,
      'estado': 'Devolucion',
      'fecha_estado_local': '2026-11-21T18:40:00',
      'venta_local': true,
      'estado_orden': 'Completada',
      'segundos_restantes_anulacion': 120,
      'motivo_rechazo': 'Comprobante borroso',
      'anulado_por': 'Empleado',
      'monto_reembolso': 45000,
      'devolucion_estado': 'Aprobada',
      'detalles': [
        {
          'id_detalle_venta': 11,
          'id_producto': 2,
          'nombre': 'Pizza Hawaiana',
          'cantidad': 2,
          'precio_unitario': 22500,
          'sub_total': 45000,
          'tamano': 'Grande',
        },
      ],
      'pagos': [
        {
          'id_pago': 9,
          'tipo': 'Nequi',
          'fecha': '2026-11-21T18:31:00',
          'estado': 'Confirmado',
          'tiene_comprobante': true,
          'cantidad_pagar': 45000,
          'depositado': 45000,
          'faltante': 0,
          'comprobante': 'https://example.com/comprobante.png',
        },
      ],
    });

    expect(venta.id, 7);
    expect(venta.codigo, 'VEN-007');
    expect(venta.clienteNombre, 'Ana Rodríguez');
    expect(venta.documento, '10203040');
    expect(venta.estado, EstadoVenta.devolucion);
    expect(venta.estadoLabel, 'Devolución');
    expect(venta.ventaLocal, isTrue);
    expect(venta.segundosRestantesAnulacion, 120);
    expect(venta.motivoRechazo, 'Comprobante borroso');
    expect(venta.anuladoPor, 'Empleado');
    expect(venta.montoReembolso, 45000);
    expect(venta.devolucionEstado, 'Aprobada');

    expect(venta.detalles.single.nombre, 'Pizza Hawaiana');
    expect(venta.detalles.single.tamano, 'Grande');
    expect(venta.detalles.single.cantidad, 2);

    final pago = venta.pagos.single;
    expect(pago.id, 9);
    expect(pago.tipo, 'Nequi');
    expect(pago.tieneComprobante, isTrue);
    expect(pago.cantidadPagar, 45000);
    expect(pago.depositado, 45000);
    expect(pago.faltante, 0);
    expect(pago.comprobante, 'https://example.com/comprobante.png');
  });

  test('EstadoVenta.desde tolera tildes y mayúsculas', () {
    expect(EstadoVenta.desde('devolución'), EstadoVenta.devolucion);
    expect(EstadoVenta.desde('POR ENTREGAR'), EstadoVenta.porEntregar);
    expect(EstadoVenta.desde('otro'), isNull);
  });

  test('ResumenPagos.fromJson distingue confirmado, pendiente y rechazado', () {
    final resumen = ResumenPagos.fromJson({
      'total': 100000,
      'recibido': 60000,
      'en_revision': 20000,
      'falta': 20000,
      'saldo_a_favor': 0,
      'pagos': [
        {
          'id_pago': 1,
          'tipo': 'Nequi',
          'estado': 'Confirmado',
          'monto_declarado': 60000,
          'monto_confirmado': 60000,
        },
        {
          'id_pago': 2,
          'tipo': 'Efectivo',
          'estado': 'Por verificar',
          'monto_declarado': 20000,
        },
        {
          'id_pago': 3,
          'tipo': 'Transferencia',
          'estado': 'Rechazado',
          'monto_declarado': 20000,
        },
      ],
    });

    expect(resumen.total, 100000);
    expect(resumen.recibido, 60000);
    expect(resumen.enRevision, 20000);
    expect(resumen.falta, 20000);
    expect(resumen.saldoAFavor, 0);

    final confirmado = resumen.pagos[0];
    expect(confirmado.id, 1);
    expect(confirmado.montoDeclarado, 60000);
    expect(confirmado.montoConfirmado, 60000);
    expect(confirmado.confirmado, isTrue);
    expect(confirmado.pendienteDeConfirmar, isFalse);

    final pendiente = resumen.pagos[1];
    expect(pendiente.montoConfirmado, isNull);
    expect(pendiente.pendienteDeConfirmar, isTrue);

    final rechazado = resumen.pagos[2];
    expect(rechazado.rechazado, isTrue);
    expect(rechazado.pendienteDeConfirmar, isFalse);
  });

  test('Cliente.fromJson usa los campos reales y calcula activo', () {
    final activo = Cliente.fromJson({
      'id_cliente': 3,
      'id_usuario': '1234567',
      'tipo_documento': 'CC',
      'nombre': 'Ana Rodríguez',
      'correo': 'ana@example.com',
      'telefono': '3001234567',
      'cliente_estado': true,
      'usuario_estado': true,
      'pedidos': 4,
    });

    expect(activo.id, 3);
    expect(activo.codigo, 'CLI-003');
    expect(activo.nombre, 'Ana Rodríguez');
    expect(activo.documento, 'CC 1234567');
    expect(activo.correo, 'ana@example.com');
    expect(activo.telefono, '3001234567');
    expect(activo.pedidos, 4);
    expect(activo.activo, isTrue);

    final inactivo = Cliente.fromJson({
      'id_cliente': 4,
      'nombre': 'Jorge Vargas',
      'cliente_estado': true,
      'usuario_estado': false,
    });
    expect(inactivo.activo, isFalse);
    expect(inactivo.pedidos, 0);
  });

  test('tienePermiso exige módulo, nombre y privilegio', () {
    final conPermiso = usuario(
      permisos: const [
        Permiso(
          modulo: 'Ventas',
          nombre: 'Ventas',
          privilegios: ['Ver', 'Editar'],
        ),
      ],
    );

    expect(tienePermiso(null, 'Ventas', 'Ventas', 'Ver'), isFalse);
    expect(tienePermiso(conPermiso, 'Ventas', 'Ventas', 'Ver'), isTrue);
    expect(tienePermiso(conPermiso, 'Ventas', 'Ventas', 'editar'), isTrue);
    expect(tienePermiso(conPermiso, 'Ventas', 'Ventas', 'Eliminar'), isFalse);
    expect(tienePermiso(conPermiso, 'Ventas', 'Clientes', 'Ver'), isFalse);
    expect(tienePermiso(conPermiso, 'Compras', 'Ventas', 'Ver'), isFalse);
  });

  test('tienePermiso acepta super administrador sin permisos', () {
    final superAdmin = usuario(superAdmin: true);
    expect(tienePermiso(superAdmin, 'Ventas', 'Ventas', 'Editar'), isTrue);
    expect(tienePermiso(superAdmin, 'Cualquiera', 'Cosa', 'Ver'), isTrue);
  });
}
