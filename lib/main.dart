import 'package:flutter/material.dart';
import 'package:travellista/models/journal_entry.dart'; // Adjust the path based on your structure
import 'home_screen.dart'; // Assuming you have a HomeScreen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travellista',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(entries: []), // Pass an empty list or load real data
    );
  }
}
