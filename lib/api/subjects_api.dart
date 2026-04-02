import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/subject_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

// GET - Fetch all subjects
Future<List<Subject>> subjectsget({required String token,required String course_id}) async {
  final uri = Uri.parse('$baseUrl/subjects?course_id=$course_id');
  try {
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
        print("course id:$course_id");
    print('GET subjects Response: ${response.statusCode}');
    print('GET subjects Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('subjects')) {
        final subjectsList = data['subjects'] as List;
        return subjectsList
            .map((item) => Subject.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('subjects data not found in response');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch subjects');
    }
  } catch (e) {
    print('Error in subjectsget: $e');
    rethrow;
  }
}

// POST - Create new subject
Future<bool> subjectspost({
  required String token,
  required String title,
  required String course_id,
  required String subjectImage,
}) async {
  final uri = Uri.parse('$baseUrl/subjects');
  try {
    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['course_id'] = course_id
      ..files.add(await http.MultipartFile.fromPath('subject_image', subjectImage))
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    
    print("POST Status: ${res.statusCode}");
    print("POST Body: ${res.body}");
    if (res.statusCode == 200 || res.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return data['success'] == true;
    } else {
      print("Server error: ${res.statusCode} ${res.reasonPhrase}, Body: ${res.body}");
      return false;
    }
  } catch (e) {
    print('Error in subjectspost: $e');
    return false;
  }
}

// PUT - Update existing subject
Future<bool> subjectsPut({
  required String token,
  required String title,
  required String subject_id,
  String? subjectImage,
}) async {
  final uri = Uri.parse('$baseUrl/subjects');
  try {
    final request = http.MultipartRequest('PUT', uri)
      ..fields['title'] = title
      ..fields['subject_id'] = subject_id
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    // Only add image if provided
    if (subjectImage != null && subjectImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('subject_image', subjectImage)
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    
    print("PUT Status: ${res.statusCode}");
    print("PUT Body: ${res.body}");

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return data['success'] == true;
    } else {
      print("Server error: ${res.statusCode}, Body: ${res.body}");
      return false;
    }
  } catch (e) {
    print('Error in subjectsPut: $e');
    return false;
  }
}


Future<bool> subjectsDelete({
  required String token,
  required String subjectId,
}) async {

  final uri = Uri.parse('$baseUrl/subjects');

  print("DELETE URL: $uri");
  print("SUBJECT ID: $subjectId");
  print("TOKEN: $token");

  try {
    final res = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: '{"id":"$subjectId"}',
    );

    print("DELETE Status: ${res.statusCode}");
    print("DELETE Body: ${res.body}");

    return res.statusCode == 200;

  } catch (e) {
    print('Error: $e');
    return false;
  }
}
