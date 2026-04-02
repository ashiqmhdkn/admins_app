import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/batch_model.dart';
import 'package:learning_admin_app/models/user_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

/// 🔹 Common headers
Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<List<User>> getBatchStudents({
  required String token,
  required String batchId,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/courses/batch/students?batch_id=$batchId');
    final response = await http.get(uri, headers: _headers(token));

    print("Fetching batch students...");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true && data['students'] != null) {
        final List<dynamic> students = data['students'];
        return students.map((json) => User.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to fetch batch students: ${response.statusCode}");
    }
  } catch (e) {
    print("Get Batch Error: $e");
    return [];
  }
}