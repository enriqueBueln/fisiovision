import 'dart:convert';
import 'package:fisiovision/config/token.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import '../models/paciente_model.dart';

class PacienteService {
  final String baseUrl = "http://localhost:8000/api/v1"; // Cambiar por la URL real de la API

  // GET: Obtener pacientes
  Future<List<Paciente>> getPacientes() async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Mapeamos la lista de JSONs a lista de Objetos Paciente
      return data.map((json) => Paciente.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pacientes');
    }
  }

  // POST: Crear paciente (o enviar video más adelante)
  Future<void> addPaciente(Paciente paciente) async {
    String token = await getData('access_token');
    print('Token obtenido en addPaciente: $token');
    await http.post(
      Uri.parse('$baseUrl/pacientes'),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: json.encode(paciente.toJson()),
    );
  }
}

final pacienteServiceProvider = Provider((ref) => PacienteService());
