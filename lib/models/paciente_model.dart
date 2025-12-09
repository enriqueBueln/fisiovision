class Paciente {
  final int? id; // En DB es bigint, en Dart int (64-bit)
  final String nombre;
  final String apellido; // second_name en DB
  final String email;
  final DateTime fechaNacimiento;
  final String genero;
  final String? direccion;
  final String? notas;
  final int? idUsuario; // Relación con tabla Usuario
  final bool isActive;

  // Getter útil para la UI
  String get nombreCompleto => '$nombre $apellido';
  
  // Calcular edad automáticamente
  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month || 
       (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  Paciente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.fechaNacimiento,
    required this.genero,
    required this.idUsuario,
    this.direccion,
    this.notas,
    this.isActive = true,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'], 
      nombre: json['name'],         // DB column: name
      apellido: json['second_name'], // DB column: second_name
      email: json['email'],
      fechaNacimiento: DateTime.parse(json['birth_date']), // DB envía "YYYY-MM-DD"
      genero: json['gender'],
      direccion: json['address'],
      notas: json['notes'],
      idUsuario: json['id_user'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nombre,
      'second_name': apellido,
      'email': email,
      'birth_date': fechaNacimiento.toIso8601String(),
      'gender': genero,
      'address': direccion,
      'notes': notas,
    };
  }
}