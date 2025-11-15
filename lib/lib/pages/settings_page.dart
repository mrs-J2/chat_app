// lib/pages/settings_page.dart
import 'package:chat_app/pages/edit_profile_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onThemeToggle;
  const SettingsPage({super.key, this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService().getCurrentUser()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDark,
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onChanged: (_) => onThemeToggle?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
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
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(user: userModel),
                ),
              );
            },
          ),
          const ListTile(
            title: Text("Version"),
            subtitle: Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}