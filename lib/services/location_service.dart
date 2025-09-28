import 'dart:math';
import 'dart:math' as math;

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;

  Position({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.heading = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
}

class LocationAccuracy {
  static const low = 1000.0;
  static const medium = 100.0;
  static const high = 10.0;
  static const best = 1.0;
  static const bestForNavigation = 0.1;
}

class LocationService {
  /// 獲取當前位置（模擬）
  Future<Position?> getCurrentPosition() async {
    try {
      // 模擬位置獲取，添加更真实的延迟
      await Future.delayed(
          Duration(milliseconds: 800 + (Random().nextInt(400))));

      // 模擬偶爾的定位失敗
      if (Random().nextDouble() < 0.1) {
        // 10% 的失敗率
        throw Exception('GPS信號弱，定位失敗');
      }

      // 返回模擬的澳門位置，添加一些隨機偏移使其更真實
      final baseLat = 22.1987;
      final baseLng = 113.5439;
      final offset = 0.001; // 約100米的偏移

      return Position(
        latitude: baseLat + (Random().nextDouble() - 0.5) * offset,
        longitude: baseLng + (Random().nextDouble() - 0.5) * offset,
        accuracy: 5.0 + Random().nextDouble() * 15.0, // 5-20米精度
      );
    } catch (e) {
      print('獲取位置失敗: $e');
      rethrow; // 重新抛出异常，让调用者处理
    }
  }

  /// 計算兩個位置之間的距離（米）
  double calculateDistance(Position start, Position end) {
    const double earthRadius = 6371000; // 地球半徑（米）

    double lat1Rad = start.latitude * pi / 180;
    double lat2Rad = end.latitude * pi / 180;
    double deltaLatRad = (end.latitude - start.latitude) * pi / 180;
    double deltaLonRad = (end.longitude - start.longitude) * pi / 180;

    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 檢查位置是否在指定範圍內
  bool isLocationInRange(
      Position center, Position target, double rangeInMeters) {
    double distance = calculateDistance(center, target);
    return distance <= rangeInMeters;
  }

  /// 檢查位置權限（模擬）
  Future<LocationPermission> checkPermission() async {
    // 模擬權限檢查
    await Future.delayed(Duration(milliseconds: 100));
    return LocationPermission.whileInUse;
  }

  /// 請求位置權限（模擬）
  Future<LocationPermission> requestPermission() async {
    // 模擬權限請求
    await Future.delayed(Duration(milliseconds: 500));
    return LocationPermission.whileInUse;
  }
}
