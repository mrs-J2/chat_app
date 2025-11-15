// lib/main.dart
import 'package:chat_app/controllers/friends_controller.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:chat_app/themes/dark_mode.dart';   // ← add this
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendsController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDark ? darkMode : lightMode,
      home: AuthGate(onThemeToggle: _toggleTheme), // pass toggle
    );
  }
}