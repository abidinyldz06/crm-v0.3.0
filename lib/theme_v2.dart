import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeV2 {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.interTextTheme().apply(
      fontFamilyFallback: ['Arial', 'sans-serif'],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: Colors.blue[800]),
      unselectedIconTheme: const IconThemeData(color: Colors.grey),
      labelType: NavigationRailLabelType.all,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    useMaterial3: true,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      fontFamilyFallback: ['Arial', 'sans-serif'],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      filled: true,
      fillColor: Colors.grey[800],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[850],
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.grey[900],
      selectedIconTheme: IconThemeData(color: Colors.blue[400]),
      unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
      labelType: NavigationRailLabelType.all,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[800],
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.grey[850],
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.blue[400],
      unselectedItemColor: Colors.grey[400],
    ),
    useMaterial3: true,
  );

  // Backward compatibility
  static ThemeData get theme => lightTheme;
} 