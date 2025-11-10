import 'package:chat_app/controllers/friends_controller.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FriendsController>(context);

    // Separate friends and non-friends
    final friendsList = controller.allUsers
        .where((user) => controller.friends.contains(user.uid))
        .toList();
    final otherUsers = controller.allUsers
        .where((user) => !controller.friends.contains(user.uid))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey[800],
        elevation: 0,
      ),
      body: controller.allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FRIENDS SECTION
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "My Friends",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (friendsList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("You have no friends yet 😢"),
                      ),
                    )
                  else
                    ...friendsList.map((user) => _buildFriendTile(context, controller, user)),

                  const Divider(thickness: 1.5),

                  // OTHER USERS SECTION
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add Friends",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...otherUsers.map((user) => _buildUserTile(context, controller, user)),
                ],
              ),
            ),
    );
  }

  Widget _buildFriendTile(BuildContext context, FriendsController controller, UserModel user) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.username),
      subtitle: Text(user.email),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.blueAccent),
            onPressed: () {
              // later
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => controller.removeFriend(user.uid),
          ),
        ],
      ),
    );
  }
Widget _buildUserTile(BuildContext context, FriendsController controller, UserModel user) {
  final hasRequest = controller.friendRequests.contains(user.uid);
  final sentRequest = controller.sentRequests.contains(user.uid);

  Widget trailingWidget;

  if (hasRequest) {
    // Incoming request
    trailingWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => controller.acceptRequest(user.uid),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => controller.declineRequest(user.uid),
        ),
      ],
    );
  } else if (sentRequest) {
    // Outgoing request - show cancel option
    trailingWidget = TextButton.icon(
      icon: const Icon(Icons.hourglass_top, color: Colors.orange),
      label: const Text("Cancel", style: TextStyle(color: Colors.orange)),
      onPressed: () => controller.cancelSentRequest(user.uid),
    );
  } else {
    // Not friends yet
    trailingWidget = TextButton.icon(
      icon: const Icon(Icons.person_add),
      label: const Text("Add"),
      onPressed: () => controller.sendRequest(user.uid),
    );
  }

  return ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
    title: Text(user.username),
    subtitle: Text(user.email),
    onTap: () {
    final isFriend = controller.friends.contains(user.uid);
    if (isFriend) {
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Not Friends"),
          content: const Text("You can’t message this user until you’re friends."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  },

    trailing: trailingWidget,
  );
}

  }
