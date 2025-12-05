import 'package:flutter/material.dart';

class CameraViewShellWithControls extends StatefulWidget {
  const CameraViewShellWithControls({Key? key}) : super(key: key);

  @override
  State<CameraViewShellWithControls> createState() =>
      _CameraViewShellWithControlsState();
}

class _CameraViewShellWithControlsState
    extends State<CameraViewShellWithControls> {
  // Estado que simula si la cámara está activa o inactiva
  bool _isActive = false;
  bool _isLoading = false; // Simula la carga del modelo o cámara

  // 1. Simula la activación de la cámara
  void _startCameraSimulation() {
    setState(() {
      _isLoading = true; // Empieza a cargar
    });

    // Simular el tiempo de inicialización de la cámara/modelo (2 segundos)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isActive = true; // Cámara "activa"
          _isLoading = false;
        });
      }
    });
  }

  // 2. Simula la desactivación de la cámara
  void _stopCameraSimulation() {
    setState(() {
      _isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- 1. Área de la Vista Previa (Simulación) ---
        AspectRatio(
          aspectRatio: 16 / 9, // Proporción de video típica (16:9)
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1.1. Simulación de la pantalla de video (negro si está activo)
                Container(
                  color: _isActive ? Colors.black : Colors.grey[200],
                  child: Center(
                    child: _isActive
                        ? const Text(
                            "🎥 FEED DE VIDEO ACTIVO (Simulado)",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )
                        : null, // Si está activo, el texto de abajo se superpone
                  ),
                ),

                // 1.2. Overlay de inactividad (Similar al JSX {!isActive && ...})
                if (!_isActive)
                  Container(
                    color: Colors.black.withOpacity(0.5), // Fondo oscuro/velado
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera, size: 64, color: Colors.white70),
                          const SizedBox(height: 16),
                          Text(
                            _isLoading
                                ? "Iniciando cámara..."
                                : "Activa la cámara para comenzar",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // --- 2. Botones de Control ---
        _isActive
            ? ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text("Detener Cámara"),
                onPressed: _stopCameraSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            : ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera),
                label: Text(_isLoading ? "Iniciando..." : "Activar Cámara"),
                onPressed: _isLoading ? null : _startCameraSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
      ],
    );
  }
}