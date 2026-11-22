import 'no_conformes_repository.dart';
import 'ventas_repository.dart';

/// Cálculo de los indicadores del admin. Todo son funciones puras sobre las
/// listas que ya devuelve el backend (no existen endpoints de indicadores).
///
/// Reglas (las mismas de la web):
/// - Solo cuentan las ventas "Completado".
/// - La fecha de una venta es la parte AAAA-MM-DD de `fecha_estado_local`; si
///   no existe, la de `fecha`. Las fechas ya están en hora de Colombia y no se
///   convierten.
/// - Semana del mes: S1 = días 1-7, S2 = 8-14, S3 = 15-21, S4 = 22-28,
///   S5 = 29 en adelante.

// ---------------------------------------------------------------------------
// Fechas
// ---------------------------------------------------------------------------

/// Momento actual en hora de Bogotá (UTC-5, sin horario de verano). Los campos
/// del resultado (año, mes, día…) ya son los de Colombia.
DateTime ahoraBogota([DateTime? ahora]) {
  return (ahora ?? DateTime.now()).toUtc().subtract(const Duration(hours: 5));
}

const List<String> nombresMes = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const List<String> _nombresDia = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// Día de hoy en Bogotá como 'AAAA-MM-DD'.
String diaBogotaTexto([DateTime? ahora]) {
  final f = ahoraBogota(ahora);
  return '${f.year.toString().padLeft(4, '0')}-'
      '${f.month.toString().padLeft(2, '0')}-'
      '${f.day.toString().padLeft(2, '0')}';
}

/// "viernes 20 de noviembre de 2026" (hora de Bogotá).
String fechaLargaBogota([DateTime? ahora]) {
  final f = ahoraBogota(ahora);
  return '${_nombresDia[f.weekday - 1]} ${f.day} de '
      '${nombresMes[f.month - 1]} de ${f.year}';
}

/// Parte AAAA-MM-DD de un texto de fecha. Si trae zona (Z o ±hh:mm) se
/// convierte a hora de Bogotá; si no trae zona, se usa tal cual.
String? diaDeTexto(String? texto) {
  if (texto == null) return null;
  final valor = texto.trim();
  if (valor.length < 10) return null;
  final tieneZona = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(valor) &&
      valor.contains(RegExp(r'[T ]\d{2}:'));
  if (tieneZona) {
    final parsed = DateTime.tryParse(valor);
    if (parsed != null) {
      final b = ahoraBogota(parsed);
      return '${b.year.toString().padLeft(4, '0')}-'
          '${b.month.toString().padLeft(2, '0')}-'
          '${b.day.toString().padLeft(2, '0')}';
    }
  }
  final dia = valor.substring(0, 10);
  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dia) ? dia : null;
}

/// Semana del mes (1 a 5) para un día del mes.
int semanaDelMes(int dia) {
  if (dia <= 7) return 1;
  if (dia <= 14) return 2;
  if (dia <= 21) return 3;
  if (dia <= 28) return 4;
  return 5;
}

class _Dia {
  const _Dia(this.anio, this.mes, this.dia);
  final int anio;
  final int mes;
  final int dia;
}

_Dia? _parseDia(String? texto) {
  final dia = diaDeTexto(texto);
  if (dia == null) return null;
  final partes = dia.split('-');
  final anio = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final d = int.tryParse(partes[2]);
  if (anio == null || mes == null || d == null) return null;
  return _Dia(anio, mes, d);
}

// ---------------------------------------------------------------------------
// Ventas completadas
// ---------------------------------------------------------------------------

/// Fecha (AAAA-MM-DD) que se usa para ubicar una venta en un periodo.
String? fechaDeVenta(Venta venta) =>
    diaDeTexto(venta.fechaEstadoLocal) ?? diaDeTexto(venta.fecha);

/// Solo las ventas en estado "Completado" que tienen una fecha válida.
List<Venta> ventasCompletadas(List<Venta> ventas) => ventas
    .where(
      (v) => v.estado == EstadoVenta.completado && fechaDeVenta(v) != null,
    )
    .toList(growable: false);

