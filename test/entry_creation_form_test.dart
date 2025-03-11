import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/models/profile.dart';
import 'package:travellista/util/storage_service.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/router/app_router.dart';

import 'entry_creation_form_test.mocks.dart';
import 'fakes/fake_routers.dart';

@GenerateMocks([
  JournalEntryProvider,
  ProfileProvider,
  StorageService,
  ImagePicker,
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

      final router = fakeNewEntryRouter(
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

      // 1. Put widget on the virtual screen
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      // ACT - Fill text fields
      final titleField = find.widgetWithText(TextFormField, 'Title');
      await tester.enterText(titleField, 'My New Title');

      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      await tester.enterText(descriptionField, 'A quick description');

      final tagField = find.widgetWithText(TextFormField, 'e.g. beach, hiking, summer');
      await tester.enterText(tagField, 'beach, hiking, summer');


      // ACT - Tap save button
      final saveButton = find.byIcon(Icons.save);
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
      expect(newEntry.tags, containsAll(['beach', 'hiking', 'summer']));
    });

    testWidgets('Adds image and video via picker', (tester) async {
      // setup / given / arrange : mock provider, storage service, image picker
      final mockJournalProvider = MockJournalEntryProvider();
      final mockProfileProvider = MockProfileProvider();
      final mockStorage = MockStorageService();
      final mockImagePicker = MockImagePicker();

      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(
        Profile(userID: 'demoUser', displayName: 'Demo Name', email: 'demo@demo.com'),
      );

      when(mockStorage.uploadFile(any, any)).thenAnswer((invocation) async {
        final path = invocation.positionalArguments[1] as String;
        if (path.startsWith('images/')) return 'https://fake.com/image.png';
        if (path.startsWith('videos/')) return 'https://fake.com/video.mp4';
        if (path.startsWith('thumbnails/')) return 'https://fake.com/thumb.jpg';
        return 'https://fake.com/default.png';
      });

      when(mockImagePicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/path/image.png'));
      when(mockImagePicker.pickVideo(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/path/video.mp4'));

      final router = fakeNewEntryRouter(
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
                pickerOverride: mockImagePicker,
              ),
            ),
          ),
        ),
      );

      // Put the widget on the virtual screen
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Act: Add an image
      final imageButton = find.byIcon(Icons.photo);
      await tester.tap(imageButton);
      await tester.pumpAndSettle();

      final galleryOption = find.textContaining('Gallery');
      await tester.tap(galleryOption);
      await tester.pumpAndSettle();

      // Verify: image picker was called
      verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);

      // Act: Add a video
      final videoButton = find.byIcon(Icons.videocam);
      await tester.tap(videoButton);
      await tester.pumpAndSettle();

      await tester.tap(galleryOption);
      await tester.pumpAndSettle();

      // Verify: video picker was called
      verify(mockImagePicker.pickVideo(source: ImageSource.gallery)).called(1);
    });
  });

  group('EntryCreationForm - Edit Entry Tests', () {
    testWidgets('Updates an existing entry with correct parameters', (WidgetTester tester) async {
      // Setup: Mock provider and storage service
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

      final editFormWidget = MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
          ChangeNotifierProvider<JournalEntryProvider>.value(value: mockJournalProvider),
          Provider<StorageService>.value(value: mockStorage),
        ],
        child: Scaffold(
          body: EntryCreationForm(
            existingEntry: existingEntry,
            storageOverride: mockStorage,
          ),
        ),
      );

      final router = fakeEditEntryRouter(editFormWidget);

      // Put widget on the virtual screen
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      // Navigate to the edit screen
      final goToEditButton = find.text('Go to Edit Screen');
      expect(goToEditButton, findsOneWidget);
      await tester.tap(goToEditButton);
      await tester.pumpAndSettle();

      // Assert (initial): Old fields should be present
      expect(find.text('Old Title'), findsOneWidget);
      expect(find.text('Old Description'), findsOneWidget);

      // Act: Edit the title
      final titleField = find.widgetWithText(TextFormField, 'Old Title');
      await tester.enterText(titleField, 'New Title');

      // Act: Tap update button
      final updateButton = find.byIcon(Icons.check);
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Assert : updateEntry is called once and captures arguments
      final verification = verify(mockJournalProvider.updateEntry(captureAny, captureAny));
      verification.called(1);

      final capturedArgs = verification.captured;
      final updatedEntryID = capturedArgs[0] as String;
      final updatedEntryObj = capturedArgs[1] as JournalEntry;

      // Assert : Confirm we updated the existing doc
      expect(updatedEntryID, 'abc123');
      expect(updatedEntryObj.title, 'New Title');
      expect(updatedEntryObj.description, 'Old Description');
      expect(updatedEntryObj.userID, 'demoUser');
    });
  });
}