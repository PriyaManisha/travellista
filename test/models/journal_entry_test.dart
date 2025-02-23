import 'package:flutter_test/flutter_test.dart';
import 'package:travellista/models/journal_entry.dart';

void main() {
  group('JournalEntry Model Tests', () {

    test('Default constructor should set all properties properly', () {
      // setup / given / arrange : a test entry
      final entry = JournalEntry(
        entryID: '123',
        userID: 'userABC',
        title: 'Test Title',
        description: 'Some description',
        timestamp: DateTime(2025, 02, 02),
        latitude: 37.7749,
        longitude: -122.4194,
        imageURLs: ['http://example.com/img1.jpg'],
        videoURLs: ['http://example.com/video1.mp4'],
        address: 'San Francisco, CA, United States',
      );

      // Assert : check the properties
      expect(entry.entryID, '123');
      expect(entry.userID, 'userABC');
      expect(entry.title, 'Test Title');
      expect(entry.description, 'Some description');
      expect(entry.timestamp, DateTime(2025, 02, 02));
      expect(entry.latitude, 37.7749);
      expect(entry.longitude, -122.4194);
      expect(entry.imageURLs, ['http://example.com/img1.jpg']);
      expect(entry.videoURLs, ['http://example.com/video1.mp4']);
      expect(entry.address, 'San Francisco, CA, United States');
    });

    test('`newEntry` constructor should generate default fields', () {
      // setup / given / arrange : a test entry
      final entry = JournalEntry.newEntry(
        userID: 'userABC',
        title: 'New Entry Title',
        description: 'A new entry description',
        imageURLs: ['img1', 'img2'],
        videoURLs: ['vid1'],
        tags: ['travel', 'food'],
      );

      // Assert : check the properties
      expect(entry.entryID, isNull, reason: 'Should initialize entryID to null');
      expect(entry.userID, 'userABC');
      expect(entry.title, 'New Entry Title');
      expect(entry.description, 'A new entry description');
      expect(entry.imageURLs, ['img1', 'img2']);
      expect(entry.videoURLs, ['vid1']);
      expect(entry.tags, ['travel', 'food']);
      expect(entry.timestamp, isNotNull);
      // Assert: check if timestamp is recent
      final now = DateTime.now();
      expect(entry.timestamp?.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      expect(entry.timestamp?.isAfter(now.subtract(const Duration(seconds: 5))), isTrue);
    });

    test('toMap() and fromMap() should correctly serialize/deserialize fields', () {
      // setup / given / arrange : a test entry
      final date = DateTime(2025, 02, 02, 12, 30);
      final entry = JournalEntry(
        entryID: 'abc123',
        title: 'Example',
        userID: 'user123',
        description: 'Test desc',
        timestamp: date,
        imageURLs: ['img1', 'img2'],
        videoURLs: ['vid1'],
        address: 'San Francisco, CA, United States',
        latitude: 37.7749,
        longitude: -122.4194,
      );

      // Act / Assert : check the serialized map
      final map = entry.toMap();
      expect(map['entryID'], 'abc123');
      expect(map['userID'], 'user123');
      expect(map['title'], 'Example');
      expect(map['description'], 'Test desc');
      expect(map['timestamp'], date.toIso8601String());
      expect(map['imageURLs'], ['img1', 'img2']);
      expect(map['videoURLs'], ['vid1']);
      expect(map['address'], 'San Francisco, CA, United States');
      expect(map['latitude'], 37.7749);
      expect(map['longitude'], -122.4194);

      // Act / Assert : rebuild from map
      final rebuiltEntry = JournalEntry.fromMap(map);
      expect(rebuiltEntry.entryID, entry.entryID);
      expect(rebuiltEntry.userID, entry.userID);
      expect(rebuiltEntry.title, entry.title);
      expect(rebuiltEntry.description, entry.description);
      expect(rebuiltEntry.timestamp, entry.timestamp);
      expect(rebuiltEntry.imageURLs, entry.imageURLs);
      expect(rebuiltEntry.videoURLs, entry.videoURLs);
      expect(rebuiltEntry.address, entry.address);
      expect(rebuiltEntry.latitude, entry.latitude);
      expect(rebuiltEntry.longitude, entry.longitude);
    });


    test('toString() should return a formatted string with all fields', () {
      // Arrange
      final entry = JournalEntry(
        entryID: 'idXYZ',
        userID: 'userXYZ',
        title: 'Some Title',
        description: 'Desc',
        latitude: 37.7749,
        longitude: -122.4194,
        address: 'San Francisco, CA, United States',
      );

      // Act
      final stringResult = entry.toString();

      // Assert
      expect(
        stringResult,
        allOf(
          contains('entryID: idXYZ'),
          contains('userID: userXYZ'),
          contains('title: Some Title'),
          contains('description: Desc'),
          contains('latitude: 37.7749'),
          contains('longitude: -122.4194'),
          contains('address: San Francisco, CA, United States'),
        ),
        reason: 'Expected toString() to contain all relevant fields',
      );
    });

    test('copyWith() should allow overriding select fields, while preserving others', () {
      // Arrange
      final original = JournalEntry(
        entryID: 'origID',
        userID: 'origUser',
        title: 'Original Title',
        description: 'Original Desc',
        timestamp: DateTime(2021, 1, 1),
        latitude: 10.0,
        longitude: 20.0,
        imageURLs: ['origImg'],
        videoURLs: ['origVid'],
        tags: ['origTag'],
        address: 'Original Address',
      );

      // Act
      final copy = original.copyWith(
        userID: 'newUser',
        address: 'New Address',
        latitude: 99.99,
      );

      // Assert - Overridden fields
      expect(copy.userID, 'newUser');
      expect(copy.address, 'New Address');
      expect(copy.latitude, 99.99);

      // Assert - Preserved fields remain the same
      expect(copy.entryID, 'origID');
      expect(copy.title, 'Original Title');
      expect(copy.description, 'Original Desc');
      expect(copy.timestamp, DateTime(2021, 1, 1));
      expect(copy.longitude, 20.0);
      expect(copy.imageURLs, ['origImg']);
      expect(copy.videoURLs, ['origVid']);
      expect(copy.tags, ['origTag']);

      // Assert - copy is a different instance, but has correct shared fields
      expect(copy, isNot(same(original)));
    });

    group('Setters / edge cases', () {
      late JournalEntry entry;

      setUp(() {
        entry = JournalEntry(userID: 'initialUser');
      });

      test('entryID setter: disallows empty string', () {
        // setup / given / arrange : a test entry
        expect(entry.entryID, isNull);

        // Act
        entry.entryID = 'myNewID';

        // Assert
        expect(entry.entryID, 'myNewID');

        // Act - try setting empty string
        entry.entryID = '';
        // Assert - entryID should not be empty
        expect(entry.entryID, isNotEmpty,
            reason: 'Should not allow empty string according to the setter logic');
      });

      test('userID setter: disallows empty string', () {
        // setup / given / arrange
        expect(entry.userID, 'initialUser');

        // Act - try to set empty user ID
        entry.userID = '';
        // Assert - userID stays as initialUser so it's not empty
        expect(entry.userID, 'initialUser');
      });

      test('address setter: should contain updated params', () {
        // setup / given / arrange
        expect(entry.address, isNull);

        // Act - try to set empty address
        entry.address = 'New Address';
        // Assert - address is updated
        expect(entry.address, 'New Address');
      });

      test('latitude and longitude setters: should update lat/long', () {
        // setup / given / arrange
        expect(entry.latitude, isNull);

        // Act / Arrange
        entry.latitude = 12.3456;
        expect(entry.latitude, 12.3456);

        // Act / Arrange
        expect(entry.longitude, isNull);
        entry.longitude = 65.4321;
        expect(entry.longitude, 65.4321);
      });

      test('tags setter - should update tag params', () {
        // setup / given / arrange
        expect(entry.tags, isEmpty);
        entry.tags = ['tag1', 'tag2'];
        // Assert
        expect(entry.tags, ['tag1', 'tag2']);
      });

      test('timestamp setter - should update timestamp param', () {
        // setup / given / arrange
        final newTime = DateTime(2030, 1, 1);
        entry.timestamp = newTime;
        // Assert
        expect(entry.timestamp, newTime);
      });
    });
  });
}
