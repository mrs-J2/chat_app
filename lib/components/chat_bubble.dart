/*import 'dart:convert';

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget{
  final String message;
  final bool isCurrentUser;
  final bool isImage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isImage= false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
      color: isCurrentUser ? Colors.green : Colors.grey.shade500 ,
      borderRadius: BorderRadius.circular(12)
    ),
    padding:const EdgeInsets.all(16),
    margin: EdgeInsets.symmetric(vertical: 2.5,horizontal: 25),
    child: isImage
    ?ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                base64Decode(message.contains('|') ? message.split('|')[1] : message),
                
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
    : Text(
      message,
      style: TextStyle(color: Colors.white),
    )
    
    )
    ;
  }
}*/