class Paciente {
  final String id;
  final String nombre;
  final String diagnostico;

  Paciente({required this.id, required this.nombre, required this.diagnostico});

  // Factory constructor: Transforma el JSON del backend a Objeto Dart
  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'].toString(), // Asegurar que sea String
      nombre: json['nombre'],
      diagnostico: json['diagnostico'],
    );
  }

  // Para enviar datos al backend (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'diagnostico': diagnostico,
    };
  }
}