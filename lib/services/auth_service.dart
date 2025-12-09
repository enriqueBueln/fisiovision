// src/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth_model.dart';

class AuthService {
  // Obtener la URL base desde el archivo .env
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http://localhost:8000';

  // Guardar token en localStorage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Obtener token del localStorage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Guardar usuario completo
  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Obtener usuario guardado
  Future<AuthUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return AuthUser.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Eliminar token y datos de usuario
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // REGISTRO
  Future<RegisterResponse> register(
    RegisterRequest request,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/register');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final error = ValidationError.fromJson(
          jsonDecode(response.body),
        );
        throw Exception(error.message);
      } else {
        throw Exception(
          'Error al registrar: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // LOGIN
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/login');

      // El endpoint espera application/x-www-form-urlencoded
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'password',
          'username': request.username,
          'password': request.password,
          'scope': '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // Guardar token
        await saveToken(loginResponse.accessToken);

        // Guardar usuario
        final user = AuthUser.fromLoginResponse(loginResponse);
        await saveUser(user);

        return loginResponse;
      } else if (response.statusCode == 422) {
        final error = ValidationError.fromJson(
          jsonDecode(response.body),
        );
        throw Exception(error.message);
      } else if (response.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos');
      } else {
        throw Exception(
          'Error al iniciar sesión: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains(
        'Email o contraseña incorrectos',
      )) {
        rethrow;
      }
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener usuario actual desde el token almacenado
  Future<AuthUser?> getCurrentUser() async {
    return await getUser();
  }

  // Hacer peticiones autenticadas
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
}
