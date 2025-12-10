// config/router.dart
import 'package:fisiovision/providers/auth_provider.dart';
import 'package:fisiovision/screens/exercises/exercise_form.dart';
import 'package:fisiovision/screens/exercises/exercise_sreen.dart';
import 'package:fisiovision/screens/login/login_screen.dart';
import 'package:fisiovision/screens/patient/patient_detail_screen.dart';
import 'package:fisiovision/screens/patient/patient_form_screen.dart';
import 'package:fisiovision/screens/patient/patient_screen.dart';
import 'package:fisiovision/screens/patient/routine-assignment/routineAssigmentScreen.dart';
import 'package:fisiovision/screens/view_patient/patient/connection_web.dart';
import 'package:fisiovision/screens/view_patient/patient/laptop_feedback.dart';
import 'package:fisiovision/screens/view_patient/patient/mobile_camera_view.dart';
import 'package:fisiovision/screens/view_patient/patient/patient_home_screen.dart';
import 'package:fisiovision/models/sesion_model.dart';
import 'package:fisiovision/screens/view_patient/patient/session_analysis_screen.dart';
import 'package:fisiovision/screens/view_patient/patient/session_history_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

// Provider del router que depende del estado de autenticación
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      // Si no está logueado y no va al login, redirigir al login
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // Si está logueado y está en el login, redirigir según tipo de usuario
      if (isLoggedIn && isGoingToLogin) {
        final user = authState.user;
        if (user != null) {
          return user.isTerapeuta ? '/pacientes' : '/home';
        }
      }

      // No hay redirect necesario
      return null;
    },
    routes: [
      // RUTA DE AUTENTICACIÓN (Login/Register)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // RUTA PARA TERAPEUTAS
      GoRoute(
        path: '/pacientes',
        builder: (context, state) => const PatientScreen(),
      ),
      GoRoute(
        path: '/paciente/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;

          return PatientDetailScreen(pacienteId: int.parse(id));
        },
      ),
      GoRoute(
        path: '/paciente/nuevo',
        builder: (context, state) => const PatientFormScreen(),
      ),
      GoRoute(
        path: '/asignacion-rutina',
        builder: (context, state) => const RoutineAssignmentScreen(),
      ),

      // RUTA PARA PACIENTES
      GoRoute(
        path: '/home',
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: '/connect-device',
        builder: (context, state) {
          final sesion = state.extra as SesionResponse?;
          return ConnectDeviceView(sesion: sesion);
        },
      ),
      GoRoute(
        path: '/camera-mobile',
        builder: (context, state) => const MobileCameraView(),
      ),
      GoRoute(
        path: '/laptop-feedback',
        builder: (context, state) => const LaptopFeedbackView(),
      ),

      // RUTAS DE EJERCICIOS
      GoRoute(
        path: '/ejercicios',
        builder: (context, state) => const ExercisesScreen(),
      ),
      GoRoute(
        path: '/ejercicio/nuevo',
        builder: (context, state) => const ExerciseFormScreen(),
      ),
    ],
  );
});

// Mantén también esta versión para compatibilidad
// pero ahora usa el routerProvider en main.dart
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // RUTA DE AUTENTICACIÓN (Login/Register)
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/paciente/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        return PatientDetailScreen(pacienteId: int.parse(id));
      },
    ),
    // RUTA PARA TERAPEUTAS
    GoRoute(
      path: '/pacientes',
      builder: (context, state) => const PatientScreen(),
    ),
    GoRoute(
      path: '/paciente/nuevo',
      builder: (context, state) => const PatientFormScreen(),
    ),
    GoRoute(
      path: '/asignacion-rutina',
      builder: (context, state) => const RoutineAssignmentScreen(),
    ),

    // RUTA PARA PACIENTES
    GoRoute(
      path: '/home',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/connect-device',
      builder: (context, state) {
        final sesion = state.extra as SesionResponse?;
        return ConnectDeviceView(sesion: sesion);
      },
    ),
    GoRoute(
      path: '/camera-mobile',
      builder: (context, state) => const MobileCameraView(),
    ),
    GoRoute(
      path: '/laptop-feedback',
      builder: (context, state) => const LaptopFeedbackView(),
    ),
    GoRoute(
      path: '/historial',
      builder: (context, state) => const SessionHistoryScreen(),
    ),
    // RUTAS DE EJERCICIOS
    GoRoute(
      path: '/ejercicios',
      builder: (context, state) => const ExercisesScreen(),
    ),
    GoRoute(
      path: '/ejercicio/nuevo',
      builder: (context, state) => const ExerciseFormScreen(),
    ),
    GoRoute(
      path: '/sesionanalisis',
      builder: (context, state) => const SessionAnalysisScreen(),
    ),
  ],
);
