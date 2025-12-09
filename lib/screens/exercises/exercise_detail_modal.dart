import 'package:flutter/material.dart';
import 'package:fisiovision/models/ejercicio_model.dart';

// ============================================================================
// MODAL DE DETALLE DEL EJERCICIO - COMPONENTE INDEPENDIENTE
// ============================================================================
class ExerciseDetailModal extends StatelessWidget {
  final Ejercicio exercise;

  const ExerciseDetailModal({super.key, required this.exercise});

  // Método estático para mostrar el modal fácilmente
  static void show(BuildContext context, Ejercicio exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ExerciseDetailModal(exercise: exercise),
    );
  }

  Color _getTypeColor(TipoEjercicio type) {
    switch (type) {
      case TipoEjercicio.fuerza:
        return const Color(0xFFE53935);
      case TipoEjercicio.movilidad:
        return const Color(0xFF43A047);
      case TipoEjercicio.flexion:
        return const Color(0xFF1E88E5);
      case TipoEjercicio.equilibrio:
        return const Color(0xFF8E24AA);
      case TipoEjercicio.rotacion:
        return const Color(0xFFFFB300);
      case TipoEjercicio.extension:
        return const Color(0xFFFB8C00);
      case TipoEjercicio.otro:
        return const Color(0xFF6D4C41);
    }
  }

  String _getTypeText(TipoEjercicio type) {
    switch (type) {
      case TipoEjercicio.fuerza:
        return 'Fuerza';
      case TipoEjercicio.movilidad:
        return 'Movilidad';
      case TipoEjercicio.flexion:
        return 'Flexión';
      case TipoEjercicio.equilibrio:
        return 'Equilibrio';
      case TipoEjercicio.rotacion:
        return 'Rotación';
      case TipoEjercicio.extension:
        return 'Extensión';
      case TipoEjercicio.otro:
        return 'Otro';
    }
  }

  String _getTypeEmoji(TipoEjercicio type) {
    switch (type) {
      case TipoEjercicio.fuerza:
        return '💪';
      case TipoEjercicio.movilidad:
        return '🚶';
      case TipoEjercicio.flexion:
        return '🤸';
      case TipoEjercicio.equilibrio:
        return '⚖️';
      case TipoEjercicio.rotacion:
        return '🔄';
      case TipoEjercicio.extension:
        return '📐';
      case TipoEjercicio.otro:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getTypeColor(exercise.tipoEnum);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar para arrastrar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white24
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header con gradiente de color
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [typeColor, typeColor.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Icono grande de fondo
                Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                // Información del ejercicio
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTypeEmoji(exercise.tipoEnum),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTypeText(exercise.tipoEnum),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción
                  _SectionCard(
                    emoji: '📝',
                    title: 'Descripción',
                    isDarkMode: isDarkMode,
                    children: [
                      Text(
                        exercise.descripcion ??
                            'Sin descripción disponible.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Parámetros del ejercicio
                  _SectionCard(
                    emoji: '⚙️',
                    title: 'Parámetros',
                    isDarkMode: isDarkMode,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ParameterBox(
                              icon: Icons.repeat,
                              label: 'Repeticiones',
                              value: '${exercise.repeticiones}',
                              color: const Color(0xFF1E88E5),
                              isDarkMode: isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ParameterBox(
                              icon: Icons.format_list_numbered,
                              label: 'Series',
                              value: '${exercise.series}',
                              color: const Color(0xFF43A047),
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ],
                      ),
                      if (exercise.duracionSegundos > 0) ...[
                        const SizedBox(height: 12),
                        _ParameterBox(
                          icon: Icons.timer_outlined,
                          label: 'Duración',
                          value: '${exercise.duracionSegundos}s',
                          color: const Color(0xFFFB8C00),
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Detalles técnicos
                  _SectionCard(
                    emoji: '🎯',
                    title: 'Detalles Técnicos',
                    isDarkMode: isDarkMode,
                    children: [
                      _InfoRow(
                        label: 'Ángulos objetivo',
                        value: exercise.angulosObjetivo,
                        icon: Icons.architecture,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Tolerancia',
                        value: '±${exercise.toleranciaGrados}°',
                        icon: Icons.tune,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'ID del ejercicio',
                        value: exercise.id.toString(),
                        icon: Icons.tag,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Acción de ver video
                            print(
                              'Ver video: ${exercise.videoReferencia}',
                            );
                          },
                          icon: const Icon(
                            Icons.play_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Ver Video'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            side: BorderSide(color: typeColor),
                            foregroundColor: typeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Acción de editar
                            print(
                              'Editar ejercicio: ${exercise.id}',
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            backgroundColor: typeColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isDarkMode;
  final List<Widget> children;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.isDarkMode,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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

class _ParameterBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  const _ParameterBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDarkMode;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
