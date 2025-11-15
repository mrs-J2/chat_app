class UserModel {
  final String uid;
  final String email;
  final String username;
  final List<String>? friends;
  final List<String>? friendRequests;
  final List<String>? sentRequests;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.friends,
    this.friendRequests,
    this.sentRequests,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friendRequests'] ?? []),
      sentRequests: List<String>.from(data['sentRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'friends': friends ?? [],
      'friendRequests': friendRequests ?? [],
      'sentRequests': sentRequests ?? [],
    };
  }
}
