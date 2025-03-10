import 'package:flutter_test/flutter_test.dart';
import 'package:travellista/models/journal_entry.dart';

void main() {
  group('JournalEntry Model Tests', () {
    test('Default constructor should set all properties properly', () {
      // Setup / Given / Arrange
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
        videoThumbnailURLs: ['http://example.com/thumb1.jpg'], // Added
        address: 'San Francisco, CA, United States',
        monthName: 'February',
        localeName: 'en_US',
        regionName: 'CA',
        countryName: 'United States',
        tags: ['tag1', 'tag2'],
      );

      // Assert
      expect(entry.entryID, '123');
      expect(entry.userID, 'userABC');
      expect(entry.title, 'Test Title');
      expect(entry.description, 'Some description');
      expect(entry.timestamp, DateTime(2025, 02, 02));
      expect(entry.latitude, 37.7749);
      expect(entry.longitude, -122.4194);
      expect(entry.imageURLs, ['http://example.com/img1.jpg']);
      expect(entry.videoURLs, ['http://example.com/video1.mp4']);
      expect(entry.videoThumbnailURLs, ['http://example.com/thumb1.jpg']); // Added
      expect(entry.address, 'San Francisco, CA, United States');
      expect(entry.tags, ['tag1', 'tag2']);
      expect(entry.monthName, 'February');
      expect(entry.localeName, 'en_US');
      expect(entry.regionName, 'CA');
      expect(entry.countryName, 'United States');
    });

    test('`newEntry` constructor should generate default fields', () {
      // Setup / Given / Arrange
      final entry = JournalEntry.newEntry(
        userID: 'userABC',
        title: 'New Entry Title',
        description: 'A new entry description',
        imageURLs: ['img1', 'img2'],
        videoURLs: ['vid1'],
        videoThumbnailURLs: ['thumb1'], // Added
        tags: ['travel', 'food'],
      );

      // Assert
      expect(entry.entryID, isNull, reason: 'Should initialize entryID to null');
      expect(entry.userID, 'userABC');
      expect(entry.title, 'New Entry Title');
      expect(entry.description, 'A new entry description');
      expect(entry.imageURLs, ['img1', 'img2']);
      expect(entry.videoURLs, ['vid1']);
      expect(entry.videoThumbnailURLs, ['thumb1']); // Added
      expect(entry.tags, ['travel', 'food']);

      // The newEntry constructor sets timestamp = now
      expect(entry.timestamp, isNotNull);
      final now = DateTime.now();
      expect(entry.timestamp?.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      expect(entry.timestamp?.isAfter(now.subtract(const Duration(seconds: 5))), isTrue);

      // If newEntry does NOT set these fields, they should remain null or empty
      expect(entry.monthName, isNull);
      expect(entry.localeName, isNull);
      expect(entry.regionName, isNull);
      expect(entry.countryName, isNull);
    });

    test('toMap() and fromMap() should correctly serialize/deserialize fields', () {
      // Setup / Given / Arrange
      final date = DateTime(2025, 02, 02, 12, 30);
      final entry = JournalEntry(
        entryID: 'abc123',
        userID: 'user123',
        title: 'Example',
        description: 'Test desc',
        timestamp: date,
        latitude: 37.7749,
        longitude: -122.4194,
        imageURLs: ['img1', 'img2'],
        videoURLs: ['vid1'],
        videoThumbnailURLs: ['thumb1'], // Added
        tags: ['tagA'],
        address: 'San Francisco, CA, United States',
        monthName: 'February',
        localeName: 'en_US',
        regionName: 'CA',
        countryName: 'United States',
      );

      // ACT / ASSERT : Convert to map
      final map = entry.toMap();
      expect(map['entryID'], 'abc123');
      expect(map['userID'], 'user123');
      expect(map['title'], 'Example');
      expect(map['description'], 'Test desc');
      expect(map['timestamp'], date.toIso8601String());
      expect(map['latitude'], 37.7749);
      expect(map['longitude'], -122.4194);
      expect(map['imageURLs'], ['img1', 'img2']);
      expect(map['videoURLs'], ['vid1']);
      expect(map['videoThumbnailURLs'], ['thumb1']); // Added
      expect(map['tags'], ['tagA']);
      expect(map['address'], 'San Francisco, CA, United States');
      expect(map['monthName'], 'February');
      expect(map['localeName'], 'en_US');
      expect(map['regionName'], 'CA');
      expect(map['countryName'], 'United States');

      // ACT / ASSERT : Convert back to JournalEntry
      final rebuiltEntry = JournalEntry.fromMap(map);
      expect(rebuiltEntry.entryID, entry.entryID);
      expect(rebuiltEntry.userID, entry.userID);
      expect(rebuiltEntry.title, entry.title);
      expect(rebuiltEntry.description, entry.description);
      expect(rebuiltEntry.timestamp, entry.timestamp);
      expect(rebuiltEntry.latitude, entry.latitude);
      expect(rebuiltEntry.longitude, entry.longitude);
      expect(rebuiltEntry.imageURLs, entry.imageURLs);
      expect(rebuiltEntry.videoURLs, entry.videoURLs);
      expect(rebuiltEntry.videoThumbnailURLs, entry.videoThumbnailURLs); // Added
      expect(rebuiltEntry.tags, entry.tags);
      expect(rebuiltEntry.address, entry.address);
      expect(rebuiltEntry.monthName, entry.monthName);
      expect(rebuiltEntry.localeName, entry.localeName);
      expect(rebuiltEntry.regionName, entry.regionName);
      expect(rebuiltEntry.countryName, entry.countryName);
    });

    test('toString() should return a formatted string with all fields', () {
      // Arrange - Create a JournalEntry
      final entry = JournalEntry(
        entryID: 'idXYZ',
        userID: 'userXYZ',
        title: 'Some Title',
        description: 'Desc',
        latitude: 37.7749,
        longitude: -122.4194,
        address: 'San Francisco, CA, United States',
        monthName: 'Feb',
        localeName: 'en_US',
        regionName: 'CA',
        countryName: 'United States',
        videoThumbnailURLs: ['thumb1'], // Added
      );

      // Act
      final stringResult = entry.toString();

      // Assert
      expect(
        stringResult,
        allOf([
          contains('entryID: idXYZ'),
          contains('userID: userXYZ'),
          contains('title: Some Title'),
          contains('description: Desc'),
          contains('latitude: 37.7749'),
          contains('longitude: -122.4194'),
          contains('address: San Francisco, CA, United States'),
          contains('monthName: Feb'),
          contains('localeName: en_US'),
          contains('regionName: CA'),
          contains('countryName: United States'),
          contains('thumbnailURL: [thumb1]'), // Updated to match actual field name
        ]),
        reason: 'Expected toString() to contain all relevant fields',
      );
    });

    test('copyWith() should allow overriding select fields, while preserving others', () {
      // Arrange - Create an original JournalEntry
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
        videoThumbnailURLs: ['origThumb'], // Added
        tags: ['origTag'],
        address: 'Original Address',
        monthName: 'January',
        localeName: 'en_US',
        regionName: 'TX',
        countryName: 'USA',
      );

      // Act : Create a copy with updated fields
      final copy = original.copyWith(
        userID: 'newUser',
        address: 'New Address',
        latitude: 99.99,
        monthName: 'August',
        videoThumbnailURLs: ['newThumb'], // Added
      );

      // Assert - Overridden fields
      expect(copy.userID, 'newUser');
      expect(copy.address, 'New Address');
      expect(copy.latitude, 99.99);
      expect(copy.monthName, 'August');
      expect(copy.videoThumbnailURLs, ['newThumb']); // Added

      // Assert - Preserved fields remain the same
      expect(copy.entryID, 'origID');
      expect(copy.title, 'Original Title');
      expect(copy.description, 'Original Desc');
      expect(copy.timestamp, DateTime(2021, 1, 1));
      expect(copy.longitude, 20.0);
      expect(copy.imageURLs, ['origImg']);
      expect(copy.videoURLs, ['origVid']);
      expect(copy.tags, ['origTag']);
      expect(copy.localeName, 'en_US');
      expect(copy.regionName, 'TX');
      expect(copy.countryName, 'USA');

      // Assert - Copy is a different instance
      expect(copy, isNot(same(original)));
    });

    group('Setters / edge cases', () {
      late JournalEntry entry;

      setUp(() {
        entry = JournalEntry(userID: 'initialUser');
      });

      // Test the entryID setter
      test('entryID setter: disallows empty string', () {
        expect(entry.entryID, isNull);

        // Act - try to set empty entry ID
        entry.entryID = 'myNewID';
        expect(entry.entryID, 'myNewID');

        // Act - try setting empty string
        entry.entryID = '';
        expect(entry.entryID, isNotEmpty,
            reason: 'Should not allow empty string according to the setter logic');
      });

      // Test the userID setter
      test('userID setter: disallows empty string', () {
        expect(entry.userID, 'initialUser');

        // Act - try to set empty user ID
        entry.userID = '';
        // Assert: userID stays 'initialUser'
        expect(entry.userID, 'initialUser');
      });

      // Test the address setter
      test('address setter: should contain updated params', () {
        expect(entry.address, isNull);
        entry.address = 'New Address';
        expect(entry.address, 'New Address');
      });

      // Test the lat/long setters
      test('latitude and longitude setters: should update lat/long', () {
        expect(entry.latitude, isNull);
        entry.latitude = 12.3456;
        expect(entry.latitude, 12.3456);

        expect(entry.longitude, isNull);
        entry.longitude = 65.4321;
        expect(entry.longitude, 65.4321);
      });

      // Test the tags setters
      test('tags setter - should update tag params', () {
        expect(entry.tags, isEmpty);
        entry.tags = ['tag1', 'tag2'];
        expect(entry.tags, ['tag1', 'tag2']);
      });

      // Test the timestamp setter
      test('timestamp setter - should update timestamp param', () {
        final newTime = DateTime(2030, 1, 1);
        entry.timestamp = newTime;
        expect(entry.timestamp, newTime);
      });

      // Test the monthname, locale, region, country setters
      test('monthName, localeName, regionName, countryName setters', () {
        expect(entry.monthName, isNull);
        entry.monthName = 'January';
        expect(entry.monthName, 'January');

        expect(entry.localeName, isNull);
        entry.localeName = 'en_GB';
        expect(entry.localeName, 'en_GB');

        expect(entry.regionName, isNull);
        entry.regionName = 'GB';
        expect(entry.regionName, 'GB');

        expect(entry.countryName, isNull);
        entry.countryName = 'United Kingdom';
        expect(entry.countryName, 'United Kingdom');
      });

      // Test the videoThumbnailURLs setter
      test('videoThumbnailURLs setter - should update video thumbnail URLs', () {
        expect(entry.videoThumbnailURLs, isEmpty);
        entry.videoThumbnailURLs = ['thumb1', 'thumb2'];
        expect(entry.videoThumbnailURLs, ['thumb1', 'thumb2']);
      });
    });
  });
}