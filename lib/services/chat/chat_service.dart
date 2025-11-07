import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
class ChatService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  //get user stream
  /*
  List<Map<String,dynamic>> = 
  [
    { 
      'email' : test@gmail.com,
      'id': ..
    }
    {
      'email' : test@gmail.com,
      'id': ..
    }
  ]
   */
  Stream<List<Map<String,dynamic>>> getUsersStream(){
    return _firestore.collection("users").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        //go through each user
        final user = doc.data();
        return user;
      }).toList();
    });
  }
  //send msg 
  Future<void> sendMessage(String recieverID, message, {bool isImage = false}) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create  new msg
    Message newMessage = Message(
      senderID:currentUserID ,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp,
      isImage:isImage);

    //construct chat room ID for the two users
    List<String> ids = [currentUserID, recieverID];
    ids.sort(); //sort the ids (this ensure the chatroomID is th esame for any 2 people)
    String chatroomID = ids.join('_');
    
    // add new message to database
    await _firestore
    .collection("chat_rooms")
    .doc(chatroomID)
    .collection("messages")
    .add(newMessage.toMap());
  }
   Future<void> sendImageMessage(String receiverID) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return; // user cancelled

      File imageFile = File(pickedImage.path);
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uniqueMessage = "${DateTime.now().millisecondsSinceEpoch}|$base64Image";

      await sendMessage(receiverID, uniqueMessage, isImage: true);
      print('✅ Image sent successfully ');
    } catch (e) {
      print('❌ Error sending image: $e');
    }
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userId, otherUserID){
    //construct a chatroom ID for the two users
    List<String> ids = [userId, otherUserID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
      .collection("chat_rooms")
      .doc(chatroomID)
      .collection("messages")
      .orderBy("timestamp", descending: false)
      .snapshots();
  }
}