import 'package:flutter/material.dart';
import 'package:travellista/nav_bar.dart';

/// Scaffold wrapper that includes the navbar
class SharedScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final int selectedIndex;

  const SharedScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      bottomNavigationBar: NavBar(selectedIndex: selectedIndex),
      body: body,
    );
  }
}
