import 'package:cloud_firestore/cloud_firestore.dart';

class WalkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user's current step count
  Future<void> saveSteps({
    required String userId,
    required int steps,
  }) async {
    try {
      final walkRef = _firestore.collection('walk_steps').doc(userId);

      final doc = await walkRef.get();

      if (doc.exists) {
        await walkRef.update({
          'steps': FieldValue.increment(steps),
        });
      } else {
        await walkRef.set({'steps': steps, 'userId': userId});
      }
    } catch (e) {
      throw Exception('Error saving steps: $e');
    }
  }

  // Fetch total steps for a specific user
  Future<int> fetchTotalSteps(String userId) async {
    try {
      final doc = await _firestore.collection('walk_steps').doc(userId).get();

      if (doc.exists) {
        return doc.data()?['steps'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Error fetching steps: $e');
    }
  }
}
