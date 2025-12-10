// src/models/analysis_model.dart

class AnalysisResponse {
  final int idSesion;
  final EjercicioInfo ejercicio;
  final DatosEntrada datosEntrada;
  final AnalisisProlog analisisProlog;

  AnalysisResponse({
    required this.idSesion,
    required this.ejercicio,
    required this.datosEntrada,
    required this.analisisProlog,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      idSesion: json['id_sesion'],
      ejercicio: EjercicioInfo.fromJson(json['ejercicio']),
      datosEntrada: DatosEntrada.fromJson(json['datos_entrada']),
      analisisProlog: AnalisisProlog.fromJson(
        json['analisis_prolog'],
      ),
    );
  }
}

class EjercicioInfo {
  final String nombre;
  final String tipo;

  EjercicioInfo({required this.nombre, required this.tipo});

  factory EjercicioInfo.fromJson(Map<String, dynamic> json) {
    return EjercicioInfo(
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}

class DatosEntrada {
  final int totalFramesAnalizados;
  final AngulosPromedio angulosPromedio;
  final String? dolorReportado;
  final String? dolorAnterior;

  DatosEntrada({
    required this.totalFramesAnalizados,
    required this.angulosPromedio,
    this.dolorReportado,
    this.dolorAnterior,
  });

  factory DatosEntrada.fromJson(Map<String, dynamic> json) {
    return DatosEntrada(
      totalFramesAnalizados: json['total_frames_analizados'],
      angulosPromedio: AngulosPromedio.fromJson(
        json['angulos_promedio'],
      ),
      dolorReportado: json['dolor_reportado'],
      dolorAnterior: json['dolor_anterior'],
    );
  }
}

class AngulosPromedio {
  final LadosAngulo codo;
  final LadosAngulo cadera;
  final LadosAngulo hombro;
  final LadosAngulo rodilla;
  final LadosAngulo tobillo;

  AngulosPromedio({
    required this.codo,
    required this.cadera,
    required this.hombro,
    required this.rodilla,
    required this.tobillo,
  });

  factory AngulosPromedio.fromJson(Map<String, dynamic> json) {
    return AngulosPromedio(
      codo: LadosAngulo.fromJson(json['codo']),
      cadera: LadosAngulo.fromJson(json['cadera']),
      hombro: LadosAngulo.fromJson(json['hombro']),
      rodilla: LadosAngulo.fromJson(json['rodilla']),
      tobillo: LadosAngulo.fromJson(json['tobillo']),
    );
  }
}

class LadosAngulo {
  final double izquierdo;
  final double derecho;

  LadosAngulo({required this.izquierdo, required this.derecho});

  factory LadosAngulo.fromJson(Map<String, dynamic> json) {
    return LadosAngulo(
      izquierdo: (json['izquierdo'] as num).toDouble(),
      derecho: (json['derecho'] as num).toDouble(),
    );
  }
}

class AnalisisProlog {
  final Map<String, ValidacionAngulo> validacionAngulos;
  final Clasificaciones clasificaciones;
  final Map<String, AnalisisSimetria> analisisSimetria;
  final List<String> recomendaciones;
  final String recomendacionGeneral;

  AnalisisProlog({
    required this.validacionAngulos,
    required this.clasificaciones,
    required this.analisisSimetria,
    required this.recomendaciones,
    required this.recomendacionGeneral,
  });

  factory AnalisisProlog.fromJson(Map<String, dynamic> json) {
    final validacionAngulosMap = <String, ValidacionAngulo>{};
    if (json['validacion_angulos'] != null) {
      (json['validacion_angulos'] as Map<String, dynamic>).forEach(
        (key, value) {
          validacionAngulosMap[key] = ValidacionAngulo.fromJson(
            value,
          );
        },
      );
    }

    final analisisSimetriaMap = <String, AnalisisSimetria>{};
    if (json['analisis_simetria'] != null) {
      (json['analisis_simetria'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        analisisSimetriaMap[key] = AnalisisSimetria.fromJson(
          value,
        );
      });
    }

    return AnalisisProlog(
      validacionAngulos: validacionAngulosMap,
      clasificaciones: Clasificaciones.fromJson(
        json['clasificaciones'],
      ),
      analisisSimetria: analisisSimetriaMap,
      recomendaciones: List<String>.from(json['recomendaciones']),
      recomendacionGeneral: json['recomendacion_general'],
    );
  }
}

class ValidacionAngulo {
  final LadoValidacion izquierdo;
  final LadoValidacion derecho;

  ValidacionAngulo({
    required this.izquierdo,
    required this.derecho,
  });

  factory ValidacionAngulo.fromJson(Map<String, dynamic> json) {
    return ValidacionAngulo(
      izquierdo: LadoValidacion.fromJson(json['izquierdo']),
      derecho: LadoValidacion.fromJson(json['derecho']),
    );
  }
}

class LadoValidacion {
  final bool valido;
  final double actual;
  final int objetivo;
  final double diferencia;

  LadoValidacion({
    required this.valido,
    required this.actual,
    required this.objetivo,
    required this.diferencia,
  });

  factory LadoValidacion.fromJson(Map<String, dynamic> json) {
    return LadoValidacion(
      valido: json['valido'],
      actual: (json['actual'] as num).toDouble(),
      objetivo: json['objetivo'],
      diferencia: (json['diferencia'] as num).toDouble(),
    );
  }
}

class Clasificaciones {
  final String postura;
  final String dolor;
  final String intensidad;

  Clasificaciones({
    required this.postura,
    required this.dolor,
    required this.intensidad,
  });

  factory Clasificaciones.fromJson(Map<String, dynamic> json) {
    return Clasificaciones(
      postura: json['postura'],
      dolor: json['dolor'],
      intensidad: json['intensidad'],
    );
  }
}

class AnalisisSimetria {
  final double diferencia;
  final String clasificacion;

  AnalisisSimetria({
    required this.diferencia,
    required this.clasificacion,
  });

  factory AnalisisSimetria.fromJson(Map<String, dynamic> json) {
    return AnalisisSimetria(
      diferencia: (json['diferencia'] as num).toDouble(),
      clasificacion: json['clasificacion'],
    );
  }
}
