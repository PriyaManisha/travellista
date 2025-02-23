import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/location_picker_screen.dart';
import 'package:travellista/util/location_service_wrapper.dart';

import 'location_picker_screen_test.mocks.dart';

@GenerateMocks([ILocationService])
void main() {
  group('LocationPickerScreen Tests', () {
    late MockILocationService mockService;

    setUp(() {
      mockService = MockILocationService();
    });

    testWidgets('Displays the initial address in the UI', (tester) async {
      // ARRANGE: Mock the service to return a mocked address
      when(mockService.reverseGeocode(any, any))
          .thenAnswer((_) async => 'Mocked Address');

      // ACT: Put the widget on the virtual screen
      await tester.pumpWidget(
        MaterialApp(
          home: LocationPickerScreen(
            initialLocation: const LatLng(47.60621, -122.33207),
            initialAddress: 'Seattle, WA, United States',
            locationService: mockService,
          ),
        ),
      );

      await tester.pump();

      // ASSERT: Check the address is shown
      expect(find.text('Seattle, WA, United States'), findsOneWidget);
    });

    testWidgets('Tapping check icon pops with current lat/long and address', (tester) async {
      // ARRANGE: Mock the service to return a mocked address
      when(mockService.reverseGeocode(any, any))
          .thenAnswer((_) async => 'Mocked Address');

      late PickedLocationResult? result;

      // ACT: Put the widget on the virtual screen
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<PickedLocationResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationPickerScreen(
                      initialLocation: const LatLng(47.60621, -122.33207),
                      initialAddress: 'Seattle, WA, United States',
                      locationService: mockService,
                    ),
                  ),
                );
              },
              child: const Text('Go to Picker'),
            );
          }),
        ),
      );

      // Tap to navigate
      await tester.tap(find.text('Go to Picker'));
      await tester.pumpAndSettle();

      // ACT : Tap the check icon to pop
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // ASSERT : The screen popped with a PickedLocationResult
      expect(result, isNotNull);
      // The lat/lng should match initial location
      expect(result!.latLng, const LatLng(47.60621, -122.33207));
      expect(result!.address, 'Seattle, WA, United States');
    });


    testWidgets('Map onTap triggers reverseGeocode and updates the address', (tester) async {
      // setup/given/arrange : mock service
      when(mockService.reverseGeocode(40.0, -74.0))
          .thenAnswer((_) async => 'Mocked New Address');

      // ACT: Put the widget on the virtual screen
      await tester.pumpWidget(
        MaterialApp(
          home: LocationPickerScreen(
            initialLocation: const LatLng(47.60621, -122.33207),
            initialAddress: 'Old Address',
            locationService: mockService,
          ),
        ),
      );
      await tester.pump();

      // ASSERT : old address is visible initially
      expect(find.text('Old Address'), findsOneWidget);

      // ACT: Simulate tapping on the map by calling the GoogleMap's onTap
      final googleMapFinder = find.byType(GoogleMap);
      expect(googleMapFinder, findsOneWidget);

      final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);
      // ASSERT : onTap is the callback used when the map is tapped
      final onTapCallback = googleMapWidget.onTap;
      expect(onTapCallback, isNotNull);

      // ACT : Call the callback with a new location
      onTapCallback?.call(const LatLng(40.0, -74.0));

      // ACT " Let the future complete
      await tester.pumpAndSettle();

      // ASSERT: The address changed to 'Mocked New Address'
      expect(find.text('Mocked New Address'), findsOneWidget);
      // VERIFY : Also confirm mock was called
      verify(mockService.reverseGeocode(40.0, -74.0)).called(1);
    });
  });
}