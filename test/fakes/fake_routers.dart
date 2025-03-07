import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/location_picker_screen.dart';
import 'package:travellista/util/location_service_wrapper.dart';

/// Fake router for new entry screen / nav
GoRouter fakeNewEntryRouter(Widget formWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => formWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}

/// Fake router for edit screen / nav
GoRouter fakeEditEntryRouter(Widget rootWidget) {
  return GoRouter(
    initialLocation: '/dummy',
    routes: [
      GoRoute(
        path: '/dummy',
        builder: (ctx, state) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                ctx.push('/edit');
              },
              child: const Text('Go to Edit Screen'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/edit',
        builder: (ctx, state) => rootWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}

/// Fake router for detail screen
GoRouter fakeDetailRouter(Widget detailWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => detailWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}

/// Fake router for location picker screen
GoRouter fakeLocationPickerRouter({
  required Widget rootScreen,
  required ILocationService service,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => rootScreen,
        routes: [
          GoRoute(
            path: 'location-picker',
            name: 'locationPicker',
            builder: (ctx, st) {
              final extras = st.extra as Map<String, dynamic>? ?? {};
              final latLng = extras['initialLocation'] as LatLng?
                  ?? const LatLng(47.60621, -122.33207);
              final addr = extras['initialAddress'] as String?
                  ?? 'Seattle, Washington, United States';

              return LocationPickerScreen(
                initialLocation: latLng,
                initialAddress: addr,
                locationService: service,
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// Fake router for profile screen
GoRouter fakeProfileRouter(Widget profileWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => profileWidget,
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const Scaffold(
          body: Center(child: Text('Fake Home Screen')),
        ),
      ),
    ],
  );
}
