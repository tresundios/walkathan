import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user profile by userId
  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data()!;
      }
      throw Exception('User profile not found');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
