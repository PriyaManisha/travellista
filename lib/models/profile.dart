class Profile {
  final String userID;
  final String? firstName;
  final String? lastName;
  final String displayName;
  final String email;
  final String? photoUrl;

  Profile({
    required this.userID,
    this.firstName,
    this.lastName,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

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

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  // Allows partial updates while returning new Profile obj
  Profile copyWith({
    String? userID,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return Profile(
      userID: userID ?? this.userID,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

