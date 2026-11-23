import 'package:flutter_test/flutter_test.dart';
import 'package:sivpro_app/shared/numeros.dart';

void main() {
  test('numeroTolerante lee texto de PostgreSQL y separadores', () {
    expect(numeroTolerante('35000.00'), 35000);
    expect(numeroTolerante('12,5'), 12.5);
    expect(numeroTolerante('35.000,50'), 35000.5);
    expect(numeroTolerante('35,000.50'), 35000.5);
    expect(numeroTolerante(42), 42);
    expect(numeroTolerante(r' $ 1500 '), 1500);
    expect(numeroTolerante('abc'), isNull);
    expect(numeroTolerante(''), isNull);
    expect(numeroTolerante(null), isNull);
  });
}
