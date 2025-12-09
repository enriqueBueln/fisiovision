// Models para Sesión

class PacienteBasicInfo {
  final int id;
  final String name;
  final String secondName;
  final String email;

  PacienteBasicInfo({
    required this.id,
    required this.name,
    required this.secondName,
    required this.email,
  });

  factory PacienteBasicInfo.fromJson(Map<String, dynamic> json) {
    return PacienteBasicInfo(
      id: json['id'],
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'second_name': secondName,
      'email': email,
    };
  }
}

class FisioterapeutaBasicInfo {
  final int id;
  final String name;
  final String secondName;
  final String email;
  final int? phoneNumber;

  FisioterapeutaBasicInfo({
    required this.id,
    required this.name,
    required this.secondName,
    required this.email,
    this.phoneNumber,
  });

  factory FisioterapeutaBasicInfo.fromJson(Map<String, dynamic> json) {
    return FisioterapeutaBasicInfo(
      id: json['id'],
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'second_name': secondName,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}

class EjercicioBasicInfo {
  final int id;
  final String name;
  final String? description;
  final String type;
  final int durationSeconds;
  final int repetitions;
  final int series;
  final String? referenceImage;
  final String? referenceVideo;

  EjercicioBasicInfo({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.durationSeconds,
    required this.repetitions,
    required this.series,
    this.referenceImage,
    this.referenceVideo,
  });

  factory EjercicioBasicInfo.fromJson(Map<String, dynamic> json) {
    return EjercicioBasicInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      durationSeconds: json['duration_seconds'],
      repetitions: json['repetitions'],
      series: json['series'],
      referenceImage: json['reference_image'],
      referenceVideo: json['reference_video'],
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
      'reference_image': referenceImage,
      'reference_video': referenceVideo,
    };
  }
}

class FeedbackBasicInfo {
  final int id;
  final int? painLevel;
  final int? difficulty;
  final int? fatigue;
  final String? notes;

  FeedbackBasicInfo({
    required this.id,
    this.painLevel,
    this.difficulty,
    this.fatigue,
    this.notes,
  });

  factory FeedbackBasicInfo.fromJson(Map<String, dynamic> json) {
    return FeedbackBasicInfo(
      id: json['id'],
      painLevel: json['pain_level'],
      difficulty: json['difficulty'],
      fatigue: json['fatigue'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pain_level': painLevel,
      'difficulty': difficulty,
      'fatigue': fatigue,
      'notes': notes,
    };
  }
}

class SesionCreate {
  final int idPaciente;
  final int idEjercicio;
  final DateTime dateSpecified;

  SesionCreate({
    required this.idPaciente,
    required this.idEjercicio,
    required this.dateSpecified,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente,
      'id_ejercicio': idEjercicio,
      'date_specified': dateSpecified.toIso8601String(),
    };
  }
}

class SesionResponse {
  final int id;
  final int idPaciente;
  final int idEjercicio;
  final int idFisioterapeuta;
  final DateTime dateSpecified;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String status;
  final int? durationSeconds;
  final int? painLevel;
  final DateTime dateCreated;
  final DateTime? dateModified;
  
  // Relaciones
  final PacienteBasicInfo? paciente;
  final FisioterapeutaBasicInfo? fisioterapeuta;
  final EjercicioBasicInfo? ejercicio;
  final FeedbackBasicInfo? feedbackPaciente;

  SesionResponse({
    required this.id,
    required this.idPaciente,
    required this.idEjercicio,
    required this.idFisioterapeuta,
    required this.dateSpecified,
    this.dateStart,
    this.dateEnd,
    required this.status,
    this.durationSeconds,
    this.painLevel,
    required this.dateCreated,
    this.dateModified,
    this.paciente,
    this.fisioterapeuta,
    this.ejercicio,
    this.feedbackPaciente,
  });

  factory SesionResponse.fromJson(Map<String, dynamic> json) {
    return SesionResponse(
      id: json['id'],
      idPaciente: json['id_paciente'],
      idEjercicio: json['id_ejercicio'],
      idFisioterapeuta: json['id_fisioterapeuta'],
      dateSpecified: DateTime.parse(json['date_specified']),
      dateStart: json['date_start'] != null 
          ? DateTime.parse(json['date_start']) 
          : null,
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
      paciente: json['paciente'] != null 
          ? PacienteBasicInfo.fromJson(json['paciente']) 
          : null,
      fisioterapeuta: json['fisioterapeuta'] != null 
          ? FisioterapeutaBasicInfo.fromJson(json['fisioterapeuta']) 
          : null,
      ejercicio: json['ejercicio'] != null 
          ? EjercicioBasicInfo.fromJson(json['ejercicio']) 
          : null,
      feedbackPaciente: json['feedback_paciente'] != null 
          ? FeedbackBasicInfo.fromJson(json['feedback_paciente']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_paciente': idPaciente,
      'id_ejercicio': idEjercicio,
      'id_fisioterapeuta': idFisioterapeuta,
      'date_specified': dateSpecified.toIso8601String(),
      'date_start': dateStart?.toIso8601String(),
      'date_end': dateEnd?.toIso8601String(),
      'status': status,
      'duration_seconds': durationSeconds,
      'pain_level': painLevel,
      'date_created': dateCreated.toIso8601String(),
      'date_modified': dateModified?.toIso8601String(),
      'paciente': paciente?.toJson(),
      'fisioterapeuta': fisioterapeuta?.toJson(),
      'ejercicio': ejercicio?.toJson(),
      'feedback_paciente': feedbackPaciente?.toJson(),
    };
  }
}
