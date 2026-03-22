import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://api.crescentlearning.org';

Map<String, String> _headers(String token) => {
      HttpHeaders.contentTypeHeader: 'application/json',
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

// ─────────────────────────────────────────────
// BATCH CODE
// ─────────────────────────────────────────────

// POST /courses/batch/code — Generate batch code (admin)
Future<String?> batchCodeGenerate({
  required String token,
  required String batchId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/code');
  try {
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId}),
    );

    print('batchCodeGenerate | ${res.statusCode} | ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['batch_code'] as String?;
    }
    return null;
  } catch (e) {
    print('Error in batchCodeGenerate: $e');
    return null;
  }
}

// DELETE /courses/batch/code — Delete batch code (admin)
Future<bool> batchCodeDelete({
  required String token,
  required String batchId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/code');
  try {
    final res = await http.delete(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId}),
    );

    print('batchCodeDelete | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchCodeDelete: $e');
    return false;
  }
}

// ─────────────────────────────────────────────
// BATCH JOIN REQUESTS
// ─────────────────────────────────────────────

// POST /courses/batch/request — Student submits join request
Future<bool> batchRequestSubmit({
  required String token,
  required String batchId,
  required String code,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/request');
  try {
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId, 'code': code}),
    );

    print('batchRequestSubmit | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchRequestSubmit: $e');
    return false;
  }
}

// GET /courses/batch/request — Admin gets batch join requests
Future<List<Map<String, dynamic>>> batchRequestsGet({
  required String token,
  String? batchId, // optional — omit to get all requests
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/request');
  try {
    final res = await http.get(
      uri,
      headers: _headers(token),
      // Note: body on GET — required by your API
    );

    // Since http.get doesn't support body, use a custom Request instead
    final request = http.Request('GET', uri)
      ..headers.addAll(_headers(token))
      ..body = jsonEncode(batchId != null ? {'batch_id': batchId} : {});

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('batchRequestsGet | ${response.statusCode} | ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['requests']?['results'] ?? data['requests'] ?? [];
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  } catch (e) {
    print('Error in batchRequestsGet: $e');
    return [];
  }
}

// POST /courses/batch/request/accept — Admin accepts a request
Future<bool> batchRequestAccept({
  required String token,
  required String requestId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/request/accept');
  try {
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'request_id': requestId}),
    );

    print('batchRequestAccept | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchRequestAccept: $e');
    return false;
  }
}

// POST /courses/batch/request/reject — Admin rejects a request
Future<bool> batchRequestReject({
  required String token,
  required String requestId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/request/reject');
  try {
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'request_id': requestId}),
    );

    print('batchRequestReject | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchRequestReject: $e');
    return false;
  }
}

// DELETE /courses/batch/request/delete — Admin deletes request(s)
// action: "single" (requires requestId) | "accepted_all"
Future<bool> batchRequestDelete({
  required String token,
  required String action, // "single" or "accepted_all"
  String? requestId,      // required only when action == "single"
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/request/delete');
  try {
    final Map<String, dynamic> body = {'action': action};
    if (action == 'single' && requestId != null) {
      body['request_id'] = requestId;
    }

    final res = await http.delete(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    print('batchRequestDelete | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchRequestDelete: $e');
    return false;
  }
}

// ─────────────────────────────────────────────
// BATCH TEACHERS
// ─────────────────────────────────────────────

// POST /courses/batch/teacher — Assign teacher to batch (admin)
Future<bool> batchTeacherAssign({
  required String token,
  required String batchId,
  required String teacherId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/teacher');
  try {
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId, 'teacher_id': teacherId}),
    );

    print('batchTeacherAssign | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchTeacherAssign: $e');
    return false;
  }
}

// DELETE /courses/batch/teacher — Remove teacher from batch (admin)
Future<bool> batchTeacherRemove({
  required String token,
  required String batchId,
  required String teacherId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/teacher');
  try {
    final res = await http.delete(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId, 'teacher_id': teacherId}),
    );

    print('batchTeacherRemove | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchTeacherRemove: $e');
    return false;
  }
}

// GET /courses/batch/teacher — Get teachers of a batch (admin)
Future<List<Map<String, dynamic>>> batchTeachersGet({
  required String token,
  required String batchId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/teacher');
  try {
    final request = http.Request('GET', uri)
      ..headers.addAll(_headers(token))
      ..body = jsonEncode({'batch_id': batchId});

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    print('batchTeachersGet | ${res.statusCode} | ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['teachers'] ?? []);
    }
    return [];
  } catch (e) {
    print('Error in batchTeachersGet: $e');
    return [];
  }
}

// ─────────────────────────────────────────────
// BATCH STUDENTS
// ─────────────────────────────────────────────

// GET /courses/batch/students — Get students of a batch (admin)
Future<List<Map<String, dynamic>>> batchStudentsGet({
  required String token,
  required String batchId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/students');
  try {
    final request = http.Request('GET', uri)
      ..headers.addAll(_headers(token))
      ..body = jsonEncode({'batch_id': batchId});

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    print('batchStudentsGet | ${res.statusCode} | ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['students'] ?? []);
    }
    return [];
  } catch (e) {
    print('Error in batchStudentsGet: $e');
    return [];
  }
}

// DELETE /courses/batch/students — Remove student from batch (admin)
Future<bool> batchStudentRemove({
  required String token,
  required String batchId,
  required String studentId,
}) async {
  final uri = Uri.parse('$baseUrl/courses/batch/students');
  try {
    final res = await http.delete(
      uri,
      headers: _headers(token),
      body: jsonEncode({'batch_id': batchId, 'student_id': studentId}),
    );

    print('batchStudentRemove | ${res.statusCode} | ${res.body}');
    return res.statusCode == 200;
  } catch (e) {
    print('Error in batchStudentRemove: $e');
    return false;
  }
}