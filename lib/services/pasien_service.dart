import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ambil token login
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

// Ambil username (jika memang di-stored di prefs, atau bisa hardcode untuk tes)
Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(
    'userName',
  ); // Pastikan login-mu simpan ini jika memang dibutuhkan
}

/// Ambil pasien hari ini by user
Future<List<Map<String, dynamic>>> getPasienByUser({
  String searchKey = " ",
  required String user,
  String rs = "%20",
}) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL tidak ditemukan!");
  if (token == null || token.isEmpty)
    throw Exception("Token login tidak ditemukan!");

  final url = Uri.parse(
    '$apiUrl/EmrPasienAktif/LookupByRuangByUser/$searchKey/$user/$rs/2',
  );
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal mengambil data pasien hari ini');
  }
  throw Exception('HTTP error ${response.statusCode}');
}
