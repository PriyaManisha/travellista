import 'package:flutter_test/flutter_test.dart';
import 'package:travellista/models/journal_entry.dart';

void main() {
  group('JournalEntry Model Tests', () {
    test('Constructor and property assignment', () {
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
      );

      expect(entry.entryID, '123');
      expect(entry.userID, 'userABC');
      expect(entry.title, 'Test Title');
      expect(entry.description, 'Some description');
      expect(entry.timestamp, DateTime(2025, 02, 02));
      expect(entry.latitude, 37.7749);
      expect(entry.longitude, -122.4194);
      expect(entry.imageURLs, ['http://example.com/img1.jpg']);
      expect(entry.videoURLs, ['http://example.com/video1.mp4']);
    });

    test('toMap and fromMap', () {
      final date = DateTime(2025, 02, 02, 12, 30);
      final entry = JournalEntry(
        title: 'Example',
        userID: 'user123',
        description: 'Test desc',
        timestamp: date,
        imageURLs: ['img1', 'img2'],
        videoURLs: ['vid1'],
      );

      final map = entry.toMap();
      // Assert : check the serialized map
      expect(map['title'], 'Example');
      expect(map['description'], 'Test desc');
      expect(map['timestamp'], date.toIso8601String());
      expect(map['imageURLs'], ['img1', 'img2']);
      expect(map['videoURLs'], ['vid1']);

      // Assert : rebuild from map
      final rebuiltEntry = JournalEntry.fromMap(map);
      expect(rebuiltEntry.title, entry.title);
      expect(rebuiltEntry.description, entry.description);
      expect(rebuiltEntry.timestamp, entry.timestamp);
      expect(rebuiltEntry.imageURLs, entry.imageURLs);
      expect(rebuiltEntry.videoURLs, entry.videoURLs);
    });
  });
}
