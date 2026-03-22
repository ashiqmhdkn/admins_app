import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> registerApi({
  required final email,
  required final password,
  required final username,
  required final role,
}) async {
  final primaryUrl = 'https://api.crescentlearning.org';
  final uri = Uri.parse('$primaryUrl/signup');

  final response = await http.post(
    uri,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'email': email,
      'password': password,
      'name': username,
      'role': role,
    }),
  );

  final Map<String, dynamic> data = jsonDecode(response.body);
  print(response.body);
  if (data['success']) {
    return 'success';
  }

  throw Exception("Token not found in response");
}
