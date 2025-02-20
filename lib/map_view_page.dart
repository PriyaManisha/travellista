import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/entry_detail_page.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();
    final entries = entryProvider.entries;

    // Show loading spinner if still fetching from Firestore
    if (entryProvider.isLoading) {
      return const SharedScaffold(
        title: 'Map View',
        selectedIndex: 2,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Group entries by lat/long so multiple at same location can be handled together
    final grouped = _groupEntriesByLatLng(entries);

    final Set<Marker> markers = {};
    for (var latLongKey in grouped.keys) {
      final latLng = _parseLatLongKey(latLongKey);
      final entriesAtLocation = grouped[latLongKey]!;

      markers.add(Marker(
        markerId: MarkerId(latLongKey),
        position: latLng,
        consumeTapEvents: true,
        onTap: () => _showMarkerEntriesBottomSheet(context, entriesAtLocation),
      ));
    }

    final CameraPosition initialCameraPosition;
    if (markers.isNotEmpty) {
      final firstMarker = markers.first.position;
      initialCameraPosition = CameraPosition(target: firstMarker, zoom: 10);
    } else {
      initialCameraPosition = const CameraPosition(
        target: LatLng(37.7749, -122.4194),
        zoom: 10,
      );
    }

    return SharedScaffold(
      title: 'Map View',
      selectedIndex: 2,
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onMapCreated: (controller) => _mapController.complete(controller),
      ),
    );
  }

  // Group entries by "lat,long" string
  Map<String, List<JournalEntry>> _groupEntriesByLatLng(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> grouped = {};
    for (var e in entries) {
      if (e.latitude != null && e.longitude != null) {
        final key = '${e.latitude},${e.longitude}';
        grouped.putIfAbsent(key, () => []).add(e);
      }
    }
    return grouped;
  }

  // Parse "lat,long" into LatLng
  LatLng _parseLatLongKey(String key) {
    final parts = key.split(',');
    final lat = double.parse(parts[0]);
    final lng = double.parse(parts[1]);
    return LatLng(lat, lng);
  }

  // Show all entries for a tapped marker
  void _showMarkerEntriesBottomSheet(BuildContext context, List<JournalEntry> entries) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            return ListTile(
              leading: e.imageURLs?.isNotEmpty == true
                  ? Image.network(e.imageURLs![0], width: 60, fit: BoxFit.cover)
                  : const Icon(Icons.photo),
              title: Text(e.title ?? 'Untitled'),
              subtitle: Text('${e.timestamp}'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EntryDetailPage(entryID: e.entryID!),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}