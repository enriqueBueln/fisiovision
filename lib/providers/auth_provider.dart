// src/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

// Instancia del servicio
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

// Estado de autenticación
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Notifier para manejar la autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());
  // ⬆️ REMOVIDO _checkAuth() del constructor

  // REGISTRO
  Future<bool> register({
    required String name,
    required String secondName,
    required String email,
    required String password,
    int? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        name: name,
        secondName: secondName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      await _authService.register(request);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(
        username: email,
        password: password,
      );

      final response = await _authService.login(request);
      final user = AuthUser.fromLoginResponse(response);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider principal de autenticación
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthNotifier(authService);
    });
