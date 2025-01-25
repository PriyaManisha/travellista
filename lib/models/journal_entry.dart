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
  })  : _entryID = entryID,
        _userID = userID,
        _timestamp = timestamp,
        _latitude = latitude,
        _longitude = longitude,
        _title = title,
        _description = description,
        _imageURLs = imageURLs,
        _videoURLs = videoURLs,
        _tags = tags;

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
      print('Error: Entry ID cannot be empty');
    } else {
      _entryID = newEntryID;
    }
  }

  set userID(String newUserID) {
    if (newUserID.isEmpty) {
      print('Error: User ID cannot be empty');
    } else {
      _userID = newUserID;
    }
  }

  set timestamp(DateTime? newTimestamp) {
    _timestamp = newTimestamp;
  }

  set latitude(double? newLatitude) {
    _latitude = newLatitude;
  }

  set longitude(double? newLongitude) {
    _longitude = newLongitude;
  }

  set title(String? newTitle) {
    _title = newTitle;
  }

  set description(String? newDescription) {
    _description = newDescription;
  }

  set imageURLs(List<String>? newImageURLs) {
    _imageURLs = newImageURLs;
  }

  set videoURLs(List<String>? newVideoURLs) {
    _videoURLs = newVideoURLs;
  }

  set tags(List<String>? newTags) {
    _tags = newTags;
  }

  // Getters and setters (same as before)
  // Getters (with null checks)
  // Getters
  String? get entryID =>
      _entryID; // Note: Getter for entryID is now defined correctly
  String get userID => _userID;
  DateTime? get timestamp => _timestamp;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get title => _title;
  String? get description => _description;
  List<String>? get imageURLs => _imageURLs;
  List<String>? get videoURLs => _videoURLs;
  List<String>? get tags => _tags;

  // Method to convert JournalEntry to a Map for Firestore
  // Method to convert JournalEntry to a Map for Firestore
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
    };
  }

  // Factory constructor to create a JournalEntry from a Map (e.g., from Firestore)
  factory JournalEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return JournalEntry.newEntry(userID: ''); // Handle null map
    }

    return JournalEntry(
      entryID: map['entryID'], // Map value for entryID
      userID: map['userID'], // Map value for userID
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : null, // Parse timestamp if present
      latitude: map['latitude'], // Map value for latitude
      longitude: map['longitude'], // Map value for longitude
      title: map['title'], // Map value for title
      description: map['description'], // Map value for description
      imageURLs: List<String>.from(map['imageURLs'] ??
          []), // Convert imageURLs to a list and handle null
      videoURLs: List<String>.from(map['videoURLs'] ??
          []), // Convert videoURLs to a list and handle null
      tags: List<String>.from(
          map['tags'] ?? []), // Convert tags to a list and handle null
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
        'tags: $_tags'
        '}';
  }
}
