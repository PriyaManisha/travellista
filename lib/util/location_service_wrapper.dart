// location_service_wrapper.dart
import 'location_service.dart';

abstract class ILocationService {
  Future<String?> reverseGeocode(double lat, double lng);
}

class LocationServiceWrapper implements ILocationService {
  @override
  Future<String?> reverseGeocode(double lat, double lng) {
    return LocationService.reverseGeocode(lat, lng);
  }
}
