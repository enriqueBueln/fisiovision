import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:fisiovision/services/websocket_service.dart';
import 'package:fisiovision/services/voice_service.dart';
import 'package:fisiovision/services/speech_service.dart';
import 'dart:convert';

class MobileCameraView extends StatefulWidget {
  final int? sessionId;
  
  const MobileCameraView({
    super.key,
    this.sessionId,
  });

  @override
  State<MobileCameraView> createState() => _MobileCameraViewState();
}

class _MobileCameraViewState extends State<MobileCameraView> {
  CameraController? _cameraController;
  final _wsService = WebSocketService();
  final _voiceService = VoiceService();
  final _speechService = SpeechService();
  bool _isStreaming = false;
  int _framesSent = 0;
  bool _isInitializing = true;
  
  // Configuración de visualización
  bool _showSkeleton = true;
  bool _showAngles = true;
  String? _selectedAngle;
  
  // Control de voz
  bool _voiceEnabled = true;

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _speechService.initialize();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopStreaming();
    _cameraController?.dispose();
    _wsService.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No hay cámaras disponibles');
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      setState(() => _isInitializing = false);

      // Iniciar streaming automáticamente
      _startFrameStreaming();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar cámara: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  DateTime? _lastVoiceInstruction;
  double _currentAngle = 0.0;

