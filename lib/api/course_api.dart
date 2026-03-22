import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/course_model.dart';

const String baseUrl = 'https://api.crescentlearning.org';

// GET - Fetch all courses
Future<List<Course>> coursesget(String token) async {
  final uri = Uri.parse('$baseUrl/courses');
  try {
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    print('GET Courses Response: ${response.statusCode}');
    print(
      "==============================================object===============================================================",
    );
    print('GET Courses Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('courses')) {
        final coursesList = data['courses'] as List;
        return coursesList
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Courses data not found in response');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      final Map<String, dynamic> error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to fetch courses');
    }
  } catch (e) {
    print('Error in coursesget: $e');
    rethrow;
  }
}

// POST - Create new course
Future<bool> coursespost({
  required String token,
  required String title,
  required String description,
  required String courseImage,
}) async {
  final uri = Uri.parse('$baseUrl/courses');
  try {
    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['description'] = description
      ..files.add(
        await http.MultipartFile.fromPath('course_image', courseImage),
      )
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
      print(
        "Server error: ${res.statusCode} ${res.reasonPhrase}, Body: ${res.body}",
      );
      return false;
    }
  } catch (e) {
    print('Error in coursespost: $e');
    return false;
  }
}

// PUT - Update existing course
Future<bool> coursesPut({
  required String token,
  required String courseId,
  required String title,
  required String description,
  required String? courseImage,
}) async {
  final uri = Uri.parse('$baseUrl/courses?course_id=$courseId');
  try {
    final request = http.MultipartRequest('PUT', uri)
      ..fields['course_id'] = courseId
      ..fields['title'] = title
      ..fields['description'] = description
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    // Only add image if provided
    if (courseImage != null && courseImage.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('course_image', courseImage),
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
    print('Error in coursesPut: $e');
    return false;
  }
}

Future<bool> coursesDelete({
  required String token,
  required String courseId,
}) async {
  final uri = Uri.parse('$baseUrl/courses');

  try {
    final res = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json', // IMPORTANT
      },
      body: jsonEncode({"id": courseId}),
    );

    print("DELETE Status: ${res.statusCode}");
    print("DELETE Body: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } else if (res.statusCode == 404) {
      print("Course not found");
      return false;
    } else {
      print("Server error: ${res.statusCode}");
      return false;
    }
  } catch (e) {
    print('Error in coursesDelete: $e');
    return false;
  }
}
