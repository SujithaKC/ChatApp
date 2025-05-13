import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/group_chat_viewmodel.dart';

// This file defines the `GroupCreateScreen` class, which provides the user interface for creating new groups.
// It includes input fields for group details and member selection.

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({Key? key}) : super(key: key);

  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _groupNameController = TextEditingController(); // Controller for the group name input field.
  final _memberEmailController = TextEditingController(); // Controller for the member email input field.
  final List<String> _memberIds = []; // List to store the IDs of added members.

  @override
  void dispose() { // Disposes controllers to free up resources.
    _groupNameController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  Future<String?> _fetchUserIdByEmail(String email) async { // Fetches a user's ID by their email from Firestore.
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();
      if (snapshot.docs.isEmpty) {
        return null; // Returns null if no user is found.
      }
      return snapshot.docs.first.id; // Returns the first matching user's ID.
    } catch (e) {
      return null; // Returns null in case of an error.
    }
  }

  @override
  Widget build(BuildContext context) { // Builds the UI for the group creation screen.
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode; // Checks if the app is in dark mode.
    return ChangeNotifierProvider(
      create: (_) => GroupChatViewModel(), // Provides the GroupChatViewModel to manage group creation logic.
      child: Consumer<GroupChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Group')), // App bar with the title 'Create Group'.
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _groupNameController, // Input field for the group name.
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _memberEmailController, // Input field for adding a member by email.
                          decoration: const InputDecoration(
                            labelText: 'Add Member by Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress, // Sets the keyboard type to email.
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.infoBlue), // Button to add a member.
                        onPressed: () async {
                          final email = _memberEmailController.text;
                          if (email.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an email')), // Shows a message if email is empty.
                            );
                            return;
                          }
                          if (email.trim() == FirebaseAuth.instance.currentUser!.email) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You cannot add yourself')), // Prevents adding the current user.
                            );
                            return;
                          }
                          final memberId = await _fetchUserIdByEmail(email); // Fetches the user ID by email.
                          if (memberId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User not found')), // Shows a message if user is not found.
                            );
                            return;
                          }
                          if (_memberIds.contains(memberId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User already added')), // Prevents adding duplicate members.
                            );
                            return;
                          }
                          setState(() {
                            _memberIds.add(memberId); // Adds the member ID to the list.
                            _memberEmailController.clear(); // Clears the email input field.
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!, // Displays error messages if any.
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkError : AppColors.lightError,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _memberIds.isEmpty
                        ? const Center(child: Text('No members added')) // Shows a message if no members are added.
                        : ListView.builder(
                            itemCount: _memberIds.length, // Displays the list of added members.
                            itemBuilder: (context, index) {
                              final memberId = _memberIds[index];
                              return StreamBuilder(
                                stream: viewModel.getUser(memberId), // Fetches user details for each member.
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const ListTile(
                                      leading: CircleAvatar(child: Text('?')),
                                      title: Text('Loading...'),
                                    );
                                  }
                                  final user = snapshot.data!;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(user.displayName.isNotEmpty
                                          ? user.displayName.substring(0, 1)
                                          : '?'),
                                    ),
                                    title: Text(user.displayName), // Displays the member's name.
                                    subtitle: Text(user.email), // Displays the member's email.
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red), // Button to remove a member.
                                      onPressed: () {
                                        setState(() {
                                          _memberIds.remove(memberId); // Removes the member from the list.
                                        });
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_groupNameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group name is required')), // Shows a message if group name is empty.
                        );
                        return;
                      }
                      if (_memberIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add at least one member')), // Shows a message if no members are added.
                        );
                        return;
                      }
                      await viewModel.createGroup(
                        _groupNameController.text, // Passes the group name.
                        _memberIds, // Passes the list of member IDs.
                      );
                      if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage!)), // Displays error messages if group creation fails.
                        );
                      } else {
                        Navigator.pop(context); // Navigates back on successful group creation.
                      }
                    },
                    child: const Text('Create Group'), // Button to create the group.
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}