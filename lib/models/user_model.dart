import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, moderator, member }
enum Gender { male, female }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final String? name;
  final Gender gender;

  UserModel({required this.uid, required this.email, required this.role, this.name, required this.gender});

  factory UserModel.fromFirebaseUser(User firebaseUser, {UserRole role = UserRole.member, String? name, Gender gender = Gender.male}) {
    return UserModel(uid: firebaseUser.uid, email: firebaseUser.email!, role: role, name: name, gender: gender);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'role': role.toString(),
        'name': name,
        'gender': gender.toString(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      role: UserRole.values.byName(json['role']),
      name: json['name'],
      gender: Gender.values.byName(json['gender']),
    );
  }
}