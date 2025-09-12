import 'dart:math';
import 'dart:async';
import 'smart_message_generator.dart';

class AIGeographicBotService {
  static final AIGeographicBotService _instance = AIGeographicBotService._internal();
  factory AIGeographicBotService() => _instance;
  AIGeographicBotService._internal();

  final Random _random = Random();
  final SmartMessageGenerator _messageGenerator = SmartMessageGenerator();
  Timer? _messageTimer;
  bool _isEnabled = true;
  
  // 地理位置信息
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentLocation;
  String? _currentCountry;
  
  // 天氣信息
  String? _currentWeather;
  double? _currentTemperature;
  
  // 環境信息
  String? _currentSeason;
  String? _currentTimeOfDay;
  
  // 回調函數
  Function(String content, double lat, double lng, double radius, Duration duration)? _onMessageGenerated;
  
  // 用戶範圍信息
  double _userRadius = 1000.0; // 默認1公里

  // 啟動機器人服務
  void startService() {
    if (!_isEnabled) return;
    
    // 立即生成 3-6 條初始訊息
    Timer(const Duration(seconds: 2), () {
      _generateInitialMessages();
    });
    
    // 定期生成新訊息 (每 2-5 分鐘)
    _scheduleNextMessage();
  }

  // 停止機器人服務
  void stopService() {
    _messageTimer?.cancel();
    _messageTimer = null;
  }

  // 設置用戶位置
  void updateUserLocation(double latitude, double longitude) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    
    // 更新地理位置信息
    _updateLocationInfo(latitude, longitude);
    
    // 更新天氣信息
    _updateWeatherInfo();
    
