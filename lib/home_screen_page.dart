import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_card.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/models/journal_entry.dart';

// Helper struct
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

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();

    if (entryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entryProvider.entries.isEmpty) {
      return SharedScaffold(
        title: 'Travellista',
        selectedIndex: 0,
        body: Center(
          child: Text('No journal entries entered yet.'),
        ),
      );
    }

    final groupedMap = _groupEntriesByLocation(entryProvider.entries);

    return SharedScaffold(
      title: 'Travellista',
      selectedIndex: 0,
      body: ListView(
        children: groupedMap.entries.map((group) {
          final locationKey = group.key;
          final entriesForGroup = group.value;

          return ExpansionTile(
            title: Text(locationKey),
            children: entriesForGroup.map((entry) {
              return EntryCard(entry: entry);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Map<String, List<JournalEntry>> _groupEntriesByLocation(
      List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> result = {};
    for (var e in entries) {
      final key = computeGroupKey(e);
      result.putIfAbsent(key, () => []).add(e);
    }
    return result;
  }
}
