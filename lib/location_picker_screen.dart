import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
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
  late final ILocationService _service;
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();

  final String _apiKey = 'AIzaSyDUJBdyOia-p-fgMxfXWcckB2xlJWquGOg';
  late GooglePlacesAutocomplete _placesService;
  List<Prediction> _predictions = [];

  LatLng? _pickedLocation;
  String? _pickedAddress;
  bool _isLoadingAddress = false;

  String? _pickedLocale;
  String? _pickedRegion;
  String? _pickedCountry;

  @override
  void initState() {
    super.initState();
    _service = widget.locationService ?? LocationServiceWrapper();
    _pickedLocation = widget.initialLocation;
    _pickedAddress = widget.initialAddress;

    _placesService = GooglePlacesAutocomplete(
      apiKey: _apiKey,
      debounceTime: 300,
      predictionsListner: (preds) {
        setState(() {
          _predictions = preds;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Pick Location'),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: _onCheckPressed,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchField(),
        _buildPredictionsList(),
        Expanded(child: _buildMap()),
        _buildAddressDisplay(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
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
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }

  Widget _buildPredictionsList() {
    if (_predictions.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        itemCount: _predictions.length,
        itemBuilder: (context, index) {
          final prediction = _predictions[index];
          return ListTile(
            title: Text(prediction.title ?? ''),
            subtitle: Text(prediction.description ?? ''),
            onTap: () {
              _onPredictionSelected(prediction);
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _pickedLocation ?? const LatLng(47.60621, -122.33207),
        zoom: 10,
      ),
      onMapCreated: (controller) => _mapController.complete(controller),
      markers: {
        if (_pickedLocation != null)
          Marker(
            markerId: const MarkerId('picked-location'),
            position: _pickedLocation!,
            draggable: true,
            onDragEnd: (pos) => _updateLocation(pos),
          ),
      },
      onTap: (pos) {
        _updateLocation(pos);
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _buildAddressDisplay() {
    return Container(
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
    );
  }

  void _onCheckPressed() {
    FocusScope.of(context).unfocus();
    context.pop(
      PickedLocationResult(
        latLng: _pickedLocation,
        address: _pickedAddress,
        locale: _pickedLocale,
        region: _pickedRegion,
        country: _pickedCountry,
      ),
    );
  }

  Future<void> _onPredictionSelected(Prediction prediction) async {
    if (prediction.placeId != null) {
      final details = await _placesService.getPredictionDetail(prediction.placeId!);
      if (details?.location != null) {
        final newLocation = LatLng(
          details!.location!.latitude,
          details.location!.longitude,
        );
        await _updateLocation(newLocation);

        setState(() {
          _predictions = [];
          _searchController.clear();
        });
      }
    }
  }

  Future<void> _updateLocation(LatLng newLocation) async {
    setState(() {
      _pickedLocation = newLocation;
      _isLoadingAddress = true;
    });

    final parsedLoc = await _service.reverseGeocode(
      newLocation.latitude,
      newLocation.longitude,
    );

    setState(() {
      if (parsedLoc != null) {
        _pickedLocale = parsedLoc.locale;
        _pickedRegion = parsedLoc.region;
        _pickedCountry = parsedLoc.country;

        final shortList = <String>[];
        if (_pickedLocale?.isNotEmpty == true) shortList.add(_pickedLocale!);
        if (_pickedRegion?.isNotEmpty == true) shortList.add(_pickedRegion!);
        if (_pickedCountry?.isNotEmpty == true) shortList.add(_pickedCountry!);
        final shortAddr = shortList.join(', ');

        _pickedAddress =
        shortAddr.isNotEmpty ? shortAddr : parsedLoc.formattedAddress;
      } else {
        _pickedAddress = null;
        _pickedLocale = null;
        _pickedRegion = null;
        _pickedCountry = null;
      }
      _isLoadingAddress = false;
    });

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(newLocation));
  }
}

class PickedLocationResult {
  final LatLng? latLng;
  final String? address;
  final String? locale;
  final String? region;
  final String? country;

  PickedLocationResult({
    this.latLng,
    this.address,
    this.locale,
    this.region,
    this.country,
  });
}