import 'package:flutter/material.dart';
import '../services/location_service.dart';

class AppState extends ChangeNotifier {
  Position? _currentLocation;
  bool _isLoading = false;
  String _currentScreen = 'intro';
  
  // Getters
  Position? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String get currentScreen => _currentScreen;
  
  /// 設置當前位置
  void setCurrentLocation(Position location) {
    _currentLocation = location;
    notifyListeners();
  }
  
  /// 設置加載狀態
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// 切換屏幕
  void navigateTo(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }
  
  /// 獲取位置權限
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await LocationService().checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService().requestPermission();
      }
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('請求位置權限失敗: $e');
      return false;
    }
  }
  
  /// 獲取當前位置
  Future<Position?> getCurrentLocation() async {
    try {
      setLoading(true);
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        setCurrentLocation(position);
      }
      return position;
    } catch (e) {
      print('獲取位置失敗: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }
}

