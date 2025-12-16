import 'dart:convert';
import 'package:fisiovision/config/token.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import '../models/paciente_model.dart';

class PacienteService {
  static String get baseUrl =>
      // ignore: prefer_adjacent_string_concatenation
      dotenv.env['DATABASE_URL'] ?? 'http:///192.168.100.7:8000' + '/api/v1';

  // GET: Obtener pacientes
  Future<List<Paciente>> getPacientes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pacientes'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await getData('access_token')}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Mapeamos la lista de JSONs a lista de Objetos Paciente
      return data.map((json) => Paciente.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pacientes');
    }
  }

  Future<Paciente> getPacienteById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pacientes/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await getData('access_token')}",
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Paciente.fromJson(data);
    } else {
      throw Exception('Error al cargar paciente con ID $id');
    }
  }

  // POST: Crear paciente (o enviar video más adelante)
  Future<void> addPaciente(Paciente paciente) async {
    String token = await getData('access_token');
    print('Token obtenido en addPaciente: $token');
    print('Enviando paciente: ${paciente.toJson()}');
    final response = await http.post(
      Uri.parse('$baseUrl/pacientes'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(paciente.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar paciente: ${response.body}');
    }
  }
}

final pacienteServiceProvider = Provider((ref) => PacienteService());
