import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/router/app_router.dart';
import 'package:travellista/video_player_widget.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/util/chip_theme_util.dart';

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
      builder: (ctx) =>
          AlertDialog(
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
    final theme = Theme
        .of(context)
        .textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.timestamp != null)
          Text(
            'Date: ${DateFormat('MM/dd/yyyy').format(entry.timestamp!)}',
            style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 8),

        if (entry.description != null && entry.description!.isNotEmpty) ...[
          Text(
            entry.description!,
            style: theme.bodyLarge,
          ),
          const SizedBox(height: 16),
        ],

        if (entry.latitude != null && entry.longitude != null) ...[
          Text(
            'Location: ${entry.address ??
                '${entry.latitude}, ${entry.longitude}'}',
            style: theme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
        ],

        if (entry.tags != null && entry.tags!.isNotEmpty) ...[
          Text(
            'Tags:',
            style: theme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: -2.0,
            children: entry.tags!.map((tag) {
              return ChipThemeUtil.buildStyledChip(
                label: tag,
                labelStyle: theme.bodyMedium,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        if (entry.imageURLs != null && entry.imageURLs!.isNotEmpty)
          _buildImageSection(context, entry.imageURLs!),

        if (entry.videoURLs != null && entry.videoURLs!.isNotEmpty)
          _buildVideoSection(context, entry),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, List<String> imageURLs) {
    final theme = Theme
        .of(context)
        .textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images:', style: theme.titleMedium),
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
                child: Container(
                  decoration:BoxDecoration(
                      border:Border.all(color:Colors.deepPurple, width:3)
                  ),
                  child:Image.network(
                    url,
                    width: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                )
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
                  child:Container(
                    decoration:BoxDecoration(
                      border:Border.all(color:Colors.deepPurple, width:3)
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  )
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

  Widget _buildVideoSection(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context).textTheme;
    final videos = entry.videoURLs ?? [];
    final thumbs = entry.videoThumbnailURLs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Videos:', style: theme.titleMedium),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoUrl = videos[index];
              String? thumbUrl;
              if (index < thumbs.length) {
                thumbUrl = thumbs[index];
              }

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showFullscreenVideo(context, videoUrl),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.black12,
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          // if we have a remote thumbnail
                          if (thumbUrl == null || thumbUrl.isEmpty)
                            const Center(
                              child: Icon(Icons.play_circle_fill,
                                  size: 50, color: Colors.white70),
                            )
                          else
                              Image.network(
                                thumbUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                          const Center(
                            child: Icon(Icons.play_circle_fill,
                                size: 50, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Show Chewie in a dialog
  void _showFullscreenVideo(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ChewieVideoPlayer(videoUrl: videoUrl),
        );
      },
    );
  }
}


