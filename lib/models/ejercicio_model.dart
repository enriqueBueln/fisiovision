enum TypeExercise { Fuerza, Cardio, Flexibilidad, Equilibrio }

class Exercise {
  final String id;
  final String nombre;
  final String descripcion;
  final String referenceVideo;
  final TypeExercise type;
  final int durationSeconds;
  final int repeticiones;
  final String objetiveAngles;
  final String instrucciones = '';
  final String precauciones = '';
  final String referenceImage;
  final int toleranceDegrees;
  final int series;
  final bool completed;
  Exercise({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.referenceVideo,
    required this.durationSeconds,
    required this.repeticiones,
    required this.series,
    required this.toleranceDegrees,
    required this.objetiveAngles,
    required this.referenceImage,
    required this.completed,
    this.type = TypeExercise.Fuerza,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      referenceVideo: json['referenceVideo'],
      repeticiones: json['repeticiones'],
      durationSeconds: json['durationSeconds'],
      toleranceDegrees: json['toleranceDegrees'],
      series: json['series'],
      referenceImage: json['referenceImage'],
      objetiveAngles: json['objetiveAngles'],
      completed: json['completed'],
      type: TypeExercise.values.firstWhere(
        (e) => e.toString() == 'TipoEjercicio.${json['type']}',
        orElse: () => TypeExercise.Fuerza,
      ),
    );
  }
}
