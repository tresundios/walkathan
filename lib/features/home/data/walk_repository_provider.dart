import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'walk_repository.dart';

final walkRepositoryProvider = Provider<WalkRepository>((ref) {
  return WalkRepository();
});
