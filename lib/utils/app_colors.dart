import 'package:flutter/material.dart';

class AppColors {
  // 主要顏色
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4ECDC4);
  static const Color accentColor = Color(0xFFFF6B6B);
  
  // 背景顏色
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // 文字顏色
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  
  // 狀態顏色
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFF56565);
  static const Color infoColor = Color(0xFF4299E1);
  
  // 邊框顏色
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEDF2F7);
  
  // 陰影顏色
  static const Color shadowColor = Color(0x1A000000);
  
  // 透明度變化
  static Color primaryWithOpacity(double opacity) => primaryColor.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) => secondaryColor.withOpacity(opacity);
  static Color accentWithOpacity(double opacity) => accentColor.withOpacity(opacity);
}