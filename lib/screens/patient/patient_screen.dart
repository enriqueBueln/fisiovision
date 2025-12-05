
import 'package:fisiovision/screens/patient/patient_view.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AQUÍ USAS TU LAYOUT PERSONALIZADO
    return ScaffoldSideMenu(
      title: "Gestión de Pacientes",
      subtitle: "Administra los expedientes y diagnósticos",
      // Configuramos el botón de acción específico para esta pantalla
      buttonText: "Nuevo Paciente",
      buttonIcon: const Icon(Icons.add),
      onButtonPressed: () {
        context.go('/paciente/nuevo'); // Ejemplo de navegación
      },
      // AQUÍ DEFINIMOS EL MENÚ LATERAL (DRAWER)
      drawer: const _MiDrawerPersonalizado(), 
      // Y AQUÍ EL CONTENIDO (Tu vista)
      body: const PatientsView(), 
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
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Pacientes"),
            onTap: () => context.go('/pacientes'), // Navegación con GoRouter
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text("Ejercicios"),
            onTap: () => context.go('/ejercicios'),
          ),
        ],
      ),
    );
  }
}