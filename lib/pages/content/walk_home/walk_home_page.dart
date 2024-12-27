import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import './pedometer_provider.dart';

// Provider for managing the user's steps. 
final userStepsProvider = StateProvider<int>((ref) => 0); 
final walkActiveProvider = StateProvider<bool>((ref) => false);
final previousStepsProvider = StateProvider<int>((ref) => 0);

class WalkHomePage extends ConsumerStatefulWidget {
  final String userId;

  const WalkHomePage({required this.userId, Key? key}) : super(key: key);

  @override
  _WalkHomePageState createState() => _WalkHomePageState();
}
/*
class _WalkHomePageState extends ConsumerState<WalkHomePage> {
  StreamSubscription<StepCount>? _subscription;
  final WalkStepRepository _walkStepRepository = WalkStepRepository();

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadInitialStepCount(); // Load initial step count from Firestore

    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }


  @override 
  void dispose() { 
    _subscription?.cancel(); 
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await requestActivityRecognitionPermission();
    await requestBodySensorsPermission();
  }

   Future<void> initPlatformState() async {

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    (await _pedestrianStatusStream.listen(onPedestrianStatusChanged))
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  // Start pedometer to track steps
  Future<void> _startPedometer() async {
    try {
      _subscription = await Pedometer.stepCountStream.listen(onStepCount);
    } catch (e) {
      print('Error starting pedometer: $e');
    }
  }

  Future<void> _stopPedometer() async {
    try {
      await _subscription?.cancel();
    } catch (e) {
      print('Error stopping pedometer: $e');
    }
  }

  // Start walk
  void _startWalk() {
    ref.read(walkActiveProvider.notifier).state = true;
    _startPedometer(); // Start listening to step count
  }

  // End walk
  void _endWalk() async { 
    ref.read(walkActiveProvider.notifier).state = false;
    _stopPedometer(); // Stop listening to step count
    
    // Save final step count to Firestore
    await _walkStepRepository.updateUserSteps( 
      userId: widget.userId, 
      newSteps: ref.read(userStepsProvider), 
      dateKey: _getDateKey(),
    ); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text('Walk ended and steps saved!')), 
      );
    }
  }

  // Handle pedometer stream error
  void _onStepCountError(error) {
    print('Step Count Error: $error'); 
    ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text('Error in step count: $error')),
    );
  }

  // Get current date key in format YYYY-MM-DD
  String _getDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Update the _loadInitialStepCount method to store previous steps
  Future<void> _loadInitialStepCount() async {
    try {
      final dateKey = _getDateKey();
      
      // Get the reference to the steps document
      final docRef = FirebaseFirestore.instance
          .collection('steps')
          .doc(widget.userId)
          .collection('daily_steps')
          .doc(dateKey);
      
      // Get the document snapshot
      final docSnapshot = await docRef.get();
      
      if (mounted) {
        if (docSnapshot.exists && docSnapshot.data()?['steps'] != null) {
          final previousSteps = docSnapshot.data()!['steps'] as int;
          // Store the previous steps count
          ref.read(previousStepsProvider.notifier).state = previousSteps;
          // Initialize the current steps count with previous steps
          ref.read(userStepsProvider.notifier).state = previousSteps;
          print('Loaded previous step count: $previousSteps for date: $dateKey');
        } else {
          // No previous data exists, set both to 0
          ref.read(previousStepsProvider.notifier).state = 0;
          ref.read(userStepsProvider.notifier).state = 0;
          print('No existing step data found. Setting initial steps to 0');
        }
      }
    } catch (e) {
      if (mounted) {
        // On error, set both to 0
        ref.read(previousStepsProvider.notifier).state = 0;
        ref.read(userStepsProvider.notifier).state = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading steps: $e')),
        );
      }
      print("Error loading initial step count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int steps = ref.watch(userStepsProvider); 
    final bool walkActive = ref.watch(walkActiveProvider);
    final int previousSteps = ref.watch(previousStepsProvider);

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
            Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
            ),
            Text(
              _steps,
              style: TextStyle(fontSize: 60),
            ),
            Divider(
              height: 100,
              thickness: 0,
              color: Colors.white,
            ),
            Text(
              'Pedestrian Status',
              style: TextStyle(fontSize: 30),
            ),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'
                      ? Icons.accessibility_new
                      : Icons.error,
              size: 100,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 30)
                    : TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            
            Text('User Information: ${widget.userId}'),
            Text('User Name: ${fbAuth.currentUser?.email}'),
            Text('Current Steps: $steps'),
            Text('Previous Steps: $previousSteps'),
            const SizedBox(height: 20),
            Text(
              'Steps Taken: $steps',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Display Start Walk button when the walk is not active
            if (!walkActive)
              ElevatedButton(
                onPressed: _startWalk, 
                child: const Text('Start Walk'),
              ),
            // Display End Walk button when the walk is active
            if (walkActive)
              ElevatedButton(
                onPressed: _endWalk, 
                child: const Text('End Walk'),
              ),
          ],
        ),
      ),
    );
  }
}
*/
class _WalkHomePageState extends ConsumerState<WalkHomePage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pedometerProvider(widget.userId).notifier).fetchInitialStepCount();
    });
  }
  
  // End walk
  void _endWalk() async { 
    ref.read(walkActiveProvider.notifier).state = false;
    //_stopPedometer(); // Stop listening to step count
    
    // Save final step count to Firest
  }


  @override
  Widget build(BuildContext context) {
    final pedometerState = ref.watch(pedometerProvider(widget.userId));
    final notifier = ref.read(pedometerProvider(widget.userId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedometer Example'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Step Count Display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Steps Taken',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      pedometerState.steps,
                      style: TextStyle(fontSize: 48, color: Colors.blue),
                    ),
                    Text(
                      pedometerState.lastUpdate != null 
                        ? 'Last updated: ${DateFormat('HH:mm').format(pedometerState.lastUpdate!)}' 
                        : 'No updates yet',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: _endWalk, 
                      child: Text('Save Today\'s Steps'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Walking Status Display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Pedestrian Status',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Icon(
                      pedometerState.status == 'walking'
                          ? Icons.directions_walk
                          : pedometerState.status == 'stopped'
                              ? Icons.accessibility_new
                              : Icons.error,
                      size: 80,
                      color: pedometerState.status == 'walking' 
                          ? Colors.green 
                          : pedometerState.status == 'stopped' 
                              ? Colors.blue 
                              : Colors.red,
                    ),
                    Text(
                      pedometerState.status,
                      style: TextStyle(
                        fontSize: 20,
                        color: pedometerState.status == 'walking' || pedometerState.status == 'stopped'
                            ? Colors.black
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Additional UI elements for other functionalities if needed
          ],
        ),
      ),
    );
  }
}