import 'package:flutter/material.dart';

enum ThemeType {
  classic, // 經典藍紫
  sunset, // 日落橙紅
  forest, // 森林綠
  ocean, // 海洋藍
  lavender, // 薰衣草紫
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

  // 預定義主題 - 針對 iOS 16 玻璃態風格進行調整
  static const AppTheme classic = AppTheme(
    type: ThemeType.classic,
    name: '經典藍紫',
    description: '優雅的藍紫漸層，經典而不失現代感',
    gradientColors: [
      Color(0xFF8E88EE), // 較淺的藍紫色
      Color(0xFFBB88EE), // 較深的藍紫色
      Color(0xFFEE88EE), // 粉紫色
    ],
    primaryColor: Color(0xFF8E88EE),
    secondaryColor: Color(0xFFBB88EE),
    accentColor: Color(0xFFEE88EE),
    backgroundColor: Color(0xFF0A0A0A),
    surfaceColor: Color(0x33FFFFFF), // 半透明白色
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFE0E0E0),
  );

  static const AppTheme sunset = AppTheme(
    type: ThemeType.sunset,
    name: '日落橙紅',
    description: '溫暖的日落色彩，充滿活力與熱情',
    gradientColors: [
      Color(0xFFFFA07A), // 淺橙色
      Color(0xFFFF7F50), // 珊瑚紅
      Color(0xFFFF6347), // 番茄紅
    ],
    primaryColor: Color(0xFFFFA07A),
    secondaryColor: Color(0xFFFF7F50),
    accentColor: Color(0xFFFF6347),
    backgroundColor: Color(0xFF0A0A0A),
    surfaceColor: Color(0x33FFFFFF),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFE0E0E0),
  );

  static const AppTheme forest = AppTheme(
    type: ThemeType.forest,
    name: '森林綠',
    description: '清新的森林綠意，帶來自然與寧靜',
    gradientColors: [
      Color(0xFF8FBC8F), // 較淺的森林綠
      Color(0xFF6B8E23), // 橄欖綠
      Color(0xFF556B2F), // 深橄欖綠
    ],
    primaryColor: Color(0xFF8FBC8F),
    secondaryColor: Color(0xFF6B8E23),
    accentColor: Color(0xFF556B2F),
    backgroundColor: Color(0xFF0A0A0A),
    surfaceColor: Color(0x33FFFFFF),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFE0E0E0),
  );

  static const AppTheme ocean = AppTheme(
    type: ThemeType.ocean,
    name: '海洋藍',
    description: '深邃的海洋藍調，沉穩而富有深度',
    gradientColors: [
      Color(0xFF87CEEB), // 天藍色
      Color(0xFF4682B4), // 鋼藍色
      Color(0xFF1E90FF), // 道奇藍
    ],
    primaryColor: Color(0xFF87CEEB),
    secondaryColor: Color(0xFF4682B4),
    accentColor: Color(0xFF1E90FF),
    backgroundColor: Color(0xFF0A0A0A),
    surfaceColor: Color(0x33FFFFFF),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFE0E0E0),
  );

  static const AppTheme lavender = AppTheme(
    type: ThemeType.lavender,
    name: '薰衣草紫',
    description: '浪漫的薰衣草紫，溫柔而夢幻',
    gradientColors: [
      Color(0xFFE6E6FA), // 薰衣草紫
      Color(0xFFD8BFD8), // 薊色
      Color(0xFFDA70D6), // 蘭花紫
    ],
    primaryColor: Color(0xFFE6E6FA),
    secondaryColor: Color(0xFFD8BFD8),
    accentColor: Color(0xFFDA70D6),
    backgroundColor: Color(0xFF0A0A0A),
    surfaceColor: Color(0x33FFFFFF),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFE0E0E0),
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
  BoxDecoration getGradientDecorationWithOpacity(double opacity) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors
              .map((color) => color.withOpacity(opacity))
              .toList(),
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  // 獲取圓角漸層裝飾 (玻璃態風格)
  BoxDecoration getRoundedGlassmorphismDecoration(double radius,
          {double opacity = 0.2, double blurStrength = 10.0}) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors
              .map((color) => color.withOpacity(opacity))
              .toList(),
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: blurStrength,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blurStrength * 1.5,
            offset: const Offset(0, 8),
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
