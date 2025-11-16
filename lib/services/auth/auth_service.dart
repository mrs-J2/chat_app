import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // check if a username is used
  Future<void> checkUsernameUniqueness(String username) async {
    final snapshot = await _firestore
        .collection("users")
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      throw Exception('username-already-in-use');
    }
  }

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 🔐 sign in
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ only create Firestore document if it doesn't exist yet
      final docRef =
          _firestore.collection("users").doc(userCredential.user!.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'uid': userCredential.user!.uid,
          'email': email,
          'username': '', // placeholder
          'firstName': '',
          'lastName': '',
          'dateOfBirth': null,
          'timestamp': Timestamp.now(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // 🧾 sign up
  Future<UserCredential> signUp(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
    String dob,
  ) async {
    try {
      await checkUsernameUniqueness(username);

      // create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dob,
        'timestamp': Timestamp.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      if (e.toString().contains('username-already-in-use')) {
        throw Exception('The username is already taken.');
      }
      throw e;
    }
  }

  // 🚪 sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
