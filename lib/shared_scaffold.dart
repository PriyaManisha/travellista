import 'package:flutter/material.dart';
import 'package:travellista/nav_bar.dart';

/// Scaffold wrapper that includes the navbar
class SharedScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const SharedScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      bottomNavigationBar: NavBar(),
      body: body,
    );
  }
}
