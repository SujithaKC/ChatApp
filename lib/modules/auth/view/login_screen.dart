import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to identify the login form and validate its fields.
  final _emailController = TextEditingController(); // Controller to manage the email input field.
  final _passwordController = TextEditingController(); // Controller to manage the password input field.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) { // Validates the email input.
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) { // Validates the password input.
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) { // Builds the login screen UI.
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode; // Checks if the app is in dark mode.
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(), // Provides the LoginViewModel to manage login logic.
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [AppColors.darkBackground, AppColors.darkSecondary]
                      : [AppColors.lightBackground, AppColors.lightSecondary],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkCardColor.withOpacity(0.3)
                                : AppColors.lightCardColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.darkOnSurface.withOpacity(0.2)
                                  : AppColors.lightOnSurface.withOpacity(0.2),
                            ),
                          ),
                          child: Form(
                            key: _formKey, // Associates the form with the validation key.
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Login', // Displays the login title.
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _emailController, // Binds the email input field to the controller.
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress, // Sets the keyboard type to email.
                                  validator: _validateEmail, // Validates the email input.
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController, // Binds the password input field to the controller.
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true, // Hides the password input.
                                  validator: _validatePassword, // Validates the password input.
                                ),
                                const SizedBox(height: 24),
                                if (viewModel.errorMessage != null)
                                  Text(
                                    viewModel.errorMessage!, // Displays error messages if login fails.
                                    style: TextStyle(color: isDarkMode ? AppColors.darkError : AppColors.lightError),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 24),
                                viewModel.isLoading
                                    ? const Center(child: CircularProgressIndicator()) // Shows a loading indicator during login.
                                    : Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) { // Validates the form before login.
                                                final success = await viewModel.login(
                                                  _emailController.text.trim(),
                                                  _passwordController.text.trim(),
                                                );
                                                if (success && mounted) {
                                                  Navigator.pushReplacementNamed(context, AppRoutes.main); // Navigates to the main screen on success.
                                                } else {
                                                  if (viewModel.errorMessage != null) {
                                                    _emailController.clear();
                                                    _passwordController.clear();
                                                  }
                                                }
                                              }
                                            },
                                            child: const Text('Login'), // Login button.
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton(
                                            onPressed: () {
                                              viewModel.clearError(); // Clears error messages.
                                              _emailController.clear();
                                              _passwordController.clear();
                                              Navigator.pushReplacementNamed(context, AppRoutes.signUp); // Navigates to the sign-up screen.
                                            },
                                            child: Text(
                                              'Need an account? Sign Up', // Sign-up navigation text.
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.white70 : AppColors.lightOnBackground,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context, AppRoutes.forgotPassword); // Navigate to the Forgot Password screen.
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.white70 : AppColors.lightOnBackground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
