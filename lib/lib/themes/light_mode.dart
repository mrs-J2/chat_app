// lib/themes/light_mode.dart
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2A7D7D),
    secondary: Color(0xFF4A9F9F),
    background: Color(0xFFF5F7FA),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF2D3748),
    onSurface: Color(0xFF2D3748),
    inversePrimary: Color(0xFF2A7D7D),
    tertiary: Color(0xFF34B7A7),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A7D7D),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: Colors.grey.shade500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFF4A9F9F), width: 2),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF34B7A7),
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(16),
      elevation: 3,
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF2D3748)),
    titleMedium: TextStyle(color: Color(0xFF2A7D7D), fontWeight: FontWeight.w600),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF2A7D7D),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1.5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFFE2E8F0),
    thickness: 1,
    indent: 16,
    endIndent: 16,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF34B7A7),
    foregroundColor: Colors.white,
  ),

  scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  useMaterial3: true,
);