// ignore_for_file: duplicate_import

import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/friends_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/settings_page.dart';

import 'package:chat_app/controllers/friends_controller.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
   const HomePage({super.key});
   @override 
   State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;


  void settings(BuildContext context){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const SettingsPage()));
  }


  @override 
  Widget build(BuildContext context){
    final controller = Provider.of<FriendsController>(context);
    final List<Widget> _pages = [
      _buildFriendsChatList(),
      const FriendsPage(), 
      const SettingsPage(), 
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: MyDrawer(),
      body: _pages[_selectedIndex],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Chats"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(
            icon:
            Stack(
              clipBehavior: Clip.none,
              children: [
              Icon(Icons.people), 
              if (controller.friendRequests.isNotEmpty)
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      );
  }


  Widget _buildFriendsChatList() {
    return Consumer<FriendsController>(
      builder: (context, controller, _) {
        final currentUser = _authService.getCurrentUser()!;
        final friendUsers = controller.allUsers
            .where((user) => controller.friends.contains(user.uid))
            .toList();

        if (friendUsers.isEmpty) {
          return const Center(child: Text("No friends yet."));
        }

        return ListView(
          children: friendUsers.map((user) {
            return UserTile(
              text: user.username,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      recieverEmail: user.email,
                      recieverID: user.uid,
                      recieverUsername: user.username,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}