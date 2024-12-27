import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Save user information in Firestore
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'gender': gender,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
