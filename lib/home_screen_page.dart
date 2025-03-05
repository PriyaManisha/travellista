import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/shared_scaffold.dart';

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
              (entry.tags?.join(' ') ?? '')
      ).toLowerCase();

      // Optional: also match partial year, month, day
      final date = entry.timestamp;
      bool dateMatch = false;
      if (date != null) {
        final yearStr = date.year.toString();
        final monthStr = date.month.toString().padLeft(2, '0');
        final dayStr = date.day.toString().padLeft(2, '0');
        // If user typed "2023" or "05" or "12" etc.
        dateMatch = yearStr.contains(lowerQuery)
            || monthStr.contains(lowerQuery)
            || dayStr.contains(lowerQuery);
      }

      return combinedText.contains(lowerQuery) || dateMatch;
    }).toList();
  }

//   String preprocessQuery(String query) {
//     // If the user typed exactly a dictionary key, replace it
//     // Or you can split by spaces and replace each token.
//     final lower = query.toLowerCase();
//
//     // For a direct match:
//     if (synonyms.containsKey(lower)) {
//       return synonyms[lower]!;
//     }
//
//     // For partial or more advanced matching, you can do fuzzy checks, etc.
//     return query;
//   }
//
//   List<JournalEntry> _buildFilteredList(List<JournalEntry> allEntries, String query) {
//     if (!_isSearching || query.trim().isEmpty) {
//       return allEntries;
//     }
//
//     final processedQuery = preprocessQuery(query);
//     final lowerQuery = processedQuery.toLowerCase();
//
//     return allEntries.where((entry) {
//       // Same logic as before...
//       final combinedText = (
//           (entry.title ?? '') + (entry.address ?? '') + (entry.tags?.join(' ') ?? '')
//       ).toLowerCase();
//
//       // Optional date checking:
//       final date = entry.timestamp;
//       bool dateMatch = false;
//       if (date != null) {
//         final yearStr = date.year.toString();      // "2023"
//         final monthNum = date.month.toString();    // "2"
//         final month2 = monthNum.padLeft(2, '0');   // "02"
//         final dayStr = date.day.toString().padLeft(2, '0');
//
//         // Also map monthNum -> month names if you want:
//         // e.g., 2 -> "february" or "feb"
//
//         dateMatch = yearStr.contains(lowerQuery)
//             || monthNum.contains(lowerQuery)
//             || month2.contains(lowerQuery)
//             || dayStr.contains(lowerQuery);
//       }
//
//       return combinedText.contains(lowerQuery) || dateMatch;
//     }).toList();
//   }

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
//   HELPER STRUCTS/FUNCTIONS FOR PARSED LOCATION (below)
// -----------------------------------------------------------

class ParsedLocation {
  final String? city;
  final String? state;
  final String? country;
  ParsedLocation({this.city, this.state, this.country});
}

// Parse city, state, country
ParsedLocation parseLocation(String? address) {
  if (address == null || address.trim().isEmpty) {
    return ParsedLocation();
  }
  final parts = address.split(',').map((p) => p.trim()).toList();

  String? city;
  String? state;
  String? country;

  if (parts.length == 1) {
    country = parts[0];
  } else if (parts.length == 2) {
    state = parts[0];
    country = parts[1];
  } else {
    city = parts[0];
    state = parts[1];
    country = parts.last;
  }

  return ParsedLocation(city: city, state: state, country: country);
}

// Group by state, country for now
String computeGroupKey(JournalEntry entry) {
  final parsed = parseLocation(entry.address);
  if (parsed.state != null && parsed.country != null) {
    return '${parsed.state}, ${parsed.country}';
  } else if (parsed.country != null) {
    return parsed.country!;
  } else {
    return 'Unknown Location';
  }
}
