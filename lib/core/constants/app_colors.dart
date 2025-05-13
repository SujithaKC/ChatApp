// This file defines the `AppColors` class, which contains color constants for the app's themes.
// It includes separate colors for light and dark themes.

import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors - White Theme
  static const Color lightPrimary = Colors.white;                    // White Background
  static const Color lightBackground = Colors.white;                // White Background
  static const Color lightCardColor = Colors.white;                 // White Cards
  static const Color lightOnBackground = Colors.black;              // Black Text
  static const Color lightSecondary = Colors.black12;               // Light Gray
  static const Color lightOnPrimary = Colors.black;                 // Text on white
  static const Color lightSurface = Colors.white;                   // Surface = White
  static const Color lightInputFillColor = Colors.black12;          // Light gray inputs
  static const Color lightButtonColor = Colors.black;               // Black Buttons
  static const Color lightOnSurface = Colors.black54;               // Dimmed text
  static const Color lightError = Colors.red;                       // Red for errors
  static const Color lightSenderMessageBg = Color.fromARGB(255, 252, 251, 251);           // Message bubble
  static const Color lightReceiverMessageBg = Colors.black12;       // Message bubble

  // Dark Theme Colors - Black Theme
  static const Color darkPrimary = Colors.black;                    // Black Background
  static const Color darkBackground = Colors.black;                 // Black Background
  static const Color darkCardColor = Colors.black;                  // Black Cards
  static const Color darkOnBackground = Colors.white;               // White Text
  static const Color darkSecondary = Colors.white10;                // Dim White
  static const Color darkOnPrimary = Colors.white;                  // Text on black
  static const Color darkSurface = Colors.black;                    // Surface = Black
  static const Color darkInputFillColor = Colors.white12;           // Light input bg
  static const Color darkButtonColor = Colors.white;                // White Buttons
  static const Color darkOnSurface = Colors.white70;                // Muted white
  static const Color darkError = Colors.redAccent;                  // Red for errors
  static const Color darkSenderMessageBg = Color.fromARGB(255, 9, 9, 9);            // Message bubble
  static const Color darkReceiverMessageBg = Colors.white10;        // Message bubble

  // Common Colors
  static const Color infoBlue = Colors.grey;                        // Info = Neutral
  static const Color iconGrey = Colors.grey;                        // Icons
  static const Color warningYellow = Colors.amber;                  // Yellow warning
}
