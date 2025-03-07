import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:travellista/map_view_page.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';

import 'map_view_page_test.mocks.dart';

@GenerateMocks([JournalEntryProvider])
void main() {
  late MockJournalEntryProvider mockProvider;

  setUp(() {
    mockProvider = MockJournalEntryProvider();
  });

  Widget createMapViewPageUnderTest() {
    return ChangeNotifierProvider<JournalEntryProvider>.value(
      value: mockProvider,
      child: const MaterialApp(
        home: MapViewPage(),
      ),
    );
  }

  group('MapViewPage Widget Tests', () {
    testWidgets('Shows CircularProgressIndicator when isLoading is true',
            (WidgetTester tester) async {
          // setup/given/arrange : mock provider
          when(mockProvider.isLoading).thenReturn(true);
          when(mockProvider.entries).thenReturn([]);

          // Act: display widget to virtual screen
          await tester.pumpWidget(createMapViewPageUnderTest());

          // Assert: we expect a circular progress spinner
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.byType(GoogleMap), findsNothing);
        });

    testWidgets('Shows GoogleMap with no markers when entries is empty and isLoading is false',
            (WidgetTester tester) async {
          // setup/given/arrange : mock provider
          when(mockProvider.isLoading).thenReturn(false);
          when(mockProvider.entries).thenReturn([]);

          // Act: display widget to virtual screen
          await tester.pumpWidget(createMapViewPageUnderTest());

          // Assert: should not find the progress indicator
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.byType(GoogleMap), findsOneWidget);

          // Act: Retrieve the GoogleMap widget
          final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));

          // Assert: Verify that the markers set is empty
          expect(googleMapWidget.markers, isEmpty);
        });

    testWidgets('Shows GoogleMap with markers for each entry when isLoading is false and there are entries',
            (WidgetTester tester) async {
          // setup/given/arrange : mock provider
          when(mockProvider.isLoading).thenReturn(false);

          // Arrange - Create sample journal entries with lat/long
          final entry1 = JournalEntry(
            entryID: '1',
            userID: 'userA',
            title: 'Title 1',
            latitude: 47.6062,
            longitude: -122.3321,
            address: 'Seattle, WA, United States',
          );
          final entry2 = JournalEntry(
            entryID: '2',
            userID: 'userB',
            title: 'Title 2',
            latitude: 34.0522,
            longitude: -118.2437,
            address: 'Los Angeles, CA, United States',
          );
          when(mockProvider.entries).thenReturn([entry1, entry2]);

          // Act - display widget to virtual screen
          await tester.pumpWidget(createMapViewPageUnderTest());

          // Assert - should not find the progress indicator
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.byType(GoogleMap), findsOneWidget);

          // Access actual GoogleMap widget
          final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));

          // Verify GoogleMap has journal markers
          final markers = googleMapWidget.markers;
          expect(markers.length, 2);

          // Assert - each entry’s lat/lng is present
          final markerPositions = markers.map((m) => m.position).toSet();
          expect(markerPositions, contains(const LatLng(47.6062, -122.3321)));
          expect(markerPositions, contains(const LatLng(34.0522, -118.2437)));
        });
    testWidgets('Search filters out non-matching entries in MapViewPage', (WidgetTester tester) async {
      // setup/given/arrange : mock provider and journal data
      when(mockProvider.isLoading).thenReturn(false);

      final entry1 = JournalEntry(
        entryID: '1',
        userID: 'userA',
        title: 'Beach Trip',
        address: 'CA, USA',
        latitude: 34.0,
        longitude: -118.0,
        tags: ['beach', 'fun'],
      );
      final entry2 = JournalEntry(
        entryID: '2',
        userID: 'userB',
        title: 'Mountain Adventure',
        address: 'CO, USA',
        latitude: 39.0,
        longitude: -105.0,
        tags: ['hiking'],
      );

      when(mockProvider.entries).thenReturn([entry1, entry2]);

      // ACT: Display the widget on the virtual screen
      await tester.pumpWidget(createMapViewPageUnderTest());
      await tester.pumpAndSettle();

      // ASSERT : we see 2 markers
      final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(googleMapWidget.markers.length, 2);

      // ACT: Toggle the search bar by tapping the search icon
      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // EXPECT : TextField for search should appear
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // ACT: type "beach" into the search field
      await tester.enterText(searchField, 'beach');
      await tester.pumpAndSettle();

      // ASSERT : only the "beach" tag entry should show up
      final updatedMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(updatedMapWidget.markers.length, 1);

      // ASSERT : last marker should be for entry1 (lat=34.0, lon=-118.0)
      final theMarker = updatedMapWidget.markers.first;
      expect(theMarker.position, const LatLng(34.0, -118.0));
    });
  });
}
