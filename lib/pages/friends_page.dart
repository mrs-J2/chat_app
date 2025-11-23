// lib/pages/friends_page.dart
import '../controllers/friends_controller.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';
import '../components/my_drawer.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FriendsController>(context);    // Filter users based on search
    final allUsers = controller.allUsers.where((user) {
      final username = user.username.toLowerCase();
      final email = user.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return username.contains(query) || email.contains(query);
    }).toList();

    final friendsList = allUsers.where((u) => controller.friends.contains(u.uid)).toList();
    final otherUsers = allUsers.where((u) => !controller.friends.contains(u.uid)).toList();

    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text("Friends"),
        elevation: 0,
      ),
      body: Stack(
  children: [
    // BACKGROUND IMAGE (theme-based)
    Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            Theme.of(context).brightness == Brightness.light
                ? "lib/assets/icon/light.jpg"
                : "lib/assets/icon/dark.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
    ),

    // PAGE CONTENT
    Column(
      children: [
        // SEARCH BAR
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search by username or email...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // LIST
        Expanded(
          child: controller.allUsers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text("My Friends",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      if (friendsList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No friends match your search"),
                        ),
                      ...friendsList.map(
                          (u) => _buildFriendTile(context, controller, u)),

                      if (otherUsers.isNotEmpty) ...[
                        const Divider(thickness: 1.5),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text("Add Friends",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        ...otherUsers.map(
                            (u) => _buildUserTile(context, controller, u)),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    ),
  ],
),

    );
  }
  
  Widget _buildFriendTile(BuildContext ctx, FriendsController ctrl, UserModel user) {
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
        // Eye Icon → Show Profile Info
        IconButton(
          icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
          onPressed: () {
            showDialog(
              context: ctx,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
                          ? NetworkImage(user.profilePicUrl!)
                          : null,
                      child: user.profilePicUrl == null || user.profilePicUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user.firstName} ${user.lastName}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "@${user.username}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _infoRow(Icons.email, "Email", user.email),
                    if (user.dob != null) _infoRow(Icons.cake, "Birthday", user.dob!),
                    _infoRow(Icons.person, "Full Name", "${user.firstName} ${user.lastName}"),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Delete Friend
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => ctrl.removeFriend(user.uid),
        ),
      ],
    ),
  );
}

// Helper widget for clean info rows
Widget _infoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildUserTile(BuildContext ctx, FriendsController ctrl, UserModel user) {
    // ← your existing method 100% unchanged
    final incoming = ctrl.friendRequests.contains(user.uid);
    final outgoing = ctrl.sentRequests.contains(user.uid);

    Widget trailing;
    if (incoming) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => ctrl.acceptRequest(user.uid)),
          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => ctrl.declineRequest(user.uid)),
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
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
              ],
            ),
          );
        }
      },
      trailing: trailing,
    );
  }
}