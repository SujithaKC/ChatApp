import 'package:chat_app/modules/chat/view/chat_list_screen.dart';
import 'package:chat_app/modules/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
//import '../../chat/view/chat_list_screen.dart';
//import '../../profile/view/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatListScreen(chatType: 'all'),
    const ChatListScreen(chatType: 'individual'),
    const ChatListScreen(chatType: 'group'),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'All Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Individual'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:  Color.fromARGB(255, 163, 119, 246),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}