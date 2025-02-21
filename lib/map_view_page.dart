import 'dart:async';
import 'dart:math';
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

  LatLngBounds? _overallBounds;

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();
    final entries = entryProvider.entries;

    if (entryProvider.isLoading) {
      return const SharedScaffold(
        title: 'Map View',
        selectedIndex: 2,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

    // Compute map's initial camera position
    final initialCameraPosition = const CameraPosition(
      target: LatLng(47.6061, -122.3328),
      zoom: 3,
    );

    // If minimum one marker, calc bounding box
    if (markers.isNotEmpty) {
      double minLat = double.infinity, maxLat = -double.infinity;
      double minLng = double.infinity, maxLng = -double.infinity;
      for (var m in markers) {
        minLat = min(minLat, m.position.latitude);
        maxLat = max(maxLat, m.position.latitude);
        minLng = min(minLng, m.position.longitude);
        maxLng = max(maxLng, m.position.longitude);
      }

      // Store bounds
      _overallBounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }

    return SharedScaffold(
      title: 'Map View',
      selectedIndex: 2,
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onMapCreated: (controller) async {
          _mapController.complete(controller);

          // Once the map created, fit to bounds
          if (_overallBounds != null) {
            await Future.delayed(const Duration(milliseconds: 200));
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(_overallBounds!, 60),
            );
          }
        },
      ),
    );
  }

  // Group entries by lat,long
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

  // Parse lat,long
  LatLng _parseLatLongKey(String key) {
    final parts = key.split(',');
    final lat = double.parse(parts[0]);
    final lng = double.parse(parts[1]);
    return LatLng(lat, lng);
  }

  // Show all entries for tapped marker
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
                  ? Image.network(
                e.imageURLs![0],
                width: 60,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              )
                  : const Icon(Icons.photo),
              title: Text(e.title ?? 'Untitled'),
              subtitle: Text('${e.address}'),
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