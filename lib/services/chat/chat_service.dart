
import '../../models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // delete entire chat
  Future<void> deleteChat(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID]..sort();
    String chatroomID = ids.join('_');

    final messagesRef = _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages");

    final snapshot = await messagesRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // send message
  Future<void> sendMessage(
  String recieverID,
  String message, {
  bool isImage = false,
  bool isFile = false,
  String? fileName,

}) async {
  final String currentUserID = _auth.currentUser!.uid;
  final String currentUserEmail = _auth.currentUser!.email!;
  final Timestamp timestamp = Timestamp.now();
  

  Message newMessage = Message(
    senderID: currentUserID,
    senderEmail: currentUserEmail,
    recieverID: recieverID,
    message: message,
    timestamp: timestamp,
    isImage: isImage,
    isFile: isFile,
    fileName: fileName, 
    heartCount: 0,
    seen: false,
  );

  List<String> ids = [currentUserID, recieverID]..sort();
  String chatroomID = ids.join('_');

  await _firestore
      .collection("chat_rooms")
      .doc(chatroomID)
      .collection("messages")
      .add(newMessage.toMap());
}

  // send image
  Future<void> sendImageMessage(String receiverID, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uniqueMessage = "${DateTime.now().millisecondsSinceEpoch}|$base64Image";

      await sendMessage(receiverID, uniqueMessage, isImage: true);
      print('Image sent successfully');
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  // send file
  Future<void> sendFileMessage(String receiverID, File file) async {
  try {
    final bytes = await file.readAsBytes();

    // Safety: prevent Firestore overflow
    if (bytes.lengthInBytes > 700 * 1024) {
      print("File too large: ${bytes.lengthInBytes / 1024} KB. Max 700 KB.");
      return;
    }

    final base64File = base64Encode(bytes);
    final fileName = file.path.split('/').last; // e.g., "document.pdf"

    final uniqueMessage = "${DateTime.now().millisecondsSinceEpoch}|$base64File";

    // FIXED: Pass fileName correctly
    await sendMessage(receiverID, uniqueMessage, isFile: true, fileName: fileName);

    print("File sent: $fileName");
  } catch (e) {
    print("Error sending file: $e");
  }
}

  // TOGGLE HEART (Instagram-style)
  Future<void> toggleHeart(String receiverID, String messageId, bool addHeart) async {
    final currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID]..sort();
    String chatroomID = ids.join('_');

    final messageRef = _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .doc(messageId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(messageRef);
      if (!snapshot.exists) return;

      final currentCount = snapshot.data()?['heartCount'] ?? 0;
      final newCount = addHeart ? currentCount + 1 : currentCount;

      transaction.update(messageRef, {'heartCount': newCount});
    });
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserID) {
    List<String> ids = [userId, otherUserID]..sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}