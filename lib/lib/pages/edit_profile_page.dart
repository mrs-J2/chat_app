// lib/pages/edit_profile_page.dart
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _dobController;
  late final TextEditingController _profilePicController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _dobController = TextEditingController(text: widget.user.dob ?? '');
    _profilePicController = TextEditingController(text: widget.user.profilePicUrl ?? '');
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'SELECT DATE OF BIRTH',
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _dobController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'dob': _dobController.text,
        'profilePicUrl': _profilePicController.text.trim().isEmpty
            ? null
            : _profilePicController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            MyTextfield(
              hintText: "First Name",
              obscureText: false,
              controller: _firstNameController,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Last Name",
              obscureText: false,
              controller: _lastNameController,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: MyTextfield(
                  hintText: "Date of Birth (YYYY-MM-DD)",
                  obscureText: false,
                  controller: _dobController,
                ),
              ),
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Username",
              obscureText: false,
              controller: _usernameController,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Profile Picture URL (optional)",
              obscureText: false,
              controller: _profilePicController,
            ),
            const SizedBox(height: 30),
            MyButton(
              text: "Save Changes",
              onTap: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _profilePicController.dispose();
    super.dispose();
  }
}