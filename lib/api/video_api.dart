import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:learning_admin_app/models/video_model.dart';
import 'package:tusc/tusc.dart';

const String baseUrl = 'https://api.crescentlearning.org';

Future<bool> videoUpload({
  required String token,
  required File videoFile,
  required int duration,
  required String title,
  required String unit_id,
  required String description,
  void Function(int sent, int total)? onProgress,
}) async {
  final uri = Uri.parse('$baseUrl/upload/video');

  try {
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Upload-Length': videoFile.lengthSync().toString(),
        'Tus-Resumable': '1.0.0',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "unit_id": unit_id,
      }),
    );

    if (response.statusCode != 200) throw Exception('Failed to get upload URL');

    final data = jsonDecode(response.body);
    final uploadUrl = data['upload_url'];

    await uploadVideoTUSC(
      uploadUrl: uploadUrl,
      videoFile: videoFile,
      token: token,
      onProgress: onProgress, 
    );

    return true;
  } catch (e) {
    rethrow;
  }
}

Future<void> uploadVideoTUSC({
  required String uploadUrl,
  required File videoFile,
  required String token,
  void Function(int sent, int total)? onProgress,
}) async {
  final client = TusClient(
    url: uploadUrl,
    file: XFile(videoFile.path),
    chunkSize: 5 * 1024 * 1024, // 5MB chunks for smoother progress
    headers: {'Authorization': 'Bearer $token'},
  );

  await client.startUpload(
    onProgress: (count, total, response) {
      if (onProgress != null) onProgress(count, total); // 👈 Trigger UI update
    },
    onComplete: (response) => print('Upload Complete'),
    onError: (error) => throw Exception(error.message),
  );
}

Future<List<Video>> videosGet({required String token, required unit_id}) async {
  final uri = Uri.parse('$baseUrl/unit/videos?unit_id=$unit_id');

  try {
    final response = await http.get(
      uri,
      headers: { 'Authorization': 'Bearer $token','Accept': 'application/json'},
    );

    print('Videos API Status: ${response.statusCode}');
    print('Videos API Body: ${response.body}');

    final contentType = response.headers['content-type'];
    if (contentType == null || !contentType.contains('application/json')) {
      throw Exception('Server did not return JSON');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey('videos')) {
        final videosList = data['videos'] as List;
        return videosList
            .map((item) => Video.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('videos key missing in response');
      }
    }

    throw Exception('Server error: ${response.statusCode}');
  } catch (e) {
    print("unitid: $unit_id");
    print("token :$token");
    print("headers:...............................................");
    print('❌ Error in videosGet: $e');
    rethrow;
  }}
Future<bool> VideoDelete({
  required String token,
  required String VideoId,
}) async {
  final uri = Uri.parse("$baseUrl/unit/videos");
  final response = await http.delete(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({"video_id": VideoId}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["success"] == true;
  } else {
    print(response);
    throw Exception("Failed to delete note: ${response.body}");
  }}
  Future<bool> VideoPut({
  required String token,
  required String VideoId,
  required String title,
  required String description,
}) async {
  final uri = Uri.parse("$baseUrl/unit/videos");
  final response = await http.put(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({"video_id": VideoId,
    "title":title,
    "desc":description
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["success"] == true;
  } else {
    print(response);
    throw Exception("Failed to delete video: ${response.body}");
  }
}
