// src/screens/session_analysis_screen.dart

import 'package:flutter/material.dart';
import 'package:fisiovision/models/analysis_model.dart';
import 'package:fisiovision/services/analysis_service.dart';

class SessionAnalysisScreen extends StatefulWidget {
  final int? sessionId;

  const SessionAnalysisScreen({super.key, this.sessionId});

  @override
  State<SessionAnalysisScreen> createState() =>
      _SessionAnalysisScreenState();
}

class _SessionAnalysisScreenState
    extends State<SessionAnalysisScreen> {
  final AnalysisService _analysisService = AnalysisService();
  AnalysisResponse? _analysis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessionId = widget.sessionId ?? 1;
      final analysis = await _analysisService.analyzeSesion(
        sessionId,
      );
      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Análisis de Sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading && _analysis != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAnalysis,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView(isDarkMode)
          : _analysis != null
          ? _buildAnalysisView(isDarkMode)
          : const SizedBox(),
    );
  }

  Widget _buildErrorView(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar análisis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisView(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información del ejercicio
          _buildExerciseHeader(isDarkMode),
          const SizedBox(height: 24),

          // Recomendación General
          _buildGeneralRecommendation(isDarkMode),
          const SizedBox(height: 24),

          // Clasificaciones
          _buildClassifications(isDarkMode),
          const SizedBox(height: 24),

          // Validación de Ángulos
          _buildAngleValidation(isDarkMode),
          const SizedBox(height: 24),

          // Análisis de Simetría
          _buildSymmetryAnalysis(isDarkMode),
          const SizedBox(height: 24),

          // Ángulos Promedio
          _buildAverageAngles(isDarkMode),
          const SizedBox(height: 24),

          // Recomendaciones Detalladas
          _buildDetailedRecommendations(isDarkMode),
          const SizedBox(height: 24),

          // Datos de Entrada
          _buildInputData(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)]
              : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _analysis!.ejercicio.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipo: ${_analysis!.ejercicio.tipo.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tag,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sesión #${_analysis!.idSesion}',
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

  Widget _buildGeneralRecommendation(bool isDarkMode) {
    final recomendacion =
        _analysis!.analisisProlog.recomendacionGeneral;
    final color = _getRecommendationColor(recomendacion);
    final icon = _getRecommendationIcon(recomendacion);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación General',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recomendacion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRecommendationColor(String recomendacion) {
    switch (recomendacion.toLowerCase()) {
      case 'continuar':
        return const Color(0xFF10B981);
      case 'pausar':
        return const Color(0xFFEF4444);
      case 'reducir':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getRecommendationIcon(String recomendacion) {
    switch (recomendacion.toLowerCase()) {
      case 'continuar':
        return Icons.check_circle;
      case 'pausar':
        return Icons.pause_circle;
      case 'reducir':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Widget _buildClassifications(bool isDarkMode) {
    final clasificaciones =
        _analysis!.analisisProlog.clasificaciones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clasificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildClassificationCard(
                'Postura',
                clasificaciones.postura,
                Icons.accessibility_new,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClassificationCard(
                'Dolor',
                clasificaciones.dolor,
                Icons.health_and_safety,
                isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildClassificationCard(
                'Intensidad',
                clasificaciones.intensidad,
                Icons.speed,
                isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationCard(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    final color = _getClassificationColor(value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getClassificationColor(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('buen') ||
        lower.contains('mínim') ||
        lower.contains('alt')) {
      return const Color(0xFF10B981);
    } else if (lower.contains('mal') || lower.contains('sever')) {
      return const Color(0xFFEF4444);
    } else if (lower.contains('medi') ||
        lower.contains('moderad')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF6B7280);
  }

  Widget _buildAngleValidation(bool isDarkMode) {
    final validacion = _analysis!.analisisProlog.validacionAngulos;

    if (validacion.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validación de Ángulos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...validacion.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAngleValidationCard(
              entry.key,
              entry.value,
              isDarkMode,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAngleValidationCard(
    String articulacion,
    ValidacionAngulo validacion,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            articulacion.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.grey[300]
                  : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSideValidation(
                  'Izquierdo',
                  validacion.izquierdo,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSideValidation(
                  'Derecho',
                  validacion.derecho,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideValidation(
    String lado,
    LadoValidacion validacion,
    bool isDarkMode,
  ) {
    final color = validacion.valido
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                validacion.valido
                    ? Icons.check_circle
                    : Icons.cancel,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                lado,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Actual: ${validacion.actual.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          Text(
            'Objetivo: ${validacion.objetivo}°',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          Text(
            'Dif: ${validacion.diferencia.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymmetryAnalysis(bool isDarkMode) {
    final simetria = _analysis!.analisisProlog.analisisSimetria;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Simetría',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...simetria.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSymmetryRow(
              entry.key,
              entry.value,
              isDarkMode,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSymmetryRow(
    String articulacion,
    AnalisisSimetria simetria,
    bool isDarkMode,
  ) {
    final color =
        simetria.clasificacion.toLowerCase() == 'simétrico'
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            simetria.clasificacion.toLowerCase() == 'simétrico'
                ? Icons.check_circle_outline
                : Icons.warning_amber,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulacion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diferencia: ${simetria.diferencia.toStringAsFixed(2)}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              simetria.clasificacion,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageAngles(bool isDarkMode) {
    final angulos = _analysis!.datosEntrada.angulosPromedio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ángulos Promedio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _buildAngleRow('Codo', angulos.codo, isDarkMode),
        _buildAngleRow('Cadera', angulos.cadera, isDarkMode),
        _buildAngleRow('Hombro', angulos.hombro, isDarkMode),
        _buildAngleRow('Rodilla', angulos.rodilla, isDarkMode),
        _buildAngleRow('Tobillo', angulos.tobillo, isDarkMode),
      ],
    );
  }

  Widget _buildAngleRow(
    String nombre,
    LadosAngulo angulo,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Izq.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${angulo.izquierdo.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                ),
                Column(
                  children: [
                    Text(
                      'Der.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${angulo.derecho.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedRecommendations(bool isDarkMode) {
    final recomendaciones =
        _analysis!.analisisProlog.recomendaciones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones Detalladas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...recomendaciones.map((rec) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRecommendationBorderColor(
                  rec,
                  isDarkMode,
                ),
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _extractEmoji(rec),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _removeEmoji(rec),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getRecommendationBorderColor(
    String rec,
    bool isDarkMode,
  ) {
    if (rec.contains('✅')) {
      return const Color(0xFF10B981).withOpacity(0.3);
    } else if (rec.contains('❌') || rec.contains('🛑')) {
      return const Color(0xFFEF4444).withOpacity(0.3);
    } else if (rec.contains('⚠️')) {
      return const Color(0xFFF59E0B).withOpacity(0.3);
    }
    return isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
  }

  String _extractEmoji(String text) {
    final emojis = ['✅', '❌', '🛑', '⚠️', '💡', '📊'];
    for (var emoji in emojis) {
      if (text.contains(emoji)) {
        return emoji;
      }
    }
    return '•';
  }

  String _removeEmoji(String text) {
    return text
        .replaceAll('✅', '')
        .replaceAll('❌', '')
        .replaceAll('🛑', '')
        .replaceAll('⚠️', '')
        .replaceAll('💡', '')
        .replaceAll('📊', '')
        .trim();
  }

  Widget _buildInputData(bool isDarkMode) {
    final datos = _analysis!.datosEntrada;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withOpacity(0.5)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Información Adicional',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Frames analizados: ${datos.totalFramesAnalizados}',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          if (datos.dolorReportado != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dolor reportado: ${datos.dolorReportado}',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
          if (datos.dolorAnterior != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dolor anterior: ${datos.dolorAnterior}',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
