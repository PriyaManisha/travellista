import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travellista/models/journal_entry.dart';

class JournalEntryProvider extends ChangeNotifier {
  final List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => _entries;

  // Fetch from Firestore when providers is created
  JournalEntryProvider() {
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    _entries.clear();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('journal_entries')
        .get();

    for (var doc in querySnapshot.docs) {
      // Convert document to JournalEntry using factory constructor
      final mapData = doc.data();
      final entryFromMap = JournalEntry.fromMap(mapData);

      // Overwrite the entryID with Firestore doc.id if needed:
      entryFromMap.entryID = doc.id;

      _entries.add(entryFromMap);
    }
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    // Save to Firestore using your model’s .toMap() function
    final docRef = await FirebaseFirestore.instance
        .collection('journal_entries')
        .add(entry.toMap());

    // Update local state with the newly created doc’s ID
    final newEntry = entry.copyWith(entryID: docRef.id);
    _entries.add(newEntry);

    notifyListeners();
  }
}
