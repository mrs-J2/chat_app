import '../pages/edit_profile_page.dart';
import '../services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../models/user_model.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onThemeToggle;
  const SettingsPage({super.key, this.onThemeToggle});

  // Helper function to build a section title
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper for Logout dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              AuthService().signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              "Log Out",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService().getCurrentUser()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              // 2. ACCOUNT SETTINGS GROUP
              _buildSectionTitle("Account", context),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: colorScheme.secondary),
                  title: const Text("Edit Profile"),
                  subtitle: Text(user.email ?? "Update your information"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();

                    if (!doc.exists) return;

                    final data = doc.data()!;
                    final userModel = UserModel(
                      uid: user.uid,
                      email: user.email!,
                      username: data['username'] ?? '',
                      firstName: data['firstName'] ?? '',
                      lastName: data['lastName'] ?? '',
                      dob: data['dob'],
                      profilePicUrl: data['profilePicUrl'],
                      isOnline: data['isOnline'] ?? false,
                      lastSeen: data['lastSeen'],
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: userModel),
                        ),
                      );
                    }
                  },
                ),
              ),

              // 3. APP APPEARANCE GROUP
              _buildSectionTitle("App Appearance", context),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: isDark,
                  secondary: Icon(
                    isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: colorScheme.secondary,
                  ),
                  onChanged: (_) => onThemeToggle?.call(),
                ),
              ),

              // 4. ACTIONS GROUP (Logout)
              _buildSectionTitle("Actions", context),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.logout_outlined, color: colorScheme.error),
                  title: Text(
                    "Log Out",
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),

        // 5. VERSION FOOTER
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0, top: 10),
          child: Text(
            "App Version 1.0.0",
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onBackground.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  ],
),

    );
  }

}
