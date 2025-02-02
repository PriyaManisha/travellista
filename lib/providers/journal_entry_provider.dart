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

      // Overwrite entryID with Firestore doc.id:
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

  Future<void> updateEntry(String entryID, JournalEntry updatedEntry) async {
    // Update in Firestore
    await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(entryID)
        .update(updatedEntry.toMap());

    // Update locally
    final index = _entries.indexWhere((e) => e.entryID == entryID);
    if (index != -1) {
      // Keep the same doc ID
      final newUpdated = updatedEntry.copyWith(entryID: entryID);
      _entries[index] = newUpdated;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String? entryID) async {
    if (entryID == null) return;

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(entryID)
        .delete();

    // Remove from list
    _entries.removeWhere((entry) => entry.entryID == entryID);
    notifyListeners();
  }
}


