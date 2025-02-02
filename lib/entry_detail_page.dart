import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/shared_scaffold.dart';


class EntryDetailPage extends StatelessWidget {
  final JournalEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
      title: entry.title ?? 'Untitled',
      actions: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryCreationForm(existingEntry: entry),
              ),
            );
          },
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Delete'),
                content:
                const Text('Are you sure you want to delete this entry?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await context.read<JournalEntryProvider>().deleteEntry(entry.entryID);
              Navigator.pop(context); // go back after deleting
            }
          },
        ),
      ],
      // The main content
      body: _buildDetailBody(context),
    );
  }

  Widget _buildDetailBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            entry.title ?? 'Untitled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Timestamp
          if (entry.timestamp != null)
            Text(
              'Date: ${entry.timestamp!.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          const SizedBox(height: 8),

          // Description
          if (entry.description != null && entry.description!.isNotEmpty)
            Text(entry.description!),
          const SizedBox(height: 16),

          // Images
          if (entry.imageURLs != null && entry.imageURLs!.isNotEmpty)
            _buildImageSection(entry.imageURLs!),

          // Videos
          if (entry.videoURLs != null && entry.videoURLs!.isNotEmpty)
            _buildVideoSection(entry.videoURLs!),

          // Location
          if (entry.latitude != null && entry.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Location: ${entry.latitude}, ${entry.longitude}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(List<String> imageURLs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageURLs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = imageURLs[index];
              return Image.network(url, width: 100, fit: BoxFit.cover);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVideoSection(List<String> videoURLs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
        // Map each video URL to a player widget or text placeholder
        ...videoURLs.map((url) {
          // Use VideoPlayerWidget w/ .network. Update tomorrow, not working as a dependency
          return Container(
            height: 200,
            margin: const EdgeInsets.only(top: 8),
            child: VideoPlayerWidget(videoUrl: url),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}
