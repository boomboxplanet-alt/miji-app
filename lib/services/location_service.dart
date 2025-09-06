import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 獲取當前位置
  Future<Position?> getCurrentLocation() async {
    try {
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