    // 更新環境信息
    _updateEnvironmentInfo();
  }
  
  // 更新用戶範圍
  void updateUserRadius(double radius) {
    _userRadius = radius;
    // 靜默更新（不打印任何機器人相關訊息）
  }
  
  // 獲取用戶範圍
  double _getUserRadius() {
    return _userRadius;
  }

  // 更新地理位置信息
  void _updateLocationInfo(double lat, double lng) {
    _currentLocation = _getLocationContext(lat, lng);
    _currentCountry = _getCountryContext(lat, lng);
    // 靜默更新位置
  }

  // 更新天氣信息
  void _updateWeatherInfo() {
    _currentWeather = _generateRandomWeather();
    _currentTemperature = 15 + _random.nextDouble() * 25; // 15-40°C
    // 靜默更新天氣
  }

  // 更新環境信息
  void _updateEnvironmentInfo() {
    final now = DateTime.now();
    final month = now.month;
    final hour = now.hour;
    
    // 季節判斷
    if (month >= 3 && month <= 5) {
      _currentSeason = '春天';
    } else if (month >= 6 && month <= 8) {
      _currentSeason = '夏天';
    } else if (month >= 9 && month <= 11) {
      _currentSeason = '秋天';
    } else {
      _currentSeason = '冬天';
    }
    
    // 時間段判斷
    if (hour >= 6 && hour < 10) {
      _currentTimeOfDay = '早晨';
    } else if (hour >= 10 && hour < 14) {
      _currentTimeOfDay = '中午';
    } else if (hour >= 14 && hour < 18) {
      _currentTimeOfDay = '下午';
    } else if (hour >= 18 && hour < 22) {
      _currentTimeOfDay = '晚上';
    } else {
      _currentTimeOfDay = '深夜';
    }
    
    // 靜默更新環境
  }

  // 生成隨機天氣
  String _generateRandomWeather() {
    final weatherTypes = [
      '晴天', '多雲', '陰天', '小雨', '中雨', '大雨', '雷陣雨',
      '霧天', '雪天', '冰雹', '沙塵暴', '颱風'
    ];
    return weatherTypes[_random.nextInt(weatherTypes.length)];
  }

  // 生成初始訊息
  void _generateInitialMessages() {
    final messageCount = 3 + _random.nextInt(4); // 3-6 條訊息
    
    for (int i = 0; i < messageCount; i++) {
      Timer(Duration(milliseconds: i * 800), () {
        _generateAndSendMessage();
      });
    }
  }

  // 調度下一條訊息
  void _scheduleNextMessage() {
    if (!_isEnabled) return;
    
    // 隨機間隔 2-5 分鐘
    final int seconds = 120 + _random.nextInt(180);
    
    _messageTimer = Timer(Duration(seconds: seconds), () {
      _generateAndSendMessage();
      _scheduleNextMessage(); // 遞歸調度
    });
  }

  // 生成並發送訊息
  void _generateAndSendMessage() {
    final message = _generateContextualMessage();
    if (message.isNotEmpty) {
      final location = _generateRandomLocation();
      final radius = _generateRandomRadius();
      final duration = _generateRandomDuration();
      
      _onMessageGenerated?.call(message, location.latitude, location.longitude, radius, duration);
    }
  }

  // 生成上下文相關的訊息
  String _generateContextualMessage() {
    // 使用智能訊息生成器
    return _messageGenerator.generateRandomLengthMessage(
      country: _currentCountry ?? '其他',
      weather: _currentWeather ?? '晴天',
      season: _currentSeason ?? '春天',
      timeOfDay: _currentTimeOfDay ?? '中午',
      minLength: 5,
      maxLength: 30,
    );
  }

  // 生成隨機位置
  ({double latitude, double longitude}) _generateRandomLocation() {
    if (_currentLatitude == null || _currentLongitude == null) {
      return (latitude: 22.1667, longitude: 113.5500); // 默認澳門
    }
    
    // 在用戶周圍的實際範圍內生成隨機位置
    final userRadius = _getUserRadius(); // 獲取用戶實際範圍
    final maxDistance = userRadius * 0.8; // 使用用戶範圍的80%，確保在範圍內
    final radiusInDegrees = maxDistance / 111000; // 轉換為度數
    
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * radiusInDegrees;
    
    final offsetLat = distance * cos(angle);
    final offsetLng = distance * sin(angle) / cos(_currentLatitude! * pi / 180);
    
    return (
      latitude: _currentLatitude! + offsetLat,
      longitude: _currentLongitude! + offsetLng,
    );
  }

  // 生成隨機範圍
  double _generateRandomRadius() {
    return 200 + _random.nextDouble() * 800; // 200-1000米
  }

  // 生成隨機持續時間
  Duration _generateRandomDuration() {
    const minutes = [30, 45, 60, 90, 120, 180, 240, 300]; // 30分鐘到5小時
    return Duration(minutes: minutes[_random.nextInt(minutes.length)]);
  }

  // 根據經緯度判斷地理位置
  String _getLocationContext(double lat, double lng) {
    // 澳門
    if (lat >= 22.1 && lat <= 22.2 && lng >= 113.5 && lng <= 113.6) {
      return '澳門';
    }
    // 香港
    else if (lat >= 22.1 && lat <= 22.6 && lng >= 113.8 && lng <= 114.5) {
      return '香港';
    }
    // 台灣主要城市
    else if (lat >= 25.0 && lat <= 25.3 && lng >= 121.4 && lng <= 121.7) {
      return '台北';
    } else if (lat >= 24.1 && lat <= 24.2 && lng >= 120.6 && lng <= 120.7) {
      return '台中';
    } else if (lat >= 22.6 && lat <= 22.7 && lng >= 120.2 && lng <= 120.4) {
      return '高雄';
    }
    // 其他台灣地區
    else if (lat >= 21.9 && lat <= 25.3 && lng >= 119.3 && lng <= 122.0) {
      return '台灣';
    }
    
    return '未知地區';
  }

  // 根據經緯度判斷國家
  String _getCountryContext(double lat, double lng) {
    // 澳門
    if (lat >= 22.1 && lat <= 22.2 && lng >= 113.5 && lng <= 113.6) {
      return '澳門';
    }
    // 香港
    else if (lat >= 22.1 && lat <= 22.6 && lng >= 113.8 && lng <= 114.5) {
      return '香港';
    }
    // 台灣
    else if (lat >= 21.9 && lat <= 25.3 && lng >= 119.3 && lng <= 122.0) {
      return '台灣';
    }
    // 其他國家
    else if (lat >= 10.0 && lat <= 14.7 && lng >= 102.3 && lng <= 107.6) {
      return '柬埔寨';
    } else if (lat >= 5.6 && lat <= 20.5 && lng >= 97.3 && lng <= 105.6) {
      return '泰國';
    } else if (lat >= 8.2 && lat <= 23.4 && lng >= 102.1 && lng <= 109.5) {
      return '越南';
    }
    
    return '其他';
  }

  // 設置回調函數
  void setOnMessageGenerated(
    Function(String content, double lat, double lng, double radius, Duration duration) callback
  ) {
    _onMessageGenerated = callback;
  }

  // 手動觸發生成訊息
  void generateMessageNow() {
    _generateAndSendMessage();
  }

  // 獲取當前狀態
  Map<String, dynamic> getCurrentStatus() {
    return {
      'location': _currentLocation,
      'country': _currentCountry,
      'weather': _currentWeather,
      'temperature': _currentTemperature,
      'season': _currentSeason,
      'timeOfDay': _currentTimeOfDay,
      'isEnabled': _isEnabled,
    };
  }

  // 啟用/禁用服務
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      startService();
    } else {
      stopService();
    }
  }

  // 獲取服務狀態
  bool get isEnabled => _isEnabled;
}
