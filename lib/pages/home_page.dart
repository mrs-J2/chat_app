// ignore_for_file: duplicate_import

import '../components/user_tile.dart';
import '../pages/chat_page.dart';
import '../pages/friends_page.dart';
import '../services/auth/auth_service.dart';
import '../components/my_drawer.dart';
import '../services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';

import '../controllers/friends_controller.dart';
import '../pages/chat_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
   final VoidCallback? onThemeToggle;  
  const HomePage({super.key, this.onThemeToggle});
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
      Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text("Chats"),
        elevation: 0,
      ),
      body: _buildFriendsChatList(),
    ),
    const FriendsPage(),
    SettingsPage(onThemeToggle: widget.onThemeToggle),
    ];
    return Scaffold(
      drawer: MyDrawer(),
      body: _pages[_selectedIndex],
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
              profilePicUrl: user.profilePicUrl,
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