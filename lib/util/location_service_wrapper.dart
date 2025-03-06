// location_service_wrapper.dart
import 'package:travellista/util/location_service.dart';
import 'package:travellista/util/parsed_location.dart';

abstract class ILocationService {
  Future<ParsedLocation?> reverseGeocode(double lat, double lng);
}

class LocationServiceWrapper implements ILocationService {
  @override
  Future<ParsedLocation?> reverseGeocode(double lat, double lng) {
    return LocationService.reverseGeocode(lat, lng);
  }
}
