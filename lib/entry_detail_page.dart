import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/router/app_router.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/shared_scaffold.dart';

class EntryDetailPage extends StatefulWidget {
  final String entryID;

  const EntryDetailPage({super.key, required this.entryID});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  bool _isDeleting = false;
  String entryUpdatePath(String id) => '/update/$id';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalEntryProvider>();

    if (!_isDeleting) {
      final index = provider.entries.indexWhere(
            (e) => e.entryID == widget.entryID,
      );

      if (index == -1) {
        context.pop();
        return const SizedBox.shrink();
      }

      final entry = provider.entries[index];

      return Stack(
        children: [
          SharedScaffold(
            title: entry.title ?? 'Untitled',
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final id = widget.entryID;
                  context.push(entryUpdatePath(id), extra: entry);
                },
              ),
              IconButton(
                key: const Key('deleteEntryButton'),
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, entry),
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildDetailBody(context, entry),
            ),
            showBackButton: true,
          ),
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
            ),
        ],
      );
    } else {
      return Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }
  }

  // Prompts the user for delete confirmation, then async delete.
  Future<void> _confirmDelete(BuildContext context, JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);

      try {
        await context.read<JournalEntryProvider>().deleteEntry(entry.entryID);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully!')),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.go(homeRoute);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting entry')),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _buildDetailBody(BuildContext context, JournalEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.timestamp != null)
          Text(
            'Date: ${DateFormat('MM/dd/yyyy').format(entry.timestamp!)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 8),

        if (entry.description != null && entry.description!.isNotEmpty)
          Text(entry.description!),
        const SizedBox(height: 16),

        if (entry.latitude != null && entry.longitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Location: ${entry.address ?? '${entry.latitude}, ${entry.longitude}'}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

        if (entry.tags != null && entry.tags!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: entry.tags!.map((tag) {
                    return Chip(label: Text(tag));
                  }).toList(),
                ),
              ],
            ),
          ),

        if (entry.imageURLs != null && entry.imageURLs!.isNotEmpty)
          _buildImageSection(entry.imageURLs!),

        if (entry.videoURLs != null && entry.videoURLs!.isNotEmpty)
          _buildVideoSection(entry.videoURLs!),
      ],
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
              return GestureDetector(
                onTap: () => _showFullscreenImage(context, url),
                child: Image.network(
                  url,
                  width: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoSection(List<String> videoURLs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Videos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videoURLs.length,
          itemBuilder: (context, index) {
            final url = videoURLs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ChewieVideoPlayer(videoUrl: url),
            );
          },
        ),
      ],
    );
  }
}

