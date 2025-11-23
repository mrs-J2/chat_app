import 'package:flutter/material.dart';
class MyTextfield extends StatelessWidget{
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Function(String)? onSubmitted;

  const MyTextfield({super.key,
  required this.hintText,
  required this.obscureText,
  required this.controller,
  this.onSubmitted,
  
});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}