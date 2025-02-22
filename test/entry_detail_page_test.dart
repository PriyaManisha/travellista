import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:travellista/entry_detail_page.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';

import 'fakes/fake_video_player.dart';
import 'entry_detail_page_test.mocks.dart';

@GenerateMocks([JournalEntryProvider])
void main() {
  late MockJournalEntryProvider mockProvider;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // So Chewie/video_player won't crash
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  setUp(() {
    mockProvider = MockJournalEntryProvider();
  });

  Widget createTestWidget(String entryID) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<JournalEntryProvider>.value(value: mockProvider),
      ],
      child: MaterialApp(
        home: EntryDetailPage(entryID: entryID),
      ),
    );
  }

  group('EntryDetailPage Tests', () {
    final sampleEntry = JournalEntry(
      entryID: 'entry123',
      userID: 'userABC',
      title: 'Test Title',
      description: 'Test Description',
      timestamp: DateTime(2025, 5, 10),
      latitude: 37.7749,
      longitude: -122.4194,
      address: 'San Francisco, CA, USA',
      imageURLs: ['http://example.com/image1.jpg'],
      videoURLs: ['http://example.com/video1.mp4'],
    );

    testWidgets('Displays entry details (title, description, date, etc.)',
            (WidgetTester tester) async {
          // Wrap in mockNetworkImagesFor
          await mockNetworkImagesFor(() async {
            // setup / given / arrange
            when(mockProvider.entries).thenReturn([sampleEntry]);

            // ACT
            await tester.pumpWidget(createTestWidget('entry123'));
            // await tester.pumpAndSettle();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 200));

            // ASSERT
            expect(find.text('Test Title'), findsOneWidget);
            expect(find.text('Test Description'), findsOneWidget);

            final formattedDate =
            DateFormat('MM/dd/yyyy').format(sampleEntry.timestamp!);
            expect(find.textContaining(formattedDate), findsOneWidget);
            expect(find.textContaining('San Francisco, CA, USA'), findsOneWidget);

            expect(find.text('Images:'), findsOneWidget);
            expect(find.text('Videos:'), findsOneWidget);
            expect(find.byType(Image), findsWidgets);
          });
        });

    testWidgets('Tapping delete button shows confirmation dialog, then user cancels',
            (WidgetTester tester) async {
          await mockNetworkImagesFor(() async {
            // setup / given / arrange
            when(mockProvider.entries).thenReturn([sampleEntry]);

            await tester.pumpWidget(createTestWidget('entry123'));
            await tester.pumpAndSettle();

            // ACT - find and tap the delete icon
            final deleteIcon = find.byIcon(Icons.delete);
            expect(deleteIcon, findsOneWidget);

            await tester.tap(deleteIcon);
            await tester.pumpAndSettle();

            // ASSERT - confirm dialog is visible
            expect(find.text('Are you sure you want to delete this entry?'), findsOneWidget);
            expect(find.text('Cancel'), findsOneWidget);
            expect(find.text('Delete'), findsOneWidget);

            // Tap "Cancel"
            await tester.tap(find.text('Cancel'));
            await tester.pumpAndSettle();

            // Dialog closed
            expect(find.text('Are you sure you want to delete this entry?'), findsNothing);
            // No delete call
            verifyNever(mockProvider.deleteEntry(any));
          });
        });

    testWidgets('Tapping delete button calls provider and shows snackBar',
            (WidgetTester tester) async {
          await mockNetworkImagesFor(() async {
            // setup / given / arrange
            when(mockProvider.entries).thenReturn([sampleEntry]);

            await tester.pumpWidget(createTestWidget('entry123'));
            // Use smaller pumps so we don't hang forever
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 200));

            // Tap the delete icon
            final deleteIcon = find.byIcon(Icons.delete);
            await tester.tap(deleteIcon);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 200));

            // Confirm
            await tester.tap(find.text('Delete'));
            await tester.pump();
            // Let snackBar animate in but do not wait so long
            await tester.pump(const Duration(milliseconds: 200));

            // Verify the provider call
            verify(mockProvider.deleteEntry('entry123')).called(1);

            // Act : Wait enough time for the pop to happen
            await tester.pump(const Duration(milliseconds: 500));
            // Assert : popped away, message would show on home page
            expect(find.text('Entry deleted successfully!'), findsNothing);
          });
        });

    testWidgets('Delete error scenario shows error snackBar',
            (WidgetTester tester) async {
          await mockNetworkImagesFor(() async {
            // setup / given / arrange
            when(mockProvider.entries).thenReturn([sampleEntry]);
            when(mockProvider.deleteEntry('entry123'))
                .thenThrow(Exception('Deletion failed'));

            await tester.pumpWidget(createTestWidget('entry123'));
            await tester.pumpAndSettle();

            // Act - Tap delete icon
            final deleteIcon = find.byIcon(Icons.delete);
            await tester.tap(deleteIcon);
            await tester.pumpAndSettle();

            // Confirm
            await tester.tap(find.text('Delete'));
            await tester.pumpAndSettle();

            // Verify error message displayed
            verify(mockProvider.deleteEntry('entry123')).called(1);
            expect(find.text('Error deleting entry'), findsOneWidget);
          });
        });

    testWidgets('Tapping an image opens a fullscreen dialog',
            (WidgetTester tester) async {
          await mockNetworkImagesFor(() async {
            // setup / given / arrange
            when(mockProvider.entries).thenReturn([sampleEntry]);

            await tester.pumpWidget(createTestWidget('entry123'));
            //await tester.pumpAndSettle();
            await tester.pump(const Duration(milliseconds: 500));

            // Act : tap image
            final imageFinder = find.byType(Image);
            expect(imageFinder, findsOneWidget);

            await tester.tap(imageFinder);
            await tester.pumpAndSettle();

            // Assert : visible dialogue
            expect(find.byType(Dialog), findsOneWidget);

            // Act / Assert : Close prompt
            await tester.ensureVisible(find.byIcon(Icons.close));
            final closeButton = find.byIcon(Icons.close);
            expect(closeButton, findsOneWidget);

            await tester.tap(closeButton, warnIfMissed: false);
            await tester.pumpAndSettle();

            // Assert : closed dialogue not showing
            expect(find.byType(Dialog), findsNothing);
          });
        });
  });
}