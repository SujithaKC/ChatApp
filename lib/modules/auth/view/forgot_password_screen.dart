import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodel/login_viewmodel.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(), // Provide LoginViewModel to the widget tree.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your email to reset your password',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    Provider.of<LoginViewModel>(context, listen: false).sendPasswordResetEmail(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent!')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid email address.')),
                    );
                  }
                },
                child: const Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
