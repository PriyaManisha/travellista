// util/parsed_location.dart
class ParsedLocation {
  final String? locale;
  final String? region;
  final String? country;
  final String? countryCode;
  final String formattedAddress;

  const ParsedLocation({
    this.locale,
    this.region,
    this.country,
    this.countryCode,
    required this.formattedAddress,
  });
}
