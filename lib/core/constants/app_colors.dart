import 'package:flutter/material.dart';

class AppColors {
  // --- ពណ៌ចម្បងស្ថាប័ន (Chenla Navy Theme) ---
  static const Color primary = Color(0xFF0F2B48); // Navy ចាស់ (Header, Buttons)
  static const Color primaryLight = Color(0xFF1B497B); // Blue ទន់
  static const Color secondary = Color(0xFF2563EB); // Accent Blue

  // --- ពណ៌ផ្ទៃខាងក្រោយ & Surface ---
  static const Color background = Color(0xFFF1F5F9); // ផ្ទៃប្រផេះស្រាលទន់ភ្នែក
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);

  // --- ពណ៌សម្គាល់ស្ថានភាពបន្ទប់ (Room Status) ---
  static const Color statusReady = Color(0xFF10B981); // បៃតង (រួចរាល់/ទំនេរ)
  static const Color statusInProgress =
      Color(0xFFF59E0B); // ទឹកក្រូច (កំពុងប្រើ/រៀបចំ)
  static const Color statusOutOfOrder = Color(0xFFEF4444); // ក្រហម (ខូច/ផ្អាក)

  // --- ពណ៌សម្គាល់វត្តមានបុគ្គលិក (Attendance Status) ---
  static const Color present = Color(0xFF10B981); // មកធ្វើការ (បៃតង)
  static const Color late = Color(0xFFF59E0B); // មកយឺត (លឿង/ទឹកក្រូច)
  static const Color permission = Color(0xFF3B82F6); // សុំច្បាប់ (ខៀវ)
  static const Color absent = Color(0xFFEF4444); // អវត្តមាន (ក្រហម)

  // --- ពណ៌អក្សរ (Text Colors) ---
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
}