  Future<void> _startFrameStreaming() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isStreaming = true);

    // Iniciar escucha continua de comandos de voz
    // Intentar primero español de España, luego México, luego genérico
    try {
      await _speechService.startListening(
        onResult: _processVoiceCommand,
        localeId: 'es_ES',
      );
    } catch (e) {
      print('⚠️ No se pudo iniciar con es_ES, intentando es_MX');
      try {
        await _speechService.startListening(
          onResult: _processVoiceCommand,
          localeId: 'es_MX',
        );
      } catch (e) {
        print('⚠️ No se pudo iniciar con es_MX, usando sistema por defecto');
        await _speechService.startListening(
          onResult: _processVoiceCommand,
          localeId: 'es',
        );
      }
    }

    // Escuchar respuestas del WebSocket para instrucciones de voz
    _wsService.stream.listen((data) {
      if (mounted && data['angulos'] != null && _voiceEnabled) {
        _processAnglesForVoiceInstructions(data['angulos']);
      }
    });

    // Enviar frames cada 100ms (10 fps)
    while (_isStreaming && mounted) {
      try {
        final image = await _cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        _wsService.sendFrame(
          frameBase64: 'data:image/jpeg;base64,$base64Image',
          timestamp: DateTime.now().toIso8601String(),
          frameNumber: _framesSent + 1,
          showSkeleton: _showSkeleton,
          showAngles: _showAngles,
          specificAngles: _selectedAngle != null ? [_selectedAngle!] : null,
        );

        setState(() => _framesSent++);

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Error enviando frame: $e');
      }
    }
  }

  void _processAnglesForVoiceInstructions(Map<String, dynamic> angulos) {
    if (!_voiceEnabled || angulos.isEmpty) return;

    // Evitar dar instrucciones muy seguidas (mínimo 3 segundos)
    final now = DateTime.now();
    if (_lastVoiceInstruction != null &&
        now.difference(_lastVoiceInstruction!).inSeconds < 3) {
      return;
    }

    _lastVoiceInstruction = now;

    // Obtener el primer ángulo disponible
    final firstJoint = angulos.values.first;
    if (firstJoint is Map) {
      final firstValue = (firstJoint as Map<String, dynamic>).values.first;
      if (firstValue is num) {
        _currentAngle = firstValue.toDouble();
      }
    } else if (firstJoint is num) {
      _currentAngle = firstJoint.toDouble();
    }

    // Dar instrucción según el ángulo
    if (_currentAngle >= 80 && _currentAngle <= 95) {
      // Ángulo perfecto
      if (_framesSent % 50 == 0) { // Cada 50 frames (~5 segundos)
        _voiceService.speakExcellent();
      }
    } else if (_currentAngle >= 70 && _currentAngle <= 105) {
      // Ángulo necesita ajuste
      _voiceService.speakAdjust();
    } else if (_currentAngle < 70) {
      // Muy bajo
      _voiceService.speakHigher();
    } else if (_currentAngle > 105) {
      // Muy alto
      _voiceService.speakLower();
    }
  }

  void _toggleVoice() {
    setState(() {
      _voiceEnabled = !_voiceEnabled;
    });

    if (_voiceEnabled) {
      _voiceService.speak("Instrucciones de voz activadas");
    } else {
      _voiceService.speak("Instrucciones de voz desactivadas");
    }
  }



  /// Procesar comando de voz con reconocimiento flexible
  void _processVoiceCommand(String command) {
    print('🎤 Comando recibido: "$command"');
    
    // Normalizar comando: minúsculas, sin acentos, sin espacios extras
    final cmd = command.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
    
    bool commandRecognized = false;
    
    // Detectar acción (mostrar u ocultar)
    final bool isMostrar = cmd.contains('mostrar') || cmd.contains('muestra') || cmd.contains('ver') || cmd.contains('enseñar');
    final bool isOcultar = cmd.contains('ocultar') || cmd.contains('oculta') || cmd.contains('esconder') || cmd.contains('quitar');
    
    // Esqueleto
    if ((isMostrar || isOcultar) && (cmd.contains('esqueleto') || cmd.contains('hueso'))) {
      setState(() => _showSkeleton = isMostrar);
      _voiceService.speak(isMostrar ? "Esqueleto visible" : "Esqueleto oculto");
      commandRecognized = true;
    }
    
    // Ángulos generales
    else if ((isMostrar || isOcultar) && (cmd.contains('angulo') || cmd.contains('numero'))) {
      setState(() => _showAngles = isMostrar);
      _voiceService.speak(isMostrar ? "Ángulos visibles" : "Ángulos ocultos");
      commandRecognized = true;
    }
    
    // Ángulos específicos
    else if (isMostrar) {
      String? angle;
      String? angleName;
      
      if (cmd.contains('codo')) {
        angle = 'codo';
        angleName = 'codo';
      } else if (cmd.contains('rodilla')) {
        angle = 'rodilla';
        angleName = 'rodilla';
      } else if (cmd.contains('hombro')) {
        angle = 'hombro';
        angleName = 'hombro';
      } else if (cmd.contains('cadera')) {
        angle = 'cadera';
        angleName = 'cadera';
      } else if (cmd.contains('tobillo') || cmd.contains('pie')) {
        angle = 'tobillo';
        angleName = 'tobillo';
      }
      
      if (angle != null) {
        setState(() {
          _selectedAngle = angle;
          _showAngles = true;
        });
        _voiceService.speak("Mostrando $angleName");
        commandRecognized = true;
      }
    }
    
    // Mostrar/ocultar todo
    if ((isMostrar || isOcultar) && (cmd.contains('todo') || cmd.contains('completo'))) {
      setState(() {
        _selectedAngle = null;
        _showSkeleton = isMostrar;
        _showAngles = isMostrar;
      });
      _voiceService.speak(isMostrar ? "Mostrando todo" : "Todo oculto");
      commandRecognized = true;
    }
    
    // Si no se reconoció el comando
    if (!commandRecognized) {
      print('⚠️ Comando no reconocido: "$command"');
      // No dar feedback de error para evitar interrupciones constantes
    }
  }

  void _stopStreaming() {
    _speechService.stopListening();
    setState(() {
      _isStreaming = false;
    });
  }

  void _handleStop() {
    _stopStreaming();
    _wsService.disconnect();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Vista de cámara
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Center(
              child: CameraPreview(_cameraController!),
            )
          else
            Center(
              child: Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Text("VISTA DE CÁMARA", style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),
          
          // 2. INDICADOR DE ESTADO Y CONTROLES (Arriba)
          SafeArea(
            child: Column(
              children: [
                // Indicador de estado
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "EN VIVO - Frames: $_framesSent",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Controles de visualización
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.settings, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Visualización',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Skeleton toggle
                          GestureDetector(
                            onTap: () => setState(() => _showSkeleton = !_showSkeleton),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _showSkeleton ? Colors.green : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.accessibility,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Esqueleto',
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Angles toggle
                          GestureDetector(
                            onTap: () => setState(() => _showAngles = !_showAngles),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _showAngles ? Colors.blue : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.straighten,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Ángulos',
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Specific angle dropdown
                          PopupMenuButton<String?>(
                            initialValue: _selectedAngle,
                            onSelected: (value) => setState(() => _selectedAngle = value),
                            color: Colors.grey.shade800,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedAngle != null ? Colors.orange : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedAngle ?? 'Todos',
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: null,
                                child: Text('Todos', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'codo',
                                child: Text('Codo', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'rodilla',
                                child: Text('Rodilla', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'hombro',
                                child: Text('Hombro', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'cadera',
                                child: Text('Cadera', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'tobillo',
                                child: Text('Tobillo', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. CONTROLES (Abajo)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.black45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón de instrucciones por voz
                  FloatingActionButton(
                    backgroundColor: _voiceEnabled ? Colors.green : Colors.grey,
                    onPressed: _toggleVoice,
                    child: Icon(
                      _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                      size: 30,
                    ),
                  ),
                  
                  // Botón de detener
                  FloatingActionButton.large(
                    backgroundColor: Colors.red,
                    onPressed: _handleStop,
                    child: const Icon(Icons.stop, size: 40),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}