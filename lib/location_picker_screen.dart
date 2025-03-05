import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/util/location_service_wrapper.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  final String? initialAddress;
  final ILocationService? locationService;

  const LocationPickerScreen({
    super.key,
    required this.initialLocation,
    this.initialAddress,
    this.locationService,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late final ILocationService _service;
  final TextEditingController _searchController = TextEditingController();

  // Google Places Autocomplete variables
  final String _apiKey = 'AIzaSyDUJBdyOia-p-fgMxfXWcckB2xlJWquGOg';
  late GooglePlacesAutocomplete _placesService;
  List<Prediction> _predictions = [];
  LatLng? _pickedLocation;
  String? _pickedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _service = widget.locationService ?? LocationServiceWrapper();
    _pickedLocation = widget.initialLocation;
    _pickedAddress = widget.initialAddress;

    // Initialize Google Places Autocomplete
    _placesService = GooglePlacesAutocomplete(
      apiKey: _apiKey,
      debounceTime: 300,
      predictionsListner: (predictions) {
        setState(() {
          _predictions = predictions;
        });
      },
    );
    _placesService.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation(LatLng newLocation) async {
    setState(() {
      _pickedLocation = newLocation;
      _isLoadingAddress = true;
    });

    final address = await _service.reverseGeocode(
      newLocation.latitude,
      newLocation.longitude,
    );

    setState(() {
      _pickedAddress = address;
      _isLoadingAddress = false;
    });

    // Update the map camera position
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  Future<void> _onPredictionSelected(Prediction prediction) async {
    if (prediction.placeId != null) {
      final details = await _placesService.getPredictionDetail(prediction.placeId!);
      if (details?.location != null) {
        final newLocation = LatLng(
          details!.location!.latitude,
          details.location!.longitude,
        );
        // Use _updateLocation to ensure consistent address formatting
        await _updateLocation(newLocation);
        setState(() {
          _predictions = []; // Clear predictions after selection
          _searchController.clear(); // Clear the search field
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                context,
                PickedLocationResult(_pickedLocation, _pickedAddress),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Autocomplete TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a place',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _placesService.getPredictions(value);
                } else {
                  setState(() {
                    _predictions = [];
                  });
                }
              },
            ),
          ),
          // Predictions List
          if (_predictions.isNotEmpty)
            SizedBox(
              height: 150, // Limit height of suggestions
              child: ListView.builder(
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    title: Text(prediction.title ?? ''),
                    subtitle: Text(prediction.description ?? ''),
                    onTap: () => _onPredictionSelected(prediction),
                  );
                },
              ),
            ),
          // The map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pickedLocation ?? const LatLng(47.60621, -122.33207),
                zoom: 10,
              ),
              onMapCreated: (controller) => _controller.complete(controller),
              markers: {
                if (_pickedLocation != null)
                  Marker(
                    markerId: const MarkerId('picked-location'),
                    position: _pickedLocation!,
                    draggable: true,
                    onDragEnd: (pos) => _updateLocation(pos),
                  ),
              },
              onTap: (pos) => _updateLocation(pos),
            ),
          ),
          // Address display
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.location_pin),
                const SizedBox(width: 8),
                Expanded(
                  child: _isLoadingAddress
                      ? const LinearProgressIndicator()
                      : Text(
                    _pickedAddress ?? 'No address found',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to return from Nav
class PickedLocationResult {
  final LatLng? latLng;
  final String? address;

  PickedLocationResult(this.latLng, this.address);
}