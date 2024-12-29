// auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:walkathan/constants/constants.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authStateProvider = StateProvider<AuthState>((ref) => AuthState.initial());

final authProvider = Provider<AuthService>((ref) {
  final authState = ref.watch(authStateProvider.notifier);
  final storage = FlutterSecureStorage();
  return AuthService(authState, storage);
});

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? name;

  AuthState({
    required this.isAuthenticated,
    this.token,
    this.name,
  });

  factory AuthState.initial() => AuthState(isAuthenticated: false);

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? name,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      name: name ?? this.name,
    );
  }
}

class AuthService {
  final StateController<AuthState> _authState;
  final FlutterSecureStorage _storage;
  AuthService(this._authState, this._storage);

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(jsonEncode(response.body));
      _authState.state = _authState.state.copyWith(
        isAuthenticated: true,
        token: data['data']['token'],
        name: data['data']['name'],
      );
      // Here, you might want to save the token to local storage like SharedPreferences or secure storage
      // Save token to secure storage
      await _storage.write(key: 'jwt_token', value: data['data']['token']);
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    return token;
  }

  Future<void> logout() async {
    _authState.state = AuthState.initial();
    await _storage.delete(key: 'jwt_token');
  }

  bool get isAuthenticated => _authState.state.isAuthenticated;
}