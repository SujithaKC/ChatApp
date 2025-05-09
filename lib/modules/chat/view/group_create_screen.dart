import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/group_chat_viewmodel.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({Key? key}) : super(key: key);

  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _groupNameController = TextEditingController();
  final _memberEmailController = TextEditingController();
  final List<String> _memberIds = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  Future<String?> _fetchUserIdByEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return snapshot.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ChangeNotifierProvider(
      create: (_) => GroupChatViewModel(),
      child: Consumer<GroupChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Group')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _groupNameController,
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
                          controller: _memberEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Add Member by Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.infoBlue),
                        onPressed: () async {
                          final email = _memberEmailController.text;
                          if (email.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an email')),
                            );
                            return;
                          }
                          if (email.trim() == FirebaseAuth.instance.currentUser!.email) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You cannot add yourself')),
                            );
                            return;
                          }
                          final memberId = await _fetchUserIdByEmail(email);
                          if (memberId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User not found')),
                            );
                            return;
                          }
                          if (_memberIds.contains(memberId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User already added')),
                            );
                            return;
                          }
                          setState(() {
                            _memberIds.add(memberId);
                            _memberEmailController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.darkError : AppColors.lightError,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _memberIds.isEmpty
                        ? const Center(child: Text('No members added'))
                        : ListView.builder(
                            itemCount: _memberIds.length,
                            itemBuilder: (context, index) {
                              final memberId = _memberIds[index];
                              return StreamBuilder(
                                stream: viewModel.getUser(memberId),
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
                                    title: Text(user.displayName),
                                    subtitle: Text(user.email),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _memberIds.remove(memberId);
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
                          const SnackBar(content: Text('Group name is required')),
                        );
                        return;
                      }
                      if (_memberIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add at least one member')),
                        );
                        return;
                      }
                      await viewModel.createGroup(
                        _groupNameController.text,
                        _memberIds,
                      );
                      if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage!)),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Create Group'),
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