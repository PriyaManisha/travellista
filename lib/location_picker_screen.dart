import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/util/location_service.dart';
import 'package:travellista/util/location_service_wrapper.dart';

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

  LatLng? _pickedLocation;
  String? _pickedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _service = widget.locationService ?? LocationServiceWrapper();
    _pickedLocation = widget.initialLocation;
    _pickedAddress = widget.initialAddress;
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
              // Return both lat/long and address to prior screen
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
