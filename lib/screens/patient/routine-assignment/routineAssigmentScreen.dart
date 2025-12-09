import 'package:fisiovision/models/paciente_model.dart';
import 'package:fisiovision/screens/patient/routine-assignment/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoutineAssignmentScreen extends ConsumerWidget {
  const RoutineAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0A0E21)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF1A1F3A)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/pacientes'),
        ),
        title: Row(
          children: [
            const Text('📋', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text(
              'Asignar Rutina',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PASO 1: Selección del Paciente
            _SectionCard(
              emoji: '👤',
              title: 'Paso 1: Selecciona el Paciente',
              stepNumber: '1',
              children: [
                _PatientSelectionCard(
                  selectedPatient: routineState.selectedPatient,
                  onSelect: () =>
                      _showPatientSelectionModal(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // PASO 2: Ejercicios Asignados
            _SectionCard(
              emoji: '💪',
              title: 'Paso 2: Agrega Ejercicios',
              stepNumber: '2',
              badge: routineState.exercises.length.toString(),
              children: [
                _AssignedExercisesList(
                  exercises: routineState.exercises,
                  onDelete: (index) {
                    ref
                        .read(routineProvider.notifier)
                        .removeExercise(index);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: routineState.selectedPatient == null
                        ? null
                        : () => _showExerciseSelectionModal(
                            context,
                            ref,
                          ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'AGREGAR EJERCICIO',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // BOTÓN FINAL DE GUARDADO
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/pacientes'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      side: BorderSide(
                        color: isDarkMode
                            ? Colors.white24
                            : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        (routineState.selectedPatient != null &&
                            routineState.exercises.isNotEmpty)
                        ? () => ref
                              .read(routineProvider.notifier)
                              .saveRoutine()
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[300],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'GUARDAR RUTINA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPatientSelectionModal(
    BuildContext context,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PatientSelectionModal(ref: ref),
    );
  }

  void _showExerciseSelectionModal(
    BuildContext context,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExerciseSelectionModal(ref: ref),
    );
  }
}

// ============================================================================
// WIDGETS PERSONALIZADOS
// ============================================================================

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String stepNumber;
  final String? badge;
  final List<Widget> children;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.stepNumber,
    required this.children,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _PatientSelectionCard extends StatelessWidget {
  final Paciente? selectedPatient;
  final VoidCallback onSelect;

  const _PatientSelectionCard({
    required this.selectedPatient,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedPatient != null;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF0F1629)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E88E5)
                : (isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.15)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E88E5).withOpacity(0.1)
                    : (isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.person : Icons.person_add_alt_1,
                color: isSelected
                    ? const Color(0xFF1E88E5)
                    : (isDarkMode
                          ? Colors.grey[600]
                          : Colors.grey[400]),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected
                        ? selectedPatient!.name
                        : 'Seleccionar Paciente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDarkMode
                                ? Colors.white
                                : Colors.black87)
                          : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                    ),
                  ),
                  if (!isSelected) const SizedBox(height: 4),
                  if (!isSelected)
                    Text(
                      'Requerido para asignar rutina',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.edit_outlined
                  : Icons.chevron_right,
              color: isDarkMode
                  ? Colors.grey[600]
                  : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientSelectionModal extends StatelessWidget {
  final WidgetRef ref;
  const _PatientSelectionModal({required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle visual
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: Color(0xFF1E88E5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Selecciona un Paciente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.15),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyPatients.length,
              itemBuilder: (context, index) {
                final patient = dummyPatients[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isDarkMode
                        ? const Color(0xFF0F1629)
                        : const Color(0xFFF8F9FA),
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFF1E88E5,
                      ).withOpacity(0.1),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    title: Text(
                      patient.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF1E88E5),
                    ),
                    onTap: () {
                      ref
                          .read(routineProvider.notifier)
                          .selectPatient(patient);
                      Navigator.pop(context);
                    },
                  ),
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
  final Function(int) onDelete;

  const _AssignedExercisesList({
    required this.exercises,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    if (exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF0F1629)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 48,
              color: isDarkMode
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay ejercicios asignados',
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Agrega ejercicios para crear la rutina',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: exercises.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF0F1629)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.15),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_run,
                color: Color(0xFF1E88E5),
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${item.series} series × ${item.reps} repeticiones',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFE53935),
              ),
              onPressed: () => onDelete(index),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ExerciseSelectionModal extends StatelessWidget {
  final WidgetRef ref;
  const _ExerciseSelectionModal({required this.ref});

  final List<Map<String, dynamic>> availableExercises = const [
    {'name': 'Sentadilla', 'icon': Icons.accessibility_new},
    {
      'name': 'Puente de Glúteo',
      'icon': Icons.airline_seat_recline_normal,
    },
    {'name': 'Elevación Lateral', 'icon': Icons.accessibility},
    {'name': 'Zancadas', 'icon': Icons.directions_walk},
    {'name': 'Plancha', 'icon': Icons.self_improvement},
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle visual
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[700]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF1E88E5),
                ),
                const SizedBox(width: 12),
                Text(
                  'Biblioteca de Ejercicios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.15),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isDarkMode
                        ? const Color(0xFF0F1629)
                        : const Color(0xFFF8F9FA),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1E88E5,
                        ).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        exercise['icon'],
                        color: const Color(0xFF1E88E5),
                      ),
                    ),
                    title: Text(
                      exercise['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Toca para agregar a la rutina',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF1E88E5),
                    ),
                    onTap: () {
                      ref
                          .read(routineProvider.notifier)
                          .addExercise(
                            AssignedExerciseDetail(
                              exerciseId: 'EX$index',
                              name: exercise['name'],
                              series: 3,
                              reps: 10,
                            ),
                          );
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text('${exercise['name']} agregado'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF43A047),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
