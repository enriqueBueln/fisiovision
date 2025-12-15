import 'package:fisiovision/config/token.dart';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'package:fisiovision/providers/ejercicios_provider.dart';
import 'package:fisiovision/providers/paciente_provider.dart';
import 'package:fisiovision/providers/rutina_provider.dart';
import 'package:fisiovision/screens/patient/therapist_patient_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class PatientDetailScreen extends ConsumerWidget {
  final int pacienteId; // Recibimos solo el ID

  const PatientDetailScreen({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 1. ESCUCHAMOS EL PROVIDER DEL PACIENTE INDIVIDUAL (Sin await)
    final asyncPaciente = ref.watch(pacienteDetalleProvider(pacienteId));
    
    // 2. ESCUCHAMOS LA RUTINA (También sin await, Riverpod lo maneja)
    final asyncRutina = ref.watch(rutinaPacienteProvider(asyncPaciente.maybeWhen(
      data: (paciente) => paciente.idUsuario!,
      orElse: () => 0,
    )));

    // 3. RETORNAMOS LA UI BASADA EN EL ESTADO DEL PACIENTE
    return asyncPaciente.when(
      // CASO: CARGANDO (Pantalla completa de carga)
      loading: () => Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
        body: const Center(child: CircularProgressIndicator()),
      ),
      
      // CASO: ERROR
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Error al cargar paciente: $err")),
      ),

      // CASO: DATOS LISTOS (Aquí va tu UI bonita)
      data: (paciente) {
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          body: CustomScrollView(
            slivers: [
              // 1. APPBAR COLAPSABLE
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    paciente.name, // Ahora es seguro usarlo
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              paciente.name.isNotEmpty ? paciente.name.substring(0, 1) : '?',
                              style: const TextStyle(fontSize: 30, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${paciente.gender} • ${paciente.edad} años",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. CONTENIDO DEL CUERPO
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // SECCIÓN: INFO CLÍNICA
                      _SectionCard(
                        icon: Icons.healing,
                        emoji: '🏥',
                        title: 'Información Clínica',
                        children: [
                          _InfoRow(
                            label: 'Notas / Diagnóstico',
                            value: paciente.notes ?? "Sin notas",
                            icon: Icons.medical_services_outlined,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'Email',
                            value: paciente.email,
                            icon: Icons.email_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // SECCIÓN: RUTINA ASIGNADA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rutina Asignada",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87
                            ),
                          ),
                          Row(
                            children: [
                              IconButton.filled(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TherapistPatientHistoryScreen(
                                        patientId: paciente.idUsuario!,
                                        patientName: paciente.name,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.history),
                                style: IconButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                tooltip: "Ver historial de sesiones",
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: () => _showAssignmentModal(context, ref, paciente.idUsuario!),
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                                tooltip: "Asignar ejercicio",
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // LISTA DE EJERCICIOS (Manejada con su propio .when)
                      asyncRutina.when(
                        loading: () => const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        )),
                        error: (err, _) => Text("Error cargando rutina: $err"),
                        data: (ejercicios) {
                          if (ejercicios.isEmpty) {
                            return _EmptyStateCard(isDarkMode: isDarkMode);
                          }
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ejercicios.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final ejercicio = ejercicios[index];
                              return _ExerciseItemCard(ejercicio: ejercicio);
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // MODAL PARA SELECCIONAR Y ASIGNAR
  void _showAssignmentModal(BuildContext context, WidgetRef ref, int patientId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _AssignExerciseModal(patientId: patientId),
    );
  }
}
class _ExerciseItemCard extends StatelessWidget {
  final Ejercicio ejercicio;
  const _ExerciseItemCard({required this.ejercicio});

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.teal),
        ),
        title: Text(ejercicio.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${ejercicio.series} series x ${ejercicio.repetitions} reps"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final bool isDarkMode;
  const _EmptyStateCard({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.none),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_add, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Sin ejercicios asignados",
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          Text(
            "Toca el botón + para agregar uno.",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AssignExerciseModal extends ConsumerWidget {
  final int patientId;
  const _AssignExerciseModal({required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Obtenemos el catálogo completo de ejercicios
    final asyncCatalogo = ref.watch(ejerciciosProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Header del modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Asignar Ejercicio", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          
          // Lista de ejercicios disponibles
          Expanded(
            child: asyncCatalogo.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (catalogo) {
                if (catalogo.isEmpty) return const Center(child: Text("No hay ejercicios creados en el sistema."));
                
                return ListView.builder(
                  itemCount: catalogo.length,
                  itemBuilder: (ctx, index) {
                    final ejercicio = catalogo[index];
                    return ListTile(
                      title: Text(ejercicio.name),
                      subtitle: Text(ejercicio.type), // Asumiendo que es String
                      leading: const Icon(Icons.accessibility),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          // LÓGICA DE ASIGNACIÓN
                          try {
                            // 1. Mostrar carga o feedback
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Asignando...")));
                            
                            // 2. Llamar al servicio
                            print("Asignando ejercicio ID ${ejercicio.id} al paciente ID $patientId con usuario ID ${await getIdUsuario()}");
                            await ref.read(rutinaServiceProvider).asignarEjercicio(patientId, ejercicio.id, await getIdUsuario());
                            
                            // 3. Refrescar la lista de la pantalla anterior
                            // Invalidamos el provider family para que vuelva a hacer el fetch
                            ref.invalidate(rutinaPacienteProvider(patientId));
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Cerrar modal
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ejercicio asignado!"), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                          }
                        },
                        child: const Text("Asignar"),
                      ),
                    );
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


class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0F1629)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}




class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    // ignore: unused_element_parameter
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      valueColor ??
                      (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
