import 'dart:convert';
import 'package:fisiovision/models/patients_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:fisiovision/config/token.dart';

class AssignedExerciseService {
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http:///192.168.100.7:8000';

  Future<List<AssignedExerciseModel>> getAssignedExercises({
    int skip = 0,
    int limit = 100,
    bool activeOnly = true,
  }) async {
    try {
      final token = await getData('access_token');

      if (token.isEmpty) {
        throw Exception(
          'No se encontró el token de autenticación',
        );
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/ejercicios-asignados/?skip=$skip&limit=$limit&active_only=$activeOnly',
      );

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => AssignedExerciseModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Token de autenticación inválido o expirado',
        );
      } else {
        throw Exception(
          'Error al obtener ejercicios: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
