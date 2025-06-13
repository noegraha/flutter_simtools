import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'main.dart'; // Agar dapat akses AppThemeMode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _loading = false;
  String? _error;

  // Fungsi reverse string (membalik kata)
  String reverseString(String word) {
    return word.split('').reversed.join('');
  }

  // Fungsi enkrip sesuai JS pada repo SmartMedika
  String enkrip(String wd) {
    String balik = reverseString(wd);
    List<String> kata = balik.split('');
    List<String> s = [];
    for (var i = 0; i < kata.length; i++) {
      int code = kata[i].codeUnitAt(0);
      if (code < 79) {
        s.add(String.fromCharCode(code + 47));
      } else {
        s.add(String.fromCharCode(code - 47));
      }
    }
    return s.join('');
  }

  Future<void> saveLoginSession({
    required String token,
    // ...tambahkan parameter lain kalau perlu
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final nama = _usernameController.text.toUpperCase();
    final pass = _passwordController.text;

    final encryptedUsername = enkrip(nama);
    final encryptedPassword = enkrip(pass);
    final apiUrl = dotenv.env['API_URL']!;
    final url = Uri.parse('$apiUrl/sisJwt');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': encryptedUsername,
          'password': encryptedPassword,
        }),
      );

      print("Login raw response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'userName',
          nama,
        ); // username sesuai input login user
        // Cek key token, sesuaikan dengan struktur API
        var token = responseData['token'];
        if (token == null && responseData['result'] != null) {
          // Jika nested
          token = responseData['result']['token'];
        }

        // Cek null dan pastikan String
        if (token == null || token is! String || token.isEmpty) {
          setState(
            () => _error = "Login gagal: Token tidak ditemukan di response!",
          );
          setState(() {
            _loading = false;
          });
          return;
        }

        await saveLoginSession(token: token);
        print('Result login: $responseData');

        if (responseData['statusCode'] == 200 || token != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berhasil Login!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(
                  appThemeMode: AppThemeMode.system,
                  onChangeThemeMode: (val) {},
                ),
              ),
            );
          }
        } else {
          setState(() => _error = responseData['message'] ?? 'Login gagal');
        }
      } else {
        setState(() => _error = 'Login gagal: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background blur
          Image.asset('assets/rsms_blur.jpg', fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          // Card login
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/companylogo.png', height: 48),

                    const SizedBox(height: 24),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'RSMS - SmartMedika 2025',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      'Version : 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
