import 'dart:convert';
import 'package:http/http.dart' as http;


const String baseUrl = 'https://api.crescentlearning.org';

  /// Send OTP
   Future<Map<String, dynamic>> sendOtp(String email) async {
    final url = Uri.parse("$baseUrl/send-otp");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);
      print("Send OTP Response: ${response.body}");
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "OTP sent successfully"
        };
      } else {
        return {
          "success": false,
          "message": data["error"] ?? "Failed to send OTP"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString()
      };
    }
  }

  /// Verify OTP
   Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/verify-otp");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
