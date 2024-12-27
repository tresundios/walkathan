import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';

final winnersProvider = FutureProvider<List<AppUser>>((ref) async {
  final resultsRepository = ref.read(resultsRepositoryProvider);
  return resultsRepository.fetchTopWinners();
});

final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  return ResultsRepository();
});

class ResultsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppUser>> fetchTopWinners() async {
    try {
      // Fetch top 3 male and female participants based on cumulative steps
      final maleSnapshot = await _firestore
          .collection('walkSteps')
          .where('gender', isEqualTo: 'male')
          .orderBy('totalSteps', descending: true)
          .limit(3)
          .get();

      final femaleSnapshot = await _firestore
          .collection('walkSteps')
          .where('gender', isEqualTo: 'female')
          .orderBy('totalSteps', descending: true)
          .limit(3)
          .get();

      final maleWinners = maleSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromJson(data);
      }).toList();

      final femaleWinners = femaleSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromJson(data);
      }).toList();

      return [...maleWinners, ...femaleWinners];
    } catch (e) {
      throw Exception('Failed to fetch winners: $e');
    }
  }
}
