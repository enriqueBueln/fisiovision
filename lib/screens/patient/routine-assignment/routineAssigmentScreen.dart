import 'package:fisiovision/models/paciente_model.dart';
import 'package:fisiovision/screens/patient/routine-assignment/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// [AQUÍ VA LA DEFINICIÓN DE LOS PROVIDERS Y MODELOS SIMULADOS DE ARRIBA]

class RoutineAssignmentScreen extends ConsumerWidget {
  const RoutineAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Rutina'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN 1: SELECCIÓN DEL PACIENTE ---
            Text(
              "Paso 1: Selecciona el Paciente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            
            _PatientSelectionCard(
              selectedPatient: routineState.selectedPatient,
              onSelect: () => _showPatientSelectionModal(context, ref),
            ),
            
            const SizedBox(height: 30),

            // --- SECCIÓN 2: EJERCICIOS ASIGNADOS ---
            Text(
              "Paso 2: Agrega Ejercicios (${routineState.exercises.length})",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),

            _AssignedExercisesList(exercises: routineState.exercises),

            const SizedBox(height: 20),

            // BOTÓN PARA AGREGAR EJERCICIO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: routineState.selectedPatient == null
                    ? null // Deshabilitado si no hay paciente
                    : () => _showExerciseSelectionModal(context, ref),
                icon: const Icon(Icons.fitness_center),
                label: const Text('AGREGAR EJERCICIO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // --- BOTÓN FINAL DE GUARDADO ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (routineState.selectedPatient != null && routineState.exercises.isNotEmpty)
                    ? () => ref.read(routineProvider.notifier).saveRoutine()
                    : null, // Deshabilitado si falta algo
                child: const Text('GUARDAR RUTINA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Función para mostrar el modal de selección de Paciente
  void _showPatientSelectionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PatientSelectionModal(ref: ref),
    );
  }

  // Función para mostrar el modal de selección de Ejercicio
  void _showExerciseSelectionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExerciseSelectionModal(ref: ref),
    );
  }
}



class _PatientSelectionCard extends StatelessWidget {
  final Paciente? selectedPatient;
  final VoidCallback onSelect;

  const _PatientSelectionCard({required this.selectedPatient, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          selectedPatient == null ? Icons.person_add_alt : Icons.person,
          color: selectedPatient == null ? Colors.grey : Colors.teal,
          size: 30,
        ),
        title: Text(
          selectedPatient == null ? "Seleccionar Paciente" : selectedPatient!.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedPatient == null ? Colors.grey : Colors.black87,
            fontSize: 16
          ),
        ),
        subtitle: selectedPatient == null ? const Text("Requerido para asignar rutina.") : null,
        trailing: const Icon(Icons.edit, color: Colors.grey),
        onTap: onSelect,
      ),
    );
  }
}
class _PatientSelectionModal extends StatelessWidget {
  final WidgetRef ref;
  const _PatientSelectionModal({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Pacientes Disponibles', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: dummyPatients.length,
              itemBuilder: (context, index) {
                final patient = dummyPatients[index];
                return ListTile(
                  title: Text(patient.nombre),
                  leading: const Icon(Icons.person_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(routineProvider.notifier).selectPatient(patient);
                    Navigator.pop(context); // Cerrar modal
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class _AssignedExercisesList extends StatelessWidget {
  final List<AssignedExerciseDetail> exercises;

  const _AssignedExercisesList({required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey.shade50,
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text("Aún no hay ejercicios asignados.", style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Evitar scroll anidado
        itemCount: exercises.length,
        separatorBuilder: (c, i) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = exercises[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              child: Icon(Icons.directions_run),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${item.series} series de ${item.reps} repeticiones"),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () {
              // Lógica para editar o eliminar ejercicio
            },
          );
        },
      ),
    );
  }
}class _ExerciseSelectionModal extends StatelessWidget {
  final WidgetRef ref;
  const _ExerciseSelectionModal({required this.ref});

  // Simulamos la lista de ejercicios disponibles
  final List<String> availableExercises = const [
    'Sentadilla', 'Puente de Glúteo', 'Elevación Lateral', 'Zancadas', 'Plancha'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Biblioteca de Ejercicios', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exerciseName = availableExercises[index];
                return ListTile(
                  title: Text(exerciseName),
                  subtitle: const Text("Toca para agregar y configurar"),
                  leading: const Icon(Icons.run_circle_outlined),
                  onTap: () {
                    // **Buena Práctica:** En una app real, aquí abrirías otro modal
                    // o diálogo para configurar series y repeticiones.
                    
                    // Simplificación: Agregamos con valores por defecto
                    ref.read(routineProvider.notifier).addExercise(
                      AssignedExerciseDetail(
                        exerciseId: 'EX$index', 
                        name: exerciseName, 
                        series: 3, 
                        reps: 10
                      )
                    );
                    Navigator.pop(context); // Cerrar modal principal
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}