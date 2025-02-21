import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/entry_card.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'home_screen_page_test.mocks.dart';

@GenerateMocks([JournalEntryProvider])

void main() {
  late MockJournalEntryProvider mockProvider;

  setUp(() {
    mockProvider = MockJournalEntryProvider();
  });

  Widget createHomeScreenUnderTest() {
    return ChangeNotifierProvider<JournalEntryProvider>.value(
      value: mockProvider,
      child: const MaterialApp(
        home: HomeScreenPage(),
      ),
    );
  }

  group('HomeScreenPage Widget Tests', () {
    testWidgets('Shows CircularProgressIndicator when isLoading is true',
            (WidgetTester tester) async {
          // Arrange
          when(mockProvider.isLoading).thenReturn(true);
          when(mockProvider.entries).thenReturn([]); // or doesn't matter
          // Act
          await tester.pumpWidget(createHomeScreenUnderTest());

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('No journal entries entered yet.'), findsNothing);
        });

    testWidgets('Shows "No journal entries..." text when not loading and entries is empty',
            (WidgetTester tester) async {
          // Arrange
          when(mockProvider.isLoading).thenReturn(false);
          when(mockProvider.entries).thenReturn([]);

          // Act
          await tester.pumpWidget(createHomeScreenUnderTest());

          // Assert
          expect(find.text('No journal entries entered yet.'), findsOneWidget);
          expect(find.byType(ExpansionTile), findsNothing);
        });

    testWidgets('Shows expansion tiles and entries when not loading and entries is not empty',
            (WidgetTester tester) async {
          // Arrange
          when(mockProvider.isLoading).thenReturn(false);

          final entry1 = JournalEntry(
            entryID: '1',
            userID: 'userA',
            title: 'Title 1',
            address: 'WA, United States',
            timestamp: DateTime(2023, 1, 1),
            latitude: 47.6062,
            longitude: -122.3321,
            imageURLs: [],
            videoURLs: [],
          );

          when(mockProvider.entries).thenReturn([entry1]);

          // Act
          await tester.pumpWidget(createHomeScreenUnderTest());

          // Assert - we expect 1 ExpansionTile for WA
          expect(find.byType(ExpansionTile), findsNWidgets(1));

          // Verify we see location text in tile
          expect(find.text('WA, United States'), findsOneWidget);

          await tester.tap(find.text('WA, United States'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(EntryCard));
          expect(find.byType(EntryCard), findsOneWidget);
          expect(find.text('Title 1'), findsOneWidget);
          await tester.pumpAndSettle();
        });
  });
}

