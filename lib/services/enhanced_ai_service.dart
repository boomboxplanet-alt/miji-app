import 'dart:math';

class EnhancedAIService {
  static final EnhancedAIService _instance = EnhancedAIService._internal();
  factory EnhancedAIService() => _instance;
  EnhancedAIService._internal();

  final Random _random = Random();
  String? _currentLocation;
  String? _currentCountry;
  int _realUserCount = 0;
  String _systemLanguage = 'zh'; // 預設中文
  String _selectedLanguage = 'auto'; // auto, zh, local

  // 設置用戶位置
  void updateUserLocation(double latitude, double longitude) {
    _currentLocation = _getLocationContext(latitude, longitude);
    _currentCountry = _getCountryContext(latitude, longitude);
  }

  // 設置真實用戶數量
  void updateRealUserCount(int count) {
    _realUserCount = count;
  }

  // 檢查是否應該停止機器人生成
  bool shouldStopBotGeneration() {
    return _realUserCount >= 3;
  }

  // 設置系統語言
  void updateSystemLanguage(String languageCode) {
    _systemLanguage = languageCode;
  }

  // 設置用戶選擇的語言偏好
  void setLanguagePreference(String preference) {
    _selectedLanguage = preference;
  }

  // 獲取當前語言偏好
  String get languagePreference => _selectedLanguage;

  // 獲取可用的語言選項
  Map<String, String> getLanguageOptions() {
    final options = <String, String>{
      'auto': '自動檢測',
      'zh': '中文',
    };

    // 根據當前國家添加本地語言選項
    if (_currentCountry != null &&
        _multiLanguageMessages.containsKey(_currentCountry)) {
      switch (_currentCountry) {
        case '柬埔寨':
          options['local'] = '高棉語';
          break;
        case '泰國':
          options['local'] = '泰語';
          break;
        case '越南':
          options['local'] = '越南語';
          break;
        case '日本':
          options['local'] = '日語';
          break;
        case '韓國':
          options['local'] = '韓語';
          break;
        case '新加坡':
          options['local'] = '英語';
          break;
        case '馬來西亞':
          options['local'] = '馬來語';
          break;
        default:
          options['local'] = '當地語言';
      }
    }

    return options;
  }

  // 根據經緯度判斷地理位置
  String _getLocationContext(double lat, double lng) {
    // 台灣主要城市和地區的經緯度範圍
    if (lat >= 25.0 && lat <= 25.3 && lng >= 121.4 && lng <= 121.7) {
      return '台北';
    } else if (lat >= 24.1 && lat <= 24.2 && lng >= 120.6 && lng <= 120.7) {
      return '台中';
    } else if (lat >= 22.6 && lat <= 22.7 && lng >= 120.2 && lng <= 120.4) {
      return '高雄';
    } else if (lat >= 24.9 && lat <= 25.1 && lng >= 121.7 && lng <= 121.9) {
      return '基隆';
    } else if (lat >= 24.7 && lat <= 24.9 && lng >= 121.1 && lng <= 121.3) {
      return '桃園';
    } else if (lat >= 24.8 && lat <= 25.0 && lng >= 121.0 && lng <= 121.2) {
      return '新竹';
    } else if (lat >= 23.9 && lat <= 24.1 && lng >= 120.4 && lng <= 120.6) {
      return '彰化';
    } else if (lat >= 23.6 && lat <= 23.8 && lng >= 120.5 && lng <= 120.7) {
      return '嘉義';
    } else if (lat >= 22.9 && lat <= 23.1 && lng >= 120.1 && lng <= 120.3) {
      return '台南';
    } else if (lat >= 23.8 && lat <= 24.0 && lng >= 121.5 && lng <= 121.7) {
      return '花蓮';
    } else if (lat >= 22.7 && lat <= 22.9 && lng >= 121.1 && lng <= 121.3) {
      return '台東';
    } else {
      return '台灣';
    }
  }

