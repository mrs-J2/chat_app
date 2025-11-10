import 'package:chat_app/services/friends/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/user_model.dart';

class FriendsController extends ChangeNotifier {
  final FriendsService _friendsService = FriendsService();
  bool get hasIncomingRequests => friendRequests.isNotEmpty;

  List<UserModel> allUsers = [];
  List<String> friends = [];
  List<String> friendRequests = [];
  List<String> sentRequests = [];


  FriendsController() {
    _listenToUsers();
  }

void _listenToUsers() {
  // Listen to all users (only once per change)
  _friendsService.getAllUsers().listen((users) {
    allUsers = users;
    notifyListeners();
  });

  // Listen to current user's own data
  _friendsService.getUserStream(_friendsService.currentUser!.uid).listen((user) {
    if (user != null) {
      friends = user.friends ?? [];
      friendRequests = user.friendRequests ?? [];
      sentRequests = user.sentRequests ?? [];
      notifyListeners();
    }
  });
}


  Future<void> sendRequest(String uid) async {
    await _friendsService.sendFriendRequest(uid);
  }

  Future<void> acceptRequest(String uid) async {
    await _friendsService.acceptFriendRequest(uid);
  }

  Future<void> declineRequest(String uid) async {
    await _friendsService.declineFriendRequest(uid);
  }

  Future<void> removeFriend(String uid) async {
    await _friendsService.removeFriend(uid);
  }
  Future<void> cancelSentRequest(String uid) async {
  await _friendsService.cancelSentRequest(uid);
}


  Future<UserModel?> getUser(String uid) async {
    return await _friendsService.getUser(uid);
  }
}
