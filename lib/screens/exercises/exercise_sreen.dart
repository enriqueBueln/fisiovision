import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:fisiovision/screens/exercises/exercise_detail_modal.dart';
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
final List<Ejercicio> dummyExercises = [
  Ejercicio(
    id: 1,
    nombre: 'Sentadilla con Banda',
    descripcion: 'Fortalecimiento de cuádriceps y glúteos.',
    videoReferencia: 'url_video_1',
    duracionSegundos: 0,
    repeticiones: 15,
    series: 3,
    toleranciaGrados: 5,
    angulosObjetivo: '90 grados de rodilla',
    imagenReferencia: 'https://placehold.co/600x400/004d40/ffffff?text=Fuerza',
    tipo: 'Fuerza',
  ),
  Ejercicio(
    id: 2,
    nombre: 'Estiramiento Isquiotibial',
    descripcion: 'Mejora la flexibilidad de la parte posterior del muslo.',
    videoReferencia: 'url_video_2',
    duracionSegundos: 30,
    repeticiones: 1,
    series: 4,
    toleranciaGrados: 10,
    angulosObjetivo: 'Máximo estiramiento cómodo',
    imagenReferencia:
        'https://placehold.co/600x400/00838f/ffffff?text=Flexibilidad',
    tipo: 'Flexibilidad',
  ),
  Ejercicio(
    id: 3,
    nombre: 'Trotar en el Sitio',
    descripcion: 'Aumento de la frecuencia cardíaca y calentamiento.',
    videoReferencia: 'url_video_3',
    duracionSegundos: 120,
    repeticiones: 1,
    series: 1,
    toleranciaGrados: 0,
    angulosObjetivo: 'N/A',
    imagenReferencia: 'https://placehold.co/600x400/00acc1/ffffff?text=Cardio',
    tipo: 'Cardio',
  ),
  Ejercicio(
    id: 4,
    nombre: 'Parado en una pierna',
    descripcion: 'Mejora la estabilidad y el equilibrio monopodal.',
    videoReferencia: 'url_video_4',
    duracionSegundos: 60,
    repeticiones: 1,
    series: 2,
    toleranciaGrados: 3,
    angulosObjetivo: 'Mantener tronco vertical',
    imagenReferencia:
        'https://placehold.co/600x400/0277bd/ffffff?text=Equilibrio',
    tipo: 'Equilibrio',
  ),
];

// ---------------------------------------------------------------------------
// VISTA DE EJERCICIOS REDISEÑADA
// ---------------------------------------------------------------------------
class ExercisesView extends StatelessWidget {
  const ExercisesView({super.key});

  // Función de utilidad para obtener el color del tipo de ejercicio
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Fuerza':
        return Colors.red.shade700;
      case 'Cardio':
        return Colors.green.shade700;
      case 'Flexibilidad':
        return Colors.blue.shade700;
      case 'Equilibrio':
        return Colors.purple.shade700;
      default:
        return Colors.grey;
    }
  }

  // Función de utilidad para obtener el texto del tipo de ejercicio
  String _getTypeText(String type) {
    switch (type) {
      case 'Fuerza':
        return 'Fuerza 💪';
      case 'Cardio':
        return 'Cardio 🏃';
      case 'Flexibilidad':
        return 'Flexibilidad 🤸';
      case 'Equilibrio':
        return 'Equilibrio ⚖️';
      default:
        return 'Desconocido';
    }
  }

  // Función de utilidad para obtener el icono del tipo
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Fuerza':
        return Icons.fitness_center;
      case 'Cardio':
        return Icons.directions_run;
      case 'Flexibilidad':
        return Icons.accessibility_new;
      case 'Equilibrio':
        return Icons.balance;
      default:
        return Icons.help;
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
          final typeColor = _getTypeColor(exercise.tipo);
          final typeIcon = _getTypeIcon(exercise.tipo);

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
                    _getTypeText(exercise.tipo),
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
                  'Reps: ${exercise.repeticiones} • Series: ${exercise.series}${exercise.duracionSegundos > 0 ? ' • ${exercise.duracionSegundos}s' : ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
  }
}
