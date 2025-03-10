import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travellista/models/profile.dart';

class ProfileService {
  final CollectionReference profilesCollection =
  FirebaseFirestore.instance.collection('profiles');

  Future<Profile?> getProfile(String uid) async {
    final docSnapshot = await profilesCollection.doc(uid).get(const GetOptions(source: Source.server));
    if (!docSnapshot.exists) {
      return null;
    }
    return Profile.fromMap(
      docSnapshot.data() as Map<String, dynamic>,
      docSnapshot.id,
    );
  }

  Future<void> setProfile(Profile profile) async {
    try {
      await profilesCollection.doc(profile.userID).set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}

