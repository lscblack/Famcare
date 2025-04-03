import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _key = 'isDarkMode';

  Future<bool> get isDarkMode async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }
}