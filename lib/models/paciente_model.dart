class Paciente {
  final int? id; // En DB es bigint, en Dart int (64-bit)
  final String name;
  final String second_name; // second_name en DB
  final String email;
  final DateTime birth_date;
  final String gender;
  final String? address;
  final String? notes;
  final int? idUsuario; // Relación con tabla Usuario
  final bool isActive;

  // Getter útil para la UI
  String get nombreCompleto => '$name $second_name';

  // Calcular edad automáticamente
  int get edad {
    final now = DateTime.now();
    int age = now.year - birth_date.year;
    if (now.month < birth_date.month ||
        (now.month == birth_date.month &&
            now.day < birth_date.day)) {
      age--;
    }
    return age;
  }

  Paciente({
    required this.id,
    required this.name,
    required this.second_name,
    required this.email,
    required this.birth_date,
    required this.gender,
    required this.idUsuario,
    this.address,
    this.notes,
    this.isActive = true,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      name: json['name'], // DB column: name
      second_name: json['second_name'], // DB column: second_name
      email: json['email'],
      birth_date: DateTime.parse(
        json['birth_date'],
      ), // DB envía "YYYY-MM-DD"
      gender: json['gender'],
      address: json['address'],
      notes: json['notes'],
      idUsuario: json['id_user'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'second_name': second_name,
      'email': email,
      'birth_date': birth_date.toIso8601String(),
      'gender': gender,
      'address': address,
      'notes': notes,
    };
  }
}
