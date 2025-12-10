import 'package:fisiovision/providers/ejercicios_provider.dart';
import 'package:fisiovision/screens/exercises/exercise_detail_modal.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:fisiovision/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>(); // Necesitas una key local

    return ScaffoldSideMenu(
      title: "Biblioteca de Ejercicios",
      subtitle: "Crea, edita y gestiona las rutinas de rehabilitación.",

      buttonText: "Crear Nuevo Ejercicio",
      buttonIcon: const Icon(Icons.add),
      onButtonPressed: () {
        context.go('/ejercicio/nuevo');
      },

      drawer: SideMenu(scaffoldKey: scaffoldKey), // Pasamos la key al SideMenu

      body: const ExercisesView(), // El contenido principal
    );
  }
}

class ExercisesView extends ConsumerWidget {
  const ExercisesView({super.key});

  // Función de utilidad para obtener el color del tipo de ejercicio
  Color _getTypeColor(String type) {
    switch (type) {
      case 'fuerza':
        return Colors.red;
      case 'rotacion':
        return Colors.blue;
      case 'movilidad':
        return Colors.green;
      case 'equilibrio':
        return Colors.orange;
      case 'extension':
        return Colors.purple;
      case 'flexion':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Función de utilidad para obtener el texto del tipo de ejercicio
  String _getTypeText(String type) {
    switch (type) {
      case 'fuerza':
        return 'Fuerza 💪';
      case 'rotacion':
        return 'Rotación 🌀';
      case 'movilidad':
        return 'Movilidad 🤸';
      case 'equilibrio':
        return 'Equilibrio ⚖️';
      case 'extension':
        return 'Extensión ↗️';
      case 'flexion':
        return 'Flexión ↘️';
      default:
        return 'Otro';
    }
  }

  // Función de utilidad para obtener el icono del tipo
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'fuerza':
        return Icons.fitness_center;
      case 'rotacion':
        return Icons.directions_run;
      case 'movilidad':
        return Icons.accessibility_new;
      case 'equilibrio':
        return Icons.balance;
      case 'flexion':
        return Icons.rotate_right;
      case 'extension':
        return Icons.open_in_full;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejerciciosAsync = ref.watch(ejerciciosProvider);

    return ejerciciosAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),

      error: (e, _) => Center(child: Text("Error al cargar: $e")),

      data: (ejercicios) {
        if (ejercicios.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No hay ejercicios registrados"),
            ),
          );
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(top: 10),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: ejercicios.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final exercise = ejercicios[index];
              final typeColor = _getTypeColor(exercise.type);
              print(exercise.type);
              final typeIcon = _getTypeIcon(exercise.type);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  backgroundColor: typeColor.withOpacity(0.15),
                  foregroundColor: typeColor,
                  radius: 24,
                  child: Icon(typeIcon, size: 26),
                ),
                title: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeText(exercise.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Reps: ${exercise.repetitions} • Series: ${exercise.series}'
                      '${exercise.duration_seconds > 0 ? ' • ${exercise.duration_seconds}s' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  ExerciseDetailModal.show(context, exercise);
                },
              );
            },
          ),
        );
      },
    );
  }
}
