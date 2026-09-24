import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true);
    final textTheme = GoogleFonts.dmSerifDisplayTextTheme(base.textTheme);
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
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: textTheme.bodyMedium,
      ),
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
}