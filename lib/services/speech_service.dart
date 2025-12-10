import 'package:speech_to_text/speech_to_text.dart';

/// Servicio para reconocimiento de voz (Speech-to-Text)
class SpeechService {
  // Singleton pattern
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _shouldKeepListening = false;
  bool _isRestarting = false;

  /// Callback cuando se reconoce texto
  Function(String)? onResult;
  String? _currentLocaleId;

  /// Inicializar el servicio de reconocimiento de voz
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          print('❌ [SpeechService] Error: ${error.errorMsg}');
          _isListening = false;
          // Reintentar si debe seguir escuchando
          if (_shouldKeepListening) {
            Future.delayed(const Duration(seconds: 2), () {
              if (_shouldKeepListening && onResult != null && _currentLocaleId != null) {
                startListening(onResult: onResult!, localeId: _currentLocaleId!);
              }
            });
          }
        },
        onStatus: (status) {
          print('📊 [SpeechService] Estado: $status');
          _isListening = status == 'listening';
          
          // Cuando termina de escuchar, reiniciar automáticamente
          if ((status == 'notListening' || status == 'done') && _shouldKeepListening && !_isRestarting) {
            _isRestarting = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_shouldKeepListening && !_isListening && onResult != null && _currentLocaleId != null) {
                print('🔄 [SpeechService] Reiniciando escucha...');
                _isRestarting = false;
                startListening(onResult: onResult!, localeId: _currentLocaleId!);
              } else {
                _isRestarting = false;
              }
            });
          }
        },
        debugLogging: false,
      );

      if (_isInitialized) {
        // Verificar idiomas disponibles
        var locales = await _speech.locales();
        var spanishLocales = locales.where((l) => l.localeId.startsWith('es')).toList();
        print('✅ [SpeechService] Inicializado: $_isInitialized');
        print('🌍 Idiomas español disponibles: ${spanishLocales.map((l) => l.localeId).join(", ")}');
      }
      
      return _isInitialized;
    } catch (e) {
      print('❌ [SpeechService] Error inicializando: $e');
      return false;
    }
  }

  /// Comenzar a escuchar de forma continua
  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'es_ES',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    _shouldKeepListening = true;
    this.onResult = onResult;
    _currentLocaleId = localeId;

    if (_isListening || _isRestarting) {
      print('⚠️ [SpeechService] Ya está escuchando o reiniciando');
      return;
    }

    String lastPartialResult = '';
    
    try {
      await _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords.toLowerCase().trim();
          
          // LOG: Mostrar TODO lo que escucha
          print('👂 Escuchado: "$text" | Final: ${result.finalResult} | Confidence: ${result.confidence}');
          
          if (text.isEmpty) return;
          
          if (result.finalResult) {
            print('🎤 [SpeechService] ✅ FINAL: "$text"');
            print('🔍 Enviando comando a procesador...');
            onResult(text);
            lastPartialResult = '';
          } else {
            // Procesar resultados parciales si contienen comandos completos
            print('🎤 Parcial: "$text" | Palabras: ${text.split(' ').length}');
            if (text != lastPartialResult && text.split(' ').length >= 2) {
              // Detectar comandos completos en parciales
              final isCommand = _isCompleteCommand(text);
              print('🔎 ¿Es comando completo? $isCommand');
              if (isCommand) {
                print('🎤 [SpeechService] ⚡ Comando detectado en parcial: "$text"');
                print('🔍 Enviando comando a procesador...');
                onResult(text);
                lastPartialResult = text;
              }
            }
          }
        },
        localeId: localeId,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(milliseconds: 1500),
      );
      print('✅ Escucha iniciada en modo continuo');
    } catch (e) {
      print('❌ [SpeechService] Error al escuchar: $e');
      _isListening = false;
      _isRestarting = false;
    }
  }
  
  /// Detectar si un texto contiene un comando completo
  bool _isCompleteCommand(String text) {
    final commands = [
      'ocultar esqueleto', 'mostrar esqueleto',
      'ocultar angulo', 'mostrar angulo',
      'ocultar codo', 'mostrar codo',
      'ocultar rodilla', 'mostrar rodilla',
      'ocultar hombro', 'mostrar hombro',
      'ocultar cadera', 'mostrar cadera',
      'ocultar tobillo', 'mostrar tobillo',
      'mostrar todo', 'ocultar todo',
      'terminar sesion', 'terminar ejercicio', 'finalizar sesion',
      'acabar sesion', 'finalizar ejercicio', 'acabar ejercicio',
    ];
    
    print('🔍 Verificando si "$text" es comando...');
    for (var cmd in commands) {
      if (text.contains(cmd)) {
        print('✅ ¡Coincide con "$cmd"!');
        return true;
      }
    }
    print('❌ No coincide con ningún comando');
    return false;
  }

  /// Detener de escuchar
  Future<void> stopListening() async {
    _shouldKeepListening = false;
    _isRestarting = false;
    try {
      await _speech.stop();
      _isListening = false;
      print('🛑 [SpeechService] Detenido');
    } catch (e) {
      print('❌ [SpeechService] Error al detener: $e');
    }
  }

  /// Cancelar
  Future<void> cancel() async {
    try {
      await _speech.cancel();
      _isListening = false;
    } catch (e) {
      print('❌ [SpeechService] Error al cancelar: $e');
    }
  }

  /// Verificar si está escuchando
  bool get isListening => _isListening;

  /// Verificar si está disponible
  bool get isAvailable => _isInitialized;

  /// Obtener idiomas disponibles
  Future<List<LocaleName>> getLocales() async {
    return await _speech.locales();
  }
}
