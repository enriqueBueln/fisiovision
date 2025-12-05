import 'package:fisiovision/providers/paciente_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Cambiamos StatelessWidget por ConsumerWidget
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Observamos" el estado del provider
    final estadoPacientes = ref.watch(pacientesProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Fisioterapia App")),
      body: estadoPacientes.when(
        // CASO 1: CARGANDO
        loading: () => Center(child: CircularProgressIndicator()),

        // CASO 2: ERROR
        error: (err, stack) => Center(child: Text("Error: $err")),

        // CASO 3: DATOS LISTOS
        data: (pacientes) {
          if (pacientes.isEmpty) return Center(child: Text("No hay pacientes"));

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return ListTile(
                title: Text(paciente.nombre),
                subtitle: Text(paciente.diagnostico),
                onTap: () {
                  // Navegar a detalles o grabar video
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ejemplo de cómo llamar a una función del Notifier
          // ref.read(pacientesProvider.notifier).cargarPacientes();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
