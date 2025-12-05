import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clave para guardar la preferencia del tema
const String _themePreferenceKey = 'is_dark_mode';

// Provider para controlar el estado del tema con persistencia
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Provider para obtener el ThemeData actual basado en el modo
final appThemeProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(themeNotifierProvider);
  return isDarkMode ? AppTheme.darkTheme() : AppTheme.lightTheme();
});

// Notifier que maneja el estado del tema con persistencia
class ThemeNotifier extends StateNotifier<bool> {
  // Iniciamos con modo oscuro en false (tema claro)
  ThemeNotifier() : super(false) {
    // Cargamos la preferencia guardada al iniciar
    _loadPreference();
  }

  // Carga la preferencia guardada
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    state = isDarkMode;
  }

  // Guarda la preferencia actual
  Future<void> _savePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  // Método para cambiar el tema
  void toggleTheme() {
    state = !state;
    _savePreference(state);
  }

  // Método para establecer un tema específico
  void setDarkMode(bool isDark) {
    state = isDark;
    _savePreference(state);
  }
}

// Clase principal de temas de la aplicación
class AppTheme {
  // Constantes comunes
  static const _fontFamily = 'MiFuente';

  // Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      colorSchemeSeed: Colors.blue,
      fontFamily: _fontFamily,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      brightness: Brightness.light,
    );
  }

  // Tema oscuro
  static ThemeData darkTheme() {
    return ThemeData(
      colorSchemeSeed: Colors.blue,
      fontFamily: _fontFamily,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      brightness: Brightness.dark,
    );
  }
}
