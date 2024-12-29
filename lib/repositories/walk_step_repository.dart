import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

class WalkStepRepository {


  /// Retrieves the last recorded day for a given user ID from Firestore.
  Future<String?> getLastDay(String userId) async {
    try {
      DocumentSnapshot doc = await walkStepsCollection.doc(userId).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('lastDay')) {
        return data['lastDay'] as String;
      }
      return null; // Return null if 'lastDay' doesn't exist
    } catch (e) {
      print('Error fetching last day: $e');
      return null;
    }
  }

  /// Saves the current day for a given user ID to Firestore.
  Future<void> saveLastDay(String userId, String day) async {
    try {
      await walkStepsCollection.doc(userId).set({
        'lastDay': day,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving last day: $e');
    }
  }

  /// Retrieves the last count for a given user ID from Firestore.
  Future<int?> getLastCount(String userId) async {
     try {
      DateTime today = DateTime.now();
      String dateKey = _getDateKey(today); // Get the current date as a key (YYYY-MM-DD)
      final snapshot = await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['count'] ?? 0;
      }
      return 0; // If no data exists for the date, return 0
    } catch (e) {
      throw Exception("Error fetching walk steps: $e");
    }
  }

  /// Saves the last count for a given user ID to Firestore.
  Future<void> saveLastCount(String userId, int steps, int count) async {
    try {
      DateTime today = DateTime.now();
      String dateKey = _getDateKey(today); // Get the current date as a key (YYYY-MM-DD)

      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': steps,
        'count': count,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we update the data without overwriting other fields
    } catch (e) {
      throw Exception("Error saving walk steps: $e");
    }
  }

  // Save walk steps for a specific day
  Future<void> saveWalkSteps(String userId, int steps, int count ) async {
    try {
      DateTime today = DateTime.now();
      String dateKey = _getDateKey(today); // Get the current date as a key (YYYY-MM-DD)

      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': steps,
        'count': count,
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
        return snapshot.data()!['count'] ?? 0;
      }
      return 0; // If no data exists for the date, return 0
    } catch (e) {
      throw Exception("Error fetching walk steps: $e");
    }
  }

  // Update the user's steps for a specific day
  Future<void> updateUserSteps({required String userId,required int newSteps,required int newCount,required String dateKey  }) async {
    try {
      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': newSteps,
        'count': newCount,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we don't overwrite other fields
    } catch (e) {
      throw Exception('Error updating user steps: $e');
    }
  }

  Future<int> getCumulativeSteps(String userId) async {
    try {
      DateTime today = DateTime.now();
      DateTime thirtyDaysAgo = today.subtract(Duration(days: 3));

      // Get date keys for the last 10 days
      List<String> last30Days = List.generate(10, (index) {
        DateTime date = thirtyDaysAgo.add(Duration(days: index));
        return _getDateKey(date);
      });

      int totalSteps = 0;

      // Query the daily_steps sub-collection for the last 10 days
      for (String dateKey in last30Days) {
        final snapshot = await walkStepsCollection
            .doc(userId)
            .collection('daily_steps')
            .doc(dateKey)
            .get();

        // Check if the document exists and then access the data
        if (snapshot.exists) {
          // Safely access the 'steps' field and cast to int
          totalSteps += (snapshot.data()?['count'] as num).toInt() ?? 0;
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

  Future<void> saveStepCount(String userId, int steps, int count) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      await walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).set({
        'steps': steps,
        'count': count,  
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
      if (doc.exists && doc.data()?['count'] != null) {
        return doc.data()?['count'] as int;
      }
    } catch (e) {
      print('Error fetching initial step count: $e');
    }
    // If no steps recorded or an error occurred, return 0
    return 0;
  }

}
