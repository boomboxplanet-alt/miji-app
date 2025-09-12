class AIBotConfig {
  // 是否在應用啟動時自動啟動機器人
  static const bool autoStartOnAppLaunch = true;
  
  // 初始訊息生成數量範圍
  static const int initialMessageMin = 3;
  static const int initialMessageMax = 6;
  
  // 初始訊息生成間隔（毫秒）
  static const int initialMessageInterval = 2000;
  
  // 自動生成訊息的間隔範圍（秒）
  static const int autoGenerateMinInterval = 120; // 2分鐘
  static const int autoGenerateMaxInterval = 300; // 5分鐘
  
  // 機器人訊息的持續時間範圍（分鐘）
  static const int messageDurationMin = 30; // 30分鐘
  static const int messageDurationMax = 300; // 5小時
  
  // 機器人訊息的發布範圍（米）
  static const double messageRadiusMin = 200.0; // 200米
  static const double messageRadiusMax = 1000.0; // 1公里
  
  // 是否在用戶範圍內隨機分布訊息
  static const bool randomizeMessageLocation = true;
  
  // 機器人訊息的優先級（數值越高越優先顯示）
  static const int botMessagePriority = 1;
  
  // 是否在控制台顯示機器人活動日誌
  static const bool enableLogging = false; // 禁用對外日誌，避免暴露機器人
  
  // 機器人訊息的標籤
  static const String botMessageTag = ''; // 移除任何顯示上的機器人標籤
  
  // 機器人訊息的內容類型
  static const List<String> supportedContentTypes = [
    'location',    // 地理位置相關
    'weather',     // 天氣相關
    'season',      // 季節相關
    'time',        // 時間相關
    'general',     // 通用內容
  ];
  
  // 機器人訊息的語言偏好
  static const Map<String, String> languagePreferences = {
    '澳門': 'zh-yue', // 粵語
    '香港': 'zh-yue', // 粵語
    '台灣': 'zh-TW',  // 繁體中文
    'default': 'auto', // 自動檢測
  };
  
  // 機器人訊息的活躍時間段
  static const Map<String, List<int>> activeTimeRanges = {
    'morning': [6, 10],    // 早晨 6-10點
    'noon': [10, 14],      // 中午 10-14點
    'afternoon': [14, 18], // 下午 14-18點
    'evening': [18, 22],   // 晚上 18-22點
    'night': [22, 6],      // 深夜 22-6點
  };
  
  // 機器人訊息的內容長度範圍
  static const int contentLengthMin = 5;  // 最少5字
  static const int contentLengthMax = 30; // 最多30字
  
  // 機器人訊息的生成策略
  static const Map<String, dynamic> generationStrategy = {
    'locationWeight': 0.3,    // 地理位置權重
    'weatherWeight': 0.25,    // 天氣權重
    'seasonWeight': 0.2,      // 季節權重
    'timeWeight': 0.15,       // 時間權重
    'generalWeight': 0.1,     // 通用內容權重
  };
  
  // 機器人訊息的質量控制
  static const Map<String, dynamic> qualityControl = {
    'minSimilarity': 0.7,     // 最小相似度（避免重複）
    'maxRepetition': 3,       // 最大重複次數
    'contentFilter': true,    // 啟用內容過濾
    'spamProtection': true,   // 啟用垃圾訊息防護
  };
  
  // 機器人訊息的性能設置
  static const Map<String, dynamic> performanceSettings = {
    'maxConcurrentMessages': 10,  // 最大並發訊息數
    'messageQueueSize': 50,       // 訊息隊列大小
    'processingTimeout': 5000,    // 處理超時時間（毫秒）
    'retryAttempts': 3,          // 重試次數
  };
}
