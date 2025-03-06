import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:travellista/models/journal_entry.dart';
import 'package:travellista/providers/journal_entry_provider.dart';
import 'package:travellista/shared_scaffold.dart';
import 'package:travellista/entry_detail_page.dart';
import 'package:travellista/entry_search.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLngBounds? _overallBounds;

  bool _isSearching = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<JournalEntryProvider>();
    final allEntries = entryProvider.entries;

    if (entryProvider.isLoading) {
      return const SharedScaffold(
        title: 'Map View',
        selectedIndex: 2,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredEntries = _buildFilteredList(allEntries, _searchQuery);

    final grouped = _groupEntriesByLatLng(filteredEntries);
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

    // If we have at least one marker, figure out bounding box
    if (markers.isNotEmpty) {
      double minLat = double.infinity, maxLat = -double.infinity;
      double minLng = double.infinity, maxLng = -double.infinity;
      for (var m in markers) {
        minLat = min(minLat, m.position.latitude);
        maxLat = max(maxLat, m.position.latitude);
        minLng = min(minLng, m.position.longitude);
        maxLng = max(maxLng, m.position.longitude);
      }

      _overallBounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }

    // Return SharedScaffold with search widget
    return SharedScaffold(
      titleWidget: EntrySearchBar(
        title: 'Map View',
        isSearching: _isSearching,
        onSearchChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        onSearchToggled: (newVal) {
          setState(() {
            _isSearching = newVal;
            if (!_isSearching) {
              _searchQuery = '';
            }
          });
        },
      ),
      selectedIndex: 2,
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        onMapCreated: (controller) async {
          _mapController.complete(controller);

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

  List<JournalEntry> _buildFilteredList(List<JournalEntry> allEntries, String query) {
    if (!_isSearching || query.trim().isEmpty) {
      return allEntries;
    }
    final lowerQuery = query.toLowerCase();

    return allEntries.where((entry) {
      final combinedText = (
          (entry.title ?? '') +
              (entry.address ?? '') +
              (entry.tags?.join(' ') ?? '') +
              (entry.monthName?.toLowerCase() ?? '')
      ).toLowerCase();
      return combinedText.contains(lowerQuery);
    }).toList();
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

  // Show bottom sheet with all entries at that marker
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
              leading: SizedBox(
                width: 50,
                height: 50,
                child: e.imageURLs?.isNotEmpty == true
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    e.imageURLs![0],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                )
                    : const Icon(Icons.photo, size: 40),
              ),
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