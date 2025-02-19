import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/shared_scaffold.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    // Listen to the JournalEntryProvider
    final entryProvider = context.watch<JournalEntryProvider>();
    final entries = entryProvider.entries;

    // Convert each entry to a Marker if lat/long are present
    final Set<Marker> markers = entries
        .where((entry) => entry.latitude != null && entry.longitude != null)
        .map((entry) {
      return Marker(
        markerId: MarkerId(entry.entryID ?? UniqueKey().toString()),
        position: LatLng(entry.latitude!, entry.longitude!),
        infoWindow: InfoWindow(
          title: entry.title ?? 'No Title',
          snippet: entry.description ?? '',
        ),
      );
    })
        .toSet();

    // Pick initial camera position:
    // If we have at least one marker, center on the first one for now.
    final CameraPosition initialCameraPosition;
    if (markers.isNotEmpty) {
      final firstMarker = markers.first.position;
      initialCameraPosition = CameraPosition(
        target: firstMarker,
        zoom: 10,
      );
    } else {
      // Fallback to def location if no entries
      initialCameraPosition = const CameraPosition(
        target: LatLng(37.7749, -122.4194), // San Fran
        zoom: 10,
      );
    }

    return SharedScaffold(
      title: 'Map View',
      selectedIndex: 2, // highlight the Map tab
      body: entryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
      ),
    );
  }
}