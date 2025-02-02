import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';


class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<JournalEntryProvider>(context).entries;

    return SharedScaffold(
      title: 'Travellista',
      body: entries.isNotEmpty
      ? ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: entries[index]);
        },
      )
          : const Center(
        child: Text(
          'No journal entries recorded yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
