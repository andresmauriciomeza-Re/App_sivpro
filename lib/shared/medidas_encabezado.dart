/// Medidas del encabezado del panel (Administrador y Empleado). Son las únicas:
/// todas las pantallas del panel usan `AppHeader`, que las lee de aquí. El
/// cliente tiene sus propios encabezados y no las usa.
abstract final class MedidasEncabezado {
  static const double alto = 62;

  /// Margen a la derecha, y a la izquierda cuando no hay flecha.
  static const double margen = 22;

  /// Con flecha: su zona táctil ya deja el dibujo a unos [margen] del borde.
  static const double margenConFlecha = 10;

  static const double letraTitulo = 22;

  static const double flecha = 25;
  static const double zonaFlecha = 48;
  static const double separacionFlecha = 4;

  static const double campana = 38;
  static const double separacionCampana = 6;

  static const double avatar = 40;
  static const double letraAvatar = 15;
}
