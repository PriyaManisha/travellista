import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travellista/models/journal_entry.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const EntryCard({super.key, required this.entry});

  String entryDetailPath(String id) => '/entry/$id';

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MM/dd/yyyy');
    final formattedDate = formatter.format(entry.timestamp!);
    final formattedLocation = '${entry.latitude}, ${entry.longitude}';
    final formattedAddress = entry.address ?? formattedLocation;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: _buildLeadingImage(),
        title: Text(entry.title ?? 'Untitled'),
        subtitle: _buildSubtitle(context, formattedDate, formattedAddress),
        onTap: () {
          context.push(entryDetailPath(entry.entryID!));
        },
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (entry.imageURLs != null && entry.imageURLs!.isNotEmpty) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Image.network(
          entry.imageURLs![0],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    } else {
      return const SizedBox(
        width: 50,
        height: 50,
        child: Icon(Icons.photo, size: 40),
      );
    }
  }

  Widget _buildSubtitle(BuildContext context, String date, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$date, $address'),
        const SizedBox(height: 4),
        if (entry.tags != null && entry.tags!.isNotEmpty)
          Wrap(
            spacing: 6.0,
            runSpacing: -2.0,
            children: entry.tags!.map((tag) {
              return Chip(
                label: Text(tag),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }
}
