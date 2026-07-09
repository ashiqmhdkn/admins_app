import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/course_model.dart';
import 'package:learning_admin_app/models/user_model.dart';

const String baseUrl = 'https://api.crescentlearning.org/admin/users';

Future<List<User>> usersGet({required String token}) async {
  final uri = Uri.parse('$baseUrl');
  try {
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    print('GET Users Response: ${response.statusCode}');
    print(
      "==============================================object===============================================================",
    );
    print('GET Users Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('users')) {
        final usersList = data['users'] as List;
        return usersList
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Users data not found in response');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch users');
    }
  } catch (e) {
    print('Error in usersGet: $e');
    rethrow;
  }
}