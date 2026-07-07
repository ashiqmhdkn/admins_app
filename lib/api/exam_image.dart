import 'dart:convert';
// import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/exam_model.dart';
import 'package:learning_admin_app/models/question_model.dart';

const String baseUrl = 'https://api.crescentlearning.org/exam/image';

Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

Future<Exam> createExamImage({
  required String token,
  required Exam exam,
}) async {
try{
  print("quiz image upload");
  for(int i = 0; i < exam.questionModels.length; i++){
    if(exam.questionModels[i].imagePath == null || exam.questionModels[i].imagePath!.isEmpty){
      continue; // Skip if there's no image to upload
    }
    var uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", uri);

    request.headers.addAll(_headers(token));

    request.fields["exam_id"] = exam.examId.toString();
    

    request.files.add(
      await http.MultipartFile.fromPath("file",exam.questionModels[i].imagePath.toString()),
    );

    final response = await request.send();
    if(response.statusCode==200){
      print("Upload successful");
  final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      print("data[url] = ${data['url']}");
      print("Before = ${exam.questionModels[i].imagePath}");
      exam.questionModels[i].imagePath = data['url']?.toString();
      print("After = ${exam.questionModels[i].imagePath}");
    }
    else{
  final error = await response.stream.bytesToString();
  print("Upload failed");
  print(response.statusCode);
  print(error);

    }
  }
  return exam;
}catch(e){
  print("Create Exam Image Error: $e");
  return exam;
  }

}