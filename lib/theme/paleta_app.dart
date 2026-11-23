import 'package:material_ui/material_ui.dart';

/// Colores del panel por función, como extensión del tema.
///
/// Cada función recibe el color que la pantalla usa hoy en modo claro y:
/// - en modo claro lo devuelve TAL CUAL (el modo claro no cambia);
/// - en modo oscuro devuelve el color de la paleta oscura para esa función.
@immutable
class PaletaApp extends ThemeExtension<PaletaApp> {
  const PaletaApp._(this.oscuro);

  static const PaletaApp claro = PaletaApp._(false);
  static const PaletaApp modoOscuro = PaletaApp._(true);

  final bool oscuro;

  // Paleta oscura (superficies por niveles).
  static const Color fondoOscuro = Color(0xFF121010);
  static const Color tarjetaOscura = Color(0xFF1C1819);
  static const Color superficieOscura = Color(0xFF252021);
  static const Color campoOscuro = Color(0xFF2A2425);
  static const Color bordeOscuro = Color(0xFF3A3234);
  static const Color textoOscuro = Color(0xFFF2EDEC);
  static const Color secundarioOscuro = Color(0xFFB8AEAD);
  static const Color atenuadoOscuro = Color(0xFF8C8281);
  static const Color rojoOscuro = Color(0xFFEF5350);
  static const Color rojoBotonOscuro = Color(0xFFC62828);

  Color _segun(Color claro, Color enOscuro) => oscuro ? enOscuro : claro;

  /// Fondo de pantalla.
  Color fondo(Color claro) => _segun(claro, fondoOscuro);

  /// Tarjetas, encabezado y barra inferior.
  Color tarjeta(Color claro) => _segun(claro, tarjetaOscura);

  /// Superficie elevada: diálogos, hojas inferiores y menús.
  Color superficie(Color claro) => _segun(claro, superficieOscura);

  /// Campos, buscadores, elementos de solo lectura y fondos grises suaves.
  Color campo(Color claro) => _segun(claro, campoOscuro);

  /// Bordes y divisores.
  Color borde(Color claro) => _segun(claro, bordeOscuro);

  /// Texto e iconos principales.
  Color texto(Color claro) => _segun(claro, textoOscuro);

  /// Texto e iconos secundarios.
  Color secundario(Color claro) => _segun(claro, secundarioOscuro);

  /// Texto atenuado y placeholders.
  Color atenuado(Color claro) => _segun(claro, atenuadoOscuro);

  /// Rojo de marca para texto, iconos y bordes.
  Color rojo(Color claro) => _segun(claro, rojoOscuro);

  /// Rojo de botones y fondos rellenos (con texto blanco).
  Color rojoBoton(Color claro) => _segun(claro, rojoBotonOscuro);

  /// Fondo rojo suave: adornos y opción elegida.
  Color rojoSuave(Color claro) =>
      _segun(claro, rojoOscuro.withValues(alpha: 0.15));

  /// Sombras: en oscuro casi nulas (se usa el borde).
  Color sombra(Color claro) => _segun(claro, Colors.transparent);

  // Estados (fondo suave + texto claro del mismo tono).
  Color exitoFondo(Color claro) => _segun(claro, const Color(0xFF1D3A28));
  Color exitoTexto(Color claro) => _segun(claro, const Color(0xFF7BD389));
  Color avisoFondo(Color claro) => _segun(claro, const Color(0xFF3A3012));
  Color avisoTexto(Color claro) => _segun(claro, const Color(0xFFFFCA5C));
  Color errorFondo(Color claro) => _segun(claro, const Color(0xFF3E1B1B));
  Color errorTexto(Color claro) => _segun(claro, const Color(0xFFFF8A80));
  Color infoFondo(Color claro) => _segun(claro, const Color(0xFF1C2E3F));
  Color infoTexto(Color claro) => _segun(claro, const Color(0xFF82B1FF));

  // Gráficos de Indicadores.
  Color graficoRojo(Color claro) => _segun(claro, const Color(0xFFE05252));
  Color graficoVerde(Color claro) => _segun(claro, const Color(0xFF43A047));
  Color pistaGrafico(Color claro) => _segun(claro, campoOscuro);

  @override
  PaletaApp copyWith() => this;

  @override
  PaletaApp lerp(covariant PaletaApp? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension PaletaContexto on BuildContext {
  /// Paleta del tema vigente (clara salvo en el panel del admin en oscuro).
  PaletaApp get pal => Theme.of(this).extension<PaletaApp>() ?? PaletaApp.claro;
}
