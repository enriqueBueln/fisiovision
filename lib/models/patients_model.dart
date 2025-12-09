class AssignedExerciseModel {
  final int id;
  final int idPaciente;
  final int idEjercicio;
  final int assignedBy;
  final String dateAssigned;
  final String? notes;
  final bool isActive;
  final String fechaCreacion;
  final String? fechaActualizacion;
  final ExerciseDetail ejercicio;

  AssignedExerciseModel({
    required this.id,
    required this.idPaciente,
    required this.idEjercicio,
    required this.assignedBy,
    required this.dateAssigned,
    this.notes,
    required this.isActive,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.ejercicio,
  });

  factory AssignedExerciseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssignedExerciseModel(
      id: json['id'],
      idPaciente: json['id_paciente'],
      idEjercicio: json['id_ejercicio'],
      assignedBy: json['assigned_by'],
      dateAssigned: json['date_assigned'],
      notes: json['notes'],
      isActive: json['is_active'],
      fechaCreacion: json['fecha_creacion'],
      fechaActualizacion: json['fecha_actualizacion'],
      ejercicio: ExerciseDetail.fromJson(json['ejercicio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_paciente': idPaciente,
      'id_ejercicio': idEjercicio,
      'assigned_by': assignedBy,
      'date_assigned': dateAssigned,
      'notes': notes,
      'is_active': isActive,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
      'ejercicio': ejercicio.toJson(),
    };
  }
}

class ExerciseDetail {
  final int id;
  final String name;
  final String description;
  final String type;
  final int durationSeconds;
  final int repetitions;
  final int series;
  final String instructions;
  final String referenceImage;
  final String referenceVideo;

  ExerciseDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationSeconds,
    required this.repetitions,
    required this.series,
    required this.instructions,
    required this.referenceImage,
    required this.referenceVideo,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      durationSeconds: json['duration_seconds'],
      repetitions: json['repetitions'],
      series: json['series'],
      instructions: json['instructions'],
      referenceImage: json['reference_image'] ?? '',
      referenceVideo: json['reference_video'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'duration_seconds': durationSeconds,
      'repetitions': repetitions,
      'series': series,
      'instructions': instructions,
      'reference_image': referenceImage,
      'reference_video': referenceVideo,
    };
  }
}
