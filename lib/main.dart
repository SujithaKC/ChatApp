import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/theme_provider.dart';
import 'routes/app_routes.dart';
import 'modules/auth/viewmodel/login_viewmodel.dart';

// This is the main entry point of the Flutter application.
// It initializes Firebase and sets up the app's theme and routing.

void main() async { // The main function is the entry point of the Flutter application.
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter bindings are initialized before running the app.
  await Firebase.initializeApp(options: firebaseOptions); // Initializes Firebase with the provided configuration.

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); // Load the saved theme preference.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => LoginViewModel()), // Provide LoginViewModel globally.
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget { // The root widget of the application.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // Listens to theme changes and rebuilds the app with the updated theme.
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Chat App', // Sets the title of the application.
          theme: themeProvider.themeData, // Applies the current theme to the app.
          initialRoute: FirebaseAuth.instance.currentUser == null ? AppRoutes.login : AppRoutes.main, // Determines the initial route based on user authentication status.
          onGenerateRoute: AppRoutes.generateRoute, // Generates routes dynamically based on the route name.
        );
      },
    );
  }
}