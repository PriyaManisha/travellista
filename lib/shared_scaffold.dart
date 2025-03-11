import 'package:flutter/material.dart';
import 'package:travellista/nav_bar.dart';

/// Scaffold wrapper
class SharedScaffold extends StatelessWidget {
  final Widget? titleWidget;
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final int selectedIndex;
  final bool showBackButton;
  final Widget? floatingActionButton;

  const SharedScaffold({
    super.key,
    this.titleWidget,
    this.title,
    required this.body,
    this.actions,
    this.selectedIndex = 0,
    this.showBackButton = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget ?? (title != null ? Text(title!) : null),
        centerTitle: false,
        actions: actions,
        automaticallyImplyLeading: showBackButton,
      ),
      bottomNavigationBar: NavBar(selectedIndex: selectedIndex),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
