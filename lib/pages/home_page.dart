import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/settings_page.dart';

class HomePage extends StatelessWidget{
   HomePage({super.key});

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();


  void settings(BuildContext context){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const SettingsPage()));
  }


  @override 
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: MyDrawer(),
      body: _buildUserList(),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Chats"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        ),
      );
  }


  //build a list of users exceptforthe current logged in user
  Widget _buildUserList(){
    return  StreamBuilder(
      stream: _chatService.getUsersStream(),
       builder: (context,snapshot){
        //error
        if (snapshot.hasError){
          return const Center(
            child: Text(
              "⚠️ Something went wrong",
              style: TextStyle(fontSize: 16, color: Colors.redAccent),));

        }
        //loading..
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Text("Loading..");
        }
        //return list view 
        return ListView(
        children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData,context)).toList(),
        );
       },
       );

  }
  //build individual list tile for user
  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  final currentUserEmail = _authService.getCurrentUser()?.email;

  // Skip current user
  if (userData["email"] != currentUserEmail) {
    final username = userData["username"] ?? "Unknown";
    final email = userData["email"] ?? "No email";
    final uid = userData["uid"] ?? "";

    return UserTile(
      text: username,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              recieverEmail: email,
              recieverID: uid,
              recieverUsername: username,
            ),
          ),
        );
      },
    );
  } else {
    return const SizedBox.shrink();
  }
}

}