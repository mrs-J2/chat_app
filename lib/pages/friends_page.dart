// lib/pages/friends_page.dart
import '../controllers/friends_controller.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FriendsController>(context);

    final friendsList = controller.allUsers
        .where((u) => controller.friends.contains(u.uid))
        .toList();
    final otherUsers = controller.allUsers
        .where((u) => !controller.friends.contains(u.uid))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        elevation: 0,
      ),
      body: controller.allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("My Friends",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  if (friendsList.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("You have no friends yet"))),
                  ...friendsList
                      .map((u) => _buildFriendTile(context, controller, u)),

                  const Divider(thickness: 1.5),

                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Add Friends",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  ...otherUsers.map((u) => _buildUserTile(context, controller, u)),
                ],
              ),
            ),
    );
  }

  Widget _buildFriendTile(
      BuildContext ctx, FriendsController ctrl, UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
            ? NetworkImage(user.profilePicUrl!)
            : null,
        child: user.profilePicUrl == null || user.profilePicUrl!.isEmpty
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
      onTap: () => Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            recieverEmail: user.email,
            recieverID: user.uid,
            recieverUsername: user.username,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(Icons.call, color: Colors.blueAccent),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ctrl.removeFriend(user.uid)),
        ],
      ),
    );
  }

  Widget _buildUserTile(
      BuildContext ctx, FriendsController ctrl, UserModel user) {
    final incoming = ctrl.friendRequests.contains(user.uid);
    final outgoing = ctrl.sentRequests.contains(user.uid);

    Widget trailing;
    if (incoming) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => ctrl.acceptRequest(user.uid)),
          IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => ctrl.declineRequest(user.uid)),
        ],
      );
    } else if (outgoing) {
      trailing = TextButton.icon(
        icon: const Icon(Icons.hourglass_top, color: Colors.orange),
        label: const Text("Cancel", style: TextStyle(color: Colors.orange)),
        onPressed: () => ctrl.cancelSentRequest(user.uid),
      );
    } else {
      trailing = TextButton.icon(
        icon: const Icon(Icons.person_add),
        label: const Text("Add"),
        onPressed: () => ctrl.sendRequest(user.uid),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
            ? NetworkImage(user.profilePicUrl!)
            : null,
        child: user.profilePicUrl == null || user.profilePicUrl!.isEmpty
            ? const Icon(Icons.person_outline)
            : null,
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
      onTap: () {
        if (ctrl.friends.contains(user.uid)) {
          Navigator.push(
            ctx,
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
            context: ctx,
            builder: (_) => AlertDialog(
              title: const Text("Not Friends"),
              content: const Text("You can’t message this user until you’re friends."),
              actions: [
                IconButton(icon: Icon(Icons.verified), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
          );
        }
      },
      trailing: trailing,
    );
  }
}