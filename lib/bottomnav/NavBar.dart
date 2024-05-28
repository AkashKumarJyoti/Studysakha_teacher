import 'package:flutter/material.dart';
import 'package:studysakha_teacher/quiz/quiz_screen.dart';

import '../class/class_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() =>
      _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? const ClassInfo() : const QuizScreen(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF08FFB8),
              Color(0xFF5799F7),
            ],
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam, color: Colors.white),
              label: 'Classes',
              backgroundColor: Colors.transparent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment, color: Colors.white),
              label: 'Quiz',
              backgroundColor: Colors.transparent,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
