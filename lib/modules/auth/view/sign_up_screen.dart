// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/theme/theme_provider.dart';
// import '../../../routes/app_routes.dart';
// import '../viewmodel/login_viewmodel.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _displayNameController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _displayNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
//     return ChangeNotifierProvider(
//       create: (_) => LoginViewModel(),
//       child: Consumer<LoginViewModel>(
//         builder: (context, viewModel, child) {
//           return Scaffold(
//             body: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isDarkMode
//                       ? [AppColors.darkBackground, AppColors.darkSecondary]
//                       : [AppColors.lightBackground, AppColors.lightSecondary],
//                 ),
//               ),
//               child: Center(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(24),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                         child: Container(
//                           padding: const EdgeInsets.all(32),
//                           decoration: BoxDecoration(
//                             color: isDarkMode
//                                 ? AppColors.darkCardColor.withOpacity(0.3)
//                                 : AppColors.lightCardColor.withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(
//                               color: isDarkMode
//                                   ? AppColors.darkOnSurface.withOpacity(0.2)
//                                   : AppColors.lightOnSurface.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Text(
//                                 'Sign Up',
//                                 style: Theme.of(context).textTheme.headlineSmall,
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 24),
//                               TextField(
//                                 controller: _displayNameController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Display Name',
//                                   prefixIcon: Icon(Icons.person),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               TextField(
//                                 controller: _emailController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Email',
//                                   prefixIcon: Icon(Icons.email),
//                                 ),
//                                 keyboardType: TextInputType.emailAddress,
//                               ),
//                               const SizedBox(height: 16),
//                               TextField(
//                                 controller: _passwordController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Password',
//                                   prefixIcon: Icon(Icons.lock),
//                                 ),
//                                 obscureText: true,
//                               ),
//                               const SizedBox(height: 24),
//                               if (viewModel.errorMessage != null)
//                                 Text(
//                                   viewModel.errorMessage!,
//                                   style: TextStyle(color: isDarkMode ? AppColors.darkError : AppColors.lightError),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               const SizedBox(height: 24),
//                               viewModel.isLoading
//                                   ? const Center(child: CircularProgressIndicator())
//                                   : Column(
//                                       children: [
//                                         ElevatedButton(
//                                           onPressed: () async {
//                                             final success = await viewModel.signUp(
//                                               _emailController.text,
//                                               _passwordController.text,
//                                               _displayNameController.text,
//                                             );
//                                             if (success && mounted) {
//                                               Navigator.pushReplacementNamed(context, AppRoutes.main);
//                                             } else {
//                                               _emailController.clear();
//                                               _passwordController.clear();
//                                               _displayNameController.clear();
//                                             }
//                                           },
//                                           child: const Text('Sign Up'),
//                                           style: ElevatedButton.styleFrom(
//                                             padding: const EdgeInsets.symmetric(vertical: 16),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         TextButton(
//                                           onPressed: () {
//                                             viewModel.clearError();
//                                             _emailController.clear();
//                                             _passwordController.clear();
//                                             _displayNameController.clear();
//                                             Navigator.pushReplacementNamed(context, AppRoutes.login);
//                                           },
//                                           child: Text(
//                                             'Have an account? Login',
//                                             style: TextStyle(
//                                               color: isDarkMode ? Colors.white70 : AppColors.lightOnBackground,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/login_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
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
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _displayNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Display Name',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: _validateDisplayName,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: _validatePassword,
                                ),
                                const SizedBox(height: 24),
                                if (viewModel.errorMessage != null)
                                  Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(color: isDarkMode ? AppColors.darkError : AppColors.lightError),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 24),
                                viewModel.isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                await viewModel.signUp(
                                                  _emailController.text.trim(),
                                                  _passwordController.text.trim(),
                                                  _displayNameController.text.trim(),
                                                );
                                                // Clear fields regardless of success, since user is signed out
                                                _emailController.clear();
                                                _passwordController.clear();
                                                _displayNameController.clear();
                                              }
                                            },
                                            child: const Text('Sign Up'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton(
                                            onPressed: () {
                                              viewModel.clearError();
                                              _emailController.clear();
                                              _passwordController.clear();
                                              _displayNameController.clear();
                                              Navigator.pushReplacementNamed(context, AppRoutes.login);
                                            },
                                            child: Text(
                                              'Have an account? Login',
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