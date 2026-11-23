import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/admin/services/producto_edicion.dart';

const _lasana = ProductoOriginal(
  tipo: 'Elaborado',
  esPizza: false,
  idCategoria: 3,
  nombre: 'Lasaña de carne',
  unidadVenta: 'und',
  imagen: 'https://ejemplo/foto.png',
  precio: 35000,
);

const _pizzaSinPrecio = ProductoOriginal(
  tipo: 'Elaborado',
  esPizza: true,
  idCategoria: 1,
  nombre: 'Pizza hawaiana',
  unidadVenta: 'porción',
  imagen: '',
);

const _gaseosa = ProductoOriginal(
  tipo: 'Reventa',
  esPizza: false,
  idCategoria: 5,
  nombre: 'Gaseosa',
  unidadVenta: 'und',
  imagen: '',
  precio: 5000,
  contenido: 350,
  contenidoUnidad: 'ml',
  unidadCompra: 'paca',
  unidadesPorEmpaque: 6,
);

String _t(double? v) => textoInicialNumero(v);

EdicionProducto _editar(
  ProductoOriginal o, {
  String? idCategoria,
  String? nombre,
  String? unidadVenta,
  String? imagen,
  String? precio,
  String? precioGrande,
  String? contenido,
  String? contenidoUnidad,
  String? unidadCompra,
  String? unidadesPorEmpaque,
}) {
  return construirEdicionProducto(
    original: o,
    idCategoria: idCategoria ?? '${o.idCategoria}',
    nombre: nombre ?? o.nombre,
    unidadVenta: unidadVenta ?? o.unidadVenta,
    imagen: imagen ?? o.imagen,
    precio: precio ?? ((o.precio ?? 0) > 0 ? _t(o.precio) : ''),
    precioGrande: precioGrande ?? _t(o.precioGrande),
    contenido: contenido ?? _t(o.contenido),
    contenidoUnidad: contenidoUnidad ?? o.contenidoUnidad,
    unidadCompra: unidadCompra ?? o.unidadCompra,
    unidadesPorEmpaque: unidadesPorEmpaque ?? '${o.unidadesPorEmpaque ?? ''}',
  );
}

void main() {
  test('números con separador de miles no se leen como decimales', () {
    expect(parsearNumeroUsuario('35.000'), 35000);
    expect(parsearNumeroUsuario('35,000'), 35000);
    expect(parsearNumeroUsuario('1.250.000'), 1250000);
    expect(parsearNumeroUsuario('\$ 35.000'), 35000);
    expect(parsearNumeroUsuario('35.000,50'), 35000.5);
    expect(parsearNumeroUsuario('35,000.50'), 35000.5);
    expect(parsearNumeroUsuario('12,5'), 12.5);
    expect(parsearNumeroUsuario('1.5'), 1.5);
    expect(parsearNumeroUsuario('abc'), isNull);
    expect(parsearNumeroUsuario(''), isNull);
  });

  test('editar solo el nombre envía solo nombre (sin imagen ni precio)', () {
    final r = _editar(_lasana, nombre: 'Lasaña   de  carne  especial ');
    expect(r.valido, isTrue);
    expect(r.cuerpo, {'nombre': 'Lasaña de carne especial'});
  });

  test('sin cambios no se envía nada', () {
    final r = _editar(_lasana);
    expect(r.valido, isFalse);
    expect(r.errores, contains('_general'));
  });

  test('imagen cambiada se envía; vaciarla envía cadena vacía', () {
    expect(
      _editar(_lasana, imagen: 'https://ejemplo/nueva.png').cuerpo['imagen'],
      'https://ejemplo/nueva.png',
    );
    expect(_editar(_lasana, imagen: '').cuerpo['imagen'], '');
  });

  test('nombre de 2 a 100 caracteres', () {
    expect(_editar(_lasana, nombre: ' a ').errores, contains('nombre'));
    expect(_editar(_lasana, nombre: 'x' * 101).errores, contains('nombre'));
    expect(_editar(_lasana, nombre: 'ab').valido, isTrue);
  });

  test('unidad de venta obligatoria y de máximo 20', () {
    expect(_editar(_lasana, unidadVenta: '').errores, contains('unidad_venta'));
    expect(
      _editar(_lasana, unidadVenta: 'x' * 21).errores,
      contains('unidad_venta'),
    );
  });

  test('pizza sin precio: editar el nombre no exige precio', () {
    final r = _editar(_pizzaSinPrecio, nombre: 'Pizza hawaiana especial');
    expect(r.valido, isTrue);
    expect(r.cuerpo.containsKey('precio_venta'), isFalse);
  });

  test('pizza: al fijar precios se exigen ambos y Grande > Mediana', () {
    expect(
      _editar(_pizzaSinPrecio, precio: '30.000').errores,
      contains('precio_grande'),
    );
    expect(
      _editar(
        _pizzaSinPrecio,
        precio: '30.000',
        precioGrande: '30.000',
      ).errores,
      contains('precio_grande'),
    );
    final ok = _editar(
      _pizzaSinPrecio,
      precio: '30.000',
      precioGrande: '45,000',
    );
    expect(ok.valido, isTrue);
    expect(ok.cuerpo, {'precio_venta': 30000, 'precio_grande': 45000});
  });

  test('Elaborado: precio cambiado debe ser mayor que 0', () {
    expect(_editar(_lasana, precio: '0').errores, contains('precio_venta'));
    expect(_editar(_lasana, precio: 'abc').errores, contains('precio_venta'));
    expect(_editar(_lasana, precio: '').errores, contains('precio_venta'));
    expect(_editar(_lasana, precio: '38.000').cuerpo, {'precio_venta': 38000});
  });

  test('Reventa: no envía precio ni unidad de venta', () {
    final r = _editar(_gaseosa, nombre: 'Gaseosa 350');
    expect(r.cuerpo, {'nombre': 'Gaseosa 350'});
  });

  test('Reventa: unidades de compra y empaque', () {
    expect(
      _editar(_gaseosa, unidadesPorEmpaque: '1').errores,
      contains('unidades_por_empaque'),
    );
    expect(_editar(_gaseosa, unidadesPorEmpaque: '12').cuerpo, {
      'unidades_por_empaque': 12,
    });
    expect(
      _editar(_gaseosa, unidadCompra: 'caja', unidadesPorEmpaque: '24').cuerpo,
      {'unidad_compra': 'caja', 'unidades_por_empaque': 24},
    );
    expect(_editar(_gaseosa, unidadCompra: 'und').cuerpo, {
      'unidad_compra': 'und',
    });
    expect(
      _editar(_gaseosa, contenidoUnidad: 'l').errores,
      contains('contenido_unidad'),
    );
    expect(
      _editar(_gaseosa, unidadCompra: 'bolsa').errores,
      contains('unidad_compra'),
    );
    expect(_editar(_gaseosa, contenido: '0').errores, contains('contenido'));
  });

  test('con errores no se arma cuerpo', () {
    final r = _editar(_lasana, nombre: '');
    expect(r.valido, isFalse);
    expect(r.cuerpo, isEmpty);
  });
}
