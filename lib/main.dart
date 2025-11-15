import 'package:chat_app_main/controllers/friends_controller.dart';
import 'package:chat_app_main/services/auth/auth_gate.dart';
import 'package:chat_app_main/services/auth/login_or_register.dart';
import 'package:chat_app_main/firebase_options.dart';
import 'package:chat_app_main/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'package:chat_app_main/themes/light_mode.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> FriendsController()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      theme: lightMode,
    );
  }
}
