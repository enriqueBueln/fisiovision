import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:fisiovision/widgets/side_menu.dart';
import 'package:flutter/material.dart';
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

// Datos de ejemplo simulados
final List<Exercise> dummyExercises = [
  Exercise(
    id: 'E001',
    nombre: 'Sentadilla con Banda',
    descripcion: 'Fortalecimiento de cuádriceps y glúteos.',
    referenceVideo: 'url_video_1',
    durationSeconds: 0,
    repeticiones: 15,
    series: 3,
    toleranceDegrees: 5,
    objetiveAngles: '90 grados de rodilla',
    referenceImage: 'https://placehold.co/600x400/004d40/ffffff?text=Fuerza',
    completed: false,
    type: TypeExercise.Fuerza,
  ),
  Exercise(
    id: 'E002',
    nombre: 'Estiramiento Isquiotibial',
    descripcion: 'Mejora la flexibilidad de la parte posterior del muslo.',
    referenceVideo: 'url_video_2',
    durationSeconds: 30,
    repeticiones: 1,
    series: 4,
    toleranceDegrees: 10,
    objetiveAngles: 'Máximo estiramiento cómodo',
    referenceImage:
        'https://placehold.co/600x400/00838f/ffffff?text=Flexibilidad',
    completed: true,
    type: TypeExercise.Flexibilidad,
  ),
  Exercise(
    id: 'E003',
    nombre: 'Trotar en el Sitio',
    descripcion: 'Aumento de la frecuencia cardíaca y calentamiento.',
    referenceVideo: 'url_video_3',
    durationSeconds: 120,
    repeticiones: 1,
    series: 1,
    toleranceDegrees: 0,
    objetiveAngles: 'N/A',
    referenceImage: 'https://placehold.co/600x400/00acc1/ffffff?text=Cardio',
    completed: false,
    type: TypeExercise.Cardio,
  ),
  Exercise(
    id: 'E004',
    nombre: 'Parado en una pierna',
    descripcion: 'Mejora la estabilidad y el equilibrio monopodal.',
    referenceVideo: 'url_video_4',
    durationSeconds: 60,
    repeticiones: 1,
    series: 2,
    toleranceDegrees: 3,
    objetiveAngles: 'Mantener tronco vertical',
    referenceImage:
        'https://placehold.co/600x400/0277bd/ffffff?text=Equilibrio',
    completed: false,
    type: TypeExercise.Equilibrio,
  ),
];

// ---------------------------------------------------------------------------
// VISTA DE EJERCICIOS REDISEÑADA
// ---------------------------------------------------------------------------
class ExercisesView extends StatelessWidget {
  const ExercisesView({super.key});

  // Función de utilidad para obtener el color del tipo de ejercicio
  Color _getTypeColor(TypeExercise type) {
    switch (type) {
      case TypeExercise.Fuerza:
        return Colors.red.shade700;
      case TypeExercise.Cardio:
        return Colors.green.shade700;
      case TypeExercise.Flexibilidad:
        return Colors.blue.shade700;
      case TypeExercise.Equilibrio:
        return Colors.purple.shade700;
    }
  }

  // Función de utilidad para obtener el texto del tipo de ejercicio
  String _getTypeText(TypeExercise type) {
    switch (type) {
      case TypeExercise.Fuerza:
        return 'Fuerza 💪';
      case TypeExercise.Cardio:
        return 'Cardio 🏃';
      case TypeExercise.Flexibilidad:
        return 'Flexibilidad 🤸';
      case TypeExercise.Equilibrio:
        return 'Equilibrio ⚖️';
    }
  }

  // Función de utilidad para obtener el icono del tipo
  IconData _getTypeIcon(TypeExercise type) {
    switch (type) {
      case TypeExercise.Fuerza:
        return Icons.fitness_center;
      case TypeExercise.Cardio:
        return Icons.directions_run;
      case TypeExercise.Flexibilidad:
        return Icons.accessibility_new;
      case TypeExercise.Equilibrio:
        return Icons.balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: dummyExercises.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final exercise = dummyExercises[index];
          final typeColor = _getTypeColor(exercise.type);
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
              exercise.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Chip del tipo de ejercicio
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
                // Información resumida
                Text(
                  'Reps: ${exercise.repeticiones} • Series: ${exercise.series}${exercise.durationSeconds > 0 ? ' • ${exercise.durationSeconds}s' : ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Navegar a la vista de detalles del ejercicio
              print('Ver detalles del ejercicio: ${exercise.nombre}');
            },
          );
        },
      ),
    );
  }
}
