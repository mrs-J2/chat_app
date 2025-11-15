import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/models/user_model.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Get current user
  User? get currentUser => _auth.currentUser;

  //  Get user model by uid
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!,uid);
    } else {
      return null;
    }
  }

  //  Get all users except current one
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUser?.uid)
          .map((doc) => UserModel.fromMap(doc.data(),doc.id))
          .toList();
    });
  }
  Stream<UserModel?> getUserStream(String uid) {
  return _firestore.collection('users').doc(uid).snapshots().map((doc) {
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    } else {
      return null;
    }
  });
}


  // Send friend request
  Future<void> sendFriendRequest(String receiverId) async {
    final senderId = currentUser!.uid;
    final senderRef = _firestore.collection('users').doc(senderId);
    final receiverRef = _firestore.collection('users').doc(receiverId);
    await receiverRef.update({
      'friendRequests': FieldValue.arrayUnion([senderId])
    });
    await senderRef.update({
    'sentRequests': FieldValue.arrayUnion([receiverId]),
  });
  }

  //  Accept friend request
  Future<void> acceptFriendRequest(String senderId) async {
    final currentId = currentUser!.uid;
    final currentRef = _firestore.collection('users').doc(currentId);
    final senderRef = _firestore.collection('users').doc(senderId);

    // Add each other to friends
    await currentRef.update({
      'friends': FieldValue.arrayUnion([senderId]),
      'friendRequests': FieldValue.arrayRemove([senderId]),
    });

    await senderRef.update({
      'friends': FieldValue.arrayUnion([currentId]),
    });
  }

  // ✅ Decline friend request
  Future<void> declineFriendRequest(String senderId) async {
    final currentId = currentUser!.uid;
    final currentRef = _firestore.collection('users').doc(currentId);

    await currentRef.update({
      'friendRequests': FieldValue.arrayRemove([senderId]),
    });
  }
  Future<void> cancelSentRequest(String receiverId) async {
  final senderId = currentUser!.uid;

  final senderRef = _firestore.collection('users').doc(senderId);
  final receiverRef = _firestore.collection('users').doc(receiverId);

  await senderRef.update({
    'sentRequests': FieldValue.arrayRemove([receiverId]),
  });

  await receiverRef.update({
    'friendRequests': FieldValue.arrayRemove([senderId]),
  });
}


  // ✅ Remove friend
  Future<void> removeFriend(String friendId) async {
    final currentId = currentUser!.uid;
    final currentRef = _firestore.collection('users').doc(currentId);
    final friendRef = _firestore.collection('users').doc(friendId);

    await currentRef.update({
      'friends': FieldValue.arrayRemove([friendId]),
    });

    await friendRef.update({
      'friends': FieldValue.arrayRemove([currentId]),
    });
  }
}
