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
  final TextEditingController _searchController = TextEditingController();

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

    // 1) Handle loading
    if (entryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) Handle no entries at all
    if (entryProvider.entries.isEmpty) {
      return _buildNoEntriesYetScaffold();
    }

    // 3) Build the filtered list
    final filteredEntries = _buildFilteredList(entryProvider.entries, _searchController.text);

    // 4) If user is searching but found 0 matches
    if (filteredEntries.isEmpty && _isSearching) {
      return _buildNoResultsScaffold();
    }

    // 5) Group & sort
    final sortedGroups = _groupAndSortEntries(filteredEntries);

    // 6) Build the normal page
    return _buildMainScaffold(sortedGroups);
  }

  // ------------------------------------------
  //    PRIVATE HELPER WIDGETS / METHODS
  // ------------------------------------------

  Widget _buildNoEntriesYetScaffold() {
    return const SharedScaffold(
      title: 'Travellista',
      selectedIndex: 0,
      body: Center(
        child: Text('No journal entries entered yet.'),
      ),
    );
  }

  Widget _buildNoResultsScaffold() {
    return SharedScaffold(
      titleWidget: _buildSearchField(),
      actions: [_buildSearchIcon()],
      selectedIndex: 0,
      body: const Center(
        child: Text('No entries match your search.'),
      ),
    );
  }

  Widget _buildMainScaffold(List<MapEntry<String, List<JournalEntry>>> sortedGroups) {
    return SharedScaffold(
      titleWidget: _isSearching ? _buildSearchField() : const Text('Travellista'),
      actions: [_buildSearchIcon()],
      selectedIndex: 0,
      body: ListView(
        children: sortedGroups.map((group) {
          final locationKey = group.key; // e.g. "State, Country"
          final entriesForGroup = group.value;

          return ExpansionTile(
            key: UniqueKey(),
            title: Text(locationKey),
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

  TextField _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
      onChanged: (_) => setState(() {}), // triggers rebuild for filtering
    );
  }

  IconButton _buildSearchIcon() {
    return IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: () {
        setState(() {
          if (_isSearching) {
            _searchController.clear();
          }
          _isSearching = !_isSearching;
        });
      },
    );
  }

  // ------------------------------------------
  //     LOGIC FOR FILTERING / GROUPING
  // ------------------------------------------

  List<JournalEntry> _buildFilteredList(List<JournalEntry> allEntries, String query) {
    if (!_isSearching || query.trim().isEmpty) {
      return allEntries;
    }
    final lowerQuery = query.toLowerCase();

    return allEntries.where((entry) {
      // Combine title, address, and tags for text matching
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

    // Sort the groups by number of items desc
    final sortedGroups = groupedMap.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return sortedGroups;
  }
}

// -----------------------------------------------------------
//   HELPER STRUCTS/FUNCTIONS FOR PARSED LOCATION
// -----------------------------------------------------------

// Group by state, country for now
String computeGroupKey(JournalEntry entry) {
  final parsed = parseAddress(entry.address);

  // If you want to group by region + country:
  if (parsed.region != null && parsed.country != null) {
    return '${parsed.region}, ${parsed.country}';
  } else if (parsed.country != null) {
    return parsed.country!;
  } else {
    return 'Unknown Location';
  }
}
