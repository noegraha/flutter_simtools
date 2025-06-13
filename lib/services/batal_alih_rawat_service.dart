import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Helper token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

// Ambil data konsul alih rawat by noreg
Future<List<Map<String, dynamic>>> fetchKonsulAlihRawat(String noreg) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL tidak ditemukan!");
  if (token == null || token.isEmpty)
    throw Exception("Token login tidak ditemukan!");

  final url = Uri.parse('$apiUrl/EmrKonsultasi/ReadAlihRawat/$noreg');
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(
      data['message'] ?? 'Gagal mengambil data konsul alih rawat',
    );
  }
  throw Exception('HTTP error ${response.statusCode}');
}

// Hapus (batal) alih rawat by konsultasiId
Future<void> deleteAlihRawat(String konsultasiId) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL tidak ditemukan!");
  if (token == null || token.isEmpty)
    throw Exception("Token login tidak ditemukan!");

  final url = Uri.parse(
    '$apiUrl/EmrKonsultasi/KonsultasiAlihRawat/$konsultasiId',
  );
  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['statusCode'] == 200) {
    return;
  }
  throw Exception(data['message'] ?? 'Gagal batal alih rawat');
}
