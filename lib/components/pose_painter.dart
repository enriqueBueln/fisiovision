import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'pose_detector_screen.dart'; // Para importar FeedbackType

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final FeedbackType feedback;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.feedback,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Seleccionar color basado en el feedback
    final Color color;
    switch (feedback) {
      case FeedbackType.correct:
        color = Colors.green;
        break;
      case FeedbackType.incorrect:
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    // Escalar los puntos del tamaño de la imagen al tamaño del widget
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    // Para la cámara frontal, la imagen se invierte horizontalmente
    Offset scalePoint(PoseLandmark landmark) {
      // Invertir X para efecto espejo de cámara frontal
      final double x = size.width - (landmark.x * scaleX);
      final double y = landmark.y * scaleY;
      return Offset(x, y);
    }

    for (final pose in poses) {
      final landmarks = pose.landmarks;

      // 1. Dibujar conexiones (líneas)
      _poseConnections.forEach((startType, endType) {
        final startLandmark = landmarks[startType];
        final endLandmark = landmarks[endType];

        if (startLandmark != null && endLandmark != null) {
          // Dibujar solo si ambos puntos tienen confianza
          if (startLandmark.likelihood > 0.5 && endLandmark.likelihood > 0.5) {
            canvas.drawLine(
              scalePoint(startLandmark),
              scalePoint(endLandmark),
              paint,
            );
          }
        }
      });

      // 2. Dibujar puntos (círculos)
      landmarks.forEach((type, landmark) {
        // Dibujar solo si el punto tiene confianza
        if (landmark.likelihood > 0.5) {
          canvas.drawCircle(
            scalePoint(landmark),
            5, // radio
            dotPaint,
          );
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses || oldDelegate.feedback != feedback;
  }

  // Mapa de conexiones del esqueleto (equivalente a PoseLandmarker.POSE_CONNECTIONS)
  static const Map<PoseLandmarkType, PoseLandmarkType> _poseConnections = {
    PoseLandmarkType.leftShoulder: PoseLandmarkType.rightShoulder,
    // PoseLandmarkType.leftShoulder: PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightShoulder: PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftElbow: PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightElbow: PoseLandmarkType.rightWrist,
    // PoseLandmarkType.leftShoulder: PoseLandmarkType.leftHip,
    // PoseLandmarkType.rightShoulder: PoseLandmarkType.rightHip,
    PoseLandmarkType.leftHip: PoseLandmarkType.rightHip,
    // PoseLandmarkType.leftHip: PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightHip: PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftKnee: PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightKnee: PoseLandmarkType.rightAnkle,
    PoseLandmarkType.leftWrist: PoseLandmarkType.leftPinky,
    PoseLandmarkType.rightWrist: PoseLandmarkType.rightPinky,
    // PoseLandmarkType.leftWrist: PoseLandmarkType.leftIndex,
    // PoseLandmarkType.rightWrist: PoseLandmarkType.rightIndex,
    // PoseLandmarkType.leftWrist: PoseLandmarkType.leftThumb,
    // PoseLandmarkType.rightWrist: PoseLandmarkType.rightThumb,
    PoseLandmarkType.leftIndex: PoseLandmarkType.leftPinky,
    PoseLandmarkType.rightIndex: PoseLandmarkType.rightPinky,
    PoseLandmarkType.leftAnkle: PoseLandmarkType.leftFootIndex,
    PoseLandmarkType.rightAnkle: PoseLandmarkType.rightFootIndex,
    // PoseLandmarkType.leftAnkle: PoseLandmarkType.leftHeel,
    // PoseLandmarkType.rightAnkle: PoseLandmarkType.rightHeel,
    PoseLandmarkType.leftHeel: PoseLandmarkType.leftFootIndex,
    PoseLandmarkType.rightHeel: PoseLandmarkType.rightFootIndex,
    PoseLandmarkType.nose: PoseLandmarkType.leftEyeInner,
    // PoseLandmarkType.nose: PoseLandmarkType.rightEyeInner,
    PoseLandmarkType.leftEyeInner: PoseLandmarkType.leftEye,
    PoseLandmarkType.rightEyeInner: PoseLandmarkType.rightEye,
    PoseLandmarkType.leftEye: PoseLandmarkType.leftEyeOuter,
    PoseLandmarkType.rightEye: PoseLandmarkType.rightEyeOuter,
    PoseLandmarkType.leftEyeOuter: PoseLandmarkType.leftEar,
    PoseLandmarkType.rightEyeOuter: PoseLandmarkType.rightEar,
    PoseLandmarkType.leftMouth: PoseLandmarkType.rightMouth,
  };
}