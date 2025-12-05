import 'package:fisiovision/components/exercise_card.dart';
import 'package:fisiovision/components/camera_view.dart';
import 'package:flutter/material.dart';

class Main extends StatelessWidget {
  final List<Map<String, String>> exercises = const [
    {
      'difficult': 'Hard',
      'title': 'Rotación de Cadera',
      'description':
          'Elige el ejercicio que deseas realizar y comienza tu sesión de rehabilitación',
      'part_body': 'Cadera',
    },
    {
      'difficult': 'Easy',
      'title': 'Extensión de Muñeca',
      'description': 'Rehabilitación específica para muñeca',
      'part_body': 'Muñeca',
    },
  ];

  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona tu Ejercicio',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige el ejercicio que deseas realizar y comienza tu sesión de rehabilitación',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraViewShellWithControls(),
                      ),
                    );
                  },
                  child: ExerciseCard(
                    difficult: ex['difficult']!,
                    title: ex['title']!,
                    description: ex['description']!,
                    partBody: ex['part_body']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
