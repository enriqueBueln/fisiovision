enum TipoEjercicio { Fuerza, Cardio, Flexibilidad, Equilibrio }

class Ejercicio {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipo; // Guardamos como String para facilitar DB
  final int duracionSegundos;
  final int repeticiones;
  final int series;
  final String angulosObjetivo; // "objective_angles" en DB
  final double toleranciaGrados;
  final String? instrucciones;
  final String? precauciones;
  final String? imagenReferencia;
  final String? videoReferencia;
  final bool isActive;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.duracionSegundos,
    required this.repeticiones,
    required this.series,
    required this.angulosObjetivo,
    required this.toleranciaGrados,
    this.descripcion,
    this.instrucciones,
    this.precauciones,
    this.imagenReferencia,
    this.videoReferencia,
    this.isActive = true,
  });

  // Helper para convertir el String de la DB a Enum en la UI si lo necesitas
  TipoEjercicio get tipoEnum {
    return TipoEjercicio.values.firstWhere(
      (e) => e.toString().split('.').last == tipo,
      orElse: () => TipoEjercicio.Fuerza,
    );
  }

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'],
      nombre: json['name'],
      descripcion: json['description'],
      tipo: json['type'], // Asumiendo que DB devuelve "Fuerza", "Cardio", etc.
      duracionSegundos: json['duration_seconds'],
      repeticiones: json['repetitions'],
      series: json['series'],
      angulosObjetivo: json['objective_angles'], // JSON String
      toleranciaGrados: (json['tolerance_degrees'] as num).toDouble(),
      instrucciones: json['instructions'],
      precauciones: json['precautions'],
      imagenReferencia: json['reference_image'],
      videoReferencia: json['reference_video'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nombre,
      'description': descripcion,
      'type': tipo,
      'duration_seconds': duracionSegundos,
      'repetitions': repeticiones,
      'series': series,
      'objective_angles': angulosObjetivo,
      'tolerance_degrees': toleranciaGrados,
      'instructions': instrucciones,
      'precautions': precauciones,
      'reference_image': imagenReferencia,
      'reference_video': videoReferencia,
      'isActive': isActive,
    };
  }
}