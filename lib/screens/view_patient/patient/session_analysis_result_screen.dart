import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionAnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const SessionAnalysisResultScreen({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final analisisProlog = analysisData['analisis_prolog'] ?? {};
    final clasificaciones = analisisProlog['clasificaciones'] ?? {};
    final recomendaciones = List<String>.from(analisisProlog['recomendaciones'] ?? []);
    final progreso = analisisProlog['progreso'] ?? {};
    final recomendacionGeneral = analisisProlog['recomendacion_general'] ?? '';
    final ejercicio = analysisData['ejercicio'] ?? {};
    final datosEntrada = analysisData['datos_entrada'] ?? {};

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Análisis de Sesión'),
        backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado general
            _buildGeneralStatusCard(
              isDarkMode: isDarkMode,
              recomendacionGeneral: recomendacionGeneral,
              ejercicio: ejercicio,
              totalFrames: datosEntrada['total_frames_analizados'] ?? 0,
            ),
            const SizedBox(height: 24),

            // Clasificaciones
            _buildClassificationsCard(
              isDarkMode: isDarkMode,
              clasificaciones: clasificaciones,
            ),
            const SizedBox(height: 24),

            // Progreso
            if (progreso.isNotEmpty)
              _buildProgressCard(
                isDarkMode: isDarkMode,
                progreso: progreso,
              ),
            const SizedBox(height: 24),

            // Análisis de simetría
            if (analisisProlog['analisis_simetria'] != null)
              _buildSymmetryCard(
                isDarkMode: isDarkMode,
                simetria: analisisProlog['analisis_simetria'],
              ),
            const SizedBox(height: 24),

            // Validación de ángulos
            if (analisisProlog['validacion_angulos'] != null)
              _buildAngleValidationCard(
                isDarkMode: isDarkMode,
                validacion: analisisProlog['validacion_angulos'],
              ),
            const SizedBox(height: 24),

            // Recomendaciones
            _buildRecommendationsCard(
              isDarkMode: isDarkMode,
              recomendaciones: recomendaciones,
            ),
            const SizedBox(height: 32),

            // Botón para volver
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Volver al Inicio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStatusCard({
    required bool isDarkMode,
    required String recomendacionGeneral,
    required Map<String, dynamic> ejercicio,
    required int totalFrames,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (recomendacionGeneral.toLowerCase()) {
      case 'continuar':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Excelente trabajo';
        break;
      case 'ajustar':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.warning;
        statusText = 'Necesita ajustes';
        break;
      case 'pausar':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'Requiere atención';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Sin clasificar';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ejercicio['nombre'] ?? 'Ejercicio',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$totalFrames frames analizados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationsCard({
    required bool isDarkMode,
    required Map<String, dynamic> clasificaciones,
  }) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assessment,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Clasificaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildClassificationItem('Postura', clasificaciones['postura'] ?? '-', isDarkMode),
          _buildClassificationItem('Dolor', clasificaciones['dolor'] ?? '-', isDarkMode),
          _buildClassificationItem('Dificultad', clasificaciones['dificultad'] ?? '-', isDarkMode),
          _buildClassificationItem('Fatiga', clasificaciones['fatiga'] ?? '-', isDarkMode),
          _buildClassificationItem('Intensidad', clasificaciones['intensidad'] ?? '-', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildClassificationItem(String label, String value, bool isDarkMode) {
    Color valueColor;
    switch (value.toLowerCase()) {
      case 'buena':
      case 'leve':
      case 'baja':
        valueColor = const Color(0xFF10B981);
        break;
      case 'moderada':
      case 'media':
        valueColor = const Color(0xFFF59E0B);
        break;
      case 'mala':
      case 'severo':
      case 'alta':
        valueColor = const Color(0xFFEF4444);
        break;
      default:
        valueColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required bool isDarkMode,
    required Map<String, dynamic> progreso,
  }) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Progreso vs Sesión Anterior',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressItem('Dolor', progreso['dolor'] ?? '-', isDarkMode),
          _buildProgressItem('Dificultad', progreso['dificultad'] ?? '-', isDarkMode),
          _buildProgressItem('Fatiga', progreso['fatigue'] ?? '-', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, bool isDarkMode) {
    IconData icon;
    Color color;

    switch (value.toLowerCase()) {
      case 'mejorando':
        icon = Icons.arrow_downward;
        color = const Color(0xFF10B981);
        break;
      case 'empeorando':
        icon = Icons.arrow_upward;
        color = const Color(0xFFEF4444);
        break;
      case 'estable':
        icon = Icons.horizontal_rule;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8),
            ),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymmetryCard({
    required bool isDarkMode,
    required Map<String, dynamic> simetria,
  }) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Color(0xFF06B6D4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Análisis de Simetría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...simetria.entries.map((entry) {
            final articulacion = entry.key;
            final data = entry.value as Map<String, dynamic>;
            final diferencia = data['diferencia'] ?? 0.0;
            final clasificacion = data['clasificacion'] ?? '';

            return _buildSymmetryItem(
              articulacion,
              diferencia,
              clasificacion,
              isDarkMode,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymmetryItem(
    String articulacion,
    dynamic diferencia,
    String clasificacion,
    bool isDarkMode,
  ) {
    Color color;
    if (clasificacion.contains('simétrico')) {
      color = const Color(0xFF10B981);
    } else if (clasificacion.contains('leve')) {
      color = const Color(0xFFF59E0B);
    } else if (clasificacion.contains('moderada')) {
      color = const Color(0xFFFB923C);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                articulacion.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Text(
                '${(diferencia as num).toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              clasificacion,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAngleValidationCard({
    required bool isDarkMode,
    required Map<String, dynamic> validacion,
  }) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.straighten,
                  color: Color(0xFFEC4899),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Validación de Ángulos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...validacion.entries.map((entry) {
            final articulacion = entry.key;
            final lados = entry.value as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulacion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                ...lados.entries.map((lado) {
                  final ladoNombre = lado.key;
                  final data = lado.value as Map<String, dynamic>;
                  final valido = data['valido'] ?? false;
                  final actual = data['actual'] ?? 0.0;
                  final objetivo = data['objetivo'] ?? 0.0;
                  final diferencia = data['diferencia'] ?? 0.0;

                  return _buildAngleValidationItem(
                    ladoNombre,
                    valido,
                    actual,
                    objetivo,
                    diferencia,
                    isDarkMode,
                  );
                }),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAngleValidationItem(
    String lado,
    bool valido,
    dynamic actual,
    dynamic objetivo,
    dynamic diferencia,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            valido ? Icons.check_circle : Icons.cancel,
            color: valido ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$lado: ${(actual as num).toStringAsFixed(1)}° (objetivo: ${(objetivo as num).toStringAsFixed(0)}°)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  'Diferencia: ${(diferencia as num).toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: valido ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard({
    required bool isDarkMode,
    required List<String> recomendaciones,
  }) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recomendaciones.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.substring(0, rec.indexOf(' ') + 1),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.substring(rec.indexOf(' ') + 1),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
