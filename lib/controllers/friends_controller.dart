import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/friends/friends_service.dart';

class FriendsController extends ChangeNotifier {
  final FriendsService _friendsService = FriendsService();
  bool get hasIncomingRequests => friendRequests.isNotEmpty;
  bool isLoading = false;
  List<UserModel> allUsers = [];
  List<String> friends = [];
  List<String> friendRequests = [];
  List<String> sentRequests = [];

  late final StreamSubscription<UserModel?> _userSub;
  late final StreamSubscription<List<UserModel>> _allUsersSub;

  FriendsController() {
    _listenToUsers();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _userSub.cancel();
    _allUsersSub.cancel();
    super.dispose();
  }


  void _listenToUsers() {
    _allUsersSub = _friendsService.getAllUsers().listen((users) {
      allUsers = users;
      notifyListeners();
    });

    final uid = _friendsService.currentUser!.uid;
    _userSub = _firestore
        .collection('users')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null)
        .listen((user) {
      if (user != null) {
        friends = user.friends ?? [];
        friendRequests = user.friendRequests ?? [];
        sentRequests = user.sentRequests ?? [];
        notifyListeners();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchInitialAllUsers(),
      _fetchInitialCurrentUser(),
    ]);
  }

  Future<void> _fetchInitialAllUsers() async {
    try {
      final uid = _friendsService.currentUser!.uid;
      final snap = await _firestore
          .collection('users')
          .get(const GetOptions(source: Source.server));

      allUsers = snap.docs
          .where((d) => d.id != uid)
          .map((d) => UserModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchAllUsers error: $e');
    }
  }

  Future<void> _fetchInitialCurrentUser() async {
    try {
      final uid = _friendsService.currentUser!.uid;
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.server));

      if (doc.exists) {
        final u = UserModel.fromMap(doc.data()!, doc.id);
        friends = u.friends ?? [];
        friendRequests = u.friendRequests ?? [];
        sentRequests = u.sentRequests ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchCurrentUser error: $e');
    }
  }

  Future<void> refresh() async {
  isLoading = true;
  notifyListeners();

  try {
    // Re-fetch everything from server (exactly like initial load)
    await Future.wait([
      _fetchInitialAllUsers(),
      _fetchInitialCurrentUser(),
    ]);
  } catch (e) {
    debugPrint("Refresh failed: $e");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
  Future<void> sendRequest(String uid) => _friendsService.sendFriendRequest(uid);
  Future<void> acceptRequest(String uid) => _friendsService.acceptFriendRequest(uid);
  Future<void> declineRequest(String uid) => _friendsService.declineFriendRequest(uid);
  Future<void> removeFriend(String uid) => _friendsService.removeFriend(uid);
  Future<void> cancelSentRequest(String uid) => _friendsService.cancelSentRequest(uid);
  Future<UserModel?> getUser(String uid) => _friendsService.getUser(uid);

  // Shortcut to Firestore (used above)
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
}