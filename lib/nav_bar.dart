import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  const NavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/home");
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, "/add",ModalRoute.withName("/home"));
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, "/map",ModalRoute.withName("/home"));
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, "/profile",ModalRoute.withName("/home"));
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      //unselectedItemColor: Theme.of(context).colorScheme.primary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
