import 'package:fisiovision/screens/exercises/exercise_form.dart';
import 'package:fisiovision/screens/exercises/exercise_sreen.dart';
import 'package:fisiovision/screens/login/login_screen.dart';
import 'package:fisiovision/screens/patient/patient_form_screen.dart';
import 'package:fisiovision/screens/patient/patient_screen.dart';
import 'package:fisiovision/screens/patient/routine-assignment/routineAssigmentScreen.dart';
import 'package:fisiovision/screens/view_patient/patient/connection_web.dart';
import 'package:fisiovision/screens/view_patient/patient/laptop_feedback.dart';
import 'package:fisiovision/screens/view_patient/patient/mobile_camera_view.dart';
import 'package:fisiovision/screens/view_patient/patient/patient_home_screen.dart';
import 'package:go_router/go_router.dart';
// Importa tus pantallas

final appRouter = GoRouter(
  initialLocation: '/pacientes',
  routes: [
    GoRoute(
      path: '/asignacion-rutina',
      builder: (context, state) {
        return const RoutineAssignmentScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // RUTA 1: Pacientes
    GoRoute(
      path: '/laptop-feedback',
      builder: (context, state) {
        return const LaptopFeedbackView();
      },
    ),
    GoRoute(
      path: '/camera-mobile',
      builder: (context, state) {
        return const MobileCameraView();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/connect-device',
      builder: (context, state) {
        return const ConnectDeviceView();
      },
    ),
    GoRoute(
      path: '/pacientes',
      builder: (context, state) => const PatientScreen(),
    ),
    GoRoute(
      path: '/paciente/nuevo',
      builder: (context, state) {
        // Aquí iría la pantalla para agregar un nuevo paciente
        return const PatientFormScreen();
      },
    ),
    // RUTA 2: Ejercicios (Ejemplo)
    GoRoute(
      path: '/ejercicios',
      builder: (context, state) =>
          const ExercisesScreen(), // Asumiendo que harás esta
    ),
    GoRoute(
      path: '/ejercicio/nuevo',
      builder: (context, state) {
        // Aquí iría la pantalla para agregar un nuevo ejercicio
        return const ExerciseFormScreen(); // Placeholder
      },
    ),
  ],
);