  // 根據經緯度判斷國家
  String _getCountryContext(double lat, double lng) {
    // 台灣
    if (lat >= 21.9 && lat <= 25.3 && lng >= 119.3 && lng <= 122.0) {
      return '台灣';
    }
    // 柬埔寨
    else if (lat >= 10.0 && lat <= 14.7 && lng >= 102.3 && lng <= 107.6) {
      return '柬埔寨';
    }
    // 泰國
    else if (lat >= 5.6 && lat <= 20.5 && lng >= 97.3 && lng <= 105.6) {
      return '泰國';
    }
    // 越南
    else if (lat >= 8.2 && lat <= 23.4 && lng >= 102.1 && lng <= 109.5) {
      return '越南';
    }
    // 新加坡
    else if (lat >= 1.1 && lat <= 1.5 && lng >= 103.6 && lng <= 104.0) {
      return '新加坡';
    }
    // 馬來西亞
    else if (lat >= 0.9 && lat <= 7.4 && lng >= 99.6 && lng <= 119.3) {
      return '馬來西亞';
    }
    // 日本
    else if (lat >= 24.0 && lat <= 46.0 && lng >= 123.0 && lng <= 146.0) {
      return '日本';
    }
    // 韓國
    else if (lat >= 33.0 && lat <= 39.0 && lng >= 124.0 && lng <= 132.0) {
      return '韓國';
    }
    // 中國大陸
    else if (lat >= 18.0 && lat <= 54.0 && lng >= 73.0 && lng <= 135.0) {
      return '中國';
    } else {
      return '其他';
    }
  }

  // 基於地理位置的訊息模板
  Map<String, List<String>> get _locationBasedMessages => {
        '台北': [
          '101大樓今天好美，但人好多',
          '捷運又誤點了，台北人的日常',
          '西門町逛街逛到腳痠',
          '信義區的咖啡廳都好貴',
          '夜市的臭豆腐還是最香',
          '房租又漲了，台北好難住',
          '上班族的悲歌，每天通勤兩小時',
          '師大夜市的雞排還是最好吃',
          '淡水河邊散步心情好',
          '陽明山看夜景，但停車位難找',
        ],
        '台中': [
          '逢甲夜市人山人海',
          '台中的太陽餅名不虛傳',
          '一中街的小吃讓人流連忘返',
          '台中公園散步很舒服',
          '彩虹眷村的彩繪好療癒',
          '高美濕地的夕陽超美',
          '台中歌劇院的建築好特別',
          '春水堂的珍珠奶茶始祖',
          '台中火車站改建後好現代',
          '東海大學的路思義教堂好美',
        ],
        '高雄': [
          '愛河的夜景好浪漫',
          '六合夜市的木瓜牛奶超讚',
          '駁二藝術特區好文青',
          '旗津的海風吹得好舒服',
          '美麗島捷運站的光之穹頂震撼',
          '蓮池潭的龍虎塔很特別',
          '西子灣看夕陽心情好',
          '高雄港的貨櫃船好壯觀',
          '鹽埕區的老店都有故事',
          '夢時代的摩天輪好浪漫',
        ],
      };

