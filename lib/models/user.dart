// lib/models/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String gender;
  final int totalSteps;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.gender,
    this.totalSteps = 0,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      gender: map['gender'],
      totalSteps: map['totalSteps'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'gender': gender,
      'totalSteps': totalSteps,
    };
  }
}