import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ChatService {
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
    },
    {
      'email' : test@gmail.com,
      'id': ..
    }
  ]
  */
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go through each user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //send msg 
  Future<void> sendMessage(String recieverID, message, {bool isImage = false,bool isFile = false, String? fileName}) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create new msg
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp,
      isImage: isImage,
      isFile: isFile,
      fileName: fileName,
    );

    //construct chat room ID for the two users
    List<String> ids = [currentUserID, recieverID];
    ids.sort(); //sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatroomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> sendImageMessage(String receiverID, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uniqueMessage = "${DateTime.now().millisecondsSinceEpoch}|$base64Image";

      await sendMessage(receiverID, uniqueMessage, isImage: true);
      print('✅ Image sent successfully');
    } catch (e) {
      print('❌ Error sending image: $e');
    }
  }
  Future<void> sendFileMessage(String receiverID, File file) async {
  try {
    final bytes = await file.readAsBytes();

    // 🔹 Safety check: prevent Firestore size overflow
    if (bytes.lengthInBytes > 700 * 1024) {
      print("⚠️ File too large (${bytes.lengthInBytes / 1024} KB). Max 700 KB allowed.");
      return;
    }

    final base64File = base64Encode(bytes);
    final fileName = file.path.split('/').last;

    final uniqueMessage = "${DateTime.now().millisecondsSinceEpoch}|$base64File";

    await sendMessage(receiverID, uniqueMessage, isFile: true, fileName: fileName);

    print("📁 File sent successfully: $fileName");
  } catch (e) {
    print("❌ Error sending file: $e");
  }
}


  //get message
  Stream<QuerySnapshot> getMessages(String userId, otherUserID) {
    //construct a chatroom ID for the two users
    List<String> ids = [userId, otherUserID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: true) // Changed to descending: true to show new messages first
        .snapshots();
  }
}
