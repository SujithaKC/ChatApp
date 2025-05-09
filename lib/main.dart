import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/theme_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Chat App',
            theme: themeProvider.themeData,
            initialRoute: FirebaseAuth.instance.currentUser == null ? AppRoutes.login : AppRoutes.main,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}