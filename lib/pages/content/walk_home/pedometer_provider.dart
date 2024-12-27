import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walkathan/repositories/walk_step_repository.dart';

final pedometerProvider = StateNotifierProvider.family<PedometerNotifier, PedometerState, String>((ref, userId) => PedometerNotifier(userId, ref.watch(walkStepRepositoryProvider)));

final walkStepRepositoryProvider = Provider<WalkStepRepository>((ref) => WalkStepRepository());

class PedometerState {
  final String steps;
  final String status;
  final DateTime? lastUpdate;

  PedometerState({this.steps = '0', this.status = '?', this.lastUpdate});

  PedometerState copyWith({String? steps, String? status, DateTime? lastUpdate}) {
    return PedometerState(
      steps: steps ?? this.steps,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class PedometerNotifier extends StateNotifier<PedometerState> {
  final String _userId;
  final WalkStepRepository _walkStepRepository;

  PedometerNotifier(this._userId, this._walkStepRepository) : super(PedometerState()) {
    _fetchInitialStepCount().then((_) => initPlatformState());
  }

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  Future<void> _fetchInitialStepCount() async {
    final initialSteps = await _walkStepRepository.getInitialStepCount(_userId);
    //state = state.copyWith(steps: initialSteps.toString());
    state = state.copyWith(steps: initialSteps == 0 ? '0' : initialSteps.toString());
  }

  Future<void> fetchInitialStepCount() async {
  try {
    final initialSteps = await _walkStepRepository.getInitialStepCount(_userId);
    state = state.copyWith(steps: initialSteps == 0 ? '0' : initialSteps.toString());
    print('Initial steps set to: ${state.steps}');
  } catch (e) {
    print('Error fetching initial step count: $e');
    // Optionally, handle the error by setting a default or error state
    state = state.copyWith(steps: 'Error');
  }
}

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      state = PedometerState(steps: 'Step Count not available', status: 'Permission Denied');
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
    _walkStepRepository.saveStepCount(_userId, event.steps); // Use the repository to save steps
    state = state.copyWith(steps: event.steps.toString(), lastUpdate: DateTime.now());
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    state = state.copyWith(status: event.status);
  }

  void onPedestrianStatusError(error) {
    state = state.copyWith(status: 'Pedestrian Status not available');
  }

  void onStepCountError(error) {
    state = state.copyWith(steps: 'Step Count not available');
  }
}