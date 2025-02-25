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
    final formattedAddress = entry.address ?? formattedLocation;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: entry.imageURLs != null && entry.imageURLs!.isNotEmpty
              ? Image.network(
            entry.imageURLs![0],
            fit: BoxFit.cover,
            width: 50,
            height: 50,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          )
              : const Icon(Icons.photo, size: 40),
        ),
        title: Text(entry.title ?? 'Untitled'),
        subtitle: Text(
          '${formattedDate}, ${formattedAddress}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
