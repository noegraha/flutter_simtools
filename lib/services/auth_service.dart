import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static Future<bool> login(String username, String password) async {
    final url = Uri.parse(
      'http://182.168.7.119/signin',
    ); // Ganti dengan URL Anda
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Anda bisa parsing token di sini kalau perlu
      return true;
    }
    return false;
  }
}
