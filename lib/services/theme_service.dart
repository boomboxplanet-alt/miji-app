import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeBoxName = 'theme_settings';
  static const String _currentThemeKey = 'current_theme';
  
  Box? _themeBox;
  AppTheme _currentTheme = AppTheme.classic;
  bool _isInitialized = false;

  AppTheme get currentTheme => _currentTheme;
  bool get isInitialized => _isInitialized;
  List<AppTheme> get availableThemes => AppTheme.allThemes;

  // 初始化主題服務
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        _themeBox = await Hive.openBox(_themeBoxName);
      } else {
        _themeBox = Hive.box(_themeBoxName);
      }
      
      // 載入保存的主題
      await _loadSavedTheme();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('主題服務初始化失敗: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // 載入保存的主題
  Future<void> _loadSavedTheme() async {
    try {
      final savedThemeData = _themeBox?.get(_currentThemeKey);
      if (savedThemeData != null) {
        final themeMap = Map<String, dynamic>.from(savedThemeData);
        _currentTheme = AppTheme.fromJson(themeMap);
      }
    } catch (e) {
      debugPrint('載入主題失敗: $e');
      _currentTheme = AppTheme.classic;
    }
  }

  // 切換主題
  Future<void> setTheme(AppTheme theme) async {
    try {
      _currentTheme = theme;
      
      // 保存主題設定
      await _saveTheme(theme);
      
      notifyListeners();
    } catch (e) {
      debugPrint('設定主題失敗: $e');
    }
  }

  // 根據類型設定主題
  Future<void> setThemeByType(ThemeType type) async {
    final theme = AppTheme.getThemeByType(type);
    await setTheme(theme);
  }

  // 保存主題設定
  Future<void> _saveTheme(AppTheme theme) async {
    try {
      await _themeBox?.put(_currentThemeKey, theme.toJson());
    } catch (e) {
      debugPrint('保存主題失敗: $e');
    }
  }

  // 獲取主題預覽顏色
  List<Color> getThemePreviewColors(AppTheme theme) {
    return theme.gradientColors;
  }

  // 檢查是否為當前主題
  bool isCurrentTheme(AppTheme theme) {
    return _currentTheme.type == theme.type;
  }

  // 獲取主題統計
  Map<String, dynamic> getThemeStats() {
    return {
      'currentTheme': _currentTheme.name,
      'availableThemes': availableThemes.length,
      'isInitialized': _isInitialized,
    };
  }

  // 重置為預設主題
  Future<void> resetToDefault() async {
    await setTheme(AppTheme.classic);
  }

  // 獲取隨機主題
  Future<void> setRandomTheme() async {
    final themes = availableThemes.where((theme) => theme.type != _currentTheme.type).toList();
    if (themes.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(themes.length);
      await setTheme(themes[randomIndex]);
    }
  }

  // 獲取下一個主題
  Future<void> setNextTheme() async {
    final currentIndex = availableThemes.indexWhere((theme) => theme.type == _currentTheme.type);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    await setTheme(availableThemes[nextIndex]);
  }

  // 獲取上一個主題
  Future<void> setPreviousTheme() async {
    final currentIndex = availableThemes.indexWhere((theme) => theme.type == _currentTheme.type);
    final previousIndex = (currentIndex - 1 + availableThemes.length) % availableThemes.length;
    await setTheme(availableThemes[previousIndex]);
  }

  // 清理資源
  @override
  Future<void> dispose() async {
    await _themeBox?.close();
    super.dispose();
  }
}