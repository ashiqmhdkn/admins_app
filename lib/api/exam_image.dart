import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';

const String baseUrl = 'https://api.crescentlearning.org/exam/image';

Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<bool> createExamImage({
  required String token,
  required Exam exam,
}) async {
try{
  var uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", uri);

    request.headers.addAll(_headers(token));

    request.fields["exam_id"] = exam.examId.toString();
    

    request.files.add(
      await http.MultipartFile.fromPath("file",exam.questionModels[0].imagePath.toString() ),
    );

    final response = await request.send();

    return response.statusCode == 200;

}catch(e){
  print("Create Exam Image Error: $e");
  return false;}

}