import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF6E5A58);
  static const Color page = Color(0xFFFFFBFA);
  static const Color headerDivider = Color(0xFFEBCBC8);

  static const Color bannerGreenBg = Color(0xFFE8F5E9);
  static const Color bannerGreenBorder = Color(0xFFA5D6A7);
  static const Color bannerGreenFg = Color(0xFF2E7D32);

  static const Color fieldBorder = Color(0xFFE2E0DE);
  static const Color fieldFill = Color(0xFFF5F4F3);

  /// Relleno del campo de búsqueda unificado (el de la barra de Gestión Ventas).
  static const Color searchFieldFill = Color(0xFFFFFDFD);

  static const Color buttonFill = Color(0xFFE8E6E4);

  static const Color statusGreenBg = Color(0xFFE2F3E5);
  static const Color statusGreenFg = Color(0xFF16813A);
  static const Color statusRedBg = Color(0xFFFFE6E8);
  static const Color statusRedFg = Color(0xFFD04444);

  static const Color cardBorder = Color(0xFFE5BDB9);
  static const Color cardDivider = Color(0xFFE5D9D7);
  static const Color cardIcon = Color(0xFF5B4643);
  static const Color iconCircleBg = Color(0xFFF2EEED);

  static const Color statCardBorder = Color(0xFFE5E0DE);

  /// Borde suave de las tarjetas de Perfil (Mi Perfil y detalle de perfil).
  static const Color profileCardBorder = Color(0xFFE5DFDD);

  /// Relleno de las cajas de campo de Mi Perfil (en reposo o en edición).
  static const Color profileFieldFill = Color(0xFFF0F0F0);

  /// Relleno de las cajas de campo de Mi Perfil mientras se edita.
  static const Color profileFieldFillActive = Color(0xFFFFFEFE);

  /// Texto de los labels de campo del Perfil.
  static const Color profileLabel = Color(0xFF5B514F);

  /// Íconos de los labels de campo del Perfil.
  static const Color profileLabelIcon = Color(0xFF968D8B);

  /// Fondo suave del botón secundario "Volver al inicio".
  static const Color buttonSoftBg = Color(0xFFF7F6F6);

  /// Borde suave del botón "Cerrar sesión" en el perfil.
  static const Color logOutBorder = Color(0xFFFFBFC2);

  static const List<Color> avatarPalette = [
    Color(0xFF008D83),
    Color(0xFF1478C9),
    Color(0xFF176CC0),
    Color(0xFF9C79CF),
    Color(0xFFE91561),
    Color(0xFFE58B36),
    Color(0xFF6D59B5),
    Color(0xFFDB4772),
    Color(0xFF7A8B9C),
    Color(0xFF2B9C6A),
  ];
}
