// In your repositories file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../constants/firebase_constants.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    // Example query to fetch leaderboard data
    final querySnapshot = await _firestore.collection('leaderboard').orderBy('score', descending: true).limit(10).get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();


    
  }

  // Helper method to generate a date key in YYYY-MM-DD format
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Helper method to generate a date key in YYYY-MM-DD format
  String _getDateKeyGiven(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<int> getUserSteps(String userId, int limit) async {
    try {
      int totalSteps = 0;
      final DateTime today = DateTime.now();
    final DateTime thirtyDaysAgo = today.subtract(Duration(days: limit-1));

    List<String> last30Days = List.generate(limit, (index) {
      DateTime date = thirtyDaysAgo.add(Duration(days: index));
      return _getDateKeyGiven(date); // Ensure this matches Firestore document IDs
    });
      for (String dateKey in last30Days) {
        int localStep = 0;
        try {
          DocumentSnapshot stepSnapshot = await walkStepsCollection
              .doc(userId)
              .collection('daily_steps')
              .doc(dateKey)
              .get();
          if (stepSnapshot.exists) {
            final data = stepSnapshot.data() as Map<String, dynamic>;
            if (data.containsKey('count')) {
              localStep = int.tryParse(data['count']?.toString() ?? '0') ?? 0;
              totalSteps += localStep;
            }
          }
        } catch (e) {
          print('Error fetching steps for $userId on $dateKey: $e');
        }
      }
      return totalSteps;
    } catch (e) {
      throw Exception('Error getting top users by steps: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopUsersBySteps(String filterGender, int limit) async {
  try {
    final DateTime today = DateTime.now();
    final DateTime thirtyDaysAgo = today.subtract(const Duration(days: 30));

    // Generate date keys for each day in the last 30 days
    List<String> last30Days = List.generate(30, (index) {
      DateTime date = thirtyDaysAgo.add(Duration(days: index));
      return _getDateKeyGiven(date);
    });

    List<Map<String, dynamic>> usersWithSteps = [];

    // Query all users
    QuerySnapshot userSnapshot = await usersCollection.get();
    
    for (var userDoc in userSnapshot.docs) {
      int totalSteps = 0;
      String userId = userDoc.id;

      // Query daily steps for each user
      for (String dateKey in last30Days) {
        int localStep = 0;
        DocumentSnapshot stepSnapshot = await walkStepsCollection
            .doc(userId)
            .collection('daily_steps')
            .doc(dateKey)
            .get();
        
        if (stepSnapshot.exists) {
              final data = stepSnapshot.data() as Map<String, dynamic>;
              if (data.containsKey('count')) {
                localStep = int.tryParse(data['count']?.toString() ?? '0') ?? 0;
                totalSteps += localStep;
              }
            }
      }
        try {
          final userData = userDoc.data() as Map<String, dynamic>?;
          usersWithSteps.add({
            'userId': userId,
            'name': userData?['name']?.toString() ?? 'Anonymous',
            'totalSteps': totalSteps,
          });
        } catch (e) {
          print('Error processing user data for userId $userId: $e');
          usersWithSteps.add({
            'userId': userId,
            'name': 'Anonymous',
            'totalSteps': totalSteps,
          });
        }
      // Add user with their total steps to the list
      // usersWithSteps.add({
      //   'userId': userId,
      //   'name': userDoc.data()['name'] ?? 'Anonymous', // Assuming there's a 'name' field for user
      //   'totalSteps': totalSteps,
      // });
    }

    // Sort users by steps in descending order and take top 10
    usersWithSteps.sort((a, b) => b['totalSteps'].compareTo(a['totalSteps']));
    return usersWithSteps.take(10).toList();
  } catch (e) {
    throw Exception('Error getting top users by steps: $e');
  }
}


    // try {
    //   final DateTime today = DateTime.now();
    //   final DateTime thirtyDaysAgo = today.subtract(Duration(days: limit-1));

    //   List<String> last30Days = List.generate(limit, (index) {
    //     return _getDateKeyGiven(thirtyDaysAgo.add(Duration(days: index)));
    //   });

    //   List<Map<String, dynamic>> usersWithSteps = [];

    //   // Fetch all users at once with the gender filter
    //   QuerySnapshot userSnapshot = await usersCollection.where('gender', isEqualTo: filterGender).get(); // Limit to 100 users for performance, adjust as needed
      
    //   // Use Future.wait for parallel processing
    //   await Future.wait(userSnapshot.docs.map((userDoc) async {
    //     int totalSteps = 0;
    //     String userId = userDoc.id;

    //     List<Future<DocumentSnapshot>> stepFutures = last30Days.map((dateKey) => 
    //       walkStepsCollection.doc(userId).collection('daily_steps').doc(dateKey).get()
    //     ).toList();

    //     List<DocumentSnapshot> stepSnapshots = await Future.wait(stepFutures);

    //     for (var stepSnapshot in stepSnapshots) {
    //        int localStep = 0;
    //       if (stepSnapshot.exists) {
    //         final data = stepSnapshot.data() as Map<String, dynamic>?;
    //         if (data?['count'] is int) {
    //           localStep = data?['count'];
    //           totalSteps += localStep;
    //         }
    //       }
    //     }

    //     final userData = userDoc.data() as Map<String, dynamic>?;
    //     usersWithSteps.add({
    //       'userId': userId,
    //       'name': userData?['name']?.toString() ?? 'Anonymous',
    //       'totalSteps': totalSteps,
    //     });
    //   }));

    //   //return usersWithSteps;

    //   usersWithSteps.sort((a, b) => b['totalSteps'].compareTo(a['totalSteps']));
    //   return usersWithSteps.take(4).toList(); // Return only top 4
    // } catch (e) {
    //   throw Exception('Error getting top users by steps: $e');
    // }
  

}

//   Future<List<Map<String, dynamic>>> getTopUsersBySteps(String filterGender, int limit) async {
//     try {
//       final DateTime today = DateTime.now();
//       final DateTime thirtyDaysAgo = today.subtract(Duration(days: limit-1));

//       List<String> last30Days = List.generate(limit, (index) {
//         DateTime date = thirtyDaysAgo.add(Duration(days: index));
//         return _getDateKeyGiven(date); // Ensure this matches Firestore document IDs
//       });

//       List<Map<String, dynamic>> usersWithSteps = [];

//       QuerySnapshot userSnapshot = await usersCollection.where('gender', isEqualTo: filterGender).get();
      
//       for (var userDoc in userSnapshot.docs) {
//         int totalSteps = 0;
//         String userId = userDoc.id;

//         for (String dateKey in last30Days) {
//           int localStep = 0;
//           try {
//             DocumentSnapshot stepSnapshot = await walkStepsCollection
//                 .doc(userId)
//                 .collection('daily_steps')
//                 .doc(dateKey)
//                 .get();
//             if (stepSnapshot.exists) {
//               final data = stepSnapshot.data() as Map<String, dynamic>;
//               if (data.containsKey('count')) {
//                 localStep = int.tryParse(data['count']?.toString() ?? '0') ?? 0;
//                 totalSteps += localStep;
//               }
//             }
//           } catch (e) {
//             print('Error fetching steps for $userId on $dateKey: $e');
//           }
//         }

//         try {
//           final userData = userDoc.data() as Map<String, dynamic>?;
//           usersWithSteps.add({
//             'userId': userId,
//             'name': userData?['name']?.toString() ?? 'Anonymous',
//             'totalSteps': totalSteps,
//           });
//         } catch (e) {
//           print('Error processing user data for userId $userId: $e');
//           usersWithSteps.add({
//             'userId': userId,
//             'name': 'Anonymous',
//             'totalSteps': totalSteps,
//           });
//         }
//       }

//       usersWithSteps.sort((a, b) => b['totalSteps'].compareTo(a['totalSteps']));
//       return usersWithSteps.take(4).toList();
//       } catch (e) {
//         throw Exception('Error getting top users by steps: $e');
//       }
//     }
// }

  

final leaderboardRepositoryProvider = Provider((ref) => LeaderboardRepository());

// Modify the FutureProvider to accept two arguments
final leaderboardDataProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, args) async {
  final leaderboardRepository = ref.watch(leaderboardRepositoryProvider);
  return await leaderboardRepository.getTopUsersBySteps(args['gender'], args['limit']);
}, name: 'leaderboardDataProvider');

final userDataProvider = FutureProvider.family<int, Map<String, dynamic>>((ref, args) async {
  final leaderboardRepository = ref.watch(leaderboardRepositoryProvider);
  return await leaderboardRepository.getUserSteps(args['user'], args['limit']);
}, name: 'userDataProvider');
