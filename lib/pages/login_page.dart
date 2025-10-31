import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatelessWidget{
  //email and pwdtxt controllers
final TextEditingController _emailController = TextEditingController();
final TextEditingController _pwController = TextEditingController();

//go to register tap
final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  //login methode
  void login(BuildContext context) async{
    //lauth service
    // ignore: non_constant_identifier_names
    final authService = AuthService();
     //try login
    try{
      await authService.signInWithEmailPassword(_emailController.text, _pwController.text) ;
    }
    //catch
    catch(e){
      showDialog(
        context: context,
         builder: (context) => AlertDialog(
          title: Text(e.toString()) ,
         )
         );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 50),
          
            //welcome back message
            Text(
              "Welcome back dude",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
        
            //email textfield
            MyTextfield(
              hintText: "Email" ,
              obscureText: false,
              controller: _emailController,
            ),  
            const SizedBox(height: 10),
            //password textfield
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController),

              const SizedBox(height: 25),
            //login button
            MyButton(
              text: "Login",
              onTap: () => login(context),
            ),
            const SizedBox(height: 25),

            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "new user? ",
                  style: 
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),

                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "register now ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary
                    ),
                    ),
                )
              ],
            )

          ],
        ),
      ),
    );
  }
}