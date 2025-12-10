import 'dart:convert';
import 'package:fisiovision/config/token.dart';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:http/http.dart' as http;

// --- SERVICIO ---
class RutinaService {
  final String baseUrl = "http://localhost:8000/api/v1";

  // Obtener los ejercicios asignados a un paciente específico
  Future<List<Ejercicio>> getRutinaPaciente(int idPaciente) async {
    // Ajusta el endpoint según tu backend real
    final response = await http.get(
      Uri.parse('$baseUrl/ejercicios-asignados/paciente/$idPaciente'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await getData('access_token')}",
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Rutina data: $data");
      return data.map((json) => Ejercicio.fromJson(json['ejercicio'])).toList();
    }
    return []; // Retorna lista vacía si falla o no hay nada por ahora
  }

  // Asignar un ejercicio existente a un paciente
  Future<void> asignarEjercicio(
    int idPaciente,
    int idEjercicio,
    int asignedBy,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ejercicios-asignados/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await getData('access_token')}",
        },
        body: json.encode({
          "id_paciente": idPaciente,
          "id_ejercicio": idEjercicio,
          "assigned_by": asignedBy,
          "date_assigned": DateTime.now().toString().split(' ')[0],
          "notes": "No notas",
          "is_active": true,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Error al asignar ejercicio: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Error de conexión: $e');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
