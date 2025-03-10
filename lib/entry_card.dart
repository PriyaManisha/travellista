import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travellista/models/journal_entry.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const EntryCard({super.key, required this.entry});

  String entryDetailPath(String id) => '/entry/$id';

  static const Color chipPurple = Color(0xFF7E57C2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final formatter = DateFormat('MM/dd/yyyy');
    final formattedDate = formatter.format(entry.timestamp!);
    final formattedLocation = '${entry.latitude}, ${entry.longitude}';
    final formattedAddress = entry.address ?? formattedLocation;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          context.push(entryDetailPath(entry.entryID!));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannerImage(context),
              const SizedBox(height: 12),
              _buildTextSection(context, theme, formattedDate, formattedAddress),
            ],
          ),
        ),
      ),
    );
  }

  // Banner image (spans card width, 100px height)
  Widget _buildBannerImage(BuildContext context) {
    if (entry.imageURLs != null && entry.imageURLs!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          entry.imageURLs![0],
          width: double.infinity,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey.shade200,
              child: const Icon(Icons.error, size: 50, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Icon(Icons.photo, size: 50, color: Colors.grey),
      );
    }
  }

  // Column of text & chips
  Widget _buildTextSection(BuildContext context, TextTheme theme, String date, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title ?? 'Untitled',
          style: theme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '$date, $address',
          style: theme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Tags
        if (entry.tags != null && entry.tags!.isNotEmpty)
          Wrap(
            spacing: 6.0,
            runSpacing: -2.0,
            children: entry.tags!.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: theme.bodySmall?.copyWith(color: Colors.white),
                ),
                backgroundColor: chipPurple,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}