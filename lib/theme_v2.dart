import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crm/services/theme_service.dart';

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
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
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
      filled: true,
      fillColor: Colors.grey[850],
    ),
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
