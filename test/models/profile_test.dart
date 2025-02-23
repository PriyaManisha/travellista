import 'package:flutter_test/flutter_test.dart';
import 'package:travellista/models/profile.dart';

void main() {
  group('Profile Model Tests', () {
    test('Constructor sets fields correctly', () {
      // setup / given / arrange
      final profile = Profile(
        userID: 'user123',
        firstName: 'John',
        lastName: 'Doe',
        displayName: 'JohnnyD',
        email: 'john@example.com',
        photoUrl: 'https://example.com/profile.jpg',
      );

      // ASSERT : Check all fields are set correctly
      expect(profile.userID, 'user123');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.displayName, 'JohnnyD');
      expect(profile.email, 'john@example.com');
      expect(profile.photoUrl, 'https://example.com/profile.jpg');
    });

    test('fromMap() constructs a Profile with default values if null fields', () {
      // setup / given / arrange
      final data = {
        'firstName': null,
        'lastName': null,
        'displayName': null,
        'email': null,
        'photoUrl': null,
      };

      final profile = Profile.fromMap(data, 'docId123');

      // ASSERT : Check all fields are set correctly
      expect(profile.userID, 'docId123');
      expect(profile.firstName, isNull);
      expect(profile.lastName, isNull);
      expect(profile.displayName, '');
      expect(profile.email, '');
      expect(profile.photoUrl, isNull);
    });

    test('fromMap() constructs a Profile with provided non-null fields', () {
      // setup / given / arrange
      final data = {
        'firstName': 'Jane',
        'lastName': 'Smith',
        'displayName': 'JSmith',
        'email': 'jane@smith.com',
        'photoUrl': 'https://example.com/jane.jpg',
      };

      final profile = Profile.fromMap(data, 'docId456');

      // ASSERT : Check all fields are set correctly
      expect(profile.userID, 'docId456');
      expect(profile.firstName, 'Jane');
      expect(profile.lastName, 'Smith');
      expect(profile.displayName, 'JSmith');
      expect(profile.email, 'jane@smith.com');
      expect(profile.photoUrl, 'https://example.com/jane.jpg');
    });

    test('toMap() returns correct map representation', () {
      // setup / given / arrange
      final profile = Profile(
        userID: 'user789',
        firstName: 'Alice',
        lastName: 'Wonder',
        displayName: 'AWonder',
        email: 'alice@wonder.com',
        photoUrl: 'https://example.com/alice.jpg',
      );

      final map = profile.toMap();

      // ASSERT : Check all fields are in the map
      expect(map['firstName'], 'Alice');
      expect(map['lastName'], 'Wonder');
      expect(map['displayName'], 'AWonder');
      expect(map['email'], 'alice@wonder.com');
      expect(map['photoUrl'], 'https://example.com/alice.jpg');
    });

    test('copyWith() returns a new Profile with updated fields', () {
      // setup / given / arrange
      final original = Profile(
        userID: 'user999',
        firstName: 'OriginalFirst',
        lastName: 'OriginalLast',
        displayName: 'OriginalDisplay',
        email: 'orig@example.com',
        photoUrl: 'http://original.com/photo.png',
      );

      final updated = original.copyWith(
        firstName: 'NewFirst',
        displayName: 'NewDisplay',
      );

      // Assert : Unchanged fields remain the same
      expect(updated.userID, original.userID);
      expect(updated.lastName, original.lastName);
      expect(updated.email, original.email);
      expect(updated.photoUrl, original.photoUrl);

      // Assert : Updated fields contain correct info
      expect(updated.firstName, 'NewFirst');
      expect(updated.displayName, 'NewDisplay');

      // Assert : Confirm it's a new Profile instance
      expect(identical(updated, original), isFalse);
    });
  });
}
