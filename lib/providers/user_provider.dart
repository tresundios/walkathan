import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProvider = StateProvider<UserModel?>((ref) => null);

final userListProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.watch(userServiceProvider).getAllUsers();
});