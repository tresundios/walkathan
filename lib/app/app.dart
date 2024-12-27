// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'providers.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Club Member Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: authState.when(
         (user) => user != null ? HomeScreen() : LoginScreen(),
        loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}