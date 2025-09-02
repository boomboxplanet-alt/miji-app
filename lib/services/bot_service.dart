import 'dart:async';
import 'dart:math';

import 'enhanced_ai_service.dart';

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal() {
    // 初始化時設定系統語言
    // 注意：ui.window.locale 已被棄用，使用 PlatformDispatcher 替代
    // final systemLocale = ui.window.locale;
    // final languageCode = systemLocale.languageCode;
    // _aiService.updateSystemLanguage(languageCode);
  }

  final Random _random = Random();
  Timer? _botTimer;
  bool _isEnabled = true; // 預設啟用機器人服務
  double? _userLatitude;
  double? _userLongitude;
  double _userRadius = 1000.0; // 用戶當前範圍，預設1000米（1公里）
  final EnhancedAIService _aiService = EnhancedAIService();

  // 真實用戶風格的留言模板
  static const List<String> _messageTemplates = [
    // 真實日常抱怨類
    '又要加班了...有人陪我嗎',
    '剛錯過公車，心情超差',
    '排隊買奶茶排了20分鐘，值得嗎？',
    '今天又遲到了，老闆臉超黑',
    '手機沒電了，現代人的恐慌',
    '塞車塞到懷疑人生',
    'WiFi又斷了，想哭',
    '錢包越來越瘦，心越來越慌',
    
    // 真實情感吐槽類
    '單身狗路過，不要餵食',
    '又被催婚了，救命',
    '前任發了動態，我該看嗎？',
    '暗戀的人今天沒回我訊息',
    '室友又不洗碗，氣死',
    '媽媽又問我什麼時候回家',
    '朋友都有對象了，就我沒有',
    '想找個人聊天，但不知道聊什麼',
    
    // 真實工作學習類
    '明天要交報告了，還沒開始寫',
    '老闆今天心情不好，大家小心',
    '考試週到了，開始懷疑人生',
    '實習工資好少，但總比沒有好',
    '同事請假，我又要加班了',
    '面試被拒絕了，繼續努力',
    '論文寫不出來，頭髮掉光了',
    '升職加薪遙遙無期',
    
    // 真實生活瑣事類
    '洗衣機壞了，衣服堆成山',
    '外送又送錯了，餓死我了',
    '鄰居家的狗又在叫，睡不著',
    '電梯又壞了，爬樓梯爬到腿軟',
    '超市大排長龍，買個菜都累',
    '停車位被佔了，想罵人',
    '網購的東西又延遲了',
    '房租又要漲了，搬家吧',
    
    // 真實美食體驗類
    '這家店踩雷了，難吃到哭',
    '排隊一小時的店，就這？',
    '深夜想吃泡麵，罪惡感滿滿',
    '減肥第一天，已經想放棄',
    '同事帶的便當好香，好想要',
    '又點了外送，錢包在哭泣',
    '自己煮的菜，連狗都不吃',
    '宵夜攤的老闆娘超兇',
    
    // 真實社交困擾類
    '群組裡都在聊天，我插不上話',
    '聚會都在聊工作，好無聊',
    '朋友圈不知道發什麼好',
    '被拉進奇怪的群組，想退出',
    '同學會不想去，但不去又怕被說',
    '社恐患者的日常掙扎',
    '想約朋友出來，但怕被拒絕',
    '一個人吃飯被側目，尷尬',
    
    // 真實購物心得類
    '又被直播帶貨洗腦了',
    '網購和實物差太多，想退貨',
    '信用卡帳單來了，不敢看',
    '雙11買了一堆用不到的東西',
    '衣櫃滿了，但還是沒衣服穿',
    '化妝品過期了，錢白花了',
    '想買的東西漲價了，心痛',
    '省錢大作戰，從今天開始',
    
    // 真實天氣反應類
    '下雨天心情就是不好',
    '太陽這麼大，不想出門',
    '冷氣費要爆表了',
    '梅雨季衣服都不乾',
    '颱風天還要上班，老闆太狠',
    '霧霾天不敢開窗',
    '溫差太大，又感冒了',
    '夏天到了，又要露肉了',
    
    // 真實健康焦慮類
    '熬夜又長痘痘了',
    '體重計上的數字不敢看',
    '眼睛乾澀，該休息了',
    '腰酸背痛，老了老了',
    '又失眠了，數羊都沒用',
    '體檢報告不敢拆',
    '運動計劃又泡湯了',
    '保健品吃了一堆，沒啥用',
    
    // 真實娛樂吐槽類
    '追的劇又停更了，編劇去哪了',
    '遊戲又更新了，流量沒了',
    '演唱會票搶不到，黃牛太可惡',
    '電影院爆米花比電影還貴',
    'KTV唱歌破音了，丟臉',
    '網紅推薦的東西都是坑',
    '綜藝節目越來越無聊',
    '短視頻刷到停不下來',
  ];

  // 不同時間段的真實留言
  static const Map<int, List<String>> _timeBasedMessages = {
    // 早晨 (6-10)
    6: [
      '鬧鐘響了三次才起床，遲到預警',
      '早餐又沒時間吃，胃痛ing',
      '公車擠死了，想回家睡覺',
      '咖啡還沒喝，腦子不在線',
      '又是Monday Blue的一天',
      '早起的鳥兒有蟲吃，但我不是鳥',
      '為什麼週一來得這麼快',
    ],
    // 上午 (10-12)
    10: [
      '開會開到想睡覺',
      '老闆又在畫大餅了',
      '咖啡喝第三杯了，心跳加速',
      '同事在摸魚，我也想摸',
      '工作群組訊息99+，不想看',
      '距離午餐還有2小時，餓',
      '上午效率？什麼是效率？',
    ],
    // 午餐 (12-14)
    12: [
      '便當又漲價了，錢包痛',
      '排隊買飯排到天荒地老',
      '同事約吃飯，錢包說不行',
      '減肥？午餐面前都是浮雲',
      '外送費比餐點還貴',
      '食堂阿姨手抖了嗎？菜這麼少',
      '午休時間不夠睡，人生好難',
    ],
    // 下午 (14-18)
    14: [
      '下午茶？我只有白開水',
      '午後昏昏欲睡，咖啡救命',
      '還有4小時下班，度日如年',
      '老闆又丟新工作過來了',
      '同事都在划手機，我也想划',
      '下午時光特別漫長',
      '為什麼時間過得這麼慢',
    ],
    // 傍晚 (18-20)
    18: [
      '終於下班了，自由萬歲',
      '加班？我選擇死亡',
      '晚餐吃什麼？人生難題',
      '回家路上塞車，想哭',
      '今天又是疲憊的一天',
      '下班第一件事：躺平',
      '為什麼上班這麼累',
    ],
    // 晚上 (20-23)
    20: [
      '躺在沙發上不想動',
      '追劇追到停不下來',
      '明天又要上班了，憂鬱',
      '宵夜時間到，減肥明天開始',
      '洗澡都懶得洗，太累了',
      '想早睡但捨不得今天結束',
      '夜晚是屬於自己的時間',
    ],
    // 深夜 (23-6)
    23: [
      '又熬夜了，明天會後悔',
      '失眠數羊數到一千隻',
      '深夜emo時間到了',
      '為什麼躺下就睡不著',
      '明天要早起，但現在不想睡',
      '夜深人靜想太多',
      '熬夜一時爽，起床火葬場',
    ],
  };

  void startBotService() {
    if (!_isEnabled) return;
    
    // 立即生成1-5條初始訊息，模擬已存在的用戶留言
    Timer(const Duration(seconds: 3), () {
      _generateInitialMessages();
    });
    
    // 然後開始定期調度新訊息
    _scheduleNextMessage();
  }
  
  void _generateInitialMessages() {
    // 隨機生成3-6條初始訊息
    final int messageCount = 3 + _random.nextInt(4); // 3到6個訊息
    
    for (int i = 0; i < messageCount; i++) {
      // 延遲生成，避免同時生成
      Timer(Duration(milliseconds: i * 500), () {
        _generateBotMessageWithCustomDuration();
      });
    }
  }
  
  void _generateBotMessageWithCustomDuration() {
    final message = _selectRandomMessage();
    final location = _generateRandomLocation();
    final radius = _generateRandomRadius();
    final duration = _generateInitialMessageDuration();
    
    _onBotMessageGenerated?.call(
      message,
      location.latitude,
      location.longitude,
      radius,
      duration,
    );
  }
  
  Duration _generateInitialMessageDuration() {
    // 生成不同剩餘時間的訊息，讓它們看起來是在不同時間發送的
    final remainingMinutes = [
      5, 15, 30, 45, 60, 90, 120, 180, 240, 300, 360
    ];
    return Duration(minutes: remainingMinutes[_random.nextInt(remainingMinutes.length)]);
  }

  void stopBotService() {
    _botTimer?.cancel();
    _botTimer = null;
  }

  void _scheduleNextMessage() {
    if (!_isEnabled) return;
    
    // 隨機間隔 30秒-2分鐘（測試用，較短間隔）
    final int seconds = 30 + _random.nextInt(90);
    
    _botTimer = Timer(Duration(seconds: seconds), () {
      _generateBotMessage();
      _scheduleNextMessage(); // 遞歸調度下一條訊息
    });
  }

  void _generateBotMessage() {
    final message = _selectRandomMessage();
    
    // 如果訊息為空（真實用戶數量達到3個以上），則不生成
    if (message.isEmpty) {
      return;
    }
    
    final location = _generateRandomLocation();
    final radius = _generateRandomRadius();
    final duration = _generateRandomDuration();
    
    // 這裡應該調用 MessageProvider 來添加訊息
    // 但為了避免循環依賴，我們通過回調來處理
    _onBotMessageGenerated?.call(
      message,
      location.latitude,
      location.longitude,
      radius,
      duration,
    );
  }

  // 隨機用戶風格前綴（偶爾使用）
  static const List<String> _userPrefixes = [
    '',  // 大部分時候不加前綴
    '',
    '',
    '',
    '',
    '路過的上班族: ',
    '匿名學生: ',
    '深夜加班狗: ',
    '社畜一枚: ',
    '打工人: ',
    '單身貴族: ',
    '減肥失敗者: ',
    '熬夜專家: ',
    '咖啡成癮者: ',
    '外送常客: ',
  ];

  String _selectRandomMessage() {
    // 80% 機率使用增強AI服務生成智能訊息
    if (_random.nextDouble() < 0.8) {
      return _aiService.generateSmartMessage();
    }
    
    // 20% 機率使用原有的訊息模板（作為後備）
    final hour = DateTime.now().hour;
    
    // 根據時間選擇合適的訊息
    List<String> timeMessages = [];
    if (hour >= 6 && hour < 10) {
      timeMessages = _timeBasedMessages[6] ?? [];
    } else if (hour >= 10 && hour < 12) {
      timeMessages = _timeBasedMessages[10] ?? [];
    } else if (hour >= 12 && hour < 14) {
      timeMessages = _timeBasedMessages[12] ?? [];
    } else if (hour >= 14 && hour < 18) {
      timeMessages = _timeBasedMessages[14] ?? [];
    } else if (hour >= 18 && hour < 20) {
      timeMessages = _timeBasedMessages[18] ?? [];
    } else if (hour >= 20 && hour < 23) {
      timeMessages = _timeBasedMessages[20] ?? [];
    } else {
      timeMessages = _timeBasedMessages[23] ?? [];
    }
    
    // 選擇訊息內容
    String message;
    if (timeMessages.isNotEmpty && _random.nextDouble() < 0.7) {
      message = timeMessages[_random.nextInt(timeMessages.length)];
    } else {
      message = _messageTemplates[_random.nextInt(_messageTemplates.length)];
    }
    
    // 20% 機率添加用戶風格前綴
    if (_random.nextDouble() < 0.2) {
      final prefix = _userPrefixes[_random.nextInt(_userPrefixes.length)];
      message = prefix + message;
    }
    
    return message;
  }

  ({double latitude, double longitude}) _generateRandomLocation() {
    // 使用用戶當前位置，如果沒有則使用台北作為預設
    double baseLat = _userLatitude ?? 25.0330; // 台北101
    double baseLng = _userLongitude ?? 121.5654;
    
    // 使用極坐標系統生成更均勻分佈的位置
    // 隨機角度（0-360度）
    final double angle = _random.nextDouble() * 2 * pi;
    // 在用戶範圍內隨機生成距離（確保機器人訊息在用戶可見範圍內）
    final double maxDistance = _userRadius * 0.8; // 使用用戶範圍的80%，確保完全在範圍內
    final double distance = _random.nextDouble() * maxDistance; // 0到最大距離
    final double radiusInDegrees = distance / 111000; // 轉換為度數（約111km/度）
    
    // 計算新位置
    final double offsetLat = radiusInDegrees * cos(angle);
    final double offsetLng = radiusInDegrees * sin(angle) / cos(baseLat * pi / 180);
    
    return (
      latitude: baseLat + offsetLat,
      longitude: baseLng + offsetLng,
    );
  }

  double _generateRandomRadius() {
    // 生成範圍要大於或等於用戶範圍，確保用戶能看到機器人訊息
    final double minRadius = _userRadius;
    final double maxRadius = _userRadius * 1.5; // 最大為用戶範圍的1.5倍
    return minRadius + _random.nextDouble() * (maxRadius - minRadius);
  }

  Duration _generateRandomDuration() {
    // 隨機生成 30分鐘到 6小時的持續時間
    final minutes = [30, 60, 120, 180, 240, 360];
    return Duration(minutes: minutes[_random.nextInt(minutes.length)]);
  }

  // 回調函數，用於通知外部有新的機器人訊息
  Function(String content, double lat, double lng, double radius, Duration duration)? _onBotMessageGenerated;
  
  void setOnBotMessageGenerated(
    Function(String content, double lat, double lng, double radius, Duration duration) callback
  ) {
    _onBotMessageGenerated = callback;
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      startBotService();
    } else {
      stopBotService();
    }
  }

  bool get isEnabled => _isEnabled;
  
  // 獲取當前語言偏好
  String get languagePreference => _aiService.languagePreference;
  
  void updateUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    _aiService.updateUserLocation(latitude, longitude);
    
    // 根據用戶位置更新語言偏好
    _updateLanguagePreference(latitude, longitude);
  }
  
  // 根據地理位置更新語言偏好
  void _updateLanguagePreference(double latitude, double longitude) {
    // 澳門和香港使用粵語
    if ((latitude >= 22.1 && latitude <= 22.2 && longitude >= 113.5 && longitude <= 113.6) || // 澳門
        (latitude >= 22.1 && latitude <= 22.6 && longitude >= 113.8 && longitude <= 114.5)) { // 香港
      _aiService.setLanguagePreference('local');
    }
    // 台灣使用中文
    else if (latitude >= 21.9 && latitude <= 25.3 && longitude >= 119.3 && longitude <= 122.0) {
      _aiService.setLanguagePreference('zh');
    }
    // 其他地區使用自動檢測
    else {
      _aiService.setLanguagePreference('auto');
    }
  }

  void updateUserRadius(double radius) {
    _userRadius = radius;
  }
  
  void updateRealUserCount(int count) {
    _aiService.updateRealUserCount(count);
  }

  // 手動觸發生成訊息（用於測試）
  void generateMessageNow() {
    _generateBotMessage();
  }

  // 獲取訊息統計
  Map<String, dynamic> getStats() {
    return {
      'totalTemplates': _messageTemplates.length,
      'timeBasedTemplates': _timeBasedMessages.length,
      'isEnabled': _isEnabled,
      'nextMessageIn': _botTimer?.isActive == true ? 'scheduled' : 'not scheduled',
    };
  }
}