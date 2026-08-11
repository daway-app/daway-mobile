import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static const String sendOtp = '/api/otp/send';
  static const String patientLogin = '/api/login/patient';
  static const String pharmacyLogin = '/api/login/pharmacy';
  static const String logout = '/api/logout';
}
