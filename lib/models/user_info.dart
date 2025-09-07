import 'package:firebase_auth/firebase_auth.dart';

class PmUserInfo {
  final String uid;
  final String? displayName;
  final String email;
  final bool isEmailVerified;
  final String? photoURL;
  final DateTime creationTime;
  final DateTime lastSignInTime;
  final String providerId;
  final bool isNewUser;

  PmUserInfo({
    required this.uid,
    this.displayName,
    required this.email,
    required this.isEmailVerified,
    this.photoURL,
    required this.creationTime,
    required this.lastSignInTime,
    required this.providerId,
    required this.isNewUser,
  });

  factory PmUserInfo.fromUserCredential(UserCredential credential) {
    return PmUserInfo(
      uid: credential.user?.uid ?? '',
      displayName: credential.user?.displayName,
      email: credential.user?.email ?? '',
      isEmailVerified: credential.user?.emailVerified ?? false,
      photoURL: credential.user?.photoURL,
      creationTime: credential.user?.metadata.creationTime ?? DateTime.now(),
      lastSignInTime:
          credential.user?.metadata.lastSignInTime ?? DateTime.now(),
      providerId: credential.additionalUserInfo?.providerId ?? '',
      isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  factory PmUserInfo.fromUser(User user) {
    return PmUserInfo(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      creationTime: user.metadata.creationTime ?? DateTime.now(),
      lastSignInTime: user.metadata.lastSignInTime ?? DateTime.now(),
      providerId: user.providerData.first.providerId,
      isNewUser: user.metadata.creationTime == user.metadata.lastSignInTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'photoURL': photoURL,
      'creationTime': creationTime.toIso8601String(),
      'lastSignInTime': lastSignInTime.toIso8601String(),
      'providerId': providerId,
      'isNewUser': isNewUser,
    };
  }

  factory PmUserInfo.fromMap(Map<String, dynamic> map) {
    return PmUserInfo(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      email: map['email'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      photoURL: map['photoURL'],
      creationTime: DateTime.parse(map['creationTime']),
      lastSignInTime: DateTime.parse(map['lastSignInTime']),
      providerId: map['providerId'] ?? '',
      isNewUser: map['isNewUser'] ?? false,
    );
  }
}
