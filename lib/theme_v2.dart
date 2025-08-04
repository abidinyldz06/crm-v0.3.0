import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'package:google_fonts/google_fonts.dart';
import 'package:crm/services/theme_service.dart';

/// Theme extension ile merkezi tasarım token’ları
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;

  // Semantik renkler
  final Color info;
  final Color success;
  final Color warning;
  final Color danger;

  const AppTokens({
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.info,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const AppTokens light = AppTokens(
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    info: Colors.blue,
    success: Colors.green,
    warning: Colors.orange,
    danger: Colors.red,
  );

  static AppTokens dark = AppTokens(
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    info: Colors.blue[400]!,
    success: Colors.green[400]!,
    warning: Colors.orange[400]!,
    danger: Colors.red[400]!,
  );

  @override
  AppTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    Color? info,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppTokens(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      info: info ?? this.info,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t)!,
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t)!,
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t)!,
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t)!,
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t)!,
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppThemeV2 {
  // Design tokens
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;

  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;

  // Semantic colors
  static const Color info = Colors.blue;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color danger = Colors.red;

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: ThemeService().seedColor, brightness: Brightness.light),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.interTextTheme().apply(
      fontFamilyFallback: ['Arial', 'sans-serif'],
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppTokens.light,
    ],
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      // Ek durum renkleri
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      helperStyle: const TextStyle(color: Color(0xFF94A3B8)),
      errorStyle: const TextStyle(color: Color(0xFFEF4444)),
      prefixIconColor: const Color(0xFF94A3B8),
      suffixIconColor: const Color(0xFF94A3B8),
    ),
    // Küçük adım 1: Material 3 düğme ailelerini standardize et
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      margin: const EdgeInsets.all(spaceSm),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: false,
      iconColor: Color(0xFF64748B),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: Color(0xFF1D4ED8)),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      indicatorColor: const Color(0xFFEFF6FF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    dividerColor: const Color(0xFFE2E8F0),
    useMaterial3: true,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: ThemeService().seedColor, brightness: Brightness.dark),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      fontFamilyFallback: ['Arial', 'sans-serif'],
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppTokens.dark,
    ],
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: BorderSide(color: Color(0xFF374151)),
      ),
      filled: true,
      fillColor: Colors.grey[850],
      // Ek durum renkleri
      labelStyle: TextStyle(color: Colors.grey[400]),
      hintStyle: TextStyle(color: Colors.grey[500]),
      helperStyle: TextStyle(color: Colors.grey[500]),
      errorStyle: const TextStyle(color: Color(0xFFF87171)),
      prefixIconColor: Colors.grey[500],
      suffixIconColor: Colors.grey[500],
    ),
    // Küçük adım 1: Material 3 düğme ailelerini standardize et (dark)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: BorderSide(color: Colors.grey[700]!),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[900],
      margin: const EdgeInsets.all(spaceSm),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: false,
      iconColor: Colors.grey[300],
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.black,
      selectedIconTheme: IconThemeData(color: Colors.blue[400]),
      unselectedIconTheme: IconThemeData(color: Colors.grey[500]),
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      indicatorColor: Colors.blueGrey[900],
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[850],
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.grey[900],
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.blue[400],
      unselectedItemColor: Colors.grey[500],
    ),
    dividerColor: Colors.grey[800],
    useMaterial3: true,
  );

  // Backward compatibility
  static ThemeData get theme => lightTheme;
}
