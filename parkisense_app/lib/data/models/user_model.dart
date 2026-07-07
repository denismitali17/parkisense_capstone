class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String accountType; // 'Patient' or 'Healthcare Worker'

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.accountType,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'accountType': accountType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      accountType: map['accountType'] ?? 'Patient',
    );
  }
}