class AppConstants {
  // 地理範圍限制
  static const double minRadius = 50.0; // 最小 50 米
  static const double maxRadius = 1000.0; // 最大 1000 米
  static const double defaultRadius = 1000.0; // 預設 1000 米（1公里）
  
  // 時間限制
  static const int minDurationMinutes = 10; // 最短 10 分鐘
  static const int maxDurationMinutes = 1440; // 最長 24 小時
  static const int defaultDurationMinutes = 60; // 預設 1 小時
  
  // 預設時間選項（分鐘）
  static const List<int> durationOptions = [
    10, 30, 60, // 10分鐘, 30分鐘, 1小時
    120, 180, 240, 300, 360, // 2-6小時
    420, 480, 540, 600, 660, 720, // 7-12小時
  ];
  
  // 時間選項標籤
  static const List<String> durationLabels = [
    '10分鐘', '30分鐘', '1小時',
    '2小時', '3小時', '4小時', '5小時', '6小時',
    '7小時', '8小時', '9小時', '10小時', '11小時', '12小時',
  ];
  
  // 訊息限制
  static const int maxMessageLength = 200; // 最大 200 字元
  
  // API 設定
  static const String baseUrl = 'https://api.miji.app';
  static const Duration requestTimeout = Duration(seconds: 30);
}