  // 擴展的情境訊息模板
  Map<String, List<String>> get _contextMessages => {
        '早晨': [
          '早安！新的一天開始了',
          '咖啡香味喚醒了我',
          '晨跑遇到好多早起的人',
          '早餐店阿姨的笑容最溫暖',
          '上班路上的風景不錯',
          '今天要加油！',
          '早起的鳥兒有蟲吃',
          '陽光透過窗戶�灑進來',
          '新的一天，新的希望',
          '早晨的空氣特別清新',
        ],
        '午餐': [
          '午餐吃什麼好呢？',
          '便當店大排長龍',
          '同事推薦的餐廳不錯',
          '減肥計畫又破功了',
          '外送費越來越貴了',
          '自己帶便當最健康',
          '午休時間太短了',
          '餐廳的服務態度很好',
          '今天想吃點不一樣的',
          '和同事一起吃飯聊天',
        ],
        '下午': [
          '下午茶時間到了',
          '咖啡因不夠，需要補充',
          '午後的陽光很溫暖',
          '工作效率開始下降',
          '想念家裡的沙發',
          '下班時間還很久',
          '開始計畫週末要做什麼',
          '同事分享的點心很好吃',
          '下午的會議好冗長',
          '期待下班後的自由時光',
        ],
        '晚上': [
          '終於下班了！',
          '晚餐要吃什麼好呢？',
          '夜市的燈光好溫馨',
          '和朋友約會聊天',
          '回家路上的夜景很美',
          '今天辛苦了，犒賞自己',
          '晚上的街道比較安靜',
          '準備回家休息了',
          '夜晚的城市有不同的美',
          '期待明天會更好',
        ],
        '深夜': [
          '夜貓子的時間到了',
          '深夜的城市特別安靜',
          '熬夜又要長痘痘了',
          '宵夜攤的老闆很親切',
          '深夜加班的辛苦',
          '失眠的夜晚特別長',
          '深夜的思考特別深刻',
          '夜晚的星空很美',
          '該睡覺了，明天還要早起',
          '深夜的街道很有氛圍',
        ],
      };

  // 天氣相關訊息
  Map<String, List<String>> get _weatherMessages => {
        '晴天': [
          '今天天氣真好，適合出門',
          '陽光灿爛，心情也跟著好起來',
          '藍天白雲，拍照的好日子',
          '這種天氣最適合野餐了',
          '太陽很大，記得防曬',
          '晴朗的天空讓人心情愉悅',
          '好天氣不出門太可惜了',
          '陽光透過樹葉的影子很美',
        ],
        '雨天': [
          '下雨天就想待在家裡',
          '雨聲很療癒，但出門不方便',
          '撐傘走路好麻煩',
          '雨後的空氣特別清新',
          '下雨天的咖啡廳特別溫馨',
          '雨天讓人想起很多回憶',
          '濕濕的地面要小心滑倒',
          '雨滴打在窗戶上的聲音很好聽',
        ],
        '陰天': [
          '陰天的氣氛有點憂鬱',
          '雲層很厚，感覺要下雨了',
          '陰天拍照不用擔心陰影',
          '這種天氣最適合在家看書',
          '陰天的溫度剛剛好',
          '灰色的天空有種特別的美',
          '陰天讓人想喝熱飲',
          '雲朵的形狀很有趣',
        ],
      };

