import 'package:flutter/material.dart';

class AppColors {
  // 主要顏色 - 採用 iOS 16 風格的柔和藍色和粉色調
  static const Color primaryColor = Color(0xFF6B8AFD); // 柔和藍
  static const Color secondaryColor = Color(0xFFC70039); // 深紅，作為強調色
  static const Color accentColor = Color(0xFFDA4453); // 暖粉色，與藍色形成對比

  // 背景顏色 - 深色主題，更深邃的背景，更透明的表面
  static const Color backgroundColor = Color(0xFF0A0A0A); // 極深背景色，接近純黑
  static const Color surfaceColor = Color(0x33FFFFFF); // 半透明白色，用於玻璃態效果

  // 文字顏色 - 適應深色背景的文字顏色
  static const Color textPrimary = Color(0xFFFFFFFF); // 白色主文本
  static const Color textSecondary = Color(0xFFE0E0E0); // 淺灰色次文本
  static const Color textLight = Color(0xFFAAAAAA); // 更淺的灰色提示文本

  // 狀態顏色 - 保持清晰的狀態指示色
  static const Color successColor = Color(0xFF4CAF50); // 綠色
  static const Color warningColor = Color(0xFFFF9800); // 橙色
  static const Color errorColor = Color(0xFFF44336); // 紅色
  static const Color infoColor = Color(0xFF2196F3); // 藍色

  // 邊框顏色 - 用於玻璃態元素的邊框
  static const Color borderColor = Color(0x33FFFFFF); // 半透明白色邊框
  static const Color dividerColor = Color(0x1AFFFFFF); // 半透明白色分割線

  // 陰影顏色 - 較淺的陰影，以營造懸浮感
  static const Color shadowColor = Color(0x40000000); // 更透明的陰影，增加深度感

  // 透明度變化 - 保留現有的透明度調整方法
  static Color primaryWithOpacity(double opacity) =>
      primaryColor.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) =>
      secondaryColor.withOpacity(opacity);
  static Color accentWithOpacity(double opacity) =>
      accentColor.withOpacity(opacity);
}
