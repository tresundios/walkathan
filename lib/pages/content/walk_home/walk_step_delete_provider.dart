import '../../../repositories/walk_step_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final walkStepRepositoryProvider = Provider<WalkStepRepository>((ref) {
  return WalkStepRepository();
});

final userWalkStepsProvider = FutureProvider.family<int, String>((ref, userId) async {
  final walkStepRepository = ref.read(walkStepRepositoryProvider);
  return await walkStepRepository.getWalkSteps(userId);
});

final saveWalkStepsProvider = Provider.family<void, Map<String, dynamic>>((ref, data) {
  final walkStepRepository = ref.read(walkStepRepositoryProvider);
  final userId = data['userId'];
  final steps = data['steps'];
  final count = data['count'];
  walkStepRepository.saveWalkSteps(userId, steps, count);
});
