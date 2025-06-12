import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

Future<String?> getApiUrl() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('apiUrl');
}
