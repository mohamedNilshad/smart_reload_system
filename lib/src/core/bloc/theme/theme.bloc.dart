import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme.event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode>{
  ThemeBloc(super.initialState){
    on<ChangeThemeEvent>(_onToggleTheme);
  }
  Future<void> _onToggleTheme(ChangeThemeEvent event, Emitter<ThemeMode> emit) async {
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      await _saveThemePreference(true);
    } else {
      emit(ThemeMode.light);
      await _saveThemePreference(false);
    }
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }
}