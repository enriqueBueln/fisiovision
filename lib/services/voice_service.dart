import 'package:flutter_tts/flutter_tts.dart';

/// Servicio para dar instrucciones por voz usando Text-to-Speech
class VoiceService {
  // Singleton pattern
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Inicializar el servicio de voz
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar idioma español
      await _flutterTts.setLanguage("es-ES");
      
      // Configurar velocidad (0.0 - 1.0, donde 0.5 es normal)
      await _flutterTts.setSpeechRate(0.5);
      
      // Configurar volumen (0.0 - 1.0)
      await _flutterTts.setVolume(1.0);
      
      // Configurar tono (0.5 - 2.0, donde 1.0 es normal)
      await _flutterTts.setPitch(1.0);

      // Callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        print('🗣️ [VoiceService] Comenzando a hablar');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        print('✅ [VoiceService] Terminó de hablar');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        print('❌ [VoiceService] Error: $msg');
      });

      _isInitialized = true;
      print('✅ [VoiceService] Inicializado correctamente');
    } catch (e) {
      print('❌ [VoiceService] Error inicializando: $e');
    }
  }

  /// Hablar un texto
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      print('🗣️ [VoiceService] Hablando: "$text"');
      await _flutterTts.speak(text);
    } catch (e) {
      print('❌ [VoiceService] Error al hablar: $e');
    }
  }

  /// Detener la voz actual
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('❌ [VoiceService] Error al detener: $e');
    }
  }

  /// Pausar
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('❌ [VoiceService] Error al pausar: $e');
    }
  }

  /// Verificar si está hablando
  bool get isSpeaking => _isSpeaking;

  /// Liberar recursos
  void dispose() {
    _flutterTts.stop();
  }

  // Métodos de conveniencia para instrucciones comunes
  Future<void> speakExcellent() => speak("¡Excelente! Mantén esa postura.");
  
  Future<void> speakAdjust() => speak("Ajusta tu postura un poco.");
  
  Future<void> speakWrong() => speak("Revisa tu postura, algo no está bien.");
  
  Future<void> speakHigher() => speak("Sube un poco más.");
  
  Future<void> speakLower() => speak("Baja un poco más.");
  
  Future<void> speakSlower() => speak("Ve más despacio.");
  
  Future<void> speakFaster() => speak("Puedes ir un poco más rápido.");
  
  Future<void> speakRest() => speak("Descansa un momento.");
  
  Future<void> speakContinue() => speak("Continúa así, muy bien.");
  
  Future<void> speakRepetition(int current, int total) => 
      speak("Repetición $current de $total.");
  
  Future<void> speakCompleted() => speak("¡Ejercicio completado! Buen trabajo.");
  
  Future<void> speakReady() => speak("Listo para comenzar.");
  
  Future<void> speakStart() => speak("¡Comencemos!");
}
