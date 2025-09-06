import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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
      Position? position;
      
      if (kIsWeb) {
        // Web 平台的特殊處理
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e) {
          print('Web 位置獲取失敗，使用預設位置: $e');
          // 使用預設位置（澳門）
          position = Position(
            latitude: 22.1987,
            longitude: 113.5439,
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        }
      } else {
        // 移動平台的處理
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      
      setCurrentLocation(position);
      return position;
    } catch (e) {
      print('獲取位置失敗: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }
}
