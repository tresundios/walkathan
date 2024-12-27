// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/step_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User-related methods
  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return User.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<User>> getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // Event-related methods
  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }

  Future<Event?> getEvent(String eventId) async {
    DocumentSnapshot snapshot = await _firestore.collection('events').doc(eventId).get();
    if (snapshot.exists) {
      return Event.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Event>> getEvents() async {
    QuerySnapshot snapshot = await _firestore.collection('events').get();
    return snapshot.docs.map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // Step entry-related methods
  Future<void> addStepEntry(StepEntry stepEntry) async {
    await _firestore
        .collection('dailySteps')
        .doc(stepEntry.userId)
        .collection('steps')
        .doc(stepEntry.date.toIso8601String())
        .set(stepEntry.toMap());
  }

  Future<List<StepEntry>> getStepEntries(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('dailySteps')
        .doc(userId)
        .collection('steps')
        .get();
    return snapshot.docs.map((doc) => StepEntry.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}