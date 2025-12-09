import 'dart:convert';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
class EjercicioService {
  final String baseUrl = "https://tu-api.com/api";

  // GET: Obtener pacientes
  Future<List<Ejercicio>> getEjercicios() async {
    final response = await http.get(Uri.parse('$baseUrl/ejercicios'));

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
    await http.post(
      Uri.parse('$baseUrl/ejercicios'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(ejercicio.toJson()),
    );
  }
}

final ejercicioServiceProvider = Provider((ref) => EjercicioService());
