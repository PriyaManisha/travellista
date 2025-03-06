// JournalEntry Model
import 'package:flutter/cupertino.dart';

class JournalEntry {
  String? _entryID;
  String _userID;
  DateTime? _timestamp;
  double? _latitude;
  double? _longitude;
  String? _title;
  String? _description;
  List<String>? _imageURLs;
  List<String>? _videoURLs;
  List<String>? _tags;
  String? _address;
  String? _monthName;
  String? _localeName;
  String? _regionName;
  String? _countryName;

  JournalEntry({
    String? entryID,
    required String userID,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    List<String>? imageURLs = const [],
    List<String>? videoURLs = const [],
    List<String>? tags = const [],
    String? address,
    String? monthName,
    String? localeName,
    String? regionName,
    String? countryName,
  })  : _entryID = entryID,
        _userID = userID,
        _timestamp = timestamp,
        _latitude = latitude,
        _longitude = longitude,
        _title = title,
        _description = description,
        _imageURLs = imageURLs,
        _videoURLs = videoURLs,
        _tags = tags,
        _address = address,
        _monthName = monthName,
        _localeName = localeName,
        _regionName = regionName,
        _countryName = countryName;

  JournalEntry.newEntry({
    required String userID,
    String? title,
    String? description,
    List<String>? imageURLs = const [],
    List<String>? videoURLs = const [],
    List<String>? tags = const [],
  })  : _userID = userID,
        _title = title,
        _description = description,
        _imageURLs = imageURLs,
        _videoURLs = videoURLs,
        _tags = tags {
    _timestamp = DateTime.now();
    _entryID = null;
  }

  // Setters

  set entryID(String? newEntryID) {
    if (newEntryID != null && newEntryID.isEmpty) {
      debugPrint('Warning: Entry ID cannot be empty');
    } else {
      _entryID = newEntryID;
    }
  }

  set userID(String newUserID) {
    if (newUserID.isEmpty) {
      debugPrint('Warning: User ID cannot be empty');
    } else {
      _userID = newUserID;
    }
  }

  set timestamp(DateTime? newTimestamp) => _timestamp = newTimestamp;
  set latitude(double? newLatitude) => _latitude = newLatitude;
  set longitude(double? newLongitude) => _longitude = newLongitude;
  set title(String? newTitle) => _title = newTitle;
  set description(String? newDescription) => _description = newDescription;
  set imageURLs(List<String>? newImageURLs) => _imageURLs = newImageURLs;
  set videoURLs(List<String>? newVideoURLs) => _videoURLs = newVideoURLs;
  set tags(List<String>? newTags) => _tags = newTags;
  set address(String? newAddress) => _address = newAddress;
  set monthName(String? newMonthName) => _monthName = newMonthName;
  set localeName(String? newLocaleName) => _localeName = newLocaleName;
  set regionName(String? newRegionName) => _regionName = newRegionName;
  set countryName(String? newCountryName) => _countryName = newCountryName;

  // Getters

  String? get entryID => _entryID;
  String get userID => _userID;
  DateTime? get timestamp => _timestamp;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get title => _title;
  String? get description => _description;
  List<String>? get imageURLs => _imageURLs;
  List<String>? get videoURLs => _videoURLs;
  List<String>? get tags => _tags;
  String? get address => _address;
  String? get monthName => _monthName;
  String? get localeName => _localeName;
  String? get regionName => _regionName;
  String? get countryName => _countryName;

  // Method to convert JournalEntry Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'entryID': _entryID,
      'userID': _userID,
      'timestamp': _timestamp?.toIso8601String(),
      'latitude': _latitude,
      'longitude': _longitude,
      'title': _title,
      'description': _description,
      'imageURLs': _imageURLs,
      'videoURLs': _videoURLs,
      'tags': _tags,
      'address': _address,
      'monthName': _monthName,
      'localeName': _localeName,
      'regionName': _regionName,
      'countryName': _countryName,
    };
  }

  // Factory constructor to create a JournalEntry from a Map (e.g., from Firestore)
  factory JournalEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return JournalEntry.newEntry(userID: '');
    }
    return JournalEntry(
      entryID: map['entryID'],
      userID: map['userID'],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : null,
      latitude: map['latitude'],
      longitude: map['longitude'],
      title: map['title'],
      description: map['description'],
      imageURLs: List<String>.from(map['imageURLs'] ?? []),
      videoURLs: List<String>.from(map['videoURLs'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      address: map['address'] as String?,
      monthName: map['monthName'] as String?,
      localeName: map['localeName'] as String?,
      regionName: map['regionName'] as String?,
      countryName: map['countryName'] as String?,
    );
  }


  @override
  String toString() {
    return 'JournalEntry{'
        'entryID: $_entryID, '
        'userID: $_userID, '
        'timestamp: $_timestamp, '
        'latitude: $_latitude, '
        'longitude: $_longitude, '
        'title: $_title, '
        'description: $_description, '
        'imageURLs: $_imageURLs, '
        'videoURLs: $_videoURLs, '
        'tags: $_tags, '
        'address: $_address, '
        'monthName: $_monthName, '
        'localeName: $_localeName, '
        'regionName: $_regionName, '
        'countryName: $_countryName'
        '}';
  }

  // CopyWith

  JournalEntry copyWith({
    String? entryID,
    String? userID,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    List<String>? imageURLs,
    List<String>? videoURLs,
    List<String>? tags,
    String? address,
    String? monthName,
    String? localeName,
    String? regionName,
    String? countryName,
  }) {
    return JournalEntry(
      entryID: entryID ?? this.entryID,
      userID: userID ?? this.userID,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      description: description ?? this.description,
      imageURLs: imageURLs ?? this.imageURLs,
      videoURLs: videoURLs ?? this.videoURLs,
      tags: tags ?? this.tags,
      address: address ?? this.address,
      monthName: monthName ?? _monthName,
      localeName: localeName ?? _localeName,
      regionName: regionName ?? _regionName,
      countryName: countryName ?? _countryName,
    );
  }
}
