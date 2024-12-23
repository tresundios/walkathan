import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:walkathan/repositories/walk_step_repository.dart';
import '../../../repositories/auth_repository_provider.dart';
import '../../../models/custom_error.dart';
import '../../../utils/error_dialog.dart';
import '../home/home_provider.dart';
import '../../../constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkathan/utils/permission_handler.dart';
import 'dart:async';

// Provider for managing the user's steps. 
final userStepsProvider = StateProvider<int>((ref) => 0); 
final walkActiveProvider = StateProvider<bool>((ref) => true);

class WalkHomePage extends ConsumerStatefulWidget {
  final String userId;

  //const WalkHomePage({Key? key, required this.userId}) : super(key: key);
  //const WalkHomePage({required this.userId, super.key});
  const WalkHomePage({required this.userId, Key? key}) : super(key: key);

  @override
  _WalkHomePageState createState() => _WalkHomePageState();
}

class _WalkHomePageState extends ConsumerState<WalkHomePage> {
  StreamSubscription<StepCount>? _subscription;
  final WalkStepRepository _walkStepRepository = WalkStepRepository();
  int _currentSteps = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startPedometer();
  }

  @override void dispose() { 
    _subscription?.cancel(); 
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await requestActivityRecognitionPermission();
    await requestBodySensorsPermission();
  }

  // Start pedometer to track steps
  void _startPedometer() {
    //_pedometerStream = Pedometer.stepCountStream;
    //_pedometerStream?.listen(_onStepCount).onError(_onStepCountError);
    _subscription = Pedometer.stepCountStream.listen(_onStepCount, onError: _onStepCountError );
  }

  // Update steps on each pedometer event
  void _onStepCount(StepCount event) {
    if (ref.read(walkActiveProvider.notifier).state) { 
      final newSteps = event.steps - _currentSteps; 
      if (newSteps > 0) { 
        // Update Firestore with new steps 
        _walkStepRepository.updateUserSteps( 
          userId: widget.userId, 
          newSteps: newSteps, 
        ); 
      } 
      
      setState(() { 
        _currentSteps = event.steps; 
      }); 
      
      // Update state using Riverpod 
      ref.read(userStepsProvider.notifier).state = _currentSteps;
    }
  }

  // Handle pedometer stream error
  void _onStepCountError(error) {
    print('Step Count Error: $error'); 
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text('Error in step count: $error')),
    );
  }
  void _endWalk() async { 
    ref.read(walkActiveProvider.notifier).state = false; 
    
    // Save final step count to Firestore 
    await _walkStepRepository.updateUserSteps( 
      userId: widget.userId, 
      newSteps: _currentSteps, 
    ); 
    
    ScaffoldMessenger.of(context).showSnackBar( 
      const SnackBar(content: Text('Walk ended and steps saved!')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    final int steps = ref.watch(userStepsProvider); 
    final bool walkActive = ref.watch(walkActiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walkathan Home'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).signout();
              } on CustomError catch (e) {
                if (!context.mounted) return;
                errorDialog(context, e);
              }
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              ref.invalidate(profileProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Information: ${widget.userId}'),
            Text('User Name: ${fbAuth.currentUser?.email}'),
            Text('Current Steps: $_currentSteps'),
            const SizedBox(height: 20),
            Text(
              'Steps Taken: $steps',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: walkActive? _endWalk: null, 
              child: const Text('End Walk'),
            ),
          ],
        ),
      ),
    );
  }
}
