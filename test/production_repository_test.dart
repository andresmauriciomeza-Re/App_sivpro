import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/admin/services/production_repository.dart';

Map<String, dynamic> orden(int id, {String tipo = 'Pedido', String estado = 'Pendiente'}) {
  return {
    'id_orden_produccion': id,
    'tipo': tipo,
    'estado': estado,
    'fecha_solicitada': '2026-11-20',
    'hora_solicitada': 830, // tipo inesperado: no debe romper el parseo
    'observacion': null,
    'lineas': <Object?>[],
  };
}

void main() {
  test('un estado o tipo desconocido no invalida la orden', () {
    final rara = OrdenProduccion.fromJson(
      orden(1, tipo: 'Mixta', estado: 'En revisión'),
    );
    expect(rara.tipo, 'Mixta');
    expect(rara.estado, 'En revisión');
    expect(rara.tipoLabel, 'Mixta');
  });

  test('campos opcionales con tipo inesperado no lanzan TypeError', () {
    final o = OrdenProduccion.fromJson(orden(2));
    expect(o.horaSolicitada, '830');
    expect(o.observacion, isNull);
  });

  test('sigue exigiendo los campos obligatorios', () {
    final sinId = orden(3)..remove('id_orden_produccion');
    expect(() => OrdenProduccion.fromJson(sinId), throwsA(anything));
  });
}
