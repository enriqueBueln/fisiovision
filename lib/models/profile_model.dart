// src/models/profile_model.dart

class PatientProfileModel {
  final String name;
  final String secondName;
  final String email;
  final String birthDate;
  final String gender;
  final String address;
  final String? notes;
  final int id;
  final int idUser;
  final int idFisioterapeuta;
  final bool isActive;
  final String dateCreated;
  final String? dateModified;

  PatientProfileModel({
    required this.name,
    required this.secondName,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.address,
    this.notes,
    required this.id,
    required this.idUser,
    required this.idFisioterapeuta,
    required this.isActive,
    required this.dateCreated,
    this.dateModified,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      address: json['address'],
      notes: json['notes'],
      id: json['id'],
      idUser: json['id_user'],
      idFisioterapeuta: json['id_fisioterapeuta'],
      isActive: json['is_active'],
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
    );
  }

  String get fullName => '$name $secondName';
}
