import 'package:chat_app/components/chat_bubble.dart';

import 'package:chat_app/components/my_textfield.dart';

import 'package:chat_app/services/auth/auth_service.dart';

import 'package:chat_app/services/chat/chat_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget{

  final String recieverEmail;

  final String recieverID;

  final String recieverUsername;



  ChatPage({

    super.key,

    required this.recieverEmail,

    required this.recieverID,

    required this.recieverUsername,

    });



    //text controller

    final TextEditingController _messageController = TextEditingController();



    //chat & auth services

    final ChatService _chatService = ChatService();

    final AuthService _authService = AuthService();



    //send message

    void sendMessage() async {

      //if there is something inside the textfield

      if(_messageController.text.isNotEmpty){

        //send the message

        await _chatService.sendMessage(recieverID,_messageController.text);



        //clear the controller

        _messageController.clear();

      }

    }



  @override

  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(

        elevation: 0,

        title: Text(recieverUsername),

        backgroundColor: Colors.transparent,

        foregroundColor: Colors.grey,

        ),

      body: Column(

        children: [

          //display all the messages

          Expanded(child: _buildMesageList(),

          ),

          //user input

          _buildUserInput(),

        ],

      ),

    );

  }



  //build message list

  Widget _buildMesageList(){

    String senderID = _authService.getCurrentUser()!.uid;

    return StreamBuilder(

      stream: _chatService.getMessages(recieverID, senderID),

      builder: (context, snapshot){

        //errors

        if (snapshot.hasError){

          return const Text("Error");

        }

        //loading

        if (snapshot.connectionState == ConnectionState.waiting){

        return const Text("loading ..");

        }



        //return list view

        return ListView(

          children: snapshot.data!.docs.map(

            (doc) => _buildMesageItem(doc)).toList(),

        );

      });

  }



  //build message item

  Widget _buildMesageItem(DocumentSnapshot doc){

    Map<String, dynamic> data = doc.data() as Map<String,dynamic>;



    //is current user

    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;



    //align msg to right is sender is current user else left

    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft ;



    return Container(

      alignment: alignment,

      child: Column(

        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,

        children: [

          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)

        ],

      ));

  }

//build message input

Widget _buildUserInput(){

  return Padding(

    padding: const EdgeInsets.only(bottom: 50.0),

    child: Row(children: [

      //textfield should take most of space

      Expanded(child: MyTextfield(

        hintText: "Type a message..",

        obscureText: false,

        controller: _messageController),

      ),

   

      //send button

      Container(

        decoration: BoxDecoration(color: Colors.green,shape: BoxShape.circle),

        margin: const EdgeInsets.only(right: 25),

        child: IconButton(

          onPressed: sendMessage,

          icon: const Icon(Icons.arrow_upward, color: Colors.white),

          ),

      ),

    ],

    ),

  );

}





}