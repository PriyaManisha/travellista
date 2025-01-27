import 'package:flutter/material.dart';
import 'models/journal_entry.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;

  EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: entry.imageURLs!.isNotEmpty
            ? Image.network(
                entry.imageURLs![0]) // Assuming first image as thumbnail
            : Icon(Icons.photo),
        title: Text(entry.title ?? 'Untitled'),
        subtitle:
            Text('${entry.timestamp}, ${entry.latitude}, ${entry.longitude}'),
        onTap: () {
          // Navigate to EntryDetailsScreen
        },
      ),
    );
  }
}
