import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static const String sendOtp = '/otp/send';
  static const String patientLogin = '/login/patient';
  static const String pharmacyLogin = '/login/pharmacy';
  static const String logout = '/logout';
  static const String patientProfile = '/profile/patient';
  static const String pharmacyProfile = '/profile/pharmacy';
  static const String pharmacyMedicines = '/pharmacy/medicines';
  static const String pharmacyMedicinesSearch = '/pharmacy/medicines/search';
  static const String pharmacyMedicinesByName = '/pharmacy/medicines/by-name';
  static const String pharmacyInventory = '/pharmacy/inventory';
  static const String pharmacyInventoryBulk = '/pharmacy/inventory/bulk';
  static const String pharmacyDashboardStats = '/pharmacy/dashboard/stats';
  static const String pharmacyRatings = '/pharmacy/ratings';
  static const String pharmacyInquiries = '/pharmacy/inquiries';
  static const String pharmacyAlternatives = '/pharmacy/alternatives';
  static const String notifications = '/notifications';
  static const String notificationsCount = '/notifications/count';
  static const String notificationsMarkAllAsRead =
      '/notifications/mark-all-as-read';
}
