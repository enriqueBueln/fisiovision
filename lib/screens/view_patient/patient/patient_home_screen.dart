import 'package:fisiovision/providers/patients_provider.dart';
import 'package:fisiovision/widgets/scaffold_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fisiovision/models/patients_model.dart';
import 'package:fisiovision/models/sesion_model.dart';
import 'package:fisiovision/services/sesion_service.dart';
import 'package:fisiovision/services/auth_service.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssignedExerciseProvider()..fetchExercises(),
      child: ScaffoldSideMenu(
        title: "Bienvenido a tu Panel",
        subtitle:
            "Aquí puedes ver tu progreso y ejercicios asignados",
        drawer: const _PatientDrawer(),
        body: const AssignedExercisesView(),
      ),
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

class AssignedExercisesView extends StatelessWidget {
  const AssignedExercisesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Consumer<AssignedExerciseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar ejercicios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchExercises(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes ejercicios asignados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu fisioterapeuta te asignará ejercicios pronto',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Lista de Ejercicios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.fetchExercises(),
                    color: isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...provider.exercises.map(
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
      },
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final AssignedExerciseModel exercise;
  final bool isDarkMode;

  const _ExerciseCard({
    required this.exercise,
    required this.isDarkMode,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isStarting = false;

  Future<void> _handleStartExercise(BuildContext context) async {
    setState(() => _isStarting = true);

    try {
      final sesionService = SesionService();
      final authService = AuthService();
      
      // Obtener el ID del paciente desde el token JWT
      final userId = await authService.getUserIdFromToken();
      
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario. Por favor, inicia sesión nuevamente.');
      }

      final sesionCreate = SesionCreate(
        idPaciente: userId,
        idEjercicio: widget.exercise.ejercicio.id,
        dateSpecified: DateTime.now(),
      );

      final sesion = await sesionService.startSesion(sesionCreate);

      if (!context.mounted) return;

      _showSuccessAndNavigate(context, sesion);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: ${e.toString().replaceAll('Exception: ', '')}',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  void _showSuccessAndNavigate(BuildContext context, SesionResponse sesion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Sesión iniciada: ${sesion.ejercicio?.name ?? "Ejercicio"}'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Navegar a la pantalla de conexión, pasando la sesión
    context.push('/connect-device', extra: sesion);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = !widget.exercise.isActive;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withOpacity(0.3)
              : (widget.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.15)),
          width: isCompleted ? 2 : 1,
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
                color: isCompleted
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFF3B82F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : Icons.fitness_center,
                color: isCompleted
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
                    widget.exercise.ejercicio.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? (widget.isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B))
                          : (widget.isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E293B)),
                      decoration: isCompleted
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
                        color: widget.isDarkMode
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.exercise.ejercicio.series} series × ${widget.exercise.ejercicio.repetitions} reps',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDarkMode
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón de acción
            if (!isCompleted)
              ElevatedButton(
                onPressed: _isStarting ? null : () => _handleStartExercise(context),
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
                  disabledBackgroundColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
                child: _isStarting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Iniciar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )
            else
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}
