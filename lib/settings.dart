import 'package:flutter/material.dart';
import 'package:travellista/util/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
