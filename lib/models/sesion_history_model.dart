// models/session_history_model.dart

class SessionHistoryModel {
  final int id;
  final int idPaciente;
  final int idEjercicio;
  final int idFisioterapeuta;
  final DateTime dateSpecified;
  final DateTime dateStart;
  final DateTime? dateEnd;
  final String status;
  final int? durationSeconds;
  final int? painLevel;
  final DateTime dateCreated;
  final DateTime? dateModified;
  final SessionPatient paciente;
  final SessionTherapist fisioterapeuta;
  final SessionExercise ejercicio;
  final String? feedbackPaciente;

  SessionHistoryModel({
    required this.id,
    required this.idPaciente,
    required this.idEjercicio,
    required this.idFisioterapeuta,
    required this.dateSpecified,
    required this.dateStart,
    this.dateEnd,
    required this.status,
    this.durationSeconds,
    this.painLevel,
    required this.dateCreated,
    this.dateModified,
    required this.paciente,
    required this.fisioterapeuta,
    required this.ejercicio,
    this.feedbackPaciente,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      id: json['id'],
      idPaciente: json['id_paciente'],
      idEjercicio: json['id_ejercicio'],
      idFisioterapeuta: json['id_fisioterapeuta'],
      dateSpecified: DateTime.parse(json['date_specified']),
      dateStart: DateTime.parse(json['date_start']),
      dateEnd: json['date_end'] != null
          ? DateTime.parse(json['date_end'])
          : null,
      status: json['status'],
      durationSeconds: json['duration_seconds'],
      painLevel: json['pain_level'],
      dateCreated: DateTime.parse(json['date_created']),
      dateModified: json['date_modified'] != null
          ? DateTime.parse(json['date_modified'])
          : null,
      paciente: SessionPatient.fromJson(json['paciente']),
      fisioterapeuta: SessionTherapist.fromJson(
        json['fisioterapeuta'],
      ),
      ejercicio: SessionExercise.fromJson(json['ejercicio']),
      feedbackPaciente: json['feedback_paciente'],
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'completada':
        return 'Completada';
      case 'en_curso':
        return 'En curso';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  String get formattedDuration {
    if (durationSeconds == null) return 'N/A';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }
}

class SessionPatient {
  final int id;
  final String name;
  final String secondName;
  final String email;

  SessionPatient({
    required this.id,
    required this.name,
    required this.secondName,
    required this.email,
  });

  factory SessionPatient.fromJson(Map<String, dynamic> json) {
    return SessionPatient(
      id: json['id'],
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
    );
  }

  String get fullName => '$name $secondName';
}

class SessionTherapist {
  final int id;
  final String name;
  final String secondName;
  final String email;
  final String? phoneNumber;

  SessionTherapist({
    required this.id,
    required this.name,
    required this.secondName,
    required this.email,
    this.phoneNumber,
  });

  factory SessionTherapist.fromJson(Map<String, dynamic> json) {
    return SessionTherapist(
      id: json['id'],
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  String get fullName => '$name $secondName';
}

class SessionExercise {
  final int id;
  final String name;
  final String description;
  final String type;
  final int durationSeconds;
  final int repetitions;
  final int series;
  final String referenceImage;
  final String referenceVideo;

  SessionExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationSeconds,
    required this.repetitions,
    required this.series,
    required this.referenceImage,
    required this.referenceVideo,
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      durationSeconds: json['duration_seconds'],
      repetitions: json['repetitions'],
      series: json['series'],
      referenceImage: json['reference_image'] ?? '',
      referenceVideo: json['reference_video'] ?? '',
    );
  }
}
