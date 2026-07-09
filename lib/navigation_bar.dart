import "package:flutter/material.dart";

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
       type: BottomNavigationBarType.fixed,
  currentIndex: 0,

  selectedItemColor: Colors.green,
  unselectedItemColor: Colors.grey,
  backgroundColor: const Color(0xFF1B1F24),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Habits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon : Icon(Icons.settings),
          label: 'Settings',
        )
      ],
    );
  }
}