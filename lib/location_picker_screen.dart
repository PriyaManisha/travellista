import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPickerScreen({
    Key? key,
    required this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
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
              Navigator.pop(context, _pickedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation ?? const LatLng(37.7749, -122.4194),
          zoom: 10,
        ),
        onMapCreated: (controller) => _controller.complete(controller),
        // Show single marker on map
        markers: {
          if (_pickedLocation != null)
            Marker(
              markerId: const MarkerId('picked-location'),
              position: _pickedLocation!,
              draggable: true,
              onDragEnd: (newPosition) {
                setState(() {
                  _pickedLocation = newPosition;
                });
              },
            ),
        },
        onTap: (LatLng tappedPoint) {
          setState(() {
            _pickedLocation = tappedPoint;
          });
        },
      ),
    );
  }
}
