import 'package:client/services/theme_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<bool> {
  final ThemeService _themeService;

  ThemeCubit(this._themeService) : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    emit(await _themeService.isDarkMode);
  }

  Future<void> toggleTheme(bool isDark) async {
    await _themeService.setDarkMode(isDark);
    emit(isDark);
  }
}