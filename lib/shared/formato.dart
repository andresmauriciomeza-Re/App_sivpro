/// Formatea un monto en pesos con separador de miles: 56000 -> $56.000.
///
/// Único formateador de dinero de la parte Administrador/Empleado.
String formatCop(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '\$${value < 0 ? '-' : ''}$buffer';
}
