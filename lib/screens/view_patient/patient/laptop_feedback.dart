import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fisiovision/services/websocket_service.dart';
import 'package:fisiovision/services/sesion_service.dart';
import 'package:fisiovision/services/ejercicio_service.dart';
import 'package:fisiovision/models/ejercicio_model.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

class LaptopFeedbackView extends StatefulWidget {
  final int? sessionId;
  
  const LaptopFeedbackView({
    super.key,
    this.sessionId,
  });

  @override
  State<LaptopFeedbackView> createState() =>
      _LaptopFeedbackViewState();
}

class _LaptopFeedbackViewState extends State<LaptopFeedbackView> {
  final _wsService = WebSocketService();
  final _sesionService = SesionService();
  final _ejercicioService = EjercicioService();
  
  bool _isSessionActive = true;
  int _currentReps = 8;
  int _totalReps = 15;
  double _currentAngle = 85.0;
  int _elapsedSeconds = 0;
  
  String? _currentFrameBase64;
  int _frameCount = 0;
  Map<String, dynamic>? _latestAnalysis;
  
  // Timer y tracking de tiempo
  Timer? _timer;
  DateTime? _sessionStartTime;
  
  // Latidos del corazón
  int _heartRate = 72;
  Timer? _heartRateTimer;
  final _random = Random();
  
  // Información del ejercicio
  Ejercicio? _ejercicio;
  Map<String, Map<String, int>>? _objetivoAngulos; // {rodilla: {izquierdo: 90, derecho: 90}}
  double? _tolerancia;
  String _currentArticulacion = 'rodilla';
  String _currentLado = 'izquierdo';
  
  // Acelerómetro (simulado)
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 9.8; // Gravedad
  Timer? _accelTimer;
  double _movementIntensity = 0.0; // 0.0 a 1.0

  @override
  void initState() {
    super.initState();
    print('🎬 [LaptopFeedback] initState - sessionId recibido: ${widget.sessionId}');
    _sessionStartTime = DateTime.now();
    _startTimers();
    _loadExerciseData();
    _connectToStream();
  }
  
