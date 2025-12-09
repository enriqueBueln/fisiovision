import 'dart:convert';
import 'package:fisiovision/models/ejercicio_asignado.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RutinasService {
  final String baseUrl = "https://tu-api.com/api";

  // POST: Asignar una lista de ejercicios a un paciente
  Future<void> asignarRutina(List<EjercicioAsignado> asignaciones) async {
    // Si tu backend soporta "Batch Insert" (insertar varios de golpe):
    final response = await http.post(
      Uri.parse('$baseUrl/ejercicios-asignados/batch'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(asignaciones.map((e) => e.toJson()).toList()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al asignar rutina');
    }
  }
}

final rutinasServiceProvider = Provider((ref) => RutinasService());
