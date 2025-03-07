import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/entry_creation_form.dart';
import 'package:travellista/entry_detail_page.dart';
import 'package:travellista/home_screen_page.dart';
import 'package:travellista/map_view_page.dart';
import 'package:travellista/profile_page.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/location_picker_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Route strings
const String homeRoute = '/home';
const String createRoute = '/create';
const String updateRoute = '/update/:entryID';
const String mapRoute = '/map';
const String profileRoute = '/profile';
const String entryDetailRoute = '/entry/:entryID';
const String locationPickerRoute = '/location-picker';

final GoRouter appRouter = GoRouter(
  initialLocation: homeRoute,
  routes: [
    GoRoute(
      path: homeRoute,
      builder: (context, state) => const HomeScreenPage(),
    ),
    GoRoute(
      path: createRoute,
      builder: (context, state) => const EntryCreationForm(),
    ),
    GoRoute(
      path: updateRoute,
      builder: (context, state) {
        final entry = state.extra as JournalEntry;
        return EntryCreationForm(existingEntry: entry);
      },
    ),
    GoRoute(
      path: mapRoute,
      builder: (context, state) => const MapViewPage(),
    ),
    GoRoute(
      path: profileRoute,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: entryDetailRoute,
      builder: (context, state) {
        final entryID = state.pathParameters['entryID']!;
        return EntryDetailPage(entryID: entryID);
      },
    ),
    GoRoute(
      path: locationPickerRoute,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        final initialLoc = extras?['initialLocation'] as LatLng?
            ?? const LatLng(47.60621, -122.33207);
        final initialAddr = extras?['initialAddress'] as String?
            ?? 'Seattle, Washington, United States';

        return LocationPickerScreen(
          initialLocation: initialLoc,
          initialAddress: initialAddr,
        );
      },
    ),

  ],
);
