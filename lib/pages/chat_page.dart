import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

    final TextEditingController _messageController = TextEditingController();
    final ChatService _chatService = ChatService();
    final AuthService _authService = AuthService();
    final ImagePicker _picker = ImagePicker();



    //send message
    void sendMessage() async {
      if(_messageController.text.isNotEmpty){
        await _chatService.sendMessage(recieverID,_messageController.text);
        _messageController.clear();

      }

    }
// Send image message

Future<void> sendImageMessage(String receiverID) async {
  try {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;

    final bytes = await File(pickedImage.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    await _chatService.sendImageMessage(receiverID);

    print('✅ Image sent');
  } catch (e) {
    print('❌ Error sending image: $e');
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



  // msg item
  Widget _buildMesageItem(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String,dynamic>;
    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    //align msg to right if sender is current user else left
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft ;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (data['isImage'] == true)
            _buildImageBubble(data['message'])
          else
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser,)
        ],
      ));

  }
Widget _buildImageBubble(String base64String) {
  try {
    Uint8List bytes = base64Decode(base64String);
    return Container(
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.memory(
        bytes,
        fit: BoxFit.cover,
      ),
    );
  } catch (e) {
    return const Text("Error loading image");
  }
}
// message input
Widget _buildUserInput(){
  return Padding(
    padding: const EdgeInsets.only(bottom: 50.0),
    child: Row(children: [
      //  Attachment button
          IconButton(
            onPressed: () => sendImageMessage(recieverID),
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),
      
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