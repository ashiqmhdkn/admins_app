import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<String> loginApi(String email, String password) async {
  final primaryUrl = 'https://api.crescentlearning.org';
  final uri = Uri.parse('$primaryUrl/login');

  final response = await http.post(
    uri,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({'email': email, 'password': password}),
  );

  final Map<String, dynamic> data = jsonDecode(response.body);
  print(data);

  final token = data['token'];
  if (token is String && token.isNotEmpty) {
    return token;
  }

  throw Exception("Token not found");
}
