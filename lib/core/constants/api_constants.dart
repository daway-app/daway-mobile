import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static const String sendOtp = '/otp/send';
  static const String otpVerify = '/otp/verify';
  static const String registerPatient = '/register/patient';
  static const String pharmacyLogin = '/login/pharmacy';
  static const String registerPharmacy = '/register/pharmacy';
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
  static const String categories = '/categories';
  static const String dosageForms = '/dosage-forms';
  static const String medicines = '/medicines';
  static const String medicinesSearch = '/medicines/search';
  static const String pharmacies = '/pharmacies';
  static const String ratings = '/ratings';
  static const String patientFavoriteMedicines = '/patient/favorites/medicines';
  static const String patientCart = '/patient/cart';
  static const String patientCartItems = '/patient/cart/items';
  static const String patientAddresses = '/patient/addresses';
  static const String patientOrders = '/patient/orders';
  static const String patientCheckout = '/patient/checkout';
  static const String patientInquiries = '/patient/inquiries';
  static const String patientAvailabilityAlerts = '/patient/availability-alerts';
  static const String patientHealthProfile = '/patient/health-profile';
}
