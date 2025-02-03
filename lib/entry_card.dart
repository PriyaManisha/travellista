import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/entry_detail_page.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;

  EntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MM/dd/yyyy');
    final formattedDate = formatter.format(entry.timestamp!);
    final formattedLocation =
        '${entry.latitude}, ${entry.longitude}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: entry.imageURLs!.isNotEmpty
            ? Image.network(
                entry.imageURLs![0])
            : Icon(Icons.photo),
        title: Text(entry.title ?? 'Untitled'),
        subtitle:
            Text('${formattedDate}, ${formattedLocation}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryDetailPage(entryID: entry.entryID!),
            ),
          );
        },
      ),
    );
  }
}
