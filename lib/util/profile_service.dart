import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travellista/models/profile.dart';

class ProfileService {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  // Fetch profile by userID
  Future<Profile?> getProfile(String uid) async {
    try {
      final docSnapshot = await usersCollection.doc(uid).get();
      if (!docSnapshot.exists) {
        return null;
      }
      return Profile.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
    } catch (e) {
      rethrow;
    }
  }

  // Create/update profile document
  Future<void> setProfile(Profile profile) async {
    try {
      await usersCollection.doc(profile.userID).set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
