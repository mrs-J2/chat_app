import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ChatPage extends StatelessWidget{
  final String recieverEmail;
  final String recieverID;

  ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
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
      appBar: AppBar(title: Text(recieverEmail)),
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
    return Text(data["message"]);
  }
//build message input
Widget _buildUserInput(){
  return Row(children: [
    //textfield should take most of space
    Expanded(child: MyTextfield(
      hintText: "Type a message..",
      obscureText: false,
      controller: _messageController),
    ),

    //send button
    IconButton(
      onPressed: sendMessage,
      icon: const Icon(Icons.arrow_upward),
      ),
  ],
  );
}


}