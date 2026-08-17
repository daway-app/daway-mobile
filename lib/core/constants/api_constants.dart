import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static const String sendOtp = '/otp/send';
  static const String patientLogin = '/login/patient';
  static const String pharmacyLogin = '/login/pharmacy';
  static const String logout = '/logout';
  static const String patientProfile = '/profile/patient';
  static const String pharmacyProfile = '/profile/pharmacy';
}
