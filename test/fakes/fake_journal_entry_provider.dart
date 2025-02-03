import 'package:travellista/providers/journal_entry_provider.dart';

// Helper to define a fake provider that disables Firestore for testing
class FakeJournalEntryProvider extends JournalEntryProvider {
  void addTestEntryToList(entry) {
    // Because `_entries` is private, you can do something like:
    entries.add(entry);
    notifyListeners();
  }
  @override
  Future<void> fetchEntries() async {

  }
}