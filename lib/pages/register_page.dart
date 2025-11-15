import 'package:chat_app_main/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_main/components/my_button.dart';
import 'package:chat_app_main/components/my_textfield.dart';
class RegisterPage extends StatelessWidget{
  
  //email and pwdtxt controllers
final TextEditingController _emailController = TextEditingController();
final TextEditingController _pwController = TextEditingController();
final TextEditingController _confirmPwController = TextEditingController();
final TextEditingController _firstNameController = TextEditingController(); 
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();       
  final TextEditingController _usernameController = TextEditingController();  

//go to login tap
final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  void _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(), 
    helpText: 'SELECT DATE OF BIRTH',
  );

  if (picked != null) {
    String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    _dobController.text = formattedDate;
  }
}

 //register methode
  void register(BuildContext context) async{
    //get auth service
    final _auth = AuthService();
    //si meme password
    /*if(_pwController.text == _confirmPwController.text){
      try{
       _auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
      }
      catch(e){
      showDialog(
        context: context,
         builder: (context) => AlertDialog(
          title: Text(e.toString()) ,
         )
      );
      }
    }*/
    //si mdps differents
    if(_pwController.text != _confirmPwController.text){
      showDialog(
        context: context,
         builder: (context) => AlertDialog(
          title: Text("passwords don't match") ,
         )
         );
         return;
    }
    //champs vides
    if (_usernameController.text.isEmpty || 
        _firstNameController.text.isEmpty || 
        _lastNameController.text.isEmpty ||
        _dobController.text.isEmpty ) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Please fill in all required fields"),
        )
      );
      return;
    }
    if (_dobController.text.length < 8) { 
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Please enter a valid Date of Birth (e.g., YYYY-MM-DD)"),
      )
    );
    return;
  }
    try{
      await _auth.signUp(
        _emailController.text, 
        _pwController.text,
        _usernameController.text,
        _firstNameController.text, 
        _lastNameController.text,  
        _dobController.text,      
      );
      
    

    } catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                //first name textfield
                MyTextfield(
                  hintText: "First Name",
                  obscureText: false,
                  controller: _firstNameController,
                ), 
                const SizedBox(height: 10),

                // Last Name textfield (NEW)
                MyTextfield(
                  hintText: "Last Name",
                  obscureText: false,
                  controller: _lastNameController,
                ), 
                const SizedBox(height: 10),

                //date of birth textfield
               GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer( // Prevents manual  input
                  child: MyTextfield(
                    hintText: "Date of Birth (YYYY-MM-DD)",
                    obscureText: false,
                    controller: _dobController,
                  ),
                ),
              ),
                const SizedBox(height: 10),

                //username textfield
                MyTextfield(
                  hintText: "Username (Unique)",
                  obscureText: false,
                  controller: _usernameController,
                ), 
                const SizedBox(height: 10),


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
                  onTap: () => register(context),
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
        ),
      ),
    );
    }
    }