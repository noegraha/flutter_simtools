import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart'; // Import LoginPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

enum AppThemeMode { system, light, dark }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppThemeMode _appThemeMode = AppThemeMode.system;

  // Helper: konversi ke ThemeMode
  ThemeMode get _themeMode {
    switch (_appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  void _setAppThemeMode(AppThemeMode mode) {
    print('🎨 Changing theme from $_appThemeMode to $mode');
    setState(() {
      _appThemeMode = mode;
    });
    print('✅ Theme changed to $_appThemeMode, ThemeMode: $_themeMode');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIM Tools',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      // App akan selalu masuk ke LoginPage terlebih dahulu
      home: LoginPage(
        appThemeMode: _appThemeMode,
        onChangeThemeMode: _setAppThemeMode,
      ),
    );
  }
}
