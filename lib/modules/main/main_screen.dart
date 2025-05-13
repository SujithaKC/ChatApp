import 'package:chat_app/modules/chat/view/chat_list_screen.dart';
import 'package:chat_app/modules/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
//import '../../chat/view/chat_list_screen.dart';
//import '../../profile/view/profile_screen.dart';

class MainScreen extends StatefulWidget { // Main screen of the app with a bottom navigation bar.
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Tracks the currently selected tab index.

  final List<Widget> _screens = [ // List of screens corresponding to each tab.
    const ChatListScreen(chatType: 'all'), // Screen showing all chats.
    const ChatListScreen(chatType: 'individual'), // Screen showing individual chats.
    const ChatListScreen(chatType: 'group'), // Screen showing group chats.
    const ProfileScreen(), // Screen showing the user's profile.
  ];

  void _onItemTapped(int index) { // Updates the selected tab index when a tab is tapped.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) { // Builds the UI for the main screen.
    return Scaffold(
      body: _screens[_selectedIndex], // Displays the screen corresponding to the selected tab.
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'All Chats'), // Tab for all chats.
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Individual'), // Tab for individual chats.
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'), // Tab for group chats.
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'), // Tab for the profile screen.
        ],
        currentIndex: _selectedIndex, // Highlights the currently selected tab.
        selectedItemColor:  Color.fromARGB(255, 163, 119, 246), // Color for the selected tab.
        unselectedItemColor: Colors.grey, // Color for unselected tabs.
        onTap: _onItemTapped, // Handles tab selection.
      ),
    );
  }
}