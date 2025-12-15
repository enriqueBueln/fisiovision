import 'dart:convert';
import 'package:fisiovision/config/token.dart';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

class EjercicioService {
  final String baseUrl = "http://localhost:8000/api/v1";

  // GET: Obtener pacientes
  Future<List<Ejercicio>> getEjercicios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ejercicios'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await getData('access_token')}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Mapeamos la lista de JSONs a lista de Objetos Ejercicio
      return data.map((json) => Ejercicio.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar ejercicios');
    }
  }

  // POST: Crear ejercicio (o enviar video más adelante)
  Future<void> addEjercicio(Ejercicio ejercicio) async {
    String token = await getData('access_token');
    print(ejercicio.toString());
    await http.post(
      Uri.parse('$baseUrl/ejercicios'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(ejercicio),
    );
  }
}

final ejercicioServiceProvider = Provider((ref) => EjercicioService());
