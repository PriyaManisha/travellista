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

ParsedLocation parseAddress(String? address) {
  if (address == null || address.trim().isEmpty) {
    return const ParsedLocation(
      locale: null,
      region: null,
      country: null,
      countryCode: null,
      formattedAddress: '',
    );
  }

  final parts = address.split(',').map((p) => p.trim()).toList();

  String? locale;
  String? region;
  String? country;

  if (parts.length == 1) {
    country = parts[0];
  } else if (parts.length == 2) {
    region = parts[0];
    country = parts[1];
  } else {
    locale = parts[0];
    region = parts[1];
    country = parts.last;
  }

  final formatted = address;

  return ParsedLocation(
    locale: locale,
    region: region,
    country: country,
    countryCode: null,
    formattedAddress: formatted,
  );
}
