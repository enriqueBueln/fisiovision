import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fisiovision/services/websocket_service.dart';
import 'package:fisiovision/services/sesion_service.dart';
import 'package:fisiovision/models/sesion_model.dart';
import 'dart:convert';

class LaptopViewerScreen extends StatefulWidget {
  const LaptopViewerScreen({super.key});

  @override
  State<LaptopViewerScreen> createState() => _LaptopViewerScreenState();
}

class _LaptopViewerScreenState extends State<LaptopViewerScreen> {
  final _sessionIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _wsService = WebSocketService();
  final _sesionService = SesionService();

  bool _isConnecting = false;
  bool _isConnected = false;
  SesionResponse? _sesion;
  Map<String, dynamic>? _latestAnalysis;
  String? _currentFrameBase64;
  int _frameCount = 0;

  @override
  void dispose() {
    _sessionIdController.dispose();
    _wsService.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);

    try {
      final sessionId = int.parse(_sessionIdController.text);

      // Verificar que la sesión existe y obtener detalles
      _sesion = await _sesionService.getSesion(sessionId);

      // Verificar estado del stream
      final streamStatus = await _sesionService.getStreamStatus(sessionId);

      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Sesión verificada! Redirigiendo...'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          duration: const Duration(seconds: 1),
        ),
      );

      // Redirigir a laptop-feedback con el ID de sesión
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      print('🚀 Redirigiendo a laptop-feedback con sessionId: $sessionId');
      context.push('/laptop-feedback', extra: sessionId);
    } catch (e) {
      setState(() => _isConnecting = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDisconnect() async {
    await _wsService.disconnect();
    setState(() {
      _isConnected = false;
      _sesion = null;
      _latestAnalysis = null;
      _currentFrameBase64 = null;
      _frameCount = 0;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Desconectado'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.laptop_mac, color: Color(0xFF1E88E5)),
            const SizedBox(width: 12),
            const Text(
              'Visualizador - Laptop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _handleDisconnect,
              tooltip: 'Desconectar',
            ),
        ],
      ),
      body: _isConnected ? _buildConnectedView(isDarkMode) : _buildConnectionForm(isDarkMode),
    );
  }

  Widget _buildConnectionForm(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono principal
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.laptop_chromebook_rounded,
                size: 60,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 32),

            // Título
            Text(
              "Conectar a Sesión",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Ingresa el ID de sesión que aparece en el móvil para visualizar el análisis en tiempo real.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Formulario
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Etiqueta
                    Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 20,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ID de Sesión',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Campo de ID
                    TextFormField(
                      controller: _sessionIdController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "123",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white24 : Colors.grey[300],
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF0F1629)
                            : const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E88E5),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el ID de sesión';
                        }
                        if (int.tryParse(value) == null) {
                          return 'ID inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón conectar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isConnecting ? null : _handleConnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor:
                              isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        ),
                        child: _isConnecting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cast_connected, size: 22),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'CONECTAR',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedView(bool isDarkMode) {
    return Column(
      children: [
        // Header con información de sesión
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cast_connected,
                  color: Color(0xFF1E88E5),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sesión #${_sesion?.id ?? ""}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'EN VIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (_sesion?.ejercicio != null)
                      Text(
                        _sesion!.ejercicio!.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Frames',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$_frameCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Contenido principal
        Expanded(
          child: _latestAnalysis == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E88E5),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Esperando frames del móvil...',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frame procesado
                      if (_currentFrameBase64 != null)
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 500),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              base64Decode(_currentFrameBase64!.split(',').last),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Ángulos detectados
                      if (_latestAnalysis!['angulos'] != null) ...[
                        Text(
                          'Ángulos Detectados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: (_latestAnalysis!['angulos'] as Map<String, dynamic>)
                              .entries
                              .map((entry) => _buildAngleCard(
                                    entry.key,
                                    entry.value,
                                    isDarkMode,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAngleCard(String name, dynamic value, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
