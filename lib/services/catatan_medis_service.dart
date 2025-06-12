import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Helper ambil token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

// Service
Future<List<Map<String, dynamic>>> fetchCatatanMedisDouble() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL belum diset di .env!");
  if (token == null || token.isEmpty)
    throw Exception("Token login belum ditemukan, silakan login ulang!");

  final url = Uri.parse('$apiUrl/EmrCatatanMedis/LookupCekCatatanMedisDouble');
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal mengambil data');
  }
  throw Exception('Error status ${response.statusCode}');
}

// Fetch detail catatan medis by noreg
Future<List<Map<String, dynamic>>> fetchCatatanMedisByReg(String noreg) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL belum diset di .env!");
  if (token == null || token.isEmpty)
    throw Exception("Token login belum ditemukan, silakan login ulang!");

  final url = Uri.parse('$apiUrl/EmrCatatanMedis/ReadCatatanByReg/$noreg');
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal mengambil data catatan medis');
  }
  throw Exception('Error status ${response.statusCode}');
}

// Hapus catatan medis by ID
Future<void> deleteCatatanMedisById(String noreg, int id) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty)
    throw Exception("API URL belum diset di .env!");
  if (token == null || token.isEmpty)
    throw Exception("Token login belum ditemukan, silakan login ulang!");

  final url = Uri.parse('$apiUrl/EmrCatatanMedis/HapusIdDouble/$noreg/$id');
  final response = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['statusCode'] == 200) {
    return;
  }
  throw Exception(data['message'] ?? 'Gagal menghapus catatan medis');
}
