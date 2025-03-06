// lib/util/location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travellista/util/parsed_location.dart';

class LocationService {
  static const _googleApiKey = 'AIzaSyDUJBdyOia-p-fgMxfXWcckB2xlJWquGOg';

  static Future<ParsedLocation?> reverseGeocode(double lat, double lng) async {
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
            final firstResult = results[0];
            final addressComponents =
            firstResult['address_components'] as List<dynamic>;

            String? locale;
            String? region;
            String? country;
            String? countryCode;

            for (final comp in addressComponents) {
              final types = comp['types'] as List<dynamic>;
              final longName = comp['long_name'] as String?;
              final shortName = comp['short_name'] as String?;

              if (types.contains('locality')) {
                // e.g. "Seattle"
                locale = longName;
              } else if (types.contains('administrative_area_level_2') &&
                  locale == null) {
                locale = longName;
              } else if (types.contains('administrative_area_level_1')) {
                region = longName;
              } else if (types.contains('country')) {
                country = longName;
                countryCode = shortName;
              }
            }

            // Grab Google's 'formatted_address'
            final formattedAddress = firstResult['formatted_address'] as String;

            return ParsedLocation(
              locale: locale,
              region: region,
              country: country,
              countryCode: countryCode,
              formattedAddress: formattedAddress,
            );
          }
        }
      }
      return null; // No results or not 'OK'
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}