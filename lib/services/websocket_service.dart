import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar conexiones WebSocket con el backend
class WebSocketService {
  static String get baseUrl =>
      dotenv.env['DATABASE_URL'] ?? 'http://localhost:8000';
  
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws');

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  
  bool _isConnected = false;
  int? _currentSessionId;

  /// Stream para escuchar mensajes del WebSocket
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// Indica si hay una conexión activa
  bool get isConnected => _isConnected;

  /// ID de la sesión actual conectada
  int? get currentSessionId => _currentSessionId;

  /// Obtener token de autenticación
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? 
           prefs.getString('flutter.access_token');
  }

  /// Conectar para enviar frames (móvil)
  /// WebSocket: /ws/{id_sesion}/send-frame
  Future<void> connectSendFrame(int sessionId) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      final token = await _getToken();
      final url = '$wsUrl/sesion/ws/$sessionId/send-frame';
      
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      _currentSessionId = sessionId;
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            _controller.add(data);
          } catch (e) {
            print('Error parseando mensaje WebSocket: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _isConnected = false;
          _controller.addError(error);
        },
        onDone: () {
          print('WebSocket cerrado');
          _isConnected = false;
          _currentSessionId = null;
        },
      );

      print('WebSocket conectado para enviar frames - Sesión: $sessionId');
    } catch (e) {
      _isConnected = false;
      _currentSessionId = null;
      throw Exception('Error conectando WebSocket: $e');
    }
  }

  /// Conectar para recibir análisis (laptop)
  /// WebSocket: /ws/{id_sesion}/analysis-stream
  Future<void> connectAnalysisStream(int sessionId) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      final token = await _getToken();
      final url = '$wsUrl/sesion/ws/$sessionId/analysis-stream';
      
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      _currentSessionId = sessionId;
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            
            // Responder a pings
            if (data['type'] == 'ping') {
              sendMessage({'type': 'pong'});
            } else {
              _controller.add(data);
            }
          } catch (e) {
            print('Error parseando mensaje WebSocket: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _isConnected = false;
          _controller.addError(error);
        },
        onDone: () {
          print('WebSocket cerrado');
          _isConnected = false;
          _currentSessionId = null;
        },
      );

      print('WebSocket conectado para análisis - Sesión: $sessionId');
      
      // Enviar ping inicial
      _startPingTimer();
    } catch (e) {
      _isConnected = false;
      _currentSessionId = null;
      throw Exception('Error conectando WebSocket: $e');
    }
  }

  Timer? _pingTimer;

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  /// Enviar frame al servidor (para móvil)
  void sendFrame({
    required String frameBase64,
    required String timestamp,
    required int frameNumber,
  }) {
    if (!_isConnected) {
      throw Exception('WebSocket no está conectado');
    }

    final message = {
      'frame': frameBase64,
      'timestamp': timestamp,
      'frame_number': frameNumber,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Enviar mensaje genérico
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      throw Exception('WebSocket no está conectado');
    }

    _channel!.sink.add(jsonEncode(message));
  }

  /// Desconectar WebSocket
  Future<void> disconnect() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    
    await _subscription?.cancel();
    await _channel?.sink.close();
    
    _isConnected = false;
    _currentSessionId = null;
    _channel = null;
    _subscription = null;
    
    print('WebSocket desconectado');
  }

  /// Limpiar recursos
  void dispose() {
    disconnect();
    _controller.close();
  }
}
