import 'package:flutter/foundation.dart';

/// Dirección del local (la misma de la web y del backend).
const String direccionLocal = 'Cra. 45 #104-30, Laureles, Medellín, Antioquia';

/// WhatsApp del local (pie de página de la web).
const String telefonoLocal = '320 882 0029';

/// Horario del local (mismas constantes que la web, `shared/utils/hora.ts`):
/// atiende de jueves a domingo de 4:00 p. m. a 10:00 p. m. y la última
/// recogida es a las 9:45 p. m., en intervalos de 15 minutos.
abstract final class HorarioLocal {
  static const int apertura = 16 * 60;
  static const int cierre = 22 * 60;
  static const int ultimaRecogida = 21 * 60 + 45;
  static const int intervalo = 15;

  /// Días de atención (Dart: lunes = 1 … domingo = 7).
  static const Set<int> dias = {
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  };

  /// Reloj del celular; las pruebas lo fijan.
  @visibleForTesting
  static DateTime Function() reloj = DateTime.now;

  /// Hora de pared de Bogotá (UTC-5 fijo, Colombia no cambia de horario),
  /// sin depender de la zona del celular.
  static DateTime ahoraBogota([DateTime? ahora]) =>
      (ahora ?? reloj()).toUtc().subtract(const Duration(hours: 5));

  static int minutosBogota([DateTime? ahora]) {
    final bogota = ahoraBogota(ahora);
    return bogota.hour * 60 + bogota.minute;
  }

  /// Horarios de recogida que quedan HOY (minutos desde medianoche): de
  /// 4:00 p. m. a 9:45 p. m. cada 15 minutos y solo los posteriores a ahora.
  static List<int> horariosRecogida([DateTime? ahora]) {
    final actual = minutosBogota(ahora);
    return [
      for (var m = apertura; m <= ultimaRecogida; m += intervalo)
        if (m > actual) m,
    ];
  }

  /// "Abierto" de jueves a domingo entre las 4:00 p. m. y las 10:00 p. m.
  static bool abierto([DateTime? ahora]) {
    final bogota = ahoraBogota(ahora);
    final minutos = bogota.hour * 60 + bogota.minute;
    return dias.contains(bogota.weekday) &&
        minutos >= apertura &&
        minutos < cierre;
  }

  /// "HH:mm" en 24 h, como lo espera `POST /ventas`.
  static String paraEnviar(int minutos) =>
      '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutos % 60).toString().padLeft(2, '0')}';

  /// "4:00 p. m." (formato de la web).
  static String texto(int minutos) {
    final h24 = (minutos ~/ 60) % 24;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final m = (minutos % 60).toString().padLeft(2, '0');
    return '$h12:$m ${h24 >= 12 ? 'p. m.' : 'a. m.'}';
  }

  /// Hora del backend ("18:30:00" o "18:30") en formato de 12 h; si no se
  /// puede leer, el texto tal cual.
  static String textoDeHora(String? hora) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(hora?.trim() ?? '');
    if (m == null) return hora ?? '';
    return texto(int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!));
  }
}
