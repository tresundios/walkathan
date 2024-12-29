// api_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import 'package:walkathan/constants/constants.dart'; 

final apiProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authProvider);
  return ApiService(authService);
});

class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  Future<http.Response> makeAuthenticatedRequest(String endpoint) async {
    final token = _authService.getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      // Handle token expiration or invalid token, e.g., log out user
    }

    return response;
  }
}