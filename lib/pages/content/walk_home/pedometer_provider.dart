import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walkathan/repositories/walk_step_repository.dart';
import 'dart:async';
import 'package:intl/intl.dart';

final pedometerProvider = StateNotifierProvider.family<PedometerNotifier, PedometerState, String>((ref, userId) => PedometerNotifier(userId, ref.watch(walkStepRepositoryProvider)));

final walkStepRepositoryProvider = Provider<WalkStepRepository>((ref) => WalkStepRepository());

class PedometerState {
  final String steps;
  final int count; // Counter state
  final String status;
  final DateTime? lastUpdate;

  PedometerState({this.steps = '0', this.count = 0, this.status = '?', this.lastUpdate});

  PedometerState copyWith({String? steps, int? count, String? status, DateTime? lastUpdate}) {
    return PedometerState(
      steps: steps ?? this.steps,
      count: count ?? this.count,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class PedometerNotifier extends StateNotifier<PedometerState> {
  final String _userId;
  final WalkStepRepository _walkStepRepository;
  String _lastDay = '';

  PedometerNotifier(this._userId, this._walkStepRepository) : super(PedometerState()) {
    _fetchInitialState().then((_) => initPlatformState());
  }

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  Future<void> _fetchInitialState() async {
    final initialSteps = await _walkStepRepository.getInitialStepCount(_userId);
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Check if today is different from the last recorded day
    final lastDay = await _walkStepRepository.getLastDay(_userId) ?? '';
    if (lastDay != today) {
      // New day, reset count to 0
      await _walkStepRepository.saveLastDay(_userId, today);
      state = state.copyWith(steps: initialSteps.toString(), count: 0);
    } else {
      // Same day, continue from where we left off
      final count = await _walkStepRepository.getLastCount(_userId) ?? 0;
      state = state.copyWith(steps: initialSteps.toString(), count: count);
    }
    _lastDay = today;
  }

  Future<void> fetchInitialState() async {
    final initialSteps = await _walkStepRepository.getInitialStepCount(_userId);
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    // Check if today is different from the last recorded day
    final lastDay = await _walkStepRepository.getLastDay(_userId) ?? '';
    if (lastDay != today) {
      // New day, reset count to 0
      await _walkStepRepository.saveLastDay(_userId, today);
      state = state.copyWith(steps: initialSteps.toString(), count: 0);
    } else {
      // Same day, continue from where we left off
      final count = await _walkStepRepository.getLastCount(_userId) ?? 0;
      state = state.copyWith(steps: initialSteps.toString(), count: count);
    }
    _lastDay = today;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      state = PedometerState(steps: 'Step Count not available', status: 'Permission Denied', count: state.count);
      return;
    }

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream?.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(onStepCount).onError(onStepCountError);
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  void onStepCount(StepCount event) {
    int newCount = state.count + 1; // Increment by 1 for each new step detected
    _walkStepRepository.saveStepCount(_userId, event.steps, newCount);
    state = state.copyWith(
      steps: event.steps.toString(), 
      count: newCount, 
      lastUpdate: DateTime.now()
    );
    _walkStepRepository.saveLastCount(_userId, event.steps, newCount); // Save the new daily count
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    state = state.copyWith(status: event.status);
  }

  void onPedestrianStatusError(error) {
    state = state.copyWith(status: 'Pedestrian Status not available', count: state.count);
  }

  void onStepCountError(error) {
    state = state.copyWith(steps: 'Step Count not available', count: state.count);
  }
}