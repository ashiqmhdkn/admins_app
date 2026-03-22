import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:learning_admin_app/api/login_api.dart';
import 'package:learning_admin_app/api/register_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends StateNotifier<String?> {
  AuthController() : super(null);

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    final token = await _getToken();
    if (token != null) {
      state = token;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = "loading";
    try {
      final token = await loginApi(email, password);
      await _saveToken(token);
      state = token;
      return true;
    } catch (e) {
      state = null;
      return false;
    }
  }

  Future<void> register({
    required final email,
    required final name,
    required final role,
    required final password,
  }) async {
    state = "loading";
    try {
      await registerApi(
        email: email,
        password: password,
        role: role,
        username: name,
      );
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _removeToken();
    state = null;
  }

  // Token management
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Public method to get current token
  Future<String?> getToken() => _getToken();
}

final authControllerProvider = StateNotifierProvider<AuthController, String?>((
  ref,
) {
  return AuthController();
});

// Convenience provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final token = ref.watch(authControllerProvider);
  return token != null && token != "loading";
});
