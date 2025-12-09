// src/models/auth_model.dart

class RegisterRequest {
  final String name;
  final String secondName;
  final String email;
  final int? phoneNumber;
  final String password;

  RegisterRequest({
    required this.name,
    required this.secondName,
    required this.email,
    this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'second_name': secondName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };
  }
}

class RegisterResponse {
  final String name;
  final String secondName;
  final String email;
  final int? phoneNumber;
  final int id;
  final bool isActive;
  final DateTime dateCreated;
  final DateTime dateModified;

  RegisterResponse({
    required this.name,
    required this.secondName,
    required this.email,
    this.phoneNumber,
    required this.id,
    required this.isActive,
    required this.dateCreated,
    required this.dateModified,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      name: json['name'],
      secondName: json['second_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      id: json['id'],
      isActive: json['is_active'],
      dateCreated: DateTime.parse(json['date_created']),
      dateModified: DateTime.parse(json['date_modified']),
    );
  }
}

class LoginRequest {
  final String username; // email
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'grant_type': 'password',
      'username': username,
      'password': password,
      'scope': '',
      'client_id': null,
      'client_secret': null,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final bool isTerapeuta;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.isTerapeuta,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      isTerapeuta: json['is_terapeuta'] ?? false,
    );
  }
}

class AuthUser {
  final String accessToken;
  final String tokenType;
  final bool isTerapeuta;

  AuthUser({
    required this.accessToken,
    required this.tokenType,
    required this.isTerapeuta,
  });

  factory AuthUser.fromLoginResponse(LoginResponse loginResponse) {
    return AuthUser(
      accessToken: loginResponse.accessToken,
      tokenType: loginResponse.tokenType,
      isTerapeuta: loginResponse.isTerapeuta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'is_terapeuta': isTerapeuta,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      isTerapeuta: json['is_terapeuta'],
    );
  }
}

class ValidationError {
  final List<ValidationErrorDetail> detail;

  ValidationError({required this.detail});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      detail: (json['detail'] as List)
          .map((e) => ValidationErrorDetail.fromJson(e))
          .toList(),
    );
  }

  String get message {
    return detail.map((e) => e.msg).join(', ');
  }
}

class ValidationErrorDetail {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationErrorDetail({
    required this.loc,
    required this.msg,
    required this.type,
  });

  factory ValidationErrorDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return ValidationErrorDetail(
      loc: json['loc'],
      msg: json['msg'],
      type: json['type'],
    );
  }
}
