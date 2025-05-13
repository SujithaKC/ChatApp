import 'package:chat_app/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/profile_viewmodel.dart';

// Screen to display and edit the user's profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController(); // Controller for the display name input field.
  final _bioController = TextEditingController(); // Controller for the bio input field.

  @override
  void dispose() { // Disposes controllers to free up resources.
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // Builds the UI for the profile screen.
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchUser(FirebaseAuth.instance.currentUser!.uid), // Fetches the current user's profile data.
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) { // Displays a loading indicator while fetching data.
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (viewModel.user == null) { // Displays an error message if the user is not found.
            return Scaffold(
              body: Center(child: Text(viewModel.errorMessage ?? 'User not found')),
            );
          }
          _displayNameController.text = viewModel.user!.displayName; // Pre-fills the display name field.
          _bioController.text = viewModel.user!.bio; // Pre-fills the bio field.

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'), // App bar title.
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6), // Button to toggle the app's theme.
                  onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                ),
                IconButton(
                  icon: const Icon(Icons.logout), // Button to log out the user.
                  onPressed: () async {
                    await viewModel.signOut(); // Signs out the user.
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login); // Navigates to the login screen.
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
                    radius: 50, // Displays the user's avatar.
                    child: Text(
                      viewModel.user!.displayName.isNotEmpty
                          ? viewModel.user!.displayName.substring(0, 1) // Shows the first letter of the display name.
                          : '?',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.user!.email, // Displays the user's email.
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _displayNameController, // Input field for the display name.
                    decoration: const InputDecoration(labelText: 'Display Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController, // Input field for the bio.
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 3, // Allows multiple lines for the bio.
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!, // Displays error messages if any.
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
                        _displayNameController.text, // Updates the display name.
                        _bioController.text, // Updates the bio.
                      );
                      if (viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(viewModel.errorMessage!)), // Shows error messages in a snackbar.
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')), // Shows a success message.
                        );
                      }
                    },
                    child: const Text('Save Changes'), // Button to save profile changes.
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