  void _startTimers() {
    // Timer para actualizar el cronómetro cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _sessionStartTime != null) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_sessionStartTime!).inSeconds;
        });
      }
    });
    
    // Timer para actualizar los latidos cada 3-5 segundos de forma aleatoria
    _updateHeartRate();
    
    // Timer para actualizar acelerómetro cada 200ms
    _updateAccelerometer();
  }
  
  void _updateHeartRate() {
    _heartRateTimer?.cancel();
    
    if (mounted) {
      setState(() {
        // Generar latidos en rango normal: 60-100 BPM
        // Durante ejercicio leve-moderado: 70-90 BPM es prudente
        _heartRate = 70 + _random.nextInt(21); // 70-90
      });
      
      // Programar próxima actualización en 3-5 segundos
      final nextUpdate = Duration(seconds: 3 + _random.nextInt(3));
      _heartRateTimer = Timer(nextUpdate, _updateHeartRate);
    }
  }
  
  void _updateAccelerometer() {
    _accelTimer?.cancel();
    
    if (mounted) {
      setState(() {
        // Simular datos de acelerómetro (m/s²)
        // X e Y varían según el movimiento, Z cerca de 9.8 (gravedad)
        
        // Generar movimiento base aleatorio
        final baseMovement = _random.nextDouble() * 0.3; // 0.0 - 0.3
        
        // Ocasionalmente (20% del tiempo) simular movimiento más intenso
        final isIntenseMovement = _random.nextDouble() < 0.2;
        final intensityFactor = isIntenseMovement ? 3.0 : 1.0;
        
        _accelX = (_random.nextDouble() - 0.5) * 2.0 * intensityFactor; // -1.0 a 1.0 (o más si intenso)
        _accelY = (_random.nextDouble() - 0.5) * 2.0 * intensityFactor;
        _accelZ = 9.8 + (_random.nextDouble() - 0.5) * 0.5 * intensityFactor; // ~9.8 con variación
        
        // Calcular intensidad del movimiento (magnitud del vector sin gravedad)
        final magnitude = sqrt(_accelX * _accelX + _accelY * _accelY);
        _movementIntensity = (magnitude / 3.0).clamp(0.0, 1.0); // Normalizar 0-1
      });
      
      // Actualizar cada 200ms para simular frecuencia de sensor real
      _accelTimer = Timer(const Duration(milliseconds: 200), _updateAccelerometer);
    }
  }
  
  Future<void> _loadExerciseData() async {
    if (widget.sessionId == null) return;
    
    try {
      print('📋 Cargando información del ejercicio...');
      // 1. Obtener la sesión
      final sesion = await _sesionService.getSesion(widget.sessionId!);
      print('✅ Sesión obtenida: ${sesion.ejercicio?.name}');
      
      // 2. Obtener el ejercicio completo con ángulos objetivo
      final ejercicios = await _ejercicioService.getEjercicios();
      final ejercicio = ejercicios.firstWhere(
        (e) => e.id == sesion.idEjercicio,
        orElse: () => throw Exception('Ejercicio no encontrado'),
      );
      
      print('✅ Ejercicio completo obtenido: ${ejercicio.name}');
      print('   Ángulos objetivo: ${ejercicio.objective_angles}');
      print('   Tolerancia: ${ejercicio.tolerance_degrees}°');
      
      // 3. Parsear ángulos objetivo
      if (ejercicio.objective_angles.isNotEmpty) {
        final parsed = jsonDecode(ejercicio.objective_angles) as Map<String, dynamic>;
        final angulosMap = <String, Map<String, int>>{};
        
        parsed.forEach((key, value) {
          if (value is Map) {
            angulosMap[key] = {
              'izquierdo': (value['izquierdo'] as num?)?.toInt() ?? 0,
              'derecho': (value['derecho'] as num?)?.toInt() ?? 0,
            };
          }
        });
        
        setState(() {
          _ejercicio = ejercicio;
          _objetivoAngulos = angulosMap;
          _tolerancia = ejercicio.tolerance_degrees;
          
          // Detectar primera articulación disponible
          if (angulosMap.isNotEmpty) {
            _currentArticulacion = angulosMap.keys.first;
          }
        });
        
        print('✅ Ángulos objetivo parseados: $_objetivoAngulos');
      }
    } catch (e) {
      print('❌ Error cargando ejercicio: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _heartRateTimer?.cancel();
    _accelTimer?.cancel();
    _wsService.dispose();
    super.dispose();
  }

  Future<void> _connectToStream() async {
    if (widget.sessionId == null) {
      print('❌ No hay sessionId');
      return;
    }

    print('🔌 Intentando conectar a analysis-stream para sesión ${widget.sessionId}');

    try {
      await _wsService.connectAnalysisStream(widget.sessionId!);
      print('✅ Conectado a WebSocket analysis-stream');
      print('🎧 Escuchando stream...');

      _wsService.stream.listen(
        (data) {
          print('📨 Mensaje recibido del WebSocket');
          print('   Tipo: ${data['type']}');
          
          if (mounted && data['type'] != 'ping' && data['type'] != 'pong') {
            print('📦 Datos recibidos: ${data.keys}');
            if (data['frame_procesado'] != null) {
              final frameStr = data['frame_procesado'] as String;
              final framePreview = frameStr.length > 50 ? frameStr.substring(0, 50) : frameStr;
              print('🖼️ Frame recibido (${frameStr.length} chars): $framePreview...');
            }
            
            setState(() {
              _latestAnalysis = data;
              _currentFrameBase64 = data['frame_procesado'];
              _frameCount = data['frame_number'] ?? _frameCount + 1;
              
              // Actualizar ángulos si están disponibles
              if (data['angulos'] != null) {
                final angulos = data['angulos'] as Map<String, dynamic>;
                // angulos tiene estructura: {codo: {izquierdo: 145.2, derecho: 148.7}}
                
                // Extraer ángulo de la articulación y lado específico
                if (angulos.containsKey(_currentArticulacion)) {
                  final articulacionData = angulos[_currentArticulacion];
                  if (articulacionData is Map && articulacionData.containsKey(_currentLado)) {
                    final anguloValue = articulacionData[_currentLado];
                    if (anguloValue is num) {
                      _currentAngle = anguloValue.toDouble();
                    }
                  }
                }
              }
            });
          } else {
            print('⏭️ Ignorando mensaje tipo: ${data['type']}');
          }
        },
        onError: (error) {
          print('❌ Error en WebSocket: $error');
        },
        onDone: () {
          print('🔚 WebSocket cerrado');
        },
      );
    } catch (e) {
      print('❌ Error conectando a stream: $e');
    }
  }

  int? _getTargetAngle() {
    if (_objetivoAngulos == null) return null;
    if (!_objetivoAngulos!.containsKey(_currentArticulacion)) return null;
    
    final articulacionAngulos = _objetivoAngulos![_currentArticulacion]!;
    return articulacionAngulos[_currentLado];
  }
  
  Color _getAngleColor() {
    final target = _getTargetAngle();
    if (target == null || _tolerancia == null) {
      // Sin datos del ejercicio, usar lógica genérica
      if (_currentAngle >= 80 && _currentAngle <= 95) {
        return const Color(0xFF10B981);
      } else if (_currentAngle >= 70 && _currentAngle <= 105) {
        return const Color(0xFFF59E0B);
      } else {
        return const Color(0xFFEF4444);
      }
    }
    
    // Comparar con objetivo del ejercicio
    final diferencia = (_currentAngle - target).abs();
    
    if (diferencia <= _tolerancia!) {
      return const Color(0xFF10B981); // Verde - Perfecto
    } else if (diferencia <= _tolerancia! * 2) {
      return const Color(0xFFF59E0B); // Ámbar - Cerca
    } else {
      return const Color(0xFFEF4444); // Rojo - Muy lejos
    }
  }

  String _getFeedbackMessage() {
    final target = _getTargetAngle();
    if (target == null || _tolerancia == null) {
      // Sin datos del ejercicio
      return "Cargando objetivo...";
    }
    
    final diferencia = _currentAngle - target;
    final diferenciaAbs = diferencia.abs();
    
    if (diferenciaAbs <= _tolerancia!) {
      return "¡Perfecto! Mantén esa posición";
    } else if (diferenciaAbs <= _tolerancia! * 1.5) {
      if (diferencia > 0) {
        return "Muy bien, flexiona un poco más";
      } else {
        return "Muy bien, extiende un poco más";
      }
    } else if (diferenciaAbs <= _tolerancia! * 2) {
      if (diferencia > 0) {
        return "Flexiona más la articulación";
      } else {
        return "Extiende más la articulación";
      }
    } else {
      if (diferencia > 0) {
        return "Necesitas flexionar mucho más";
      } else {
        return "Necesitas extender mucho más";
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  Color _getMovementColor() {
    if (_movementIntensity < 0.3) {
      return const Color(0xFF10B981); // Verde - Estable
    } else if (_movementIntensity < 0.6) {
      return const Color(0xFFF59E0B); // Ámbar - Movimiento moderado
    } else {
      return const Color(0xFFEF4444); // Rojo - Mucho movimiento
    }
  }
  
  String _getMovementMessage() {
    if (_movementIntensity < 0.2) {
      return "Excelente estabilidad";
    } else if (_movementIntensity < 0.4) {
      return "Buen control del cuerpo";
    } else if (_movementIntensity < 0.6) {
      return "Intenta moverte menos";
    } else if (_movementIntensity < 0.8) {
      return "¡Te estás moviendo mucho!";
    } else {
      return "¡Mantén el cuerpo estable!";
    }
  }
  
  IconData _getMovementIcon() {
    if (_movementIntensity < 0.3) {
      return Icons.check_circle_outline;
    } else if (_movementIntensity < 0.6) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [LaptopFeedback] build - sessionId: ${widget.sessionId}, frameCount: $_frameCount, hasFrame: ${_currentFrameBase64 != null}');
    
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
                    // Frame de video
                    if (_currentFrameBase64 != null)
                      Image.memory(
                        base64Decode(
                          _currentFrameBase64!.contains(',')
                              ? _currentFrameBase64!.split(',').last
                              : _currentFrameBase64!,
                        ),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.red.shade900,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Colors.white, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error al decodificar imagen',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    error.toString(),
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: isDarkMode
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Esperando frames del móvil...',
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
                  // ÁNGULO
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Ángulo ${_currentArticulacion}",
                    icon: Icons.architecture,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Ángulo actual
                        Text(
                          '${_currentAngle.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: angleColor,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Mostrar objetivo y diferencia
                        if (_getTargetAngle() != null && _tolerancia != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Objetivo: ${_getTargetAngle()}°',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: angleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '±${_tolerancia!.toStringAsFixed(0)}°',
                                  style: TextStyle(
                                    color: angleColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Barra de progreso visual
                          _AngleProgressBar(
                            current: _currentAngle,
                            target: _getTargetAngle()!.toDouble(),
                            tolerance: _tolerancia!,
                            color: angleColor,
                            isDarkMode: isDarkMode,
                          ),
                        ] else
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
                              'Cargando objetivo...',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
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
                  const SizedBox(height: 16),

                  // FRECUENCIA CARDÍACA
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Frecuencia Cardíaca",
                    icon: Icons.favorite,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_heartRate',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFDC2626),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'BPM',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Normal',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ESTABILIDAD (ACELERÓMETRO)
                  _MetricCard(
                    isDarkMode: isDarkMode,
                    title: "Estabilidad corporal",
                    icon: Icons.speed,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Indicador visual de movimiento
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getMovementColor().withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                _getMovementIcon(),
                                size: 32,
                                color: _getMovementColor(),
                              ),
                              // Círculo pulsante según intensidad
                              if (_movementIntensity > 0.5)
                                Container(
                                  width: 70 * _movementIntensity,
                                  height: 70 * _movementIntensity,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getMovementColor().withOpacity(0.2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Datos del acelerómetro
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _AccelRow(
                                label: 'X',
                                value: _accelX,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 4),
                              _AccelRow(
                                label: 'Y',
                                value: _accelY,
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 4),
                              _AccelRow(
                                label: 'Z',
                                value: _accelZ,
                                isDarkMode: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Mensaje de feedback
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getMovementColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getMovementMessage(),
                            style: TextStyle(
                              color: _getMovementColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
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

// Widget para mostrar barra de progreso del ángulo
class _AngleProgressBar extends StatelessWidget {
  final double current;
  final double target;
  final double tolerance;
  final Color color;
  final bool isDarkMode;

  const _AngleProgressBar({
    required this.current,
    required this.target,
    required this.tolerance,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular el rango visible (target ± tolerance * 3 para mejor visualización)
    final minRange = target - (tolerance * 3);
    final maxRange = target + (tolerance * 3);
    
    // Posición normalizada del ángulo actual (0.0 a 1.0)
    final normalizedCurrent = ((current - minRange) / (maxRange - minRange)).clamp(0.0, 1.0);
    
    // Posición del objetivo (siempre en el centro, 0.5)
    final normalizedTarget = 0.5;
    
    // Zona de tolerancia normalizada
    final toleranceZone = tolerance / (maxRange - minRange);
    
    return Column(
      children: [
        // Diferencia con el objetivo
        Text(
          '${(current - target).abs().toStringAsFixed(1)}° de diferencia',
          style: TextStyle(
            color: isDarkMode
                ? const Color(0xFF64748B)
                : const Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        // Barra de progreso
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF1E293B)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Zona de tolerancia (verde)
              Positioned(
                left: (normalizedTarget - toleranceZone) * 100,
                child: Container(
                  width: (toleranceZone * 2) * 100,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Indicador del objetivo (línea vertical)
              Positioned(
                left: normalizedTarget * 100 - 1,
                child: Container(
                  width: 2,
                  height: 8,
                  color: const Color(0xFF10B981),
                ),
              ),
              // Indicador de la posición actual
              Positioned(
                left: (normalizedCurrent * 100) - 4,
                top: -2,
                child: Container(
                  width: 8,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Etiquetas de rango
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${minRange.toStringAsFixed(0)}°',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
            Text(
              '${maxRange.toStringAsFixed(0)}°',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget para mostrar una fila de datos del acelerómetro
class _AccelRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isDarkMode;

  const _AccelRow({
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: isDarkMode
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)} m/s²',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF1E293B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFeatures: const [
              FontFeature.tabularFigures(),
            ],
          ),
        ),
      ],
    );
  }
}
