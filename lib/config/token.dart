import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance(); // Obtiene una instancia
  await prefs.setString(key, value); // Guarda el string
}

Future<String> getData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? ''; // Devuelve el valor o un string vacío si no existe
}