// lib/providers/profile_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/app_user.dart';

// Provider to fetch user profile
final profileProvider = FutureProvider.family<AppUser, String>((ref, userId) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.getUserProfile(userId);
});
