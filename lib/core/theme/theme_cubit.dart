import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<String> {
  // Themes: 'dark', 'light', 'pink', 'red', 'silver'
  ThemeCubit() : super('dark');

  static const String _themeKey = 'custom_theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey) ?? 'dark';
    emit(savedTheme);
  }

  Future<void> setTheme(String modeStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, modeStr);
    emit(modeStr);
  }
}