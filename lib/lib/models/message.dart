// lib/models/message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String recieverID;
  final String message;
  final Timestamp timestamp;
  final bool isImage;
  final bool isFile;
  final String? fileName;
  final int heartCount; // ← Only hearts

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.recieverID,
    required this.message,
    required this.timestamp,
    this.isImage = false,
    this.isFile = false,
    this.fileName,
    this.heartCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': recieverID,
      'message': message,
      'timestamp': timestamp,
      'isImage': isImage,
      'isFile': isFile,
      'fileName': fileName,
      'heartCount': heartCount,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      recieverID: map['recieverID'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'],
      isImage: map['isImage'] ?? false,
      isFile: map['isFile'] ?? false,
      fileName: map['fileName'],
      heartCount: map['heartCount'] ?? 0,
    );
  }
}