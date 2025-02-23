import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';

import 'entry_creation_form_test.mocks.dart';

@GenerateMocks([
  JournalEntryProvider,
  ProfileProvider,
  StorageService,
])

main() {
  group('EntryCreationForm - New Entry Tests', () {
    testWidgets('Creates a new entry with correct parameters from user input', (tester) async {
        // setup / given / arrange : mock provider and storage service
      final mockJournalProvider = MockJournalEntryProvider();
      final mockProfileProvider = MockProfileProvider();
      final mockStorage = MockStorageService();
      when(mockStorage.uploadFile(any, any))
          .thenAnswer((_) async => 'https://fake.com/uploaded_img.png');

      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(
        Profile(
          userID: 'demoUser',
          displayName: 'Demo Name',
          email: 'demo@demo.com',
        ),
      );

      when(mockStorage.uploadFile(any, any))
          .thenAnswer((_) async => 'https://fake.com/uploaded_img.png');

      // 1. Put widget on the virtual screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
            ChangeNotifierProvider<JournalEntryProvider>.value(value: mockJournalProvider),
            Provider<StorageService>.value(value: mockStorage),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EntryCreationForm(
                storageOverride: mockStorage,
              ),
            ),
          ),
        ),
      );

      // ACT - Fill text fields
      final titleField = find.widgetWithText(TextFormField, 'Title');
      await tester.enterText(titleField, 'My New Title');

      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      await tester.enterText(descriptionField, 'A quick description');

      // ACT - Tap save button
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // ASSERT - addEntry is called once
      final verifyCall = verify(mockJournalProvider.addEntry(captureAny));
      verifyCall.called(1);

      // ASSERT - Check captured JournalEntry has correct elements
      final newEntry = verifyCall.captured.single as JournalEntry;
      expect(newEntry.title, 'My New Title');
      expect(newEntry.description, 'A quick description');
      expect(newEntry.userID, 'demoUser');
    });
  });

  group('EntryCreationForm - Edit Entry Tests', () {
    testWidgets('Updates an existing entry with correct parameters', (WidgetTester tester) async {
      // setup / given / arrange : mock provider and storage service
      final mockJournalProvider = MockJournalEntryProvider();
      final mockProfileProvider = MockProfileProvider();
      final mockStorage = MockStorageService();

      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(
        Profile(
          userID: 'demoUser',
          displayName: 'Demo Name',
          email: 'demo@demo.com',
        ),
      );

      when(mockStorage.uploadFile(any, any))
          .thenAnswer((_) async => 'https://fake.com/uploaded_file.png');

      // Existing entry for editing
      final existingEntry = JournalEntry(
        entryID: 'abc123',
        userID: 'demoUser',
        title: 'Old Title',
        description: 'Old Description',
        timestamp: DateTime(2025, 02, 02),
        latitude: 37.7749,
        longitude: -122.4194,
      );

      // ACT - Put widget on the virtual screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
            ChangeNotifierProvider<JournalEntryProvider>.value(value: mockJournalProvider),
            Provider<StorageService>.value(value: mockStorage),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EntryCreationForm(
                existingEntry: existingEntry,
                storageOverride: mockStorage,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ASSERT (initial) - old fields should be present
      expect(find.text('Old Title'), findsOneWidget);
      expect(find.text('Old Description'), findsOneWidget);

      // ACT - Edit the title
      final titleField = find.widgetWithText(TextFormField, 'Old Title');
      await tester.enterText(titleField, 'New Title');

      // ACT - tap update button
      final updateButton = find.text('Update Entry');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // ASSERT (final) - updateEntry is called once and captures aruments
      final verification = verify(mockJournalProvider.updateEntry(captureAny, captureAny));
      verification.called(1);

      final capturedArgs = verification.captured;
      final updatedEntryID = capturedArgs[0] as String;
      final updatedEntryObj = capturedArgs[1] as JournalEntry;

      // Confirm we updated the existing doc
      expect(updatedEntryID, 'abc123');
      // Confirm the new title & old description
      expect(updatedEntryObj.title, 'New Title');
      expect(updatedEntryObj.description, 'Old Description');
      // Check userID
      expect(updatedEntryObj.userID, 'demoUser');
    });
  });
}