import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/batch_model.dart';

const String baseUrl = 'https://api.crescentlearning.org/courses/batch';

/// 🔹 Common headers
Map<String, String> _headers(String token) => {
  "Authorization": "Bearer $token",
};

// ==========================================================
// 🟢 CREATE BATCH (Multipart)
// ==========================================================
Future<bool> postBatch({
  required String token,
  required String name,
  required String courseId,
  required String duration,
  required String imagePath,
}) async {
  try {
    var uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", uri);

    request.headers.addAll(_headers(token));

    request.fields["name"] = name;
    request.fields["course_id"] = courseId;
    request.fields["duration"] = duration;

    request.files.add(
      await http.MultipartFile.fromPath("batch_image", imagePath),
    );

    final response = await request.send();

    return response.statusCode == 200;
  } catch (e) {
    print("Create Batch Error: $e");
    return false;
  }
}

// ==========================================================
// 🔵 GET BATCHES
// ==========================================================
Future<List<Batch>> getBatches({
  required String token,
  required String courseId,
}) async {
  try {
    final uri = Uri.parse('$baseUrl?course_id=$courseId');
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final batchesList = data['batch'] as List;
      return batchesList
          .map((item) => Batch.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to fetch batches");
    }
  } catch (e) {
    print("Get Batch Error: $e");
    return [];
  }
}

// ==========================================================
// 🟡 UPDATE BATCH
// ==========================================================
Future<bool> putBatch({
  required String token,
  required String batchId,
  required String name,
  required String duration,
  String? imagePath,
}) async {
  try {
    var uri = Uri.parse('$baseUrl?batch_id=$batchId');

    var request = http.MultipartRequest("PUT", uri);

    request.headers.addAll(_headers(token));

    request.fields["name"] = name;
    request.fields["duration"] = duration;

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath("batch_image", imagePath),
      );
    }

    final response = await request.send();

    return response.statusCode == 200;
  } catch (e) {
    print("Update Batch Error: $e");
    return false;
  }
}

// ==========================================================
// 🔴 DELETE BATCH
// ==========================================================
Future<bool> batchdelete({
  required String token,
  required String batchId,
}) async {
  try {
    var uri = Uri.parse('$baseUrl?batch_id=$batchId');

    final response = await http.delete(uri, headers: _headers(token));

    return response.statusCode == 200;
  } catch (e) {
    print("Delete Batch Error: $e");
    return false;
  }
}
