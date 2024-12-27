import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:pedometer/pedometer.dart';
import '../repository/walk_step_repository.dart';
import '../../walkathon/models/walk_step_model.dart';

class WalkHomePage extends ConsumerStatefulWidget {
  final String userId;

  const WalkHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _WalkHomePageState createState() => _WalkHomePageState();
}

class _WalkHomePageState extends ConsumerState<WalkHomePage> {
  Stream<StepCount>? _pedometerStream;
  int _currentSteps = 0;
  int _totalSteps = 0;

  @override
  void initState() {
    super.initState();
    _startPedometer();
  }

  // Start pedometer to track steps
  void _startPedometer() {
    _pedometerStream = Pedometer.stepCountStream;
    _pedometerStream?.listen(_onStepCount).onError(_onStepCountError);
  }

  // Update steps on each pedometer event
  void _onStepCount(StepCount event) {
    setState(() {
      _currentSteps = event.steps;
      _totalSteps += event.steps;
    });
  }

  // Handle pedometer stream error
  void _onStepCountError(error) {
    // Handle error here
    print('Pedometer Error: $error');
  }

  // Save walk steps to Firestore or other storage
  Future<void> _saveWalkSteps() async {
    final data = {
      'userId': widget.userId,
      'steps': _totalSteps,
    };

    await ref.read(saveWalkStepsProvider)(data); // Save to repository
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walkathon Home'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle logout
              ref.read(authRepositoryProvider).signout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${widget.userId}'),
            Text('Current Steps: $_currentSteps'),
            Text('Total Steps: $_totalSteps'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveWalkSteps,
              child: const Text('Save Walk Steps'),
            ),
            const SizedBox(height: 20),
            // Display saved steps
            Consumer(
              builder: (context, ref, child) {
                final savedSteps = ref.watch(userWalkStepsProvider(widget.userId));

                return savedSteps.when(
                  data: (steps) => Text('Saved Steps: $steps'),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
