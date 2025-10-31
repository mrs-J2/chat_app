import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatService{
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  
  //get message

}