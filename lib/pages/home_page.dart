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
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed:()=> settings(context), 
            icon:const Icon(Icons.settings_rounded),)
        ],),
        //body: _buildUserList(),
      body: Container(
        decoration: BoxDecoration(
        ),
        child: _buildUserList(),
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
  Widget _buildUserListItem(
    Map<String, dynamic> userData, BuildContext context){
    //display all users except current user
    if(userData["email"] != _authService.getCurrentUser()!.email){
    return UserTile(
      text: userData["email"],
      onTap: () {
        //tapped on a user -> go to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => ChatPage(
            recieverEmail: userData["email"],
            recieverID: userData["uid"],
          ),
          ));
      },
    );
  } else{
    return  Container();
  
  }
  }
}