  // 多語言訊息模板
  Map<String, List<String>> get _multiLanguageMessages => {
        '柬埔寨': [
          'សួស្តី! តើអ្នកនៅទីនេះដែរឬ?', // 你好！你也在這裡嗎？
          'ថ្ងៃនេះអាកាសធាតុល្អណាស់', // 今天天氣很好
          'ខ្ញុំចង់ញ៉ាំបាយ', // 我想吃飯
          'ទីនេះមានមនុស្សច្រើន', // 這裡人很多
          'តើមានអ្នកណាចង់ជជែកទេ?', // 有人想聊天嗎？
          '今天心情不錯', // 中文訊息（台灣人偶爾發中文）
          '想念台灣的夜市', // 中文訊息
          'ទីក្រុងនេះស្អាត', // 這個城市很美
          'ខ្ញុំស្រលាញ់ប្រទេសកម្ពុជា', // 我愛柬埔寨
          '工作好累，想回家了', // 中文訊息
        ],
        '泰國': [
          'สวัสดีครับ! มีใครอยู่ที่นี่บ้างไหม?', // 你好！有人在這裡嗎？
          'วันนี้อากาศดีจัง', // 今天天氣很好
          'อยากกินข้าวแล้ว', // 想吃飯了
          'ที่นี่คนเยอะมาก', // 這裡人很多
          'มีใครอยากคุยกันไหม?', // 有人想聊天嗎？
          '泰式奶茶真的很好喝', // 中文訊息
          '曼谷的交通真的很塞', // 中文訊息
          'ชอบเมืองไทยมาก', // 很喜歡泰國
          'อาหารไทยอร่อยที่สุด', // 泰國菜最好吃
          '想念台灣的珍珠奶茶', // 中文訊息
        ],
        '越南': [
          'Xin chào! Có ai ở đây không?', // 你好！有人在這裡嗎？
          'Hôm nay thời tiết đẹp quá', // 今天天氣很好
          'Tôi muốn ăn cơm', // 我想吃飯
          'Chỗ này đông người quá', // 這裡人太多了
          'Có ai muốn trò chuyện không?', // 有人想聊天嗎？
          '越南河粉真的很香', // 中文訊息
          '胡志明市好熱鬧', // 中文訊息
          'Tôi yêu Việt Nam', // 我愛越南
          'Phở Việt Nam ngon nhất', // 越南河粉最好吃
          '想念台灣的小籠包', // 中文訊息
        ],
        '日本': [
          'こんにちは！誰かいますか？', // 你好！有人嗎？
          '今日はいい天気ですね', // 今天天氣很好
          'お腹が空きました', // 肚子餓了
          'ここは人が多いですね', // 這裡人很多
          '誰か話しませんか？', // 有人想聊天嗎？
          '日本的拉麵真的很棒', // 中文訊息
          '東京的櫻花季好美', // 中文訊息
          '日本大好き', // 很喜歡日本
          '寿司が一番美味しい', // 壽司最好吃
          '想念台灣的鹽酥雞', // 中文訊息
        ],
        '韓國': [
          '안녕하세요! 누구 있나요?', // 你好！有人嗎？
          '오늘 날씨가 좋네요', // 今天天氣很好
          '배고파요', // 肚子餓了
          '여기 사람이 많네요', // 這裡人很多
          '누구 대화할래요?', // 有人想聊天嗎？
          '韓式烤肉真的很香', // 中文訊息
          '首爾的夜景好美', // 中文訊息
          '한국 정말 좋아해요', // 真的很喜歡韓國
          '김치찌개가 최고', // 泡菜鍋最棒
          '想念台灣的滷肉飯', // 中文訊息
        ],
        '新加坡': [
          'Hello! Anyone here?', // 英文
          'Weather is so hot today', // 英文
          'I want to eat already', // 英文
          'So many people here', // 英文
          'Anyone want to chat?', // 英文
          '新加坡的叻沙很好吃', // 中文訊息
          '烏節路好多人', // 中文訊息
          'Singapore very nice lah', // 新加坡式英文
          'Chicken rice is the best', // 英文
          '想念台灣的夜市', // 中文訊息
        ],
        '馬來西亞': [
          'Hello! Ada orang tak?', // 馬來文混英文
          'Hari ini panas sangat', // 今天很熱
          'Saya lapar already', // 我餓了（混合語言）
          'Ramai orang kat sini', // 這裡很多人
          'Anyone nak chat?', // 有人想聊天嗎？
          '馬來西亞的椰漿飯很香', // 中文訊息
          '吉隆坡的雙子塔好壯觀', // 中文訊息
          'Malaysia boleh!', // 馬來西亞可以！
          'Nasi lemak paling sedap', // 椰漿飯最好吃
          '想念台灣的珍珠奶茶', // 中文訊息
        ],
      };

