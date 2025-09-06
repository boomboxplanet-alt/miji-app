import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

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
      if (kIsWeb) {
        // Web 平台的特殊處理
        await _getLocationForWeb();
      } else {
        // 移動平台的處理
        await _getLocationForMobile();
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('位置獲取錯誤: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getLocationForWeb() async {
    try {
      // 在 Web 上使用較簡單的方法獲取位置
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10), // 設置超時
      );
      print('Web 位置獲取成功: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
    } catch (e) {
      print('Web 位置獲取失敗: $e');
      // 如果獲取位置失敗，使用預設位置（澳門）
      _currentPosition = Position(
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
      print('使用預設位置: 澳門');
    }
  }

  Future<void> _getLocationForMobile() async {
    // 檢查位置服務是否啟用
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置服務未啟用');
    }

    // 檢查位置權限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置權限被拒絕');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置權限被永久拒絕');
    }

    // 獲取當前位置
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
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