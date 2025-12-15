// services/session_history_service.dart
import 'dart:convert';
import 'package:fisiovision/models/sesion_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:fisiovision/services/auth_service.dart';

class SessionHistoryService {
  final String baseUrl = 'http:///192.168.100.7:8000/api/v1';
  final AuthService _authService = AuthService();

  Future<List<SessionHistoryModel>> getSessions({
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sesiones?skip=$skip&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => SessionHistoryModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente',
        );
      } else {
        throw Exception(
          'Error al obtener el historial: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<SessionHistoryModel?> getSessionById(int id) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sesiones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return SessionHistoryModel.fromJson(
          json.decode(response.body),
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Error al obtener la sesión: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
