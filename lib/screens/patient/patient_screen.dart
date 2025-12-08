import 'package:fisiovision/screens/patient/patient_view.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldSideMenu(
      title: "Gestión de Pacientes",
      subtitle: "Administra los expedientes y diagnósticos",
      buttonText: "Nuevo Paciente",
      buttonIcon: const Icon(Icons.add),
      onButtonPressed: () {
        context.go('/paciente/nuevo');
      },
      body: const PatientsView(),
    );
  }
}
