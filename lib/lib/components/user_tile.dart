import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String? profilePicUrl;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.text,
    this.profilePicUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 20,
              backgroundImage: profilePicUrl != null && profilePicUrl!.isNotEmpty
                  ? NetworkImage(profilePicUrl!)
                  : null,
              child: profilePicUrl == null || profilePicUrl!.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 16),

            // Username
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}