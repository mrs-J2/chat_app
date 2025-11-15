
import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF075E54),      
    secondary: Color(0xFF128C7E),
    background: Color(0xFF0D1B1E),  
    surface: Color(0xFF111B21),      
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white70,
    onSurface: Colors.white70,
    inversePrimary: Color(0xFF075E54),
    tertiary: Color(0xFF25D366),   
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF111B21),
    foregroundColor: Colors.white,   
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1F2C34),
    hintStyle: TextStyle(color: Colors.grey.shade400),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      borderSide: const BorderSide(color: Color(0xFF128C7E), width: 2),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF25D366),
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(16),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF111B21),
    selectedItemColor: Color(0xFF25D366),
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF111B21),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF2A3942),
    thickness: 1,
    indent: 16,
    endIndent: 16,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF25D366),
    foregroundColor: Colors.white,
  ),

  scaffoldBackgroundColor: const Color(0xFF0D1B1E),
  useMaterial3: true,
);