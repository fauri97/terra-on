import 'package:flutter/material.dart';

/// TerraON — Tema Material 3 (Flutter puro)
/// - seedColor: #009688 (verde-azulado)
/// - Modo claro padrão; escuro opcional
/// - Estilos básicos para AppBar, Botões, Chips e Inputs

const Color kSeedColor = Color(0xFF009688);

ThemeData themeLight() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.light,
  );
  return _themeFromScheme(scheme);
}

ThemeData themeDark() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  );
  return _themeFromScheme(scheme);
}

ThemeData _themeFromScheme(ColorScheme scheme) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  final textTheme = base.textTheme
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
      .copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.25),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.25),
        bodySmall: base.textTheme.bodySmall?.copyWith(height: 1.20),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(letterSpacing: .2),
        labelMedium: base.textTheme.labelMedium?.copyWith(letterSpacing: .2),
        labelSmall: base.textTheme.labelSmall?.copyWith(letterSpacing: .2),
      );

  final appBarTheme = AppBarTheme(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 2,
    centerTitle: true,
    titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    iconTheme: IconThemeData(color: scheme.onSurface),
  );

  final shapeMd = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(48, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: shapeMd,
      elevation: 0,
      textStyle: textTheme.labelLarge,
    ),
  );

  final filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: shapeMd,
      textStyle: textTheme.labelLarge,
    ),
  );

  final outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: shapeMd,
      side: BorderSide(color: scheme.outline),
      foregroundColor: scheme.primary,
      textStyle: textTheme.labelLarge,
    ),
  );

  final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(48, 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: shapeMd,
      foregroundColor: scheme.primary,
      textStyle: textTheme.labelLarge,
    ),
  );

  final border = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: scheme.outlineVariant),
  );

  final focusedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: scheme.primary, width: 2),
  );

  final inputTheme = InputDecorationTheme(
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
    border: border,
    enabledBorder: border,
    focusedBorder: focusedBorder,
    errorBorder: border.copyWith(borderSide: BorderSide(color: scheme.error)),
    focusedErrorBorder: focusedBorder.copyWith(
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    helperStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
  );

  final chipTheme = base.chipTheme.copyWith(
    shape: const StadiumBorder(),
    side: BorderSide(color: scheme.outlineVariant),
    selectedColor: scheme.secondaryContainer,
    checkmarkColor: scheme.onSecondaryContainer,
    labelStyle: textTheme.bodyMedium,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  );

  final cardTheme = CardThemeData(
    color: scheme.surface,
    elevation: 0,
    surfaceTintColor: scheme.surfaceTint,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    margin: const EdgeInsets.all(0),
  );

  final navBarTheme = NavigationBarThemeData(
    height: 64,
    indicatorColor: scheme.secondaryContainer,
    surfaceTintColor: Colors.transparent,
    labelTextStyle: MaterialStateProperty.resolveWith((states) {
      final style = textTheme.labelMedium!;
      return states.contains(MaterialState.selected)
          ? style.copyWith(fontWeight: FontWeight.w600)
          : style;
    }),
  );

  return base.copyWith(
    colorScheme: scheme,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    filledButtonTheme: filledButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    inputDecorationTheme: inputTheme,
    chipTheme: chipTheme,
    cardTheme: cardTheme,
    navigationBarTheme: navBarTheme,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.tertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
   
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
  );
}
