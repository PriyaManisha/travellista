import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/models/journal_entry.dart';
import 'entry_creation_form_test.mocks.dart';

@GenerateMocks([
  JournalEntryProvider,
  StorageService,
])
main() {
  group('EntryCreationForm - New Entry Tests', () {
    testWidgets('Creates a new entry with correct parameters from user input', (tester) async {
      // setup / given / arrange : mock provider and storage service
      final mockProvider = MockJournalEntryProvider();
      final mockStorage = MockStorageService();
      when(mockStorage.uploadFile(any, any))
          .thenAnswer((_) async => 'https://fake.com/uploaded_img.png');

      // 1. Put the widget on the virtual screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<JournalEntryProvider>.value(value: mockProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EntryCreationForm(storageOverride: mockStorage),
            ),
          ),
        ),
      );

      // Act : Fill text fields
      final titleField = find.widgetWithText(TextFormField, 'Title');
      await tester.enterText(titleField, 'My New Title');

      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      await tester.enterText(descriptionField, 'A quick description');

      // Act : Tap save button
      final saveButton = find.text('Save Entry');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pumpAndSettle();

      // Asset : verify entry added
      final verifyCall = verify(mockProvider.addEntry(captureAny));
      verifyCall.called(1);

      final newEntry = verifyCall.captured.single as JournalEntry;
      expect(newEntry.title, 'My New Title');
      expect(newEntry.description, 'A quick description');

      // Assert : make sure no media was uploaded
      verifyNever(mockStorage.uploadFile(any, any));
    });
  });

  group('EntryCreationForm - Edit Entry Tests', () {
    testWidgets('Updates an existing entry with correct parameters', (WidgetTester tester) async {
      // setup / given / arrange : mock provider and storage service
      final mockProvider = MockJournalEntryProvider();
      final mockStorage = MockStorageService();

      when(mockStorage.uploadFile(any, any))
          .thenAnswer((_) async => 'https://fake.com/uploaded_file.png');

      // Arrange: existing entry to simulate editing
      final existingEntry = JournalEntry(
        entryID: 'abc123',
        userID: 'some_user_id',
        title: 'Old Title',
        description: 'Old Description',
        timestamp: DateTime(2025, 02, 02),
        latitude: 37.7749,
        longitude: -122.4194,
      );

      // 1. Put the widget on the virtual screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<JournalEntryProvider>.value(value: mockProvider),
            Provider<StorageService>.value(value: mockStorage),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: EntryCreationForm(
                existingEntry: existingEntry,
                storageOverride: mockStorage, // <-- pass the mock
              ),
            ),
          ),
        ),
      );

      // Assert : entry fields should be pre-filled
      expect(find.text('Old Title'), findsOneWidget);
      expect(find.text('Old Description'), findsOneWidget);

      // Act : edit title field
      final titleField = find.widgetWithText(TextFormField, 'Old Title');
      await tester.enterText(titleField, 'New Title');

      // Act : tap "Update" button
      final updateButton = find.text('Update Entry');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert : verify updateEntry is called and captures arguments:
      final verification = verify(mockProvider.updateEntry(captureAny, captureAny));
      verification.called(1);

      final capturedArgs = verification.captured;
      final updatedEntryID = capturedArgs[0] as String;
      final updatedEntryObj = capturedArgs[1] as JournalEntry;

      // Assert : verify details of updated entry
      expect(updatedEntryID, 'abc123');
      expect(updatedEntryObj.title, 'New Title');
      expect(updatedEntryObj.description, 'Old Description');
    });
  });
}