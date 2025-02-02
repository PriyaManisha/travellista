import 'package:flutter/material.dart';
import 'package:travellista/nav_bar.dart';

/// Scaffold wrapper that includes the navbar
class SharedScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const SharedScaffold({
    super.key,
    required this.body,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: NavBar(),
      body: body,
    );
  }
}
