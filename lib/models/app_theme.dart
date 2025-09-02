import 'package:flutter/material.dart';

enum ThemeType {
  classic,    // 經典藍紫
  sunset,     // 日落橙紅
  forest,     // 森林綠
  ocean,      // 海洋藍
  lavender,   // 薰衣草紫
}

class AppTheme {
  final ThemeType type;
  final String name;
  final String description;
  final List<Color> gradientColors;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const AppTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.gradientColors,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  // 預定義主題
  static const AppTheme classic = AppTheme(
    type: ThemeType.classic,
    name: '經典藍紫',
    description: '優雅的藍紫漸層，經典而不失現代感',
    gradientColors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0xFFf093fb),
    ],
    primaryColor: Color(0xFF667eea),
    secondaryColor: Color(0xFF764ba2),
    accentColor: Color(0xFFf093fb),
    backgroundColor: Color(0xFFF8F9FA),
    surfaceColor: Color(0xFFFFFFFF),
    textPrimaryColor: Color(0xFF2D3748),
    textSecondaryColor: Color(0xFF718096),
  );

  static const AppTheme sunset = AppTheme(
    type: ThemeType.sunset,
    name: '日落橙紅',
    description: '溫暖的日落色彩，充滿活力與熱情',
    gradientColors: [
      Color(0xFFff9a9e),
      Color(0xFFfecfef),
      Color(0xFFfecfef),
    ],
    primaryColor: Color(0xFFff6b6b),
    secondaryColor: Color(0xFFff8e53),
    accentColor: Color(0xFFff6b9d),
    backgroundColor: Color(0xFFFFF8F6),
    surfaceColor: Color(0xFFFFFFFF),
    textPrimaryColor: Color(0xFF2D3748),
    textSecondaryColor: Color(0xFF718096),
  );

  static const AppTheme forest = AppTheme(
    type: ThemeType.forest,
    name: '森林綠',
    description: '清新的森林綠意，帶來自然與寧靜',
    gradientColors: [
      Color(0xFF11998e),
      Color(0xFF38ef7d),
      Color(0xFF38ef7d),
    ],
    primaryColor: Color(0xFF10ac84),
    secondaryColor: Color(0xFF00d2d3),
    accentColor: Color(0xFF54a0ff),
    backgroundColor: Color(0xFFF0FFF4),
    surfaceColor: Color(0xFFFFFFFF),
    textPrimaryColor: Color(0xFF2D3748),
    textSecondaryColor: Color(0xFF718096),
  );

  static const AppTheme ocean = AppTheme(
    type: ThemeType.ocean,
    name: '海洋藍',
    description: '深邃的海洋藍調，沉穩而富有深度',
    gradientColors: [
      Color(0xFF2980b9),
      Color(0xFF6bb6ff),
      Color(0xFF74b9ff),
    ],
    primaryColor: Color(0xFF0984e3),
    secondaryColor: Color(0xFF74b9ff),
    accentColor: Color(0xFF00cec9),
    backgroundColor: Color(0xFFF0F8FF),
    surfaceColor: Color(0xFFFFFFFF),
    textPrimaryColor: Color(0xFF2D3748),
    textSecondaryColor: Color(0xFF718096),
  );

  static const AppTheme lavender = AppTheme(
    type: ThemeType.lavender,
    name: '薰衣草紫',
    description: '浪漫的薰衣草紫，溫柔而夢幻',
    gradientColors: [
      Color(0xFFa8edea),
      Color(0xFFfed6e3),
      Color(0xFFfed6e3),
    ],
    primaryColor: Color(0xFF9c88ff),
    secondaryColor: Color(0xFFffecd2),
    accentColor: Color(0xFFff9ff3),
    backgroundColor: Color(0xFFFAF5FF),
    surfaceColor: Color(0xFFFFFFFF),
    textPrimaryColor: Color(0xFF2D3748),
    textSecondaryColor: Color(0xFF718096),
  );

  // 獲取所有可用主題
  static List<AppTheme> get allThemes => [
    classic,
    sunset,
    forest,
    ocean,
    lavender,
  ];

  // 根據類型獲取主題
  static AppTheme getThemeByType(ThemeType type) {
    switch (type) {
      case ThemeType.classic:
        return classic;
      case ThemeType.sunset:
        return sunset;
      case ThemeType.forest:
        return forest;
      case ThemeType.ocean:
        return ocean;
      case ThemeType.lavender:
        return lavender;
    }
  }

  // 獲取漸層裝飾
  BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: gradientColors,
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 獲取帶透明度的漸層裝飾
  BoxDecoration getGradientDecorationWithOpacity(double opacity) => BoxDecoration(
    gradient: LinearGradient(
      colors: gradientColors.map((color) => color.withOpacity(opacity)).toList(),
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // 獲取圓角漸層裝飾
  BoxDecoration getRoundedGradientDecoration(double radius, {double opacity = 1.0}) => BoxDecoration(
    gradient: LinearGradient(
      colors: gradientColors.map((color) => color.withOpacity(opacity)).toList(),
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.4),
        blurRadius: 25,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 40,
        offset: const Offset(0, 15),
      ),
    ],
  );

  // 序列化
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
  };

  // 反序列化
  factory AppTheme.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = ThemeType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => ThemeType.classic,
    );
    return getThemeByType(type);
  }
}