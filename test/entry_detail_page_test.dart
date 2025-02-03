import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/entry_detail_page.dart';
import 'fakes/fake_journal_entry_provider.dart';

void main() {
  testWidgets(
    'Confirm EntryDetailPage shows the entry title, date, description',
        (WidgetTester tester) async {
          // setup / given / arrange : fake provider and a test entry
      final provider = FakeJournalEntryProvider();
      final testEntry = JournalEntry(
        entryID: 'abc123',
        title: 'My Test Journal',
        description: 'This is a test entry.',
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime(2025, 02, 02),
        userID: 'xxx',
      );
      provider.entries.add(testEntry);

      // 1. Act: Pump the widget and display to virtual screen
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<JournalEntryProvider>.value(
            value: provider,
            child: EntryDetailPage(entryID: 'abc123'),
          ),
        ),
      );

      // Assert:
      // 1. Title
      expect(find.text('My Test Journal'), findsOneWidget);
      // 2. Date: The detail page code uses e.g. 'Date: 2025-02-02'
      expect(find.text('Date: 02/02/2025'), findsOneWidget);
      // 3. Description
      expect(find.text('This is a test entry.'), findsOneWidget);
      // 4. Location
      expect(find.text('Location: 37.7749, -122.4194'), findsOneWidget);
    },
  );
}
