import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final usersCollection = FirebaseFirestore.instance.collection('users');
final walkStepsCollection = FirebaseFirestore.instance.collection('walk_steps');

final fbAuth = FirebaseAuth.instance;
