import 'package:chat_app_main/themes/chat_background_theme.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFB39DDB),      // Soft Lavender (User Chat Bubble, Primary color)
    secondary: Color(0xFF7E57C2),    // Deep Violet (AppBar, Strong Accent)
    background: Color.fromARGB(255, 229, 199, 244),
    surface: Color(0xFFF5F5F5),      // Light gray cards
    onPrimary: Color(0xFF424242),    // Dark text on primary
    onSecondary: Colors.white,
    onBackground: Color(0xFF424242), // Main body text color
    onSurface: Color(0xFF424242),
    inversePrimary: Color(0xFF7E57C2), // Deep Violet
    tertiary: Color(0xFF81C784),     // Mint Green Accent (FAB, Send Button)
  ),
  scaffoldBackgroundColor:  Color(0xFFDCDAF0),
  extensions: <ThemeExtension<dynamic>>[
    const ChatBackgroundTheme(
      chatBackgroundPath: 'lib/assets/icon/background.jpg', // ⬅️ Light Mode Image
    ),
  ],
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF7E57C2), // Deep Violet
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
    hintStyle: TextStyle(color: Colors.grey),
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
      borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2), // Updated to Deep Violet
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF81C784), // Mint Green
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(16),
      elevation: 3,
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF424242)), // Updated to dark text color
    titleMedium:
        TextStyle(color: Color(0xFF7E57C2), fontWeight: FontWeight.w600), // Updated to Deep Violet
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF7E57C2), // Updated to Deep Violet
    unselectedItemColor: Colors.grey,
    showUnselectedLabels: true,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFFF5F5F5), // Light gray cards
    elevation: 1.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFFE2E8F0),
    thickness: 1,
    indent: 16,
    endIndent: 16,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF81C784), // Updated to Mint Green
    foregroundColor: Colors.white,
  ),
  useMaterial3: true,
);
