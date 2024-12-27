// lib/providers/walk_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/repository/walk_step_repository.dart';

// Provider for WalkStepRepository
final walkStepRepositoryProvider = Provider<WalkStepRepository>((ref) {
  return WalkStepRepository();
});

// Provider for saving walk steps
final saveWalkStepsProvider = Provider.family<void, Map<String, dynamic>>((ref, data) async {
  final walkStepRepository = ref.read(walkStepRepositoryProvider);
  final String userId = data['userId'];
  final int steps = data['steps'];
  await walkStepRepository.saveWalkSteps(userId, steps);
});

// Provider for fetching winners
final winnersProvider = FutureProvider<Map<String, List<AppUser>>>((ref) async {
  final walkStepRepository = ref.read(walkStepRepositoryProvider);
  return await walkStepRepository.fetchWinners();
});
