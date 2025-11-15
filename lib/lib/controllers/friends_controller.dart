import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/friends/friends_service.dart';

class FriendsController extends ChangeNotifier {
  final FriendsService _friendsService = FriendsService();
  bool get hasIncomingRequests => friendRequests.isNotEmpty;

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

  // --------------------------------------------------------------
  // 1. Real-time listeners (server-first)
  // --------------------------------------------------------------
  void _listenToUsers() {
    // ---- all other users ------------------------------------------------
    _allUsersSub = _friendsService.getAllUsers().listen((users) {
      allUsers = users;
      notifyListeners();
    });

    // ---- current user (force server on first read) ----------------------
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

  // --------------------------------------------------------------
  // 2. Initial fetch from server (bypass cache)
  // --------------------------------------------------------------
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

  // --------------------------------------------------------------
  // 3. Public refresh (pull-to-refresh)
  // --------------------------------------------------------------
  Future<void> refresh() async => _fetchInitialData();

  // --------------------------------------------------------------
  // 4. Service wrappers
  // --------------------------------------------------------------
  Future<void> sendRequest(String uid) => _friendsService.sendFriendRequest(uid);
  Future<void> acceptRequest(String uid) => _friendsService.acceptFriendRequest(uid);
  Future<void> declineRequest(String uid) => _friendsService.declineFriendRequest(uid);
  Future<void> removeFriend(String uid) => _friendsService.removeFriend(uid);
  Future<void> cancelSentRequest(String uid) => _friendsService.cancelSentRequest(uid);
  Future<UserModel?> getUser(String uid) => _friendsService.getUser(uid);

  // Shortcut to Firestore (used above)
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
}