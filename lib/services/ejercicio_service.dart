import 'dart:convert';
import 'package:fisiovision/config/token.dart';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

class EjercicioService {
  static String get baseUrl =>
      // ignore: prefer_adjacent_string_concatenation
      dotenv.env['DATABASE_URL'] ?? 'http:///192.168.100.7:8000' + '/api/v1';

  // GET: Obtener pacientes
  Future<List<Ejercicio>> getEjercicios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/ejercicios'),
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
      Uri.parse('$baseUrl/api/v1/ejercicios'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(ejercicio),
    );
  }
  Future<Ejercicio> getEjercicioById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/ejercicios/$id'),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Ejercicio.fromJson(data);
    } else {
      throw Exception('Error al cargar ejercicio con ID $id');
    }
  }
}

final ejercicioServiceProvider = Provider((ref) => EjercicioService());
