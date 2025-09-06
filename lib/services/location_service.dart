import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 獲取當前位置
  Future<Position?> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // Web 平台的特殊處理
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e) {
          print('Web 位置獲取失敗，使用預設位置: $e');
          // 使用預設位置（澳門）
          return Position(
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
        // 檢查位置權限
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return null;
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          return null;
        }
        
        // 獲取位置
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    } catch (e) {
      print('獲取位置失敗: $e');
      return null;
    }
  }
  
  /// 計算兩個位置之間的距離（米）
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
  
  /// 檢查位置是否在指定範圍內
  bool isLocationInRange(Position center, Position target, double rangeInMeters) {
    double distance = calculateDistance(center, target);
    return distance <= rangeInMeters;
  }
}
