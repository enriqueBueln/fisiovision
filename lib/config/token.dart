import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance(); // Obtiene una instancia
  await prefs.setString(key, value); // Guarda el string
}

Future<String> getData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? ''; // Devuelve el valor o un string vacío si no existe
}


Future<int> getIdUsuario() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null || token.isEmpty) return 0;
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  print("Decoded Token: $decodedToken");
  // Suponiendo que el id de usuario está en el campo 'id' del payload
  return decodedToken['id'] is int ? decodedToken['id'] : int.tryParse(decodedToken['id'].toString()) ?? 0;
}