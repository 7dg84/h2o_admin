import 'package:flutter/material.dart';

class AppConfig {
  static const String apiBaseUrl = 'https://h2o.smart-food.cc/api'; // Change to production URL when needed
  
  // Institutional Colors
  static const Color primaryBlue = Color(0xFF003366); // Deep Institutional Blue
  static const Color secondaryAzure = Color(0xFF00A3E0); // Water Azure
  static const Color tertiaryTeal = Color(0xFF008080);
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Semantic Status Colors
  static const Color statusPending = Color(0xFFEF4444); // Red
  static const Color statusInReview = Color(0xFFF59E0B); // Amber
  static const Color statusInAttention = Color(0xFF3B82F6); // Blue
  static const Color statusResolved = Color(0xFF10B981); // Green
  static const Color statusClosed = Color(0xFF64748B); // Slate
}
