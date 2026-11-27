import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Detecta si el teléfono es de gama baja, para simplificar animaciones.
///
/// Se decide con la RAM física y la versión de Android. No se usa
/// `isLowRamDevice` de `device_info_plus`: en ese paquete viene de
/// `lowMemory` (poca memoria libre en ese instante), no del tipo de equipo.
abstract final class GamaDispositivo {
  /// Hasta 3 GB: un teléfono "de 3 GB" informa unos 2800 MB y uno de 4 GB,
  /// unos 3700 MB.
  static const int ramBajaMb = 3072;

  /// Android 8.1 (API 27) o anterior.
  static const int sdkBajo = 27;

  static bool _baja = false;
  static bool _leida = false;

  /// false mientras no se haya leído, y fuera de Android.
  static bool get baja => _baja;

  /// Transición entre tema claro y oscuro; en gama baja, cambio directo.
  static Duration get duracionTema =>
      _baja ? Duration.zero : const Duration(milliseconds: 150);

  /// Un valor 0 significa "no informado" y no cuenta.
  static bool esBaja({required int ramMb, required int sdk}) =>
      (ramMb > 0 && ramMb <= ramBajaMb) || (sdk > 0 && sdk <= sdkBajo);

  static Future<void> cargar() async {
    if (_leida) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final datos = await DeviceInfoPlugin().androidInfo.timeout(
          const Duration(seconds: 1),
        );
        if (_leida) return;
        _baja = esBaja(ramMb: datos.physicalRamSize, sdk: datos.version.sdkInt);
      } catch (_) {
        // Sin el dato se trata como equipo normal.
      }
    }
    _leida = true;
  }

  /// Las pruebas fijan la gama; null vuelve a leerla.
  @visibleForTesting
  static set simulada(bool? baja) {
    _leida = baja != null;
    _baja = baja ?? false;
  }
}
