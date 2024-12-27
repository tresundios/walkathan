// lib/services/pedometer_service.dart

import 'package:pedometer/pedometer.dart';
import 'dart:async';

class PedometerService {
  StreamSubscription<int>? _subscription;

  Stream<int> get stepCountStream {
    Stream<StepCount> stepCountStream = Pedometer.stepCountStream;
    return stepCountStream.map((stepCount) => stepCount.steps);
  }

  Future<int> getTodayStepCount() async {
    int stepCount = await Pedometer.stepCountStream.first.then((value) => value.steps);
    return stepCount;
  }

  void startTracking() {
    _subscription = Pedometer.stepCountStream.listen(
      (StepCount count) {
        // Handle step count updates
        print('Step count: ${count.steps}');
      },
      onError: (error) {
        // Handle error
        print('Error: $error');
      },
      onDone: () {
        // Handle stream completion
        print('Pedometer stream finished.');
      },
      cancelOnError: true,
    );
  }

  void stopTracking() {
    _subscription?.cancel();
  }
}