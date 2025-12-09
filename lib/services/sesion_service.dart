import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sesion_model.dart';

class SesionService {
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http://localhost:8000';

  // Obtener token del localStorage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Crear headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Iniciar una nueva sesión de ejercicio
  /// POST /sesion/start
  Future<SesionResponse> startSesion(SesionCreate sesionData) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/v1/sesiones/start');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(sesionData.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SesionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Ejercicio no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Finalizar una sesión de ejercicio
  /// PUT /sesion/{id}/end
  Future<SesionResponse> endSesion(int sesionId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/v1/sesiones/$sesionId/end');

      final response = await http.put(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SesionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Sesión no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al finalizar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener sesión activa para un ejercicio específico
  /// GET /sesion/active/{id_ejercicio}
  Future<SesionResponse?> getActiveSesion(int idEjercicio) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/v1/sesiones/active/$idEjercicio');

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SesionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No hay sesión activa
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener historial de sesiones del paciente
  /// GET /sesion/history
  Future<List<SesionResponse>> getSesionHistory() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/v1/sesiones/history');

      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SesionResponse.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener historial');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