List<Venta> ventasDelMes(List<Venta> completadas, int anio, int mes) {
  return completadas.where((v) {
    final d = _parseDia(fechaDeVenta(v));
    return d != null && d.anio == anio && d.mes == mes;
  }).toList(growable: false);
}

// ---------------------------------------------------------------------------
// 1. Clientes
// ---------------------------------------------------------------------------

class TopCliente {
  const TopCliente({
    required this.id,
    required this.nombre,
    required this.pedidos,
    required this.valor,
  });

  final String id;
  final String nombre;
  final int pedidos;
  final double valor;
}

/// Unión del top 10 por pedidos y el top 10 por valor, ordenada por pedidos
/// (y por valor en empates). [ventas] deben ser completadas del periodo.
List<TopCliente> topClientes(List<Venta> ventas, {int limite = 10}) {
  final acumulado = <String, _AcumCliente>{};
  for (final venta in ventas) {
    final clave = venta.documento ?? 'cliente-${venta.idCliente ?? venta.id}';
    final item = acumulado.putIfAbsent(
      clave,
      () => _AcumCliente(clave, venta.clienteNombre),
    );
    item.pedidos += 1;
    item.valor += venta.monto;
  }
  final todos = acumulado.values.toList();

  int porPedidos(_AcumCliente a, _AcumCliente b) {
    final c = b.pedidos.compareTo(a.pedidos);
    return c != 0 ? c : b.valor.compareTo(a.valor);
  }

  int porValor(_AcumCliente a, _AcumCliente b) {
    final c = b.valor.compareTo(a.valor);
    return c != 0 ? c : b.pedidos.compareTo(a.pedidos);
  }

  final topPedidos = ([...todos]..sort(porPedidos)).take(limite);
  final topValor = ([...todos]..sort(porValor)).take(limite);
  final union = <String, _AcumCliente>{
    for (final c in topPedidos) c.id: c,
    for (final c in topValor) c.id: c,
  }.values.toList()..sort(porPedidos);

  return union
      .map(
        (c) => TopCliente(
          id: c.id,
          nombre: c.nombre,
          pedidos: c.pedidos,
          valor: c.valor,
        ),
      )
      .toList(growable: false);
}

class _AcumCliente {
  _AcumCliente(this.id, this.nombre);
  final String id;
  final String nombre;
  int pedidos = 0;
  double valor = 0;
}

// ---------------------------------------------------------------------------
// 2. Productos
// ---------------------------------------------------------------------------

class TopProducto {
  const TopProducto({
    required this.nombre,
    required this.unidades,
    required this.medianas,
    required this.grandes,
  });

  final String nombre;

  /// Unidades vendidas sin tamaño (o con otro tamaño).
  final double unidades;

  /// Porciones de tamaño "Mediana".
  final double medianas;

  /// Porciones de tamaño "Grande".
  final double grandes;

  double get total => unidades + medianas + grandes;
}

/// Top 10 de productos por cantidad total vendida. [ventas] deben ser
/// completadas del periodo.
List<TopProducto> topProductos(List<Venta> ventas, {int limite = 10}) {
  final acumulado = <String, List<double>>{}; // [unidades, medianas, grandes]
  for (final venta in ventas) {
    for (final linea in venta.detalles) {
      final valores = acumulado.putIfAbsent(linea.nombre, () => [0, 0, 0]);
      final tamano = (linea.tamano ?? '').trim().toLowerCase();
      if (tamano == 'mediana') {
        valores[1] += linea.cantidad;
      } else if (tamano == 'grande') {
        valores[2] += linea.cantidad;
      } else {
        valores[0] += linea.cantidad;
      }
    }
  }
  final lista =
      acumulado.entries
          .map(
            (e) => TopProducto(
              nombre: e.key,
              unidades: e.value[0],
              medianas: e.value[1],
              grandes: e.value[2],
            ),
          )
          .toList()
        ..sort((a, b) {
          final c = b.total.compareTo(a.total);
          return c != 0 ? c : a.nombre.compareTo(b.nombre);
        });
  return lista.take(limite).toList(growable: false);
}

// ---------------------------------------------------------------------------
// 3. Ventas por periodo
// ---------------------------------------------------------------------------

