import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/entry_card.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/providers/profile_provider.dart';
import 'package:travellista/models/journal_entry.dart';

import 'home_screen_page_test.mocks.dart';

@GenerateMocks([JournalEntryProvider, ProfileProvider])

void main() {
  late MockJournalEntryProvider mockJournalProvider;
  late MockProfileProvider mockProfileProvider;

  setUp(() {
    mockJournalProvider = MockJournalEntryProvider();
    mockProfileProvider = MockProfileProvider();
  });

  Widget createHomeScreenUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
        ChangeNotifierProvider<JournalEntryProvider>.value(value: mockJournalProvider),
      ],
      child: const MaterialApp(
        home: HomeScreenPage(),
      ),
    );
  }

  group('HomeScreenPage Widget Tests', () {
    testWidgets('Shows CircularProgressIndicator when isLoading is true', (WidgetTester tester) async {
      // setup / given / arrange : mock providers
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(null);
      when(mockJournalProvider.isLoading).thenReturn(true);
      when(mockJournalProvider.entries).thenReturn([]);

      // Act - display widget to virtual screen
      await tester.pumpWidget(createHomeScreenUnderTest());

      // Assert - we expect a circular progress spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('No journal entries entered yet.'), findsNothing);
    });

    testWidgets('Shows "No journal entries..." text when not loading and entries is empty', (WidgetTester tester) async {
      // setup / given / arrange : mock providers
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(null);
      when(mockJournalProvider.isLoading).thenReturn(false);
      when(mockJournalProvider.entries).thenReturn([]);

      // Act - display widget to virtual screen
      await tester.pumpWidget(createHomeScreenUnderTest());

      // Assert
      expect(find.text('No journal entries entered yet.'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('Shows expansion tiles and entries when not loading and entries is not empty', (WidgetTester tester) async {
      // setup / given / arrange : mock providers
      when(mockProfileProvider.isLoading).thenReturn(false);
      when(mockProfileProvider.profile).thenReturn(null);
      when(mockJournalProvider.isLoading).thenReturn(false);

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

      when(mockJournalProvider.entries).thenReturn([entry1]);

      // Act - display widget to virtual screen
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

