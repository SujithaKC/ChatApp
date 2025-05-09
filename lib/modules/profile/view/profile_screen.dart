import 'package:chat_app/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchUser(FirebaseAuth.instance.currentUser!.uid),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (viewModel.user == null) {
            return Scaffold(
              body: Center(child: Text(viewModel.errorMessage ?? 'User not found')),
            );
          }
          _displayNameController.text = viewModel.user!.displayName;
          _bioController.text = viewModel.user!.bio;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await viewModel.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      viewModel.user!.displayName.isNotEmpty
                          ? viewModel.user!.displayName.substring(0, 1)
                          : '?',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.user!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: 'Display Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? AppColors.darkError
                            : AppColors.lightError,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.updateProfile(
                        _displayNameController.text,
                        _bioController.text,
                      );
                      if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage!)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
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