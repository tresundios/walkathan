// lib/features/walkathon/repository/walk_step_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/walk_step_model.dart';
import '../../utils/handle_exception.dart';

class WalkStepRepository {
  final FirebaseFirestore _firestore;

  WalkStepRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Save walk steps to Firestore
  Future<void> saveWalkSteps(String userId, int steps) async {
    try {
      final today = DateTime.now();
      final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Reference to the user's walk steps document
      DocumentReference userWalkStepsDoc = _firestore.collection('walksteps').doc(userId);

      // Update the document with today's steps
      await userWalkStepsDoc.set({
        'dailySteps.$formattedDate': FieldValue.increment(steps),
        'totalSteps': FieldValue.increment(steps),
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleException(e);
    }
  }

  // Fetch total steps for a user
  Future<int> fetchTotalSteps(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('walksteps').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['totalSteps'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw handleException(e);
    }
  }

  // Fetch daily steps for a user
  Future<Map<String, dynamic>> fetchDailySteps(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('walksteps').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['dailySteps'] ?? {};
      }
      return {};
    } catch (e) {
      throw handleException(e);
    }
  }

  // Fetch top 3 male and female winners
  Future<Map<String, List<AppUser>>> fetchWinners() async {
    try {
      // Fetch all users with their totalSteps
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      List<AppUser> males = [];
      List<AppUser> females = [];

      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final user = AppUser(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          gender: data['gender'] ?? 'unknown',
        );
        final totalSteps = data['totalSteps'] ?? 0;

        if (user.gender.toLowerCase() == 'male') {
          males.add(user.copyWith(totalSteps: totalSteps));
        } else if (user.gender.toLowerCase() == 'female') {
          females.add(user.copyWith(totalSteps: totalSteps));
        }
      }

      // Sort by totalSteps descending
      males.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));
      females.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

      // Take top 3
      List<AppUser> topMales = males.take(3).toList();
      List<AppUser> topFemales = females.take(3).toList();

      return {
        'male': topMales,
        'female': topFemales,
      };
    } catch (e) {
      throw handleException(e);
    }
  }
}
