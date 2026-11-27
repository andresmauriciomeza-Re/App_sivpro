import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencia de modo oscuro guardada en el dispositivo (no va al backend).
class ModoOscuroController {
  ModoOscuroController._();

  static final ModoOscuroController instance = ModoOscuroController._();

  static const String clave = 'modo_oscuro';

  /// Lo que usa el tema.
  final ValueNotifier<bool> oscuro = ValueNotifier<bool>(false);

  /// Lo que muestra el interruptor: cambia al instante, antes que el tema.
  final ValueNotifier<bool> interruptor = ValueNotifier<bool>(false);

  /// Margen para que el interruptor se mueva antes de repintar la app.
  static const Duration retardoTema = Duration(milliseconds: 150);

  int _turno = 0;

  Future<void>? _carga;

  /// Lee la preferencia guardada una sola vez (llamadas repetidas reutilizan
  /// la misma lectura). Si falla, se queda en modo claro.
  Future<void> cargar() => _carga ??= _leer();

  Future<void> _leer() async {
    var guardado = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      guardado = prefs.getBool(clave) ?? false;
    } catch (_) {
      // Sin almacenamiento: modo claro.
    }
    interruptor.value = guardado;
    oscuro.value = guardado;
  }

  /// Desde el interruptor: se mueve ya, se guarda en segundo plano y el tema
  /// cambia justo después. Si se vuelve a tocar, manda el último toque.
  Future<void> alternar(bool valor) async {
    final turno = ++_turno;
    interruptor.value = valor;
    final guardado = _guardar(valor);
    await Future<void>.delayed(retardoTema);
    if (turno == _turno) oscuro.value = valor;
    await guardado;
  }

  /// Cambio inmediato de interruptor y tema, y lo guarda.
  Future<void> cambiar(bool valor) {
    _turno++;
    interruptor.value = valor;
    oscuro.value = valor;
    return _guardar(valor);
  }

  Future<void> _guardar(bool valor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(clave, valor);
    } catch (_) {
      // Sin almacenamiento disponible el cambio dura solo esta sesión.
    }
  }
}