class PuntoVentas {
  const PuntoVentas({
    required this.etiqueta,
    required this.monto,
    required this.cantidad,
  });

  final String etiqueta;
  final double monto;
  final int cantidad;
}

/// Total vendido por día del mes (solo los días con ventas).
List<PuntoVentas> ventasPorDia(List<Venta> completadas, int anio, int mes) {
  final montos = <int, double>{};
  final cantidades = <int, int>{};
  for (final venta in ventasDelMes(completadas, anio, mes)) {
    final d = _parseDia(fechaDeVenta(venta))!;
    montos[d.dia] = (montos[d.dia] ?? 0) + venta.monto;
    cantidades[d.dia] = (cantidades[d.dia] ?? 0) + 1;
  }
  final dias = montos.keys.toList()..sort();
  return [
    for (final dia in dias)
      PuntoVentas(
        etiqueta: '$dia de ${nombresMes[mes - 1]}',
        monto: montos[dia]!,
        cantidad: cantidades[dia]!,
      ),
  ];
}

/// Total vendido por cada mes del año (los 12 meses).
List<PuntoVentas> ventasPorMes(List<Venta> completadas, int anio) {
  final montos = List<double>.filled(12, 0);
  final cantidades = List<int>.filled(12, 0);
  for (final venta in completadas) {
    final d = _parseDia(fechaDeVenta(venta));
    if (d == null || d.anio != anio || d.mes < 1 || d.mes > 12) continue;
    montos[d.mes - 1] += venta.monto;
    cantidades[d.mes - 1] += 1;
  }
  return [
    for (var i = 0; i < 12; i++)
      PuntoVentas(
        etiqueta: nombresMes[i][0].toUpperCase() + nombresMes[i].substring(1),
        monto: montos[i],
        cantidad: cantidades[i],
      ),
  ];
}

/// Total vendido por año (solo años con ventas), del más antiguo al actual.
List<PuntoVentas> ventasPorAnio(List<Venta> completadas) {
  final montos = <int, double>{};
  final cantidades = <int, int>{};
  for (final venta in completadas) {
    final d = _parseDia(fechaDeVenta(venta));
    if (d == null) continue;
    montos[d.anio] = (montos[d.anio] ?? 0) + venta.monto;
    cantidades[d.anio] = (cantidades[d.anio] ?? 0) + 1;
  }
  final anios = montos.keys.toList()..sort();
  return [
    for (final anio in anios)
      PuntoVentas(
        etiqueta: '$anio',
        monto: montos[anio]!,
        cantidad: cantidades[anio]!,
      ),
  ];
}

// ---------------------------------------------------------------------------
// 4. Productos no conformes
// ---------------------------------------------------------------------------

class SemanaNoConforme {
  const SemanaNoConforme({
    required this.semana,
    required this.registros,
    required this.unidadesAfectadas,
    required this.porTipo,
  });

  /// 1 a 5.
  final int semana;

  /// Cantidad de registros de la semana.
  final int registros;
  final double unidadesAfectadas;

  /// Registros por tipo de no conformidad.
  final Map<String, int> porTipo;
}

/// Registros de no conformes por semana (S1 a S5) del mes indicado.
List<SemanaNoConforme> noConformesPorSemana(
  List<ProductoNoConforme> registros,
  int anio,
  int mes,
) {
  final conteo = List<int>.filled(5, 0);
  final unidades = List<double>.filled(5, 0);
  final tipos = List.generate(5, (_) => <String, int>{});
  for (final registro in registros) {
    final d = _parseDia(registro.fechaRegistro);
    if (d == null || d.anio != anio || d.mes != mes) continue;
    final i = semanaDelMes(d.dia) - 1;
    conteo[i] += 1;
    unidades[i] += registro.cantidadAfectada;
    tipos[i][registro.tipoNoConformidad] =
        (tipos[i][registro.tipoNoConformidad] ?? 0) + 1;
  }
  return [
    for (var i = 0; i < 5; i++)
      SemanaNoConforme(
        semana: i + 1,
        registros: conteo[i],
        unidadesAfectadas: unidades[i],
        porTipo: tipos[i],
      ),
  ];
}
