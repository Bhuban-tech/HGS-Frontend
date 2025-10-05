import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080/users";
  // 🔴 For Android Emulator use 10.0.2.2 instead of localhost
  // 🔴 For real device use your PC IP address, e.g. "http://192.168.1.100:8080/users"

  static Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // ✅ Success
    } else {
      throw Exception("Failed to register: ${response.body}");
    }
  }
}
