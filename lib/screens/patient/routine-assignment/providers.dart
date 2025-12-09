import 'package:fisiovision/models/paciente_model.dart';
import 'package:riverpod/legacy.dart';

class AssignedExerciseDetail {
  final String exerciseId;
  final String name;
  final int series;
  final int reps;
  AssignedExerciseDetail({
    required this.exerciseId,
    required this.name,
    this.series = 3,
    this.reps = 10,
  });
}

// Estado de la Rutina en curso
class RoutineState {
  final Paciente? selectedPatient;
  final List<AssignedExerciseDetail> exercises;
  RoutineState({this.selectedPatient, this.exercises = const []});

  RoutineState copyWith({
    Paciente? selectedPatient,
    List<AssignedExerciseDetail>? exercises,
  }) {
    return RoutineState(
      selectedPatient: selectedPatient ?? this.selectedPatient,
      exercises: exercises ?? this.exercises,
    );
  }
}

final routineProvider =
    StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
      return RoutineNotifier();
    });

class RoutineNotifier extends StateNotifier<RoutineState> {
  RoutineNotifier() : super(RoutineState());

  void selectPatient(Paciente patient) {
    state = RoutineState(
      selectedPatient: patient,
      exercises: state.exercises,
    );
  }

  void addExercise(AssignedExerciseDetail exercise) {
    state = RoutineState(
      selectedPatient: state.selectedPatient,
      exercises: [...state.exercises, exercise],
    );
  }

  // Lógica para guardar la rutina y resetear el estado
  void saveRoutine() {
    print(
      "Guardando rutina para ${state.selectedPatient?.nombre} con ${state.exercises.length} ejercicios.",
    );
    // Aquí iría la llamada a tu API
    state = RoutineState(); // Resetear
  }

  void removeExercise(int index) {
    state = state.copyWith(
      exercises: List.from(state.exercises)..removeAt(index),
    );
  }
}

// Datos de ejemplo
final List<Paciente> dummyPatients = [
  Paciente(id: 1, nombre: 'Enrique', apellido: 'Buelna', email: 'enrique@gmail.com', fechaNacimiento: DateTime.parse('1900-01-01'), genero: 'M', idUsuario: 1)
];
