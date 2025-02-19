import 'package:flutter/material.dart';
import 'package:travellista/profile.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/map_view_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch(index) {
      case 0:
      // Navigate to Home
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreenPage())
        );
        break;
      case 1:
      // Navigate to Create Entry
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EntryCreationForm())
        );
        break;
      case 2:
        // Navigate to Map
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MapViewPage())
        );
        break;
      case 3:
      // Navigate to Profile
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfilePage())
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.primary,
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
