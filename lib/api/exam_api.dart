import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/exam_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

/// 🔹 Common headers
Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<String?> createQuiz({
  required String token,
  required Exam exam,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/quiz/create');
    final response = await http.post(
      uri,
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(exam.toJson()),
    );

    print("Creating quiz...");
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['exam_id'] as String;
      }
      return null;
    } else {
      throw Exception("Failed to create quiz: ${response.statusCode}");
    }
  } catch (e) {
    print("Create Quiz Error: $e");
    return null;
  }
}