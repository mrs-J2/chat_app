import '../../pages/register_page.dart';
import 'package:flutter/material.dart';
import '../../pages/login_page.dart';

class LoginOrRegister extends StatefulWidget{
  final VoidCallback? onThemeToggle;
  const LoginOrRegister({super.key,this.onThemeToggle});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}
class _LoginOrRegisterState extends State<LoginOrRegister> {
  //mloul twari login
  bool showLoginPage = true;

  //tbadel
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
    return LoginPage(
      onTap: togglePages,
    );
  } else {
    return RegisterPage(
      onTap: togglePages,
    );
  }
} 
}