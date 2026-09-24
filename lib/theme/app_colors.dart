import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color red = Color(0xFFC9151E);
  static const Color ink = Color(0xFF211616);
  static const Color muted = Color(0xFF6E5A58);
  static const Color page = Color(0xFFFFFBFA);
  static const Color headerDivider = Color(0xFFEBCBC8);

  static const Color bannerGreenBg = Color(0xFFE8F5E9);
  static const Color bannerGreenBorder = Color(0xFFA5D6A7);
  static const Color bannerGreenFg = Color(0xFF2E7D32);

  static const Color bannerBlueBg = Color(0xFFF2F6FF);
  static const Color bannerBlueBorder = Color(0xFFB7D1F5);
  static const Color bannerBlueFg = Color(0xFF304A72);

  static const Color fieldBorder = Color(0xFFE2E0DE);
  static const Color fieldFill = Color(0xFFF5F4F3);

  static const Color tableHeaderFill = Color(0xFFF2F0EF);
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
  static const Color statGreenBg = Color(0xFFF0FFF7);
  static const Color statGreenBorder = Color(0xFF8DE9BD);
  static const Color statGreenNumber = Color(0xFF009C68);
  static const Color statGreenLabel = Color(0xFF167653);

  static const Color salesIconBg = Color(0xFFEAF2FF);
  static const Color salesIconFg = Color(0xFF1464F4);
  static const Color returnIconBg = Color(0xFFFFEBCF);
  static const Color returnIconFg = Color(0xFFB44A00);
  static const Color cardSubtext = Color(0xFFAAA09D);
  static const Color badgeGreenBg = Color(0xFFE5FAF0);
  static const Color badgeGreenFg = Color(0xFF008C5A);

  /// Track encendido del switch de estado de cliente (verde).
  static const Color switchTrackActive = Color(0xFF2E9E5B);

  /// Chip de filtro "Todas" (rojo de la app) en Devoluciones.
  static const Color returnChipAllBg = Color(0xFFFFE6E8);
  static const Color returnChipAllFg = Color(0xFFC9151E);

  /// Chip de filtro "Pendientes" (naranja de la app) en Devoluciones.
  static const Color returnChipPendingBg = Color(0xFFFFEBCF);
  static const Color returnChipPendingFg = Color(0xFFB44A00);

  /// Chip de filtro "Resueltas" (verde) en Devoluciones.
  static const Color returnChipResolvedBg = Color(0xFFE2F3E5);
  static const Color returnChipResolvedFg = Color(0xFF16813A);

  /// Borde suave de las tarjetas de Perfil (Más opciones y detalle de perfil).
  static const Color profileCardBorder = Color(0xFFE5DFDD);

  /// Divisor interno de la tarjeta de Perfil (detalle).
  static const Color profileDivider = Color(0xFFEDE8E7);

  /// Relleno de las cajas de campo del Perfil (no editables o en reposo).
  static const Color profileFieldFill = Color(0xFFF2F2F2);

  /// Relleno de las cajas de campo del Perfil mientras se edita.
  static const Color profileFieldFillActive = Color(0xFFFFFEFE);

  /// Texto de los labels de campo del Perfil.
  static const Color profileLabel = Color(0xFF5B514F);

  /// Íconos de los labels de campo del Perfil.
  static const Color profileLabelIcon = Color(0xFF968D8B);

  /// Fondo de la etiqueta "S.I.V.PRO" en la tarjeta de Más opciones.
  static const Color profileChipBg = Color(0xFFE6E2E1);

  /// Borde gris claro del botón "Editar" en píldora.
  static const Color pillBorder = Color(0xFFE0DDDB);

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