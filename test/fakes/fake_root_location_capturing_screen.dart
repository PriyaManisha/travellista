import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travellista/location_picker_screen.dart';

class RootLocationCapturingScreen extends StatefulWidget {
  @override
  State<RootLocationCapturingScreen> createState() => _RootLocationCapturingScreenState();
}

class _RootLocationCapturingScreenState extends State<RootLocationCapturingScreen> {
  PickedLocationResult? lastPicked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await context.push<PickedLocationResult>(
              '/location-picker',
              extra: {
                'initialLocation': const LatLng(47.60621, -122.33207),
                'initialAddress': 'Seattle, WA, United States',
              },
            );
            setState(() {
              lastPicked = result;
            });
          },
          child: const Text('Go to Picker'),
        ),
      ),
      floatingActionButton: lastPicked == null
          ? null
          : FloatingActionButton(
        onPressed: () {},
        child: Text(
          lastPicked!.address ?? 'No address',
        ),
      ),
    );
  }
}
