import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paleta_app.dart';

abstract final class AppTheme {
  /// Tema de siempre (modo claro) con la paleta clara, que no altera colores.
  static final ThemeData claro = _construir(
    ThemeData(useMaterial3: true),
  ).copyWith(extensions: const [PaletaApp.claro]);

  /// Modo oscuro: solo se usa en el panel del Administrador.
  static final ThemeData oscuro = _construirOscuro();

  static ThemeData _construir(ThemeData base) {
    final tituloTextTheme = GoogleFonts.montserratTextTheme(base.textTheme);
    final textoTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);
    final textTheme = textoTextTheme.copyWith(
      displayLarge: tituloTextTheme.displayLarge,
      displayMedium: tituloTextTheme.displayMedium,
      displaySmall: tituloTextTheme.displaySmall,
      headlineLarge: tituloTextTheme.headlineLarge,
      headlineMedium: tituloTextTheme.headlineMedium,
      headlineSmall: tituloTextTheme.headlineSmall,
      titleLarge: tituloTextTheme.titleLarge,
    );
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodyLarge,
        errorStyle: textTheme.bodySmall,
        helperStyle: textTheme.bodyMedium,
        counterStyle: textTheme.bodySmall,
        prefixStyle: textTheme.bodyLarge,
        suffixStyle: textTheme.bodyLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(contentTextStyle: textTheme.bodyMedium),
      chipTheme: ChipThemeData(labelStyle: textTheme.labelMedium),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
        leadingAndTrailingTextStyle: textTheme.labelLarge,
      ),
      tooltipTheme: TooltipThemeData(textStyle: textTheme.bodyMedium),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.titleSmall,
        dataTextStyle: textTheme.bodyMedium,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: base.drawerTheme.backgroundColor,
      ),
    );
  }

  static ThemeData _construirOscuro() {
    const esquema = ColorScheme(
      brightness: Brightness.dark,
      primary: PaletaApp.rojoOscuro,
      onPrimary: Colors.white,
      primaryContainer: PaletaApp.rojoBotonOscuro,
      onPrimaryContainer: Colors.white,
      secondary: PaletaApp.rojoOscuro,
      onSecondary: Colors.white,
      secondaryContainer: PaletaApp.campoOscuro,
      onSecondaryContainer: PaletaApp.textoOscuro,
      error: Color(0xFFFF8A80),
      onError: PaletaApp.fondoOscuro,
      surface: PaletaApp.tarjetaOscura,
      onSurface: PaletaApp.textoOscuro,
      onSurfaceVariant: PaletaApp.secundarioOscuro,
      surfaceContainerLowest: PaletaApp.fondoOscuro,
      surfaceContainerLow: PaletaApp.tarjetaOscura,
      surfaceContainer: PaletaApp.tarjetaOscura,
      surfaceContainerHigh: PaletaApp.superficieOscura,
      surfaceContainerHighest: PaletaApp.campoOscuro,
      outline: PaletaApp.bordeOscuro,
      outlineVariant: PaletaApp.bordeOscuro,
      inverseSurface: PaletaApp.textoOscuro,
      onInverseSurface: PaletaApp.fondoOscuro,
      inversePrimary: PaletaApp.rojoBotonOscuro,
      surfaceTint: Colors.transparent,
      shadow: Colors.transparent,
    );
    final base = _construir(
      ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: esquema,
        scaffoldBackgroundColor: PaletaApp.fondoOscuro,
        canvasColor: PaletaApp.superficieOscura,
        dividerColor: PaletaApp.bordeOscuro,
      ),
    );
    final textTheme = base.textTheme.apply(
      bodyColor: PaletaApp.textoOscuro,
      displayColor: PaletaApp.textoOscuro,
    );
    const bordeCampo = UnderlineInputBorder(
      borderSide: BorderSide(color: PaletaApp.bordeOscuro),
    );
    return base.copyWith(
      textTheme: textTheme,
      extensions: const [PaletaApp.modoOscuro],
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: PaletaApp.superficieOscura,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PaletaApp.superficieOscura,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: PaletaApp.superficieOscura,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: PaletaApp.superficieOscura,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PaletaApp.campoOscuro,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: PaletaApp.rojoOscuro,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: PaletaApp.campoOscuro,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: PaletaApp.atenuadoOscuro,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: PaletaApp.secundarioOscuro,
        ),
        counterStyle: textTheme.bodySmall?.copyWith(
          color: PaletaApp.atenuadoOscuro,
        ),
        enabledBorder: bordeCampo,
        border: bordeCampo,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: PaletaApp.rojoOscuro,
        selectionColor: PaletaApp.rojoOscuro.withValues(alpha: 0.35),
        selectionHandleColor: PaletaApp.rojoOscuro,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PaletaApp.rojoOscuro,
        linearTrackColor: PaletaApp.campoOscuro,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: PaletaApp.superficieOscura,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PaletaApp.rojoBotonOscuro,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PaletaApp.textoOscuro,
          side: const BorderSide(color: PaletaApp.bordeOscuro),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PaletaApp.rojoOscuro,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: PaletaApp.campoOscuro,
        selectedColor: PaletaApp.rojoOscuro.withValues(alpha: 0.15),
        side: const BorderSide(color: PaletaApp.bordeOscuro),
        labelStyle: textTheme.labelMedium,
        checkmarkColor: PaletaApp.rojoOscuro,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : PaletaApp.secundarioOscuro,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? PaletaApp.rojoBotonOscuro
              : PaletaApp.campoOscuro,
        ),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: PaletaApp.superficieOscura,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: PaletaApp.superficieOscura,
      ),
      iconTheme: const IconThemeData(color: PaletaApp.textoOscuro),
      dividerTheme: const DividerThemeData(color: PaletaApp.bordeOscuro),
      listTileTheme: base.listTileTheme.copyWith(
        textColor: PaletaApp.textoOscuro,
        iconColor: PaletaApp.secundarioOscuro,
      ),
    );
  }
}
