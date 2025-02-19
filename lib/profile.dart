import 'package:flutter/material.dart';
import 'package:travellista/util/theme_manager.dart';
import 'package:travellista/shared_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
      title: 'Profile',
      selectedIndex: 3,
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeManager.themeNotifier,
            builder: (context, currentTheme, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: currentTheme == ThemeMode.dark,
                onChanged: (value) {
                  ThemeManager.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
