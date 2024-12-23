import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../repositories/walk_step_repository.dart';

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
  walkStepRepository.saveWalkSteps(userId, steps);
});
