class EjercicioAsignado {
  final int? id; // Puede ser nulo si apenas lo vamos a crear
  final int idPaciente;
  final int idEjercicio;
  final int idFisioterapeuta; // assigned_by
  final DateTime fechaAsignacion;
  final String? notas;
  final bool isActive;

  // Opcional: Para mostrar nombres en la UI sin hacer otra petición
  // Esto depende de si tu Backend hace "Join" y te manda el nombre del ejercicio
  final String? nombreEjercicioAuxiliar; 

  EjercicioAsignado({
    this.id,
    required this.idPaciente,
    required this.idEjercicio,
    required this.idFisioterapeuta,
    required this.fechaAsignacion,
    this.notas,
    this.isActive = true,
    this.nombreEjercicioAuxiliar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_paciente': idPaciente,
      'id_ejercicio': idEjercicio,
      'assigned_by': idFisioterapeuta,
      'date_assigned': fechaAsignacion.toIso8601String(),
      'notes': notas,
      'isActive': isActive,
    };
  }
}