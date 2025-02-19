import 'package:flutter/material.dart';
import 'package:travellista/profile.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/map_view_page.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  const NavBar({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index) {
    // Navigate based on the item tapped.
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreenPage())
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EntryCreationForm())
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MapViewPage())
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfilePage())
        );
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
