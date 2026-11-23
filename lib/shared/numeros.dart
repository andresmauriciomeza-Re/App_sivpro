/// Lectura tolerante de números que llegan del backend.
///
/// PostgreSQL entrega los `numeric` como texto ("35000.00"). Se acepta
/// número o texto con punto o coma decimal ("12.5", "12,5") y también con
/// separador de miles cuando vienen ambos ("35.000,50", "35,000.50": el
/// último separador es el decimal). Devuelve null si no es un número finito.
double? numeroTolerante(dynamic valor) {
  if (valor is num) return valor.isFinite ? valor.toDouble() : null;
  if (valor is! String) return null;
  var texto = valor.trim().replaceAll(RegExp(r'[\s$]'), '');
  if (texto.isEmpty) return null;
  final punto = texto.lastIndexOf('.');
  final coma = texto.lastIndexOf(',');
  if (punto >= 0 && coma >= 0) {
    final decimal = punto > coma ? '.' : ',';
    final miles = decimal == '.' ? ',' : '.';
    texto = texto.replaceAll(miles, '').replaceAll(decimal, '.');
  } else {
    texto = texto.replaceAll(',', '.');
  }
  final numero = double.tryParse(texto);
  return numero != null && numero.isFinite ? numero : null;
}
