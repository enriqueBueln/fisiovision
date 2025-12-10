// src/services/profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';

class ProfileService {
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http://localhost:8000';

  final AuthService _authService = AuthService();

  // Obtener información del paciente autenticado
  Future<PatientProfileModel> getPatientInfo() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final url = Uri.parse('$baseUrl/api/v1/auth/pacientes');

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PatientProfileModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception(
          'No autenticado. Por favor, inicia sesión nuevamente.',
        );
      } else {
        throw Exception(
          'Error al obtener la información del paciente: ${response.statusCode}',
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
