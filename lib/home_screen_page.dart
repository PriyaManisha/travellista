import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();

    if (entryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SharedScaffold(
      title: 'Travellista',
      body: ListView.builder(
        itemCount: entryProvider.entries.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: entryProvider.entries[index]);
        },
      ),
    );
  }
}
