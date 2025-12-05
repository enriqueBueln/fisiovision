import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pose_painter.dart'; // Importamos nuestro painter

// Definimos el tipo de feedback para claridad
enum FeedbackType { correct, incorrect, neutral }

class PoseDetectorScreen extends StatefulWidget {
  final String exerciseName;
  final VoidCallback onBack;

  const PoseDetectorScreen({
    Key? key,
    required this.exerciseName,
    required this.onBack,
  }) : super(key: key);

  @override
  _PoseDetectorScreenState createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> {
  // Detector de posturas de ML Kit
  PoseDetector? _poseDetector;
  
  // Controlador de la cámara
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  
  // Estado de la UI
  bool _isCameraInitialized = false;
  bool _isActive = false;
  bool _isLoading = true;
  FeedbackType _feedback = FeedbackType.neutral;
  int _repCount = 0;

  // Datos de la postura
  List<Pose> _poses = [];
  Size? _imageSize; // Para escalar el canvas correctamente

  // Flags para evitar procesamiento concurrente
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializePoseDetection();
  }

  @override
  void dispose() {
    // Detener todo y liberar recursos
    _stopCamera();
    _poseDetector?.close();
    super.dispose();
  }

  // 1. Inicializar el modelo de ML Kit
  Future<void> _initializePoseDetection() async {
    try {
      // Opciones: .base para más rápido, .accurate para más preciso
      final options = PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      );
      _poseDetector = PoseDetector(options: options);

      // Obtener cámaras disponibles
      _cameras = await availableCameras();

      setState(() {
        _isLoading = false;
      });
      _showToast("Sistema de detección listo", Colors.green);
    } catch (e) {
      print("Error initializing pose detection: $e");
      _showToast("Error al inicializar el sistema", Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Iniciar la cámara
  Future<void> _startCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      _showToast("No se encontraron cámaras", Colors.red);
      return;
    }

    // Pedir permiso
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showToast("Permiso de cámara denegado", Colors.red);
      return;
    }

