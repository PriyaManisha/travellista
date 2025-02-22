class Profile {
  final String userID;
  final String? firstName;
  final String? lastName;
  final String displayName;
  final String email;
  final String? photoUrl;

  Profile({
    required this.userID,
    this. firstName,
    this.lastName,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  // Construct Profile from Firestore doc snapshot
  factory Profile.fromMap(Map<String, dynamic> data, String documentId) {
    return Profile(
      userID: documentId,
      firstName: data['firstName'],
      lastName: data['lastName'],
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  // Convert Profile object to map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
