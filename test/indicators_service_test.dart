import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/admin/services/indicators_service.dart';
import 'package:sivpro_app/admin/services/no_conformes_repository.dart';
import 'package:sivpro_app/admin/services/production_repository.dart';
import 'package:sivpro_app/admin/services/production_summary_service.dart';
import 'package:sivpro_app/admin/services/ventas_repository.dart';

Venta venta({
  required int id,
  required String estado,
  required double monto,
  String documento = '1',
  String nombre = 'Ana',
  String? fechaEstadoLocal,
  String? fecha,
  Object? idDevolucion,
  String? devolucionFecha,
  List<Map<String, Object?>> detalles = const [],
}) {
  return Venta.fromJson({
    'id_venta': id,
    'id_usuario': documento,
    'cliente_nombre': nombre,
    'monto': monto,
    'estado': estado,
    'fecha': fecha ?? '2026-11-01T10:00:00.000000',
    'fecha_estado_local': fechaEstadoLocal,
    'id_devolucion': idDevolucion,
    'devolucion_fecha': devolucionFecha,
    'detalles': detalles,
  });
}

void main() {
  test('semana del mes: 1-7, 8-14, 15-21, 22-28 y 29 en adelante', () {
    expect(
      [1, 7, 8, 14, 15, 21, 22, 28, 29, 31].map(semanaDelMes),
      [1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
    );
  });

  test('hora de Bogotá es UTC-5', () {
    final f = ahoraBogota(DateTime.utc(2026, 11, 20, 3, 0));
    expect([f.year, f.month, f.day, f.hour], [2026, 11, 19, 22]);
    expect(
      fechaLargaBogota(DateTime.utc(2026, 11, 20, 15, 0)),
      'viernes 20 de noviembre de 2026',
    );
  });

  test('solo cuentan ventas completadas y se usa fecha_estado_local', () {
    final ventas = [
      venta(
        id: 1,
        estado: 'Completado',
        monto: 100,
        fechaEstadoLocal: '2026-11-05T09:00:00',
        fecha: '2026-10-31T23:00:00',
      ),
      venta(id: 2, estado: 'Anulado', monto: 999),
      venta(id: 3, estado: 'Devolucion', monto: 999),
      venta(id: 4, estado: 'Por entregar', monto: 999),
      venta(id: 5, estado: 'Completado', monto: 50, fecha: '2026-11-06T08:00:00'),
    ];
    final completadas = ventasCompletadas(ventas);
    expect(completadas.map((v) => v.id), [1, 5]);
    expect(ventasDelMes(completadas, 2026, 11).length, 2);
    expect(ventasDelMes(completadas, 2026, 10), isEmpty);
  });

  test('devoluciones del mes: por fecha de la devolución, sin convertir '
      'zonas, de la más reciente a la más antigua', () {
    final ventas = <Venta>[
      // Sin devolución: no cuenta.
      venta(id: 1, estado: 'Completado', monto: 1000),
      // Fecha de la devolución en noviembre aunque la venta sea de octubre.
      venta(
        id: 2,
        estado: 'Devolucion',
        monto: 1000,
        fecha: '2026-10-28T12:00:00.000000',
        idDevolucion: 5,
        devolucionFecha: '2026-11-03T09:00:00.000000',
      ),
      // Sin fecha de devolución: cae a la de la venta.
      venta(
        id: 3,
        estado: 'Completado',
        monto: 1000,
        fecha: '2026-11-15T18:00:00.000000',
        idDevolucion: '6',
      ),
      // Último día de octubre a las 23:59: cuenta en octubre.
      venta(
        id: 4,
        estado: 'Devolucion',
        monto: 1000,
        idDevolucion: 7,
        devolucionFecha: '2026-10-31T23:59:59.000000',
      ),
    ];
    expect(devolucionesDelMes(ventas, 2026, 11).map((v) => v.id), [3, 2]);
    expect(devolucionesDelMes(ventas, 2026, 10).map((v) => v.id), [4]);
    expect(devolucionesDelMes(ventas, 2026, 9), isEmpty);
  });

  test('cantidad de productos: suma de las cantidades (como la web)', () {
    final conLineas = venta(
      id: 1,
      estado: 'Devolucion',
      monto: 1000,
      detalles: [
        {'nombre': 'Pizza', 'cantidad': '3', 'tamano': 'Mediana'},
        {'nombre': 'Gaseosa', 'cantidad': 2, 'tamano': null},
        {'nombre': 'Rota', 'cantidad': null},
      ],
    );
    expect(cantidadProductos(conLineas), 5);
    expect(cantidadProductos(venta(id: 2, estado: 'Devolucion', monto: 0)), 0);
  });

  test('top productos suma tamaños aparte y ordena por total', () {
    final ventas = [
      venta(
        id: 1,
        estado: 'Completado',
        monto: 1,
        detalles: [
          {'nombre': 'Pizza', 'cantidad': 2, 'tamano': 'Mediana'},
          {'nombre': 'Pizza', 'cantidad': 1, 'tamano': 'Grande'},
          {'nombre': 'Gaseosa', 'cantidad': 3},
        ],
      ),
      venta(
        id: 2,
        estado: 'Completado',
        monto: 1,
        detalles: [
          {'nombre': 'Pizza', 'cantidad': 1},
        ],
      ),
    ];
    final top = topProductos(ventas);
    expect(top.first.nombre, 'Pizza');
    expect(top.first.total, 4);
    expect(top.first.medianas, 2);
    expect(top.first.grandes, 1);
    expect(top.first.unidades, 1);
    expect(top[1].nombre, 'Gaseosa');
  });

  test('ventas por día, mes y año', () {
    final completadas = ventasCompletadas([
      venta(id: 1, estado: 'Completado', monto: 100, fechaEstadoLocal: '2026-11-05T09:00:00'),
      venta(id: 2, estado: 'Completado', monto: 50, fechaEstadoLocal: '2026-11-05T18:00:00'),
      venta(id: 3, estado: 'Completado', monto: 70, fechaEstadoLocal: '2026-03-02T18:00:00'),
      venta(id: 4, estado: 'Completado', monto: 10, fechaEstadoLocal: '2025-12-31T23:59:00'),
    ]);
    final dias = ventasPorDia(completadas, 2026, 11);
    expect(dias.length, 1);
    expect(dias.first.monto, 150);
    expect(dias.first.cantidad, 2);

    final meses = ventasPorMes(completadas, 2026);
    expect(meses.length, 12);
    expect(meses[10].monto, 150);
    expect(meses[2].monto, 70);

    final anios = ventasPorAnio(completadas);
    expect(anios.map((p) => p.etiqueta), ['2025', '2026']);
    expect(anios.last.monto, 220);
  });

  test('no conformes por semana y tipo', () {
    final registros = [
      ProductoNoConforme.fromJson({
        'fecha_registro': '2026-11-01',
        'tipo_no_conformidad': 'Quemado',
        'cantidad_afectada': 2,
      }),
      ProductoNoConforme.fromJson({
        'fecha_registro': '2026-11-07',
        'tipo_no_conformidad': 'Quemado',
        'cantidad_afectada': '1',
      }),
      ProductoNoConforme.fromJson({
        'fecha_registro': '2026-11-29',
        'tipo_no_conformidad': 'Crudo',
        'cantidad_afectada': 4,
      }),
      ProductoNoConforme.fromJson({
        'fecha_registro': '2026-10-29',
        'tipo_no_conformidad': 'Crudo',
        'cantidad_afectada': 9,
      }),
    ];
    final semanas = noConformesPorSemana(registros, 2026, 11);
    expect(semanas.map((s) => s.registros), [2, 0, 0, 0, 1]);
    expect(semanas[0].porTipo, {'Quemado': 2});
    expect(semanas[0].unidadesAfectadas, 3);
    expect(semanas[4].porTipo, {'Crudo': 1});
  });

  test('resumen de producción: activas y completadas hoy', () {
    OrdenProduccion orden(String estado, {String? completada}) {
      return OrdenProduccion.fromJson({
        'id_orden_produccion': 1,
        'tipo': 'Pedido',
        'estado': estado,
        'fecha_solicitada': '2026-11-20',
        'fecha_completada': completada,
        'lineas': <Object?>[],
      });
    }

    final resumen = ProductionSummary.desde(
      [
        orden('Pendiente'),
        orden('En proceso'),
        orden('Completada', completada: '2026-11-20T08:00:00'),
        orden('Completada', completada: '2026-11-19T08:00:00'),
        orden('Cancelada'),
      ],
      ahora: DateTime.utc(2026, 11, 20, 15, 0),
    );
    expect(resumen.ordenesActivas, 2);
    expect(resumen.completadasHoy, 1);
  });
}
