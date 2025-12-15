// src/services/analysis_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_model.dart';
import '../services/auth_service.dart';

class AnalysisService {
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http://192.168.100.7:8000';

  final AuthService _authService = AuthService();

  // Analizar sesión con Prolog
  Future<AnalysisResponse> analyzeSesion(int idSesion) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse(
        '$baseUrl/api/v1/prolog/sesion/$idSesion/analizar',
      );

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalysisResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception(
          'No autenticado. Por favor, inicia sesión nuevamente.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Sesión no encontrada.');
      } else {
        throw Exception(
          'Error al analizar la sesión: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }
}
