import 'package:flutter/material.dart';

class LaptopFeedbackView extends StatelessWidget {
  const LaptopFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Row(
        children: [
          // --- COLUMNA IZQUIERDA: VIDEO CON IA ---
          Expanded(
            flex: 3, // Ocupa el 75% de la pantalla
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.tealAccent, width: 2), // Borde "Tecnológico"
                boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 20)],
              ),
              child: Stack(
                children: [
                  // Placeholder del Video Stream
                  const Center(child: Icon(Icons.accessibility_new, size: 100, color: Colors.white24)),
                  
                  // OVERLAY DE SKELETON (Simulado)
                  // Aquí pintarías tu CustomPainter con los puntos de la IA
                  
                  // OVERLAY DE MENSAJE DE RETROALIMENTACIÓN
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green, width: 2)
                      ),
                      child: const Text(
                        "¡EXCELENTE POSTURA!", // Esto cambia dinámicamente según la API
                        style: TextStyle(
                          color: Colors.greenAccent, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // --- COLUMNA DERECHA: MÉTRICAS ---
          Expanded(
            flex: 1, // Ocupa el 25% restante
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              child: Column(
                children: [
                  // TARJETA DE REPETICIONES
                  _InfoCard(
                    title: "REPETICIONES",
                    value: "8 / 15",
                    color: Colors.white,
                    icon: Icons.refresh,
                  ),
                  const SizedBox(height: 15),
                  
                  // TARJETA DE ÁNGULO (Importante para tu proyecto)
                  _InfoCard(
                    title: "ÁNGULO RODILLA",
                    value: "85°", // Valor en tiempo real
                    color: Colors.amber, // Cambia a rojo si está mal
                    icon: Icons.architecture,
                  ),
                  const SizedBox(height: 15),

                  // TARJETA DE TIEMPO
                  _InfoCard(
                    title: "TIEMPO",
                    value: "00:45",
                    color: Colors.white,
                    icon: Icons.timer,
                  ),
                  
                  const Spacer(),
                  
                  // BOTÓN TERMINAR
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {}, 
                      child: const Text("TERMINAR SESIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para las tarjetas de la derecha
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _InfoCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade800,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}