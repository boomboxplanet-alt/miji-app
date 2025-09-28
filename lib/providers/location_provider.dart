import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 使用簡化的位置服務
      final locationService = LocationService();
      _currentPosition = await locationService.getCurrentPosition();

      // 如果获取位置成功，清除之前的错误信息
      if (_currentPosition != null) {
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentPosition = null; // 确保在失败时清除位置数据
      print('LocationProvider获取位置失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // 使用簡化的距離計算
    return _calculateDistance(lat1, lon1, lat2, lon2);
  }

  // 簡化的距離計算方法
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半徑（米）

    double lat1Rad = lat1 * 3.14159265359 / 180;
    double lat2Rad = lat2 * 3.14159265359 / 180;
    double deltaLatRad = (lat2 - lat1) * 3.14159265359 / 180;
    double deltaLonRad = (lon2 - lon1) * 3.14159265359 / 180;

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLocationData() {
    _currentPosition = null;
    _errorMessage = null;
    notifyListeners();
  }
}
