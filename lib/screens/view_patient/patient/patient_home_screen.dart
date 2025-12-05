import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AQUÍ USAS TU LAYOUT PERSONALIZADO
    return ScaffoldSideMenu(
      title: "Bienvenido a tu Panel de Paciente",
      subtitle: "Aquí puedes ver tu progreso y ejercicios asignados",
      // Configuramos el botón de acción específico para esta pantalla
      // buttonText: "Nuevo Paciente",
      // buttonIcon: const Icon(Icons.add),
      // onButtonPressed: () {
        // context.go('/paciente/nuevo'); // Ejemplo de navegación
      // },
      // AQUÍ DEFINIMOS EL MENÚ LATERAL (DRAWER)
      drawer: const _MiDrawerPersonalizado(), 
      // Y AQUÍ EL CONTENIDO (Tu vista)
      body: const AssignedExercisesView() 
    );
  }
}

// Un Drawer sencillo para navegar
class _MiDrawerPersonalizado extends StatelessWidget {
  const _MiDrawerPersonalizado();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("Menú Fisioterapia")),
          // ListTile(
          //   leading: const Icon(Icons.people),
          //   title: const Text("Pacientes"),
          //   onTap: () => context.go('/pacientes'), // Navegación con GoRouter
          // ),
          // ListTile(
          //   leading: const Icon(Icons.fitness_center),
          //   title: const Text("Ejercicios"),
          //   onTap: () => context.go('/ejercicios'),
          // ),
        ],
      ),
    );
  }
}

// Modelo dummy para la vista (puedes usar tu modelo Exercise real)
class AssignedExercise {
  final String title;
  final String duration;
  final bool isCompleted;
  AssignedExercise(this.title, this.duration, this.isCompleted);
}

class AssignedExercisesView extends StatelessWidget {
  const AssignedExercisesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados (Mock Data)
    final exercises = [
      AssignedExercise("Sentadilla Profunda", "3 series - 15 reps", false),
      AssignedExercise("Flexión de Codo", "4 series - 12 reps", true),
      AssignedExercise("Abducción de Hombro", "3 series - 10 reps", false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Text(
            "Tu Rutina de Hoy",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        // EL ESTILO QUE PEDISTE: Card contenedora
        Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = exercises[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isCompleted ? Colors.green.shade50 : Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isCompleted ? Icons.check : Icons.fitness_center,
                    color: item.isCompleted ? Colors.green : Colors.teal,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: Text(item.duration),
                trailing: item.isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          // Navegar a la pantalla de conexión
                          // context.push('/connect-device'); 
                          context.go('/connect-device');
                        },
                        child: const Text("Iniciar"),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}