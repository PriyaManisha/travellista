import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travellista/location_picker_screen.dart';
import 'package:travellista/util/location_service_wrapper.dart';
import 'package:travellista/util/parsed_location.dart';
import 'fakes/fake_routers.dart';
import 'fakes/fake_root_location_capturing_screen.dart';

import 'location_picker_screen_test.mocks.dart';

@GenerateMocks([ILocationService])
void main() {
  group('LocationPickerScreen Tests', () {
    late MockILocationService mockService;

    setUp(() {
      mockService = MockILocationService();
    });

    testWidgets('Displays the initial address in the UI', (tester) async {
      // setup / arrange / given : mock data and service, fake router, fake root screen
      when(mockService.reverseGeocode(any, any))
          .thenAnswer((_) async => const ParsedLocation(
        formattedAddress: 'Mocked Address',
      ));
      final router = fakeLocationPickerRouter(
        rootScreen: LocationPickerScreen(
          initialLocation: const LatLng(47.60621, -122.33207),
          initialAddress: 'Seattle, WA, United States',
          locationService: mockService,
        ),
        service: mockService,
      );

      // ACT : put the widget on the screen
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      // ASSERT: 'Seattle, WA, United States' is shown
      expect(find.text('Seattle, WA, United States'), findsOneWidget);
    });

    testWidgets('Tapping check icon returns a PickedLocationResult', (tester) async {
      // setup / arrange / given : mock data and service, fake router, fake root screen
      when(mockService.reverseGeocode(any, any)).thenAnswer((_) async =>
      const ParsedLocation(
        formattedAddress: 'Mocked Address',
      ),
      );
      final router = fakeLocationPickerRouter(
        rootScreen: RootLocationCapturingScreen(),
        service: mockService,
      );

      // ACT : put the widget on the screen
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // ACT : tap "Go to Picker"
      await tester.tap(find.text('Go to Picker'));
      await tester.pumpAndSettle();

      // Act tap map at a given long/latitude
      final mapFinder = find.byType(GoogleMap);
      final mapWidget = tester.widget<GoogleMap>(mapFinder);
      mapWidget.onTap?.call(const LatLng(47.60621, -122.33207));
      await tester.pumpAndSettle();

      // ACT : Tap check icon in the location picker
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // ASSERT / VERIFY : RootTestScreen's setState has updated:
      expect(find.text('Mocked Address'), findsOneWidget, reason: 'FAB shows the picked address');
    });

    testWidgets('Map onTap triggers reverseGeocode and updates the address', (tester) async {
      // setup / arrange / given : mock data and service, fake router
      when(mockService.reverseGeocode(40.0, -74.0)).thenAnswer((_) async =>
      const ParsedLocation(
        formattedAddress: 'Mocked New Address',
      ),
      );
      final router = fakeLocationPickerRouter(
        rootScreen: LocationPickerScreen(
          initialLocation: const LatLng(47.60621, -122.33207),
          initialAddress: 'Seattle, WA, United States',
          locationService: mockService,
        ),
        service: mockService,
      );

      // ACT : put the widget on the screen
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // ASSERT : 'Seattle, WA, United States' is shown
      expect(find.text('Seattle, WA, United States'), findsOneWidget);

      // ACT : Find the GoogleMap widget
      final googleMapFinder = find.byType(GoogleMap);
      final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);

      // ACT : Simulate user tapping new location
      googleMapWidget.onTap?.call(const LatLng(40.0, -74.0));

      await tester.pumpAndSettle();

      // ASSERT / VERIFY : Confirm new address
      expect(find.text('Mocked New Address'), findsOneWidget);
      verify(mockService.reverseGeocode(40.0, -74.0)).called(1);
    });
  });
}