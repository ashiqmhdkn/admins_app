import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:learning_admin_app/models/notes_model.dart';


const String _baseUrl = "https://api.crescentlearning.org"; // update if different

/// GET /units/notes?unit_id=...
Future<List<Note>> notesGet({
  required String token,
  required String unitId,
}) async {
  final uri = Uri.parse("$_baseUrl/units/notes?unit_id=$unitId");
  final response = await http.get(
    uri,
    headers: {"Authorization": "Bearer $token"},
  );
  print("notes get request has been send");
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data["notes"] ?? [];
    print(List);
    return list.map((e) => Note.fromJson(e)).toList();
  } else {
    throw Exception("Failed to fetch notes: ${response.body}");
  }
}

/// POST /units/notes  (multipart — title + optional file)
Future<bool> notesPost({
  required String token,
  required String unitId,
  required String title,
  required File file,
}) async {
  final uri = Uri.parse("$_baseUrl/units/notes");

  final request = http.MultipartRequest("POST", uri)
    ..headers["Authorization"] = "Bearer $token"
    ..fields["unit_id"] = unitId
    ..fields["title"] = title;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
  print(request);
  print(request.fields);
  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["success"] == true;
  } else {
    throw Exception("Failed to create note: ${response.body}");
  }
}

/// PUT /units/notes  (multipart — note_id + optional title/file)
Future<bool> notesPut({
  required String token,
  required String noteId,
  String? title,
  File? file,
}) async {
  final uri = Uri.parse("$_baseUrl/units/notes");

  final request = http.MultipartRequest("PUT", uri)
    ..headers["Authorization"] = "Bearer $token"
    ..fields["note_id"] = noteId;

  if (title != null) request.fields["title"] = title;

  if (file != null) {
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["success"] == true;
  } else {
    throw Exception("Failed to update note: ${response.body}");
  }
}

/// DELETE /units/notes  { note_id }
Future<bool> notesDelete({
  required String token,
  required String noteId,
}) async {
  final uri = Uri.parse("$_baseUrl/units/notes");

  final response = await http.delete(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode({"note_id": noteId}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["success"] == true;
  } else {
    throw Exception("Failed to delete note: ${response.body}");
  }
}