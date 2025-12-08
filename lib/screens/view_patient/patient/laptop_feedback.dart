import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LaptopFeedbackView extends StatefulWidget {
  const LaptopFeedbackView({super.key});

  @override
  State<LaptopFeedbackView> createState() =>
      _LaptopFeedbackViewState();
}

class _LaptopFeedbackViewState extends State<LaptopFeedbackView> {
  bool _isSessionActive = true;
  int _currentReps = 8;
  int _totalReps = 15;
  double _currentAngle = 85.0;
  int _elapsedSeconds = 45;

  void _endSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF64748B)),
            SizedBox(width: 12),
            Text('Finalizar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas terminar la sesión actual?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSessionActive = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text('Sesión finalizada exitosamente'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              // context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('TERMINAR'),
          ),
        ],
      ),
    );
  }

  Color _getAngleColor() {
    if (_currentAngle >= 80 && _currentAngle <= 95) {
      return const Color(0xFF10B981); // Verde suave
    } else if (_currentAngle >= 70 && _currentAngle <= 105) {
      return const Color(0xFFF59E0B); // Ámbar
    } else {
      return const Color(0xFFEF4444); // Rojo suave
    }
  }

  String _getFeedbackMessage() {
    if (_currentAngle >= 80 && _currentAngle <= 95) {
      return "Excelente postura";
    } else if (_currentAngle >= 70 && _currentAngle <= 105) {
      return "Ajusta el ángulo";
    } else {
      return "Revisa tu postura";
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;
    final angleColor = _getAngleColor();
    final feedbackMessage = _getFeedbackMessage();

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isSessionActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isSessionActive
                  ? 'Sesión en progreso'
                  : 'Sesión finalizada',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sentadilla',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // COLUMNA IZQUIERDA: VIDEO
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Placeholder del Video
                    Container(
                      color: isDarkMode
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              size: 80,
                              color: isDarkMode
                                  ? const Color(0xFF475569)
                                  : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Vista de cámara',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Indicador IA
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(
                                  0xFF1E293B,
                                ).withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'IA activa',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mensaje de feedback
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: angleColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: angleColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          feedbackMessage,
                          style: TextStyle(
                            color: angleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // COLUMNA DERECHA: MÉTRICAS
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
              child: Column(
                children: [
                  // PROGRESO
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Progreso",
                    icon: Icons.track_changes,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_currentReps',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' / $_totalReps',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _currentReps / _totalReps,
                            minHeight: 6,
                            backgroundColor: isDarkMode
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            valueColor:
                                const AlwaysStoppedAnimation<
                                  Color
                                >(Color(0xFF3B82F6)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${((_currentReps / _totalReps) * 100).toStringAsFixed(0)}% completado',
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ÁNGULO
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Ángulo rodilla",
                    icon: Icons.architecture,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          '${_currentAngle.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: angleColor,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: angleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Objetivo: 80° - 95°',
                            style: TextStyle(
                              color: angleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TIEMPO
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Tiempo",
                    icon: Icons.schedule,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // BOTONES
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSessionActive
                          ? _endSession
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: isDarkMode
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      child: const Text(
                        'Terminar sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(
                          () =>
                              _isSessionActive = !_isSessionActive,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDarkMode
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF1E293B),
                        side: BorderSide(
                          color: isDarkMode
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isSessionActive ? 'Pausar' : 'Reanudar',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _MetricCard extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final IconData icon;
  final Widget child;

  const _MetricCard({
    required this.isDarkMode,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
