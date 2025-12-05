import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {
  static initEnv() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';
}