  // 生成智能訊息
  String generateSmartMessage() {
    // 如果真實用戶數量達到3個以上，返回空字符串（不生成訊息）
    if (shouldStopBotGeneration()) {
      return '';
    }

    final hour = DateTime.now().hour;
    final messages = <String>[];

    // 根據語言偏好決定使用哪種語言
    String targetLanguage = _determineTargetLanguage();

    // 根據語言偏好和地理位置決定使用哪種語言
    if (_currentCountry != null &&
        _multiLanguageMessages.containsKey(_currentCountry)) {
      if (targetLanguage == 'local') {
        // 強制使用當地語言
        messages.addAll(_multiLanguageMessages[_currentCountry]!);
        return messages[_random.nextInt(messages.length)];
      } else if (targetLanguage == 'auto') {
        // 自動模式：根據系統語言和地理位置決定
        if (_systemLanguage != 'zh') {
          // 非中文系統，70% 機率使用當地語言
          if (_random.nextDouble() < 0.7) {
            messages.addAll(_multiLanguageMessages[_currentCountry]!);
            return messages[_random.nextInt(messages.length)];
          }
        } else {
          // 中文系統，50% 機率使用當地語言（模擬台灣人在海外會說當地語言）
          if (_random.nextDouble() < 0.5) {
            messages.addAll(_multiLanguageMessages[_currentCountry]!);
            return messages[_random.nextInt(messages.length)];
          }
        }
      }
    }

    // 根據時間添加情境訊息
    if (hour >= 6 && hour < 10) {
      messages.addAll(_contextMessages['早晨'] ?? []);
    } else if (hour >= 11 && hour < 14) {
      messages.addAll(_contextMessages['午餐'] ?? []);
    } else if (hour >= 14 && hour < 18) {
      messages.addAll(_contextMessages['下午'] ?? []);
    } else if (hour >= 18 && hour < 23) {
      messages.addAll(_contextMessages['晚上'] ?? []);
    } else {
      messages.addAll(_contextMessages['深夜'] ?? []);
    }

    // 根據地理位置添加訊息（台灣城市）
    if (_currentLocation != null &&
        _locationBasedMessages.containsKey(_currentLocation)) {
      messages.addAll(_locationBasedMessages[_currentLocation]!);
    }

    // 隨機添加天氣相關訊息
    final weatherTypes = ['晴天', '雨天', '陰天'];
    final randomWeather = weatherTypes[_random.nextInt(weatherTypes.length)];
    messages.addAll(_weatherMessages[randomWeather] ?? []);

    // 添加基礎訊息模板作為後備
    messages.addAll(_getBaseMessages());

    // 隨機選擇一條訊息
    if (messages.isEmpty) {
      return '今天天氣不錯呢';
    }

    String selectedMessage = messages[_random.nextInt(messages.length)];

    // 移除地理位置前綴（避免「在台灣」等開頭）

    // 20% 機率添加情感表達
    if (_random.nextDouble() < 0.2) {
      final emotions = ['😊', '😅', '🤔', '😴', '🙄', '😋', '🤗', '😌'];
      selectedMessage += ' ${emotions[_random.nextInt(emotions.length)]}';
    }

    return selectedMessage;
  }

  // 決定目標語言
  String _determineTargetLanguage() {
    switch (_selectedLanguage) {
      case 'zh':
        return 'zh';
      case 'local':
        return 'local';
      case 'auto':
      default:
        // 自動檢測：優先使用系統語言
        return _systemLanguage == 'zh' ? 'zh' : 'local';
    }
  }

  // 基礎訊息模板
  List<String> _getBaseMessages() {
    return [
      '今天過得怎麼樣？',
      '有人想聊天嗎？',
      '這個地方人真多',
      '生活就是這樣吧',
      '希望明天會更好',
      '感謝生活中的小確幸',
      '每天都是新的開始',
      '保持樂觀的心態',
      '和大家分享好心情',
      '珍惜當下的美好時光',
      '工作雖然累，但很充實',
      '週末計畫做什麼呢？',
      '最近有什麼好電影嗎？',
      '推薦一家不錯的餐廳',
      '這裡的風景很不錯',
      '路過這裡，順便打個招呼',
      '今天學到了新東西',
      '分享一個有趣的發現',
      '生活需要一些小驚喜',
      '感恩遇到的每個人',
    ];
  }

  // 生成多樣化的訊息（避免重複）
  List<String> generateMultipleMessages(int count) {
    final messages = <String>[];
    final usedMessages = <String>{};

    while (messages.length < count && usedMessages.length < 100) {
      final message = generateSmartMessage();
      if (!usedMessages.contains(message)) {
        messages.add(message);
        usedMessages.add(message);
      }
    }

    return messages;
  }
}
