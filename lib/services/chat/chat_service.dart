import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService{
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
        //go through each individual user
        final user = doc.data();
        //return user
        return user;
      }).toList();
    });
  }
  //send message 
  Future<void> sendMessage(String recieverID, message) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID:currentUserID ,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp);

    //construct chat room ID for the two users (sorted to ensure uniqueness)
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