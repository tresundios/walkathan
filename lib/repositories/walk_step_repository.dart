import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

class WalkStepRepository {

  // Save walk steps for a specific day
  Future<void> saveWalkSteps(String userId, int steps ) async {
    try {
      DateTime today = DateTime.now();
      String dateKey = _getDateKey(today); // Get the current date as a key (YYYY-MM-DD)

      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': steps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we update the data without overwriting other fields
    } catch (e) {
      throw Exception("Error saving walk steps: $e");
    }
  }

  // Get walk steps for a specific day
  Future<int> getWalkSteps(String userId) async {
    try {
      DateTime today = DateTime.now();
      String dateKey = _getDateKey(today); // Get the current date as a key (YYYY-MM-DD)
      final snapshot = await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['steps'] ?? 0;
      }
      return 0; // If no data exists for the date, return 0
    } catch (e) {
      throw Exception("Error fetching walk steps: $e");
    }
  }

  // Update the user's steps for a specific day
  Future<void> updateUserSteps({
    required String userId,
    required int newSteps,
    required String dateKey, // Pass date key to update steps for the specific day
  }) async {
    try {
      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': newSteps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we don't overwrite other fields
    } catch (e) {
      throw Exception('Error updating user steps: $e');
    }
  }

  Future<int> getCumulativeSteps(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime tenDaysAgo = today.subtract(Duration(days: 30));

      // Get date keys for the last 10 days
      List<String> last10Days = List.generate(10, (index) {
        DateTime date = tenDaysAgo.add(Duration(days: index));
        return _getDateKey(date);
      });

      int totalSteps = 0;

      // Query the daily_steps sub-collection for the last 10 days
      for (String dateKey in last10Days) {
        final snapshot = await walkStepsCollection
            .doc(userId)
            .collection('daily_steps')
            .doc(dateKey)
            .get();

        // Check if the document exists and then access the data
        if (snapshot.exists) {
          // Safely access the 'steps' field and cast to int
          totalSteps += (snapshot.data()?['steps'] as num).toInt() ?? 0;
        }
      }

      return totalSteps;
    } catch (e) {
      throw Exception('Error getting cumulative steps: $e');
    }
  }

  // Helper method to generate a date key in YYYY-MM-DD format
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveStepCount(String userId, int steps) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': steps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we don't overwrite other fields
    } catch (e) {
      print('Error saving step count: $e');
    }
  }

  Future<int> getInitialStepCount(String userId) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final doc = await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).get();
      if (doc.exists && doc.data()?['steps'] != null) {
        return doc.data()?['steps'] as int;
      }
    } catch (e) {
      print('Error fetching initial step count: $e');
    }
    // If no steps recorded or an error occurred, return 0
    return 0;
  }

}
