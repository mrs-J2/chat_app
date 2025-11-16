import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  
  final String firstName;
  final String lastName;
  

  final String? dob;
  final String? profilePicUrl;

  final List<String>? friends;
  final List<String>? friendRequests;
  final List<String>? sentRequests;
  final bool isOnline;
  final Timestamp? lastSeen;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,     
    required this.lastName,      
    this.dob,              
    this.profilePicUrl,     
    this.friends,
    this.friendRequests,
    this.sentRequests,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      firstName: data['firstName'] ?? '',     
      lastName: data['lastName'] ?? '',       
      dob: data['dob'],                   
      profilePicUrl: data['profilePicUrl'],    
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friendRequests'] ?? []),
      sentRequests: List<String>.from(data['sentRequests'] ?? []),
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'firstName': firstName,     
      'lastName': lastName,       
      'dob': dob, 
      'profilePicUrl': profilePicUrl,                
      'friends': friends ?? [],
      'friendRequests': friendRequests ?? [],
      'sentRequests': sentRequests ?? [],
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }
}