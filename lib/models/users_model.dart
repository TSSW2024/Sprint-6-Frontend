class UserModel {
  final String displayName;
  final String email;
  final String uid;
  final bool verified;
  final String role;
  final String photoURL;

  UserModel({
    required this.displayName,
    required this.email,
    required this.uid,
    required this.verified,
    required this.role,
    required this.photoURL,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'],
      email: map['email'],
      uid: map['uid'],
      verified: map['verified'],
      role: map['role'],
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'verified': verified,
      'role': role,
      'photoURL': photoURL,
    };
  }
}
