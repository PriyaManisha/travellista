import 'package:flutter/material.dart';
import 'models/journal_entry.dart'; // Adjust the path if needed
import 'entry_card.dart'; // This is your custom widget
import 'entry_creation_form.dart';

class HomeScreen extends StatelessWidget {
  final List<JournalEntry> entries; // Consider passing entries as a parameter

  HomeScreen({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travellista'),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: entries[index]); // Create EntryCard widget
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to EntryCreationForm
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EntryCreationForm()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
