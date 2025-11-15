import 'package:chat_app_main/components/my_textfield.dart';
import 'package:chat_app_main/services/auth/auth_service.dart';
import 'package:chat_app_main/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart'; 

class ChatPage extends StatelessWidget {
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

  // send text message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(recieverID, _messageController.text);
      _messageController.clear();
    }
  }

  // send image
  Future<void> sendImageMessage(String receiverID) async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return; 
      File imageFile = File(pickedImage.path); 
      await _chatService.sendImageMessage(receiverID, imageFile); 
      print('✅ Image sent successfully');
    } catch (e) {
      print('❌ Error sending image: $e');
    }
  }

  // send any file
  Future<void> sendFile(String receiverID) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      File file = File(result.files.single.path!);
      await _chatService.sendFileMessage(receiverID, file);

      print("📁 File sent successfully: ${file.path.split('/').last}");
    } catch (e) {
      print("❌ Error sending file: $e");
    }
  }

  // format timestamp
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(recieverUsername),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(recieverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading messages..."));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          reverse: true,
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    Alignment alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    Timestamp timestamp = data['timestamp'];
    String formattedTime = _formatTimestamp(timestamp);

    Widget messageContent;

    if (data['isImage'] == true) {
      messageContent = _buildImageBubble(data['message']);
    } else if (data['isFile'] == true) {
      messageContent = _buildFileBubble(data['fileName'] ?? "Unknown File");
    } else {
      messageContent = ChatBubble(
        clipper: ChatBubbleClipper1(
          type: isCurrentUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
        ),
        alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        backGroundColor: isCurrentUser ? Colors.green : Colors.grey.shade500,
        child: Text(
          data["message"],
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          messageContent,
          Padding(
            padding: EdgeInsets.only(
              top: 2,
              bottom: 10,
              left: isCurrentUser ? 0 : 25,
              right: isCurrentUser ? 25 : 0,
            ),
            child: Text(
              formattedTime,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(String base64String) {
    try {
      final String imageBase64 = base64String.contains('|')
          ? base64String.split('|')[1]
          : base64String;
      Uint8List bytes = base64Decode(imageBase64);
      return Container(
        constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade200,
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.memory(bytes, fit: BoxFit.cover),
      );
    } catch (e) {
      return const Text("Error loading image");
    }
  }

  Widget _buildFileBubble(String fileName) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onSelected: (value) {
              if (value == 0) sendImageMessage(recieverID);
              if (value == 1) sendFile(recieverID);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text("Send Image")),
              const PopupMenuItem(value: 1, child: Text("Send File")),
            ],
          ),
          Expanded(
            child: MyTextfield(
              hintText: "Type a message..",
              obscureText: false,
              controller: _messageController,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
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
