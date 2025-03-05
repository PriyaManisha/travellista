// lib/util/location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const _googleApiKey = 'AIzaSyDUJBdyOia-p-fgMxfXWcckB2xlJWquGOg';

  static Future<String?> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_googleApiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          if (results.isNotEmpty) {
            final addressComponents = results[0]['address_components'] as List<dynamic>;

            String? city;
            String? state;
            String? country;

            for (final comp in addressComponents) {
              final types = comp['types'] as List<dynamic>;

              // Country
              if (types.contains('country')) {
                country = comp['long_name'];
              }
              // State/Province (administrative_area_level_1)
              else if (types.contains('administrative_area_level_1')) {
                state = comp['short_name']; // Use short_name for brevity (e.g., "RJ")
              }

              else if (types.contains('locality') && city == null) {
                city = comp['long_name'];
              }
              else if (types.contains('administrative_area_level_2') && city == null) {
                city = comp['long_name'];
              }
            }

            // Build address string with flexible logic
            final parts = <String>[];

            // If we have a city, add it; otherwise, skip it
            if (city != null) {
              parts.add(city);
            }
            // If we have a state and it's not redundant with city, add it
            if (state != null && state != city) {
              parts.add(state);
            }
            // Always add country if present
            if (country != null) {
              parts.add(country);
            }

            final partialAddress = parts.join(', ');
            return partialAddress.isEmpty ? null : partialAddress;
          }
        }
      }
      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}