import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCardColor,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightOnBackground),
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.lightOnBackground),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey),
    ),
   appBarTheme: const AppBarTheme(
  color: AppColors.lightPrimary,
  elevation: 0,
  iconTheme: IconThemeData(color: AppColors.lightOnBackground), // Changed from white to black
  titleTextStyle: TextStyle(color: AppColors.lightOnBackground, fontSize: 20, fontWeight: FontWeight.bold),
),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        backgroundColor: AppColors.lightOnBackground,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: AppColors.lightOnSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCardColor,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkOnBackground),
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.darkOnBackground),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey),
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        backgroundColor: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkOnSurface,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}