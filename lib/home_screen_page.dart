import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/entry_search.dart';
import 'package:travellista/util/parsed_location.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final journalProvider = context.read<JournalEntryProvider>();
      final userID = profileProvider.profile?.userID ?? 'demoUser';
      journalProvider.fetchEntriesForUser(userID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();

    if (entryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entryProvider.entries.isEmpty) {
      return _buildNoEntriesYetScaffold();
    }

    final filteredEntries = _buildFilteredList(entryProvider.entries, _searchQuery);

    if (filteredEntries.isEmpty && _isSearching) {
      return _buildNoResultsScaffold();
    }

    final sortedGroups = _groupAndSortEntries(filteredEntries);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _buildMainScaffold(sortedGroups),
    );
  }

  Widget _buildNoEntriesYetScaffold() {
    final theme = Theme.of(context).textTheme;
    return SharedScaffold(
      title: 'Travellista',
      selectedIndex: 0,
      body: Center(
        child: Text(
          'No journal entries entered yet.',
          style: theme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildNoResultsScaffold() {
    final theme = Theme.of(context).textTheme;

    return SharedScaffold(
      titleWidget: EntrySearchBar(
        title: 'Travellista',
        isSearching: _isSearching,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSearchToggled: (val) {
          setState(() {
            _isSearching = val;
            if (!_isSearching) {
              _searchQuery = '';
              FocusScope.of(context).unfocus();
            }
          });
        },
      ),
      selectedIndex: 0,
      body: Center(
        child: Text(
          'No entries match your search.',
          style: theme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildMainScaffold(List<MapEntry<String, List<JournalEntry>>> sortedGroups) {
    final theme = Theme.of(context).textTheme;

    return SharedScaffold(
      titleWidget: EntrySearchBar(
        title: 'Travellista',
        isSearching: _isSearching,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSearchToggled: (val) {
          setState(() {
            _isSearching = val;
            if (!_isSearching) {
              _searchQuery = '';
              FocusScope.of(context).unfocus();
            }
          });
        },
      ),
      selectedIndex: 0,
      body: ListView(
        children: sortedGroups.map((group) {
          final locationKey = group.key;
          final entriesForGroup = group.value;
          return ExpansionTile(
            key: UniqueKey(),
            title: Text(
              locationKey,
              style: theme.bodyLarge,
            ),
            leading: const Icon(Icons.location_on),
            trailing: const Icon(Icons.keyboard_arrow_down),
            textColor: Theme.of(context).colorScheme.primary,
            iconColor: Theme.of(context).colorScheme.primary,
            collapsedIconColor: Colors.grey,
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: entriesForGroup.map((entry) => EntryCard(entry: entry)).toList(),
          );
        }).toList(),
      ),
    );
  }

  List<JournalEntry> _buildFilteredList(List<JournalEntry> allEntries, String query) {
    if (!_isSearching || query.trim().isEmpty) {
      return allEntries;
    }
    final lowerQuery = query.toLowerCase();

    return allEntries.where((entry) {
      final combinedText = (
          (entry.title ?? '') +
              (entry.address ?? '') +
              (entry.tags?.join(' ') ?? '') +
              (entry.monthName?.toLowerCase() ?? '')
      ).toLowerCase();

      final date = entry.timestamp;
      bool dateMatch = false;
      if (date != null) {
        final yearStr = date.year.toString();
        final monthStr = date.month.toString().padLeft(2, '0');
        final dayStr = date.day.toString().padLeft(2, '0');
        dateMatch = yearStr.contains(lowerQuery)
            || monthStr.contains(lowerQuery)
            || dayStr.contains(lowerQuery);
      }

      return combinedText.contains(lowerQuery) || dateMatch;
    }).toList();
  }

  List<MapEntry<String, List<JournalEntry>>> _groupAndSortEntries(List<JournalEntry> entries) {
    final groupedMap = <String, List<JournalEntry>>{};
    for (final e in entries) {
      final key = computeGroupKey(e);
      groupedMap.putIfAbsent(key, () => []).add(e);
    }
    final sortedGroups = groupedMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return sortedGroups;
  }
}

String computeGroupKey(JournalEntry entry) {
  final parsed = parseAddress(entry.address);

  if (parsed.region != null && parsed.country != null) {
    return '${parsed.region}, ${parsed.country}';
  } else if (parsed.country != null) {
    return parsed.country!;
  } else {
    return 'Unknown Location';
  }
}