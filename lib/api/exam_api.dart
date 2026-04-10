import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:tusc/tusc.dart';

const String baseUrl = 'https://api.crescentlearning.org';

/// 🔹 Common headers
Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<bool> createQuiz({
  required String token,
  required Exam exam,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/exam');
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
        return true;
      }
      return false;
    } else {
      throw Exception("Failed to create quiz: ${response.statusCode}");
    }
  } catch (e) {
    print("Create Quiz Error: $e");
    return false;
  }
}
Future<List<Exam>> getsubjectExams({
    required String token,
    required String subjectId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/exam/all?subject_id=$subjectId",
    );
      final response = await http.get(
        url,
        headers: {
          ..._headers(token),
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final List list = data["exams"] ?? [];
        return list.map((e)=>Exam.fromJson(e)).toList(); 
    } 
    else{
     throw Exception("Failed to fetch Exams: ${response.body}");
    }
  }
  Future<List<Exam>> getunitExams({
    required String token,
    required String unitId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/exam/all?unit_id=$unitId",
    );

      final response = await http.get(
        url,
        headers: {
          ..._headers(token),
          'Content-Type': 'application/json',
                  },
      );

      final data = jsonDecode(response.body);
      print(data);
       if (response.statusCode == 200) {
        final List list = data["exams"] ?? [];
        return list.map((e)=>Exam.fromJson(e)).toList(); 
    } 
    else{
     throw Exception("Failed to fetch Exams: ${response.body}");
    }
    }

