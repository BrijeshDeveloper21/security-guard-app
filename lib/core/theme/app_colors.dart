import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents (Figma style soft & vibrant)
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color accent = Color(0xFF0EA5E9); // Sky 500

  // Surface & Backgrounds (Dark theme - Keep for compatibility if needed)
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF334155); // Slate 700
  static const Color borderDark = Color(0xFF475569); // Slate 600

  // Surface & Backgrounds (Light theme - Clean & Airy)
  static const Color bgLight = Color(0xFFF9FAFB); // Gray 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color cardLight = Color(0xFFFFFFFF); // Pure White for cards
  static const Color borderLight = Color(0xFFF3F4F6); // Gray 100
  
  // Soft shadows for cards
  static const Color shadowLight = Color(0x0A000000); // Very soft black

  // Status Colors (Mandatory security states - brighter variants)
  static const Color statusApproved = Color(0xFF10B981); // Emerald 500
  static const Color statusPending = Color(0xFFF59E0B); // Amber 500
  static const Color statusRejected = Color(0xFFEF4444); // Red 500
  static const Color statusInside = Color(0xFF3B82F6); // Blue 500
  static const Color statusExited = Color(0xFF6B7280); // Gray 500
  static const Color statusOnline = Color(0xFF10B981); // Emerald 500
  static const Color statusOffline = Color(0xFFF97316); // Orange 500
  static const Color statusSyncing = Color(0xFF8B5CF6); // Violet 500

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF111827); // Gray 900
  static const Color textSecondaryLight = Color(0xFF4B5563); // Gray 600
  static const Color textMutedLight = Color(0xFF9CA3AF); // Gray 400

  // Operational / Quick Action Colors
  static const Color actionVisitor = Color(0xFF6366F1); // Indigo 500
  static const Color actionDelivery = Color(0xFFF59E0B); // Amber 500
  static const Color actionScanQr = Color(0xFF10B981); // Emerald 500
  static const Color actionFind = Color(0xFF8B5CF6); // Violet 500
  static const Color actionInside = Color(0xFF0EA5E9); // Sky 500
  static const Color actionEmergency = Color(0xFFEF4444); // Red 500
}