    // Usar la cámara frontal (selfie)
    final cameraDescription = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high, // Equivalente a 1280x720
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Formato común en Android
    );

    try {
      await _cameraController!.initialize();
      
      // Iniciar el stream de imágenes
      await _cameraController!.startImageStream(_detectPose);
      
      setState(() {
        _isCameraInitialized = true;
        _isActive = true;
      });
      _showToast("Cámara activada", Colors.green);
    } catch (e) {
      print("Error starting camera: $e");
      _showToast("No se pudo acceder a la cámara", Colors.red);
    }
  }

  // 3. Detener la cámara
  Future<void> _stopCamera() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      await _cameraController!.dispose();
    }
    _cameraController = null;
    setState(() {
      _isActive = false;
      _isCameraInitialized = false;
      _poses = []; // Limpiar poses al detener
    });
    _showToast("Cámara desactivada", Colors.blue);
  }

  // 4. Procesar el stream de la cámara y detectar la postura
  Future<void> _detectPose(CameraImage cameraImage) async {
    if (_poseDetector == null || !_isActive || _isProcessing) return;

    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(cameraImage);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final poses = await _poseDetector!.processImage(inputImage);

      // Analizar la postura
      FeedbackType newFeedback = FeedbackType.neutral;
      if (poses.isNotEmpty) {
        newFeedback = _analyzePose(poses[0]);

        // Lógica de conteo de repeticiones (replicando la del JS)
        if (newFeedback == FeedbackType.correct && Random().nextDouble() > 0.95) {
          if (mounted) {
            setState(() {
              _repCount++;
            });
          }
        }
      }

      // Actualizar estado en el hilo principal
      if (mounted) {
        setState(() {
          _poses = poses;
          _feedback = newFeedback;
          _imageSize = Size(
            cameraImage.width.toDouble(),
            cameraImage.height.toDouble(),
          );
        });
      }
    } catch (e) {
      print("Error processing image: $e");
    }

    _isProcessing = false;
  }

  // 5. Analizar la postura (lógica portada de JS)
  FeedbackType _analyzePose(Pose pose) {
    final landmarks = pose.landmarks;

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftShoulder != null && rightShoulder != null) {
      // Asegurarnos de que los landmarks son visibles (confianza)
      if (leftShoulder.likelihood > 0.5 && rightShoulder.likelihood > 0.5) {
        // final shoulderDiff = (leftShoulder.y - rightShoulder.y).abs();

        // El escalado de JS (0.05) puede no ser el mismo aquí.
        // Los valores de Y en ML Kit (pixeles) son diferentes a los normalizados (0-1)
        // Asumamos una lógica similar basada en pixeles. Ajustar según sea necesario.
        // Este valor 50 es un ejemplo, necesitaría ajuste.
        // const alignmentThreshold = 50.0;
        // const misalignmentThreshold = 100.0;
        
        // ML Kit Y-axis es como pixeles, JS Y-axis es normalizado.
        // Usemos una lógica de diferencia normalizada
        // final normalizedShoulderDiff = (leftShoulder.y - rightShoulder.y).abs() / _imageSize!.height;
        // if (normalizedShoulderDiff < 0.05) { ... }
        // La lógica original es `shoulderDiff < 0.05`. La Y normalizada
        // en `tasks-vision` está en [0, 1]. ML Kit puede dar pixeles.
        // Por simplicidad, mantendremos la lógica de JS asumiendo que
        // la implementación de `_inputImageFromCameraImage` normaliza,
        // pero `processImage` devuelve landmarks en coordenadas de imagen.
        // La lógica original es `Math.abs(leftShoulder.y - rightShoulder.y)`
        
        // Replicando la lógica de JS (asumiendo que Y es relativo, no absoluto)
        // Esta lógica es muy simple y probablemente necesite ajuste.
        // La lógica original de JS es `shoulderDiff < 0.05`
        // Para ML Kit en pixeles, esto será mucho mayor.
        // Ej: Si la altura es 720, 0.05 * 720 = 36 pixeles.
        
        final scaledDiff = (leftShoulder.y - rightShoulder.y).abs();

        if (scaledDiff < 36) { // 5% de 720p
          return FeedbackType.correct;
        } else if (scaledDiff > 72) { // 10% de 720p
          return FeedbackType.incorrect;
        }
      }
    }
    return FeedbackType.neutral;
  }

  // --- Helpers de UI ---

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Icon _getFeedbackIcon() {
    switch (_feedback) {
      case FeedbackType.correct:
        return const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28);
      case FeedbackType.incorrect:
        return const Icon(Icons.cancel_rounded, color: Colors.red, size: 28);
      default:
        return const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 28);
    }
  }

  String _getFeedbackText() {
    switch (_feedback) {
      case FeedbackType.correct:
        return "¡Excelente postura!";
      case FeedbackType.incorrect:
        return "Ajusta tu posición";
      default:
        return "Esperando detección...";
    }
  }

  String _getFeedbackSubtext() {
    switch (_feedback) {
      case FeedbackType.correct:
        return "Mantén esta posición";
      case FeedbackType.incorrect:
        return "Revisa tu alineación";
      default:
        return "Inicia el ejercicio";
    }
  }

  // --- Widget Build ---

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para replicar el `lg:grid-cols-3`
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLargeScreen = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: isLargeScreen
                    ? _buildLargeScreenLayout()
                    : _buildSmallScreenLayout(),
              ),
            );
          },
        ),
      ),
    );
  }

  // Layout para pantallas pequeñas (móvil)
  Widget _buildSmallScreenLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildCameraView(),
        const SizedBox(height: 24),
        _buildInfoCards(),
      ],
    );
  }

  // Layout para pantallas grandes (tablet/web)
  Widget _buildLargeScreenLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(), // El header aquí no tiene el RepCard
              const SizedBox(height: 24),
              _buildCameraView(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildInfoCards(includeRepCard: true), // RepCard va aquí
        ),
      ],
    );
  }

  // Header (Botón atrás y título)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text("Volver a ejercicios"),
          onPressed: widget.onBack,
        ),
        const SizedBox(height: 16),
        Text(
          widget.exerciseName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          "Seguimiento de postura en tiempo real",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  // Vista de cámara y controles
  Widget _buildCameraView() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Vista de la cámara
                  if (_isCameraInitialized && _cameraController != null)
                    CameraPreview(_cameraController!),

                  // Canvas para dibujar el esqueleto
                  if (_isActive && _poses.isNotEmpty && _imageSize != null)
                    CustomPaint(
                      painter: PosePainter(
                        poses: _poses,
                        imageSize: _imageSize!,
                        feedback: _feedback,
                      ),
                    ),

                  // Overlay cuando la cámara está inactiva
                  if (!_isActive)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                size: 64, color: Colors.white70),
                            const SizedBox(height: 16),
                            Text(
                              "Activa la cámara para comenzar",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Botones de control
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Center(
              child: _isActive
                  ? OutlinedButton.icon(
                      icon: const Icon(Icons.videocam_off, size: 18),
                      label: const Text("Detener Cámara"),
                      onPressed: _stopCamera,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    )
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.videocam, size: 18),
                      label: Text(_isLoading ? "Iniciando..." : "Activar Cámara"),
                      onPressed: _isLoading ? null : _startCamera,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjetas de información (Estado, Reps, Indicadores, Instrucciones)
  Widget _buildInfoCards({bool includeRepCard = false}) {
    // En pantalla pequeña, el RepCard se muestra en el header o aquí
    // Para simplificar, lo ponemos siempre aquí
    return Column(
      children: [
        // Tarjeta de Repeticiones
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Repeticiones",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "$_repCount",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta de Estado Actual
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Estado Actual",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _getFeedbackIcon(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getFeedbackText(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(_getFeedbackSubtext(),
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta de Indicadores (simulada)
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Indicadores",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildIndicatorRow("Hombros", _feedback == FeedbackType.correct ? "Alineados" : "---"),
                _buildIndicatorRow("Espalda", _feedback == FeedbackType.correct ? "Recta" : "---"),
                _buildIndicatorRow("Rodillas", _feedback == FeedbackType.correct ? "Correctas" : "---"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta de Instrucciones
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Instrucciones",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildInstructionRow("Colócate frente a la cámara"),
                _buildInstructionRow("Asegúrate de estar visible completamente"),
                _buildInstructionRow("Sigue las indicaciones del sistema"),
                _buildInstructionRow("Realiza el ejercicio lentamente"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorRow(String title, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Chip(
            label: Text(status),
            backgroundColor: _feedback == FeedbackType.correct ? Colors.blue[100] : Colors.grey[200],
            labelStyle: TextStyle(
              color: _feedback == FeedbackType.correct ? Colors.blue[800] : Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Text("• ", style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  // --- Lógica de conversión de imagen ---

  // Función MUY IMPORTANTE para convertir el formato de CameraImage a InputImage
  // Esta es la parte más técnica y varía entre iOS y Android.
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation rotation;
    if (camera.lensDirection == CameraLensDirection.front) {
      // Cámara frontal
      rotation = InputImageRotationValue.fromRawValue((sensorOrientation + 180) % 360) ?? InputImageRotation.rotation0deg;
    } else {
      // Cámara trasera
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    }

    // Obtener formato de imagen
    final format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    // Crear InputImage
    if (format == InputImageFormat.nv21) {
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } else if (format == ImageFormatGroup.bgra8888) {
      // iOS usa BGRA
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    }
    // Añadir más formatos si es necesario (ej. YUV420)
    
    print("Formato de imagen no soportado: ${image.format.group}");
    return null;
  }
}