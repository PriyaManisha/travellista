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
  });
}
