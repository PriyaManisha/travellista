import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travellista/models/journal_entry.dart';

class JournalEntryProvider extends ChangeNotifier {
  final List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => _entries;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch from Firestore when providers is created
  JournalEntryProvider() {
    //fetchEntries();
  }

  // Fetch all entries
  Future<void> fetchEntriesForUser(String userID) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    _entries.clear();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('journal_entries')
        .where('userID', isEqualTo: userID)
        .get();

    for (var doc in querySnapshot.docs) {
      final mapData = doc.data();
      final entry = JournalEntry.fromMap(mapData);
      entry.entryID = doc.id;
      _entries.add(entry);
    }

    _isLoading = false;
    if (_entries.isNotEmpty) {
      notifyListeners();
    }
  }

  Future<void> addEntry(JournalEntry entry) async {
    // Save to Firestore using model’s .toMap() function
    final docRef = await FirebaseFirestore.instance
        .collection('journal_entries')
        .add(entry.toMap());

    await docRef.update({'entryID': docRef.id});

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




