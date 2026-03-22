import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/user_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

// Fetch user profile
Future<User> profileapi(String token) async {
  final uri = Uri.parse('$baseUrl/profile');

  try {
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    print('Profile API Status: ${response.statusCode}');
    print('Profile API Headers: ${response.headers}');
    print('Profile API Body: ${response.body}');

    // 🚨 Guard: ensure JSON response
    final contentType = response.headers['content-type'];

    if (contentType == null || !contentType.contains('application/json')) {
      print(token);
      throw Exception('Server did not return JSON');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey('user')) {
        return User.fromJson(data['user']);
      } else {
        throw Exception('User key missing in response');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Token expired');
    }

    throw Exception('Server error: ${response.statusCode}');
  } catch (e) {
    print('❌ Error in profileapi: $e');
    rethrow;
  }
}


// Update user profile
Future<String> profileupdate(String token, User user) async {
  final uri = Uri.parse('$baseUrl/profile');

  try {
    final response = await http.put(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'name': user.username,
        'email': user.email,
        'role': user.role,
        'phone': user.phone,
      }),
    );

    print('Profile Update Response: ${response.statusCode}');
    print('Profile Update Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data.containsKey('success') && data['success'] == true) {
        return 'Profile updated successfully';
      } else if (data.containsKey('message')) {
        return data['message'];
      } else {
        return 'Profile updated';
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Invalid request');
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update profile');
    }
  } catch (e) {
    print('Error in profileupdate: $e');
    rethrow;
  }
}
