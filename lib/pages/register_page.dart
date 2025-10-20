import 'package:flutter/material.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
class RegisterPage extends StatelessWidget{
  
  //email and pwdtxt controllers
final TextEditingController _emailController = TextEditingController();
final TextEditingController _pwController = TextEditingController();
final TextEditingController _confirmPwController = TextEditingController();

//go to login tap
final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});
 //register methode
  void register(){
    //register impl
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
              "Let's create an account for you",
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

              const SizedBox(height: 10),
            //confirm password textfield
            MyTextfield(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmPwController),

              const SizedBox(height: 25),
            //login button
            MyButton(
              text: "Register",
              onTap: register,
            ),
            const SizedBox(height: 25),

            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "already have an account? ",
                  style: 
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),

                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "login now ",
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