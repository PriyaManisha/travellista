import 'package:flutter/material.dart';
import 'package:travellista/util/theme_manager.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
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
