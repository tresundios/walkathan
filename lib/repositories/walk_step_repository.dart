import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

class WalkStepRepository {

  Future<void> saveWalkSteps(String userId, int steps) async {
    try {
      await walkStepsCollection.doc(userId).set({
        'steps': steps,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge ensures we update the data without overwriting other fields
    } catch (e) {
      throw Exception("Error saving walk steps: $e");
    }
  }

  Future<int> getWalkSteps(String userId) async {
    try {
      final snapshot = await walkStepsCollection.doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['steps'] ?? 0;
      }
      return 0; // If no data exists, return 0
    } catch (e) {
      throw Exception("Error fetching walk steps: $e");
    }
  }

  /// Update user steps in Firestore 
  Future<void> updateUserSteps({ 
    required String userId, 
    required int newSteps, 
    }) async { 
      try { 
        await walkStepsCollection.doc(userId).set({ 
          'steps': FieldValue.increment(newSteps), 
          'timestamp': FieldValue.serverTimestamp(), 
        }, SetOptions(merge: true)); 
      } catch (e) { 
        throw Exception('Error updating user steps: $e'); 
      }
    }

    /// Get user steps from Firestore 
    Future<int> getUserSteps(String userId) async { 
      try { 
        final DocumentSnapshot documentSnapshot = await walkStepsCollection.doc(userId).get(); 
        if (documentSnapshot.exists) { 
          return documentSnapshot['steps'] ?? 0; 
        } else { 
          return 0; 
        } 
      } catch (e) { 
        throw Exception('Error retrieving user steps: $e'); 
      }
    }
}
