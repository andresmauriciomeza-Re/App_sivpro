import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencia de modo oscuro guardada en el dispositivo (no va al backend).
class ModoOscuroController {
  ModoOscuroController._();

  static final ModoOscuroController instance = ModoOscuroController._();

  static const String clave = 'modo_oscuro';

  final ValueNotifier<bool> oscuro = ValueNotifier<bool>(false);

  Future<void>? _carga;

  /// Lee la preferencia guardada una sola vez (llamadas repetidas reutilizan
  /// la misma lectura). Si falla, se queda en modo claro.
  Future<void> cargar() => _carga ??= _leer();

  Future<void> _leer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      oscuro.value = prefs.getBool(clave) ?? false;
    } catch (_) {
      oscuro.value = false;
    }
  }

  /// Cambia el modo y lo guarda para la próxima vez que se abra la app.
  Future<void> cambiar(bool valor) async {
    oscuro.value = valor;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(clave, valor);
    } catch (_) {
      // Sin almacenamiento disponible el cambio dura solo esta sesión.
    }
  }
}
