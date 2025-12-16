import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:fisiovision/services/websocket_service.dart';
import 'package:fisiovision/services/voice_service.dart';
import 'package:fisiovision/services/speech_service.dart';
import 'package:fisiovision/services/sesion_service.dart';
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
  void dispose() async {
    print('🔄 Liberando recursos de la cámara...');
    _stopStreaming();
    
    // Asegurar que la cámara se libere correctamente
    try {
      await _cameraController?.dispose();
      _cameraController = null;
      print('✅ Cámara liberada');
    } catch (e) {
      print('⚠️ Error al liberar cámara: $e');
    }
    
    _wsService.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print('🎥 Intento ${retryCount + 1} de inicializar cámara...');
        
        // Limpiar controlador previo si existe
        await _cameraController?.dispose();
        _cameraController = null;
        
        // Pequeña espera para liberar recursos
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw Exception('No hay cámaras disponibles en el dispositivo');
        }

        print('📱 Cámaras disponibles: ${cameras.length}');
        
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        print('📷 Usando cámara: ${frontCamera.name}');

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();
        
        if (!mounted) return;
        
        setState(() => _isInitializing = false);

        print('✅ Cámara inicializada exitosamente');

        // Iniciar streaming automáticamente
        _startFrameStreaming();
        return; // Éxito, salir del bucle
        
      } catch (e) {
        retryCount++;
        print('❌ Error intento $retryCount: $e');
        
        if (retryCount >= maxRetries) {
          // Último intento falló
          if (mounted) {
            String errorMessage;
            if (e.toString().contains('cameraNotReadable')) {
              errorMessage = 'La cámara está siendo usada por otra aplicación.\n\n'
                  '📱 Si estás en móvil:\n'
                  '• Cierra otras apps de cámara\n'
                  '• Reinicia la app\n\n'
                  '💻 Si estás en Windows:\n'
                  '• Cierra Chrome, Teams, Zoom\n'
                  '• Verifica Configuración → Privacidad → Cámara\n'
                  '• Detén el debug (q) y corre: flutter run';
            } else if (e.toString().contains('CameraException')) {
              errorMessage = 'Error de hardware de cámara.\n\n'
                  'Soluciones:\n'
                  '1. Reinicia el dispositivo\n'
                  '2. Verifica permisos de cámara\n'
                  '3. Prueba con otra cámara';
            } else {
              errorMessage = 'Error al inicializar cámara:\n$e\n\n'
                  'Presiona Reintentar después de:\n'
                  '• Cerrar apps que usen la cámara\n'
                  '• Verificar permisos';
            }
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Error de Cámara'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        final cameras = await availableCameras();
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cámaras Disponibles'),
                            content: Text(
                              cameras.isEmpty
                                  ? 'No se detectaron cámaras'
                                  : cameras.map((c) => '${c.name}\n${c.lensDirection}').join('\n\n'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Ver Cámaras'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    child: const Text('Cerrar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isInitializing = true;
                      });
                      _initializeCamera();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return;
        }
        
        // Esperar antes del siguiente reintento
        await Future.delayed(Duration(seconds: retryCount));
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
    print('════════════════════════════════════════');
    print('🎤 COMANDO RECIBIDO: "$command"');
    print('════════════════════════════════════════');
    
    // Normalizar comando: minúsculas, sin acentos, sin espacios extras
    final cmd = command.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
    
    print('📝 Comando normalizado: "$cmd"');
    
    bool commandRecognized = false;
    
    // Detectar acción (mostrar u ocultar)
    final bool isMostrar = cmd.contains('mostrar') || cmd.contains('muestra') || cmd.contains('ver') || cmd.contains('enseñar');
    final bool isOcultar = cmd.contains('ocultar') || cmd.contains('oculta') || cmd.contains('esconder') || cmd.contains('quitar');
    
    print('🔍 Análisis: isMostrar=$isMostrar, isOcultar=$isOcultar');
    
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
    
    // Terminar sesión - más variaciones
    print('🔎 Verificando si es comando de terminar...');
    print('   - ¿Contiene terminar? ${cmd.contains('terminar')}');
    print('   - ¿Contiene finalizar? ${cmd.contains('finalizar')}');
    print('   - ¿Contiene acabar? ${cmd.contains('acabar')}');
    print('   - ¿Contiene sesion? ${cmd.contains('sesion')}');
    print('   - ¿Contiene ejercicio? ${cmd.contains('ejercicio')}');
    print('   - ¿Contiene entrenamiento? ${cmd.contains('entrenamiento')}');
    
    if ((cmd.contains('terminar') || cmd.contains('finalizar') || cmd.contains('acabar')) && 
        (cmd.contains('sesion') || cmd.contains('ejercicio') || cmd.contains('entrenamiento'))) {
      print('✅✅✅ Comando TERMINAR SESIÓN detectado ✅✅✅');
      _voiceService.speak("Finalizando sesión");
      Future.delayed(const Duration(milliseconds: 500), () {
        print('⏰ Ejecutando _finishSession...');
        _finishSession();
      });
      commandRecognized = true;
    } else {
      print('❌ NO es comando de terminar sesión');
    }
    
    // Si no se reconoció el comando
    if (!commandRecognized) {
      print('⚠️⚠️⚠️ Comando NO RECONOCIDO: "$command" ⚠️⚠️⚠️');
      print('════════════════════════════════════════');
      // No dar feedback de error para evitar interrupciones constantes
    } else {
      print('✅✅✅ Comando RECONOCIDO y PROCESADO ✅✅✅');
      print('════════════════════════════════════════');
    }
  }

  void _stopStreaming() {
    _speechService.stopListening();
    setState(() {
      _isStreaming = false;
    });
  }

  Future<void> _finishSession() async {
    print('🏁 Iniciando finalización de sesión...');
    
    if (widget.sessionId == null) {
      print('⚠️ No hay sessionId para finalizar');
      _voiceService.speak("No hay sesión activa");
      return;
    }

    print('🛑 Deteniendo streaming y WebSocket...');
    _stopStreaming();
    _wsService.disconnect();

    try {
      print('📤 Enviando petición para finalizar sesión ${widget.sessionId}...');
      final sesionService = SesionService();
      await sesionService.finishSesion(sessionId: widget.sessionId!);
      
      print('✅ Sesión finalizada exitosamente');
      
      if (mounted) {
        _voiceService.speak("Sesión completada. Por favor, déjanos tu feedback");
        // Dar tiempo a que termine de hablar antes de navegar
        await Future.delayed(const Duration(milliseconds: 500));
        
        print('🔀 Navegando a pantalla de feedback...');
        context.go('/session-feedback', extra: widget.sessionId);
      }
    } catch (e) {
      print('❌ Error al finalizar sesión: $e');
      if (mounted) {
        _voiceService.speak("Error al finalizar sesión");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        context.go('/home');
      }
    }
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

          // 3. TARJETA DE AYUDA DE COMANDOS DE VOZ
          Positioned(
            right: 16,
            bottom: 140,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Comandos de Voz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  _buildVoiceCommand('🦴', 'Mostrar/Ocultar esqueleto'),
                  _buildVoiceCommand('📐', 'Mostrar/Ocultar ángulos'),
                  _buildVoiceCommand('💪', 'Mostrar codo/rodilla/hombro'),
                  _buildVoiceCommand('👀', 'Mostrar/Ocultar todo'),
                  _buildVoiceCommand('🛑', 'Terminar sesión/ejercicio'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Tip: Habla claro y espera la confirmación',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. CONTROLES (Abajo)
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

  Widget _buildVoiceCommand(String emoji, String command) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              command,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}