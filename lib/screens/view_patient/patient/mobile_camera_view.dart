import 'package:flutter/material.dart';
class MobileCameraView extends StatelessWidget {
  const MobileCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTA: Aquí iría el CameraPreview(controller) real.
    // Usamos un Container negro para simular la cámara.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. EL VIDEO (Simulado)
          Center(
            child: Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Text("VISTA DE CÁMARA", style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
          
          // 2. INDICADOR DE ESTADO (Arriba)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
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
                    const Text("EN VIVO - Conectado a Laptop", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          // 3. CONTROLES (Abajo)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.black45,
              child: Center(
                child: FloatingActionButton.large(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    // Lógica para detener stream
                    // context.pop();
                  },
                  child: const Icon(Icons.stop, size: 40),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}