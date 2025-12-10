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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      idPaciente: json['id_paciente'] is int 
          ? json['id_paciente'] 
          : int.parse(json['id_paciente'].toString()),
      idEjercicio: json['id_ejercicio'] is int 
          ? json['id_ejercicio'] 
          : int.parse(json['id_ejercicio'].toString()),
      idFisioterapeuta: json['id_fisioterapeuta'] is int 
          ? json['id_fisioterapeuta'] 
          : int.parse(json['id_fisioterapeuta'].toString()),
      dateSpecified: DateTime.parse(json['date_specified'].toString()),
      dateStart: DateTime.parse(json['date_start'].toString()),
      dateEnd: json['date_end'] != null
          ? DateTime.parse(json['date_end'].toString())
          : null,
      status: json['status'].toString(),
      durationSeconds: json['duration_seconds'] != null
          ? (json['duration_seconds'] is int 
              ? json['duration_seconds'] 
              : int.parse(json['duration_seconds'].toString()))
          : null,
      painLevel: json['pain_level'] != null
          ? (json['pain_level'] is int 
              ? json['pain_level'] 
              : int.parse(json['pain_level'].toString()))
          : null,
      dateCreated: DateTime.parse(json['date_created'].toString()),
      dateModified: json['date_modified'] != null
          ? DateTime.parse(json['date_modified'].toString())
          : null,
      paciente: SessionPatient.fromJson(json['paciente']),
      fisioterapeuta: SessionTherapist.fromJson(json['fisioterapeuta']),
      ejercicio: SessionExercise.fromJson(json['ejercicio']),
      feedbackPaciente: json['feedback_paciente']?.toString(),
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'].toString(),
      secondName: json['second_name'].toString(),
      email: json['email'].toString(),
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'].toString(),
      secondName: json['second_name'].toString(),
      email: json['email'].toString(),
      phoneNumber: json['phone_number']?.toString(),
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'].toString(),
      description: json['description'].toString(),
      type: json['type'].toString(),
      durationSeconds: json['duration_seconds'] is int 
          ? json['duration_seconds'] 
          : int.parse(json['duration_seconds'].toString()),
      repetitions: json['repetitions'] is int 
          ? json['repetitions'] 
          : int.parse(json['repetitions'].toString()),
      series: json['series'] is int 
          ? json['series'] 
          : int.parse(json['series'].toString()),
      referenceImage: (json['reference_image'] ?? '').toString(),
      referenceVideo: (json['reference_video'] ?? '').toString(),
    );
  }
}
