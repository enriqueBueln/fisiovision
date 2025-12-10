enum TipoEjercicio {
  fuerza,
  movilidad,
  equilibrio,
  rotacion,
  extension,
  flexion,
  otro,
}

class Ejercicio {
  final int id;
  final String name;
  final String? description;
  final String type; // Guardamos como String para facilitar DB
  final int duration_seconds;
  final int repetitions;
  final int series;
  final String objective_angles; // "objective_angles" en DB
  final double tolerance_degrees;
  final String? instructions;
  final String? precautions;
  final String? reference_image;
  final String? reference_video;
  final bool isActive;

  Ejercicio({
    required this.id,
    required this.name,
    required this.type,
    required this.duration_seconds,
    required this.repetitions,
    required this.series,
    required this.objective_angles,
    required this.tolerance_degrees,
    this.description,
    this.instructions,
    this.precautions,
    this.reference_image,
    this.reference_video,
    this.isActive = true,
  });

  // Helper para convertir el String de la DB a Enum en la UI si lo necesitas
  TipoEjercicio get tipoEnum {
    return TipoEjercicio.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => TipoEjercicio.fuerza,
    );
  }

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    print("AAAAAAAAAAAAAAAAAAAA $json");
    return Ejercicio(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type:
          json['type'] ?? 'aaaaaa', // Asumiendo que DB devuelve "Fuerza", "Cardio", etc.
      duration_seconds: json['duration_seconds'] ?? 0,
      repetitions: json['repetitions'] ?? 0,
      series: json['series'] ?? 0,
      objective_angles: json['objective_angles'] ?? ' ', // JSON String
      tolerance_degrees: (json['tolerance_degrees'] as num?)?.toDouble() ?? 0.0,
      instructions: json['instructions'] ?? 'asdasdasd ',
      precautions: json['precautions'] ?? 'dasdasd ',
      reference_image: json['reference_image'] ?? ' dasdasdas',
      reference_video: json['reference_video'] ?? 'sdasdas ',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'duration_seconds': duration_seconds,
      'repetitions': repetitions,
      'series': series,
      'objective_angles': objective_angles,
      'tolerance_degrees': tolerance_degrees,
      'instructions': instructions,
      'precautions': precautions,
      'reference_image': reference_image,
      'reference_video': reference_video,
    };
  }

  @override
  toString(){
    return toJson().toString();
  }

  // FUNCIÓN CLAVE PARA LA TRANSFORMACIÓN
  Map<String, Map<String, int>> _transformarAngulos(Map<String, int> angulosInternos) {
    // Estructura final: {"cadera": {"izquierdo": 10, "derecho": 10}}
    final Map<String, Map<String, int>> resultado = {};

    angulosInternos.forEach((key, value) {
      // key es algo como "cadera_izquierdo"
      final parts = key.split('_'); // Divide en ["cadera", "izquierdo"]
      
      if (parts.length < 2) return; // Ignorar claves mal formadas

      final articulacion = parts[0]; // "cadera"
      final lado = parts.last;        // "izquierdo"
      
      // Inicializar el mapa de la articulación si no existe
      if (!resultado.containsKey(articulacion)) {
        resultado[articulacion] = {};
      }
      
      // Asignar el valor al lado correcto
      resultado[articulacion]![lado] = value;
    });

    return resultado;
  }
}
