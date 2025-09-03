import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Helper ambil token login
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

// 🔹 Ambil semua IP
Future<List<Map<String, dynamic>>> fetchIpAll() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || apiUrl.isEmpty) throw Exception("API URL belum diset!");
  if (token == null || token.isEmpty) throw Exception("Token tidak ditemukan!");

  final url = Uri.parse('$apiUrl/SisJwt/GetIpAll');
  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal ambil data');
  }
  throw Exception('Error ${res.statusCode}');
}

// 🔹 Ambil IP by Ruang
Future<List<Map<String, dynamic>>> fetchIpByRuang(String ruangId) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/GetIpByRuang/$ruangId');
  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal ambil data');
  }
  throw Exception('Error ${res.statusCode}');
}

// 🔹 Ambil list ruangan
Future<List<Map<String, dynamic>>> fetchRuangan() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/GetRuangan/%20');
  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal ambil data');
  }
  throw Exception('Error ${res.statusCode}');
}

// 🔹 Post / Aktivasi / NonAktivasi CORS
Future<bool> postCors(String ip) async => _postCorsAction("PostCors", ip);
Future<bool> aktifCors(String ip) async => _postCorsAction("AktivasiCors", ip);
Future<bool> inaktifCors(String ip) async => _postCorsAction("InAktivasi", ip);

Future<bool> _postCorsAction(String endpoint, String ip) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/$endpoint');
  final res = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({"ipComputer": ip}),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data['statusCode'] == 200;
  }
  return false;
}

// 🔹 Cari IP/MAC
Future<List<Map<String, dynamic>>> fetchIpMac(String ip, String mac) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/GetIPMac/$ip/$mac');
  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    if (data['statusCode'] == 200) {
      return List<Map<String, dynamic>>.from(data['result']);
    }
    throw Exception(data['message'] ?? 'Gagal ambil data');
  }
  throw Exception('Error ${res.statusCode}');
}

// 🔹 Delete IP/MAC
Future<bool> deleteIpMac(String ip, String mac) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/DeleteIPMac/$ip/$mac');
  final res = await http.delete(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data['statusCode'] == 200;
  }
  return false;
}

// 🔹 Tambah IP/MAC
Future<bool> postIpMac({
  required String ip,
  required String mac,
  required String ruangId,
  required String keterangan,
}) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await getToken();
  if (apiUrl == null || token == null) throw Exception("Config belum siap!");

  final url = Uri.parse('$apiUrl/SisJwt/PostIPMac');
  final res = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "ipComputer": ip,
      "macAddress": mac,
      "ruangId": ruangId,
      "keterangan": keterangan,
    }),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    return data['statusCode'] == 200;
  }
  return false;
}
