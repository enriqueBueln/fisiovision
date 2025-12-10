import 'package:fisiovision/models/ejercicio_model.dart';

class Asignacion {
  final int id;
  final int idPaciente;
  final int idEjercicio;
  final Ejercicio ejercicio;

  Asignacion({
    required this.id,
    required this.idPaciente,
    required this.idEjercicio,
    required this.ejercicio,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      id: json['id'],
      idPaciente: json['id_paciente'],
      idEjercicio: json['id_ejercicio'],
      ejercicio: Ejercicio.fromJson(json['ejercicio']),
    );
  }
}
