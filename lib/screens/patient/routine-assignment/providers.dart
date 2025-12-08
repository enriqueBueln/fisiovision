
import 'package:fisiovision/models/paciente_model.dart';
import 'package:riverpod/legacy.dart';

class AssignedExerciseDetail {
  final String exerciseId;
  final String name;
  final int series;
  final int reps;
  AssignedExerciseDetail({required this.exerciseId, required this.name, this.series = 3, this.reps = 10});
}

// Estado de la Rutina en curso
class RoutineState {
  final Paciente? selectedPatient;
  final List<AssignedExerciseDetail> exercises;
  RoutineState({this.selectedPatient, this.exercises = const []});
}

final routineProvider = StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  return RoutineNotifier();
});

class RoutineNotifier extends StateNotifier<RoutineState> {
  RoutineNotifier() : super(RoutineState());

  void selectPatient(Paciente patient) {
    state = RoutineState(selectedPatient: patient, exercises: state.exercises);
  }

  void addExercise(AssignedExerciseDetail exercise) {
    state = RoutineState(
      selectedPatient: state.selectedPatient,
      exercises: [...state.exercises, exercise]
    );
  }
  // Lógica para guardar la rutina y resetear el estado
  void saveRoutine() {
    print("Guardando rutina para ${state.selectedPatient?.nombre} con ${state.exercises.length} ejercicios.");
    // Aquí iría la llamada a tu API
    state = RoutineState(); // Resetear
  }
}

// Datos de ejemplo
final List<Paciente> dummyPatients = [
  Paciente(id: 'P001', nombre: 'Elena Rodríguez',),
  Paciente(id: 'P002', nombre: 'Carlos López'),
  Paciente(id: 'P003', nombre: 'María García'),
];