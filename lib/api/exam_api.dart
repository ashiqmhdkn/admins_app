import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/api/exam_image.dart';
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

/// 🔹 Common headers
Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<bool> createQuiz({
  required String token,
  required Exam exam,
}) async {
  // try {
    // print("URL = ${data['url']}");
    // exam.questionModels[0].imagePath = "TEST_URL";
    // print("Image = ${exam.questionModels[0].imagePath}");
    exam=await createExamImage(token: token, exam: exam);
    final QuestionModel question = exam.questionModels[0];
    print(" Exam ID: ${question.imagePath}");
    print("Questions: ${exam.questionModels.length}");
    print("Question ID: ${exam.questionModels[0].questionId}");
    print("Image Path: ${exam.questionModels[0].imagePath}");
    print("Title: ${exam.questionModels[0].title}");
    try{
    final uri = Uri.parse('$baseUrl/exam');
    print("Creating quiz ");
    final response = await http.post(
      uri,
      headers: {
        ..._headers(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode(exam.toJson()),
    );

    print("Creating quiz...");
    if (response.statusCode==201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        return true;
      }
      return false;
    }
     else {
      throw Exception("Failed to create quiz: ${response.statusCode}");
    }
    // return true; // Assuming the quiz creation is successful for now
  } catch (e) {
    print("Create Quiz Error: $e");
    return false;
  }
}


Future<bool> examDelete({
  required String token,
  required String examId,
}) async {
  final uri = Uri.parse('$baseUrl/exam');

  try {
    final res = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json', // IMPORTANT
      },
      body: jsonEncode({"exam_id": examId}),
    );

    print("DELETE Status: ${res.statusCode}");
    print("DELETE Body: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } else if (res.statusCode == 404) {
      print("Exam not found");
      return false;
    } else {
      print("Server error: ${res.statusCode}");
      return false;
    }
  } catch (e) {
    print('Error in examDelete: $e');
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

  Future<List<QuestionModel>> getQuestions({
    required String token,
    required String examId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/exam?exam_id=$examId",
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
        final List list = data["questions"] ?? [];
        return list.map((e)=>QuestionModel.fromJson(e)).toList(); 
    } 
    else{
     throw Exception("Failed to fetch Exam questions: ${response.body}");
    }
  }

