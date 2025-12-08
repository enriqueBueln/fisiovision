import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldSideMenu(
      title: "Bienvenido a tu Panel",
      subtitle:
          "Aquí puedes ver tu progreso y ejercicios asignados",
      drawer: const _PatientDrawer(),
      body: const AssignedExercisesView(),
    );
  }
}

class _PatientDrawer extends StatelessWidget {
  const _PatientDrawer();

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1F3A)
          : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF1E88E5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Mi Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home_outlined,
              color: Color(0xFF1E88E5),
            ),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.fitness_center,
              color: Color(0xFF1E88E5),
            ),
            title: const Text('Mis Ejercicios'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Color(0xFF1E88E5),
            ),
            title: const Text('Historial'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF64748B),
            ),
            title: const Text('Configuración'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class AssignedExercise {
  final String title;
  final String series;
  final String reps;
  final bool isCompleted;
  final String difficulty;

  AssignedExercise({
    required this.title,
    required this.series,
    required this.reps,
    required this.isCompleted,
    required this.difficulty,
  });
}

class AssignedExercisesView extends StatelessWidget {
  const AssignedExercisesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final exercises = [
      AssignedExercise(
        title: "Sentadilla Profunda",
        series: "3",
        reps: "15",
        isCompleted: false,
        difficulty: "Moderado",
      ),
      AssignedExercise(
        title: "Flexión de Codo",
        series: "4",
        reps: "12",
        isCompleted: true,
        difficulty: "Fácil",
      ),
      AssignedExercise(
        title: "Abducción de Hombro",
        series: "3",
        reps: "10",
        isCompleted: false,
        difficulty: "Fácil",
      ),
    ];

    final completedCount = exercises
        .where((e) => e.isCompleted)
        .length;
    final totalCount = exercises.length;
    final progress = completedCount / totalCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de Resumen
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6),
                  const Color(0xFF1E88E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tu Rutina de Hoy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$completedCount/$totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% completado',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Lista de Ejercicios
          Text(
            'Ejercicios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          ...exercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseCard(
                exercise: exercise,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final AssignedExercise exercise;
  final bool isDarkMode;

  const _ExerciseCard({
    required this.exercise,
    required this.isDarkMode,
  });

  Color _getDifficultyColor() {
    switch (exercise.difficulty) {
      case "Fácil":
        return const Color(0xFF10B981);
      case "Moderado":
        return const Color(0xFFF59E0B);
      case "Difícil":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor();

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: exercise.isCompleted
              ? const Color(0xFF10B981).withOpacity(0.3)
              : (isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.15)),
          width: exercise.isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icono
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: exercise.isCompleted
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFF3B82F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                exercise.isCompleted
                    ? Icons.check_circle
                    : Icons.fitness_center,
                color: exercise.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF3B82F6),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: exercise.isCompleted
                          ? (isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B))
                          : (isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E293B)),
                      decoration: exercise.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: isDarkMode
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.series} series × ${exercise.reps} reps',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          exercise.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón de acción
            if (!exercise.isCompleted)
              ElevatedButton(
                onPressed: () => context.go('/connect-device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Iniciar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.check_circle,
                color: const Color(0xFF10B981),
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
