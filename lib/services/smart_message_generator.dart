import 'dart:math';

class SmartMessageGenerator {
  static final SmartMessageGenerator _instance = SmartMessageGenerator._internal();
  factory SmartMessageGenerator() => _instance;
  SmartMessageGenerator._internal();

  final Random _random = Random();

  // 生成智能訊息
  String generateSmartMessage({
    required String location,
    required String country,
    required String weather,
    required String season,
    required String timeOfDay,
  }) {
    final messages = <String>[];
    
    // 根據地理位置添加訊息
    messages.addAll(_getLocationBasedMessages(country));
    
    // 根據天氣添加訊息
    messages.addAll(_getWeatherBasedMessages(weather));
    
    // 根據季節添加訊息
    messages.addAll(_getSeasonBasedMessages(season));
    
    // 根據時間段添加訊息
    messages.addAll(_getTimeBasedMessages(timeOfDay));
    
    // 添加通用訊息
    messages.addAll(_getGeneralMessages());
    
    if (messages.isEmpty) {
      return '今天天氣不錯呢';
    }
    
    // 隨機選擇訊息
    String selectedMessage = messages[_random.nextInt(messages.length)];
    
    // 智能調整字數到 5-30 字範圍
    selectedMessage = _adjustMessageLength(selectedMessage, weather, season, timeOfDay);
    
    // 添加表情符號
    selectedMessage = _addEmotion(selectedMessage);
    
    return selectedMessage;
  }

  // 智能調整訊息長度
  String _adjustMessageLength(String message, String weather, String season, String timeOfDay) {
    final currentLength = message.length;
    
    // 如果訊息太長，智能截斷
    if (currentLength > 30) {
      // 嘗試在句號、逗號等標點符號處截斷
      final punctuationMarks = ['。', '，', '！', '？', '；', '：', '、'];
      for (String mark in punctuationMarks) {
        final index = message.lastIndexOf(mark, 30);
        if (index > 20) { // 確保至少有20個字
          return message.substring(0, index + 1);
        }
      }
      // 如果沒有合適的標點符號，直接截斷到30字
      return message.substring(0, 30);
    }
    
    // 如果訊息太短，智能擴展
    if (currentLength < 5) {
      return _expandShortMessage(message, weather, season, timeOfDay);
    }
    
    return message;
  }

  // 擴展短訊息
  String _expandShortMessage(String message, String weather, String season, String timeOfDay) {
    final expansions = <String>[];
    
    // 根據天氣擴展
    switch (weather) {
      case '晴天':
        expansions.addAll(['今天天氣真好', '陽光很溫暖', '藍天白雲好美']);
        break;
      case '雨天':
        expansions.addAll(['下雨天心情', '雨聲很催眠', '雨後空氣清新']);
        break;
      case '多雲':
        expansions.addAll(['雲朵很漂亮', '天氣很舒服', '適合出門走走']);
        break;
      case '雪天':
        expansions.addAll(['下雪了真美', '雪景很漂亮', '冬天來了']);
        break;
    }
    
    // 根據季節擴展
    switch (season) {
      case '春天':
        expansions.addAll(['春天來了', '萬物復甦', '適合踏青']);
        break;
      case '夏天':
        expansions.addAll(['夏天到了', '天氣很熱', '想游泳']);
        break;
      case '秋天':
        expansions.addAll(['秋高氣爽', '落葉很美', '適合郊遊']);
        break;
      case '冬天':
        expansions.addAll(['冬天來了', '天氣很冷', '想窩在被窩']);
        break;
    }
    
    // 根據時間段擴展
    switch (timeOfDay) {
      case '早晨':
        expansions.addAll(['早安', '新的一天開始了', '早起精神好']);
        break;
      case '中午':
        expansions.addAll(['午餐時間到了', '好餓啊', '想吃飯']);
        break;
      case '下午':
        expansions.addAll(['下午茶時間', '想喝咖啡', '工作加油']);
        break;
      case '晚上':
        expansions.addAll(['晚餐吃什麼', '晚上好涼爽', '夜景很美']);
        break;
      case '深夜':
        expansions.addAll(['又熬夜了', '深夜emo時間', '失眠數羊']);
        break;
    }
    
    if (expansions.isNotEmpty) {
      final expansion = expansions[_random.nextInt(expansions.length)];
      return '$expansion，$message';
    }
    
    return '今天$message';
  }

  // 添加情感表達
  String _addEmotion(String message) {
    // 30% 機率添加表情符號
    if (_random.nextDouble() < 0.3) {
      final emotions = [
        '😊', '😅', '🤔', '😴', '🙄', '😋', '🤗', '😌',
        '🌤️', '🌧️', '❄️', '🌸', '🍃', '🌙', '☀️', '🌈'
      ];
      final emotion = emotions[_random.nextInt(emotions.length)];
      message += ' $emotion';
    }
    
    return message;
  }

  // 根據地理位置獲取訊息
  List<String> _getLocationBasedMessages(String country) {
    switch (country) {
      case '澳門':
        return [
          '大三巴好多人影相',
          '威尼斯人嘅賭場好大',
          '澳門嘅葡撻真係好好食',
          '新馬路嘅手信店好多',
          '澳門嘅夜景真係好靚',
          '我想去官也街食嘢',
          '澳門嘅豬扒包好出名',
          '我想去澳門塔睇風景',
          '澳門嘅葡國菜好特別',
          '我想去路氹城shopping',
          '大三巴好多人',
          '葡撻真係好好食',
          '夜景真係好靚',
          '想去威尼斯人',
          '豬扒包好出名'
        ];
      case '香港':
        return [
          '維港嘅夜景好靚',
          '我想去銅鑼灣shopping',
          '香港嘅茶餐廳真係好好食',
          '我想去尖沙咀睇夜景',
          '香港嘅交通真係好方便',
          '我想食蛋撻',
          '我想去中環行街',
          '香港嘅叮叮車好有特色',
          '我想去旺角食嘢',
          '香港嘅夜景真係好靚',
          '維港夜景好靚',
          '想去銅鑼灣',
          '茶餐廳好好食',
          '叮叮車好有特色',
          '蛋撻真係好食'
        ];
      case '台灣':
        return [
          '101大樓今天好美',
          '捷運又誤點了',
          '西門町逛街逛到腳痠',
          '信義區的咖啡廳都好貴',
          '夜市的臭豆腐還是最香',
          '房租又漲了',
          '上班族的悲歌',
          '師大夜市的雞排還是最好吃',
          '淡水河邊散步心情好',
          '陽明山看夜景',
          '101大樓好美',
          '捷運又誤點',
          '西門町好多人',
          '臭豆腐好香',
          '雞排好好吃'
        ];
      default:
        return [
          '這裡風景真好',
          '想認識新朋友',
          '生活真美好',
          '想分享心情',
          '這裡好美'
        ];
    }
  }

  // 根據天氣獲取訊息
  List<String> _getWeatherBasedMessages(String weather) {
    switch (weather) {
      case '晴天':
        return [
          '太陽好大，不想出門',
          '今天天氣真好',
          '陽光曬得好舒服',
          '藍天白雲好美',
          '適合出去走走',
          '太陽好大',
          '天氣真好',
          '陽光很溫暖',
          '藍天白雲',
          '適合出門'
        ];
      case '雨天':
        return [
          '下雨天心情就是不好',
          '梅雨季衣服都不乾',
          '雨聲好催眠',
          '想在家睡覺',
          '雨後的空氣好清新',
          '下雨天',
          '雨聲催眠',
          '想睡覺',
          '雨後清新',
          '梅雨季'
        ];
      case '多雲':
        return [
          '雲朵好美',
          '今天不太熱',
          '適合戶外活動',
          '雲層遮住了太陽',
          '天氣很舒服',
          '雲朵很美',
          '不太熱',
          '適合活動',
          '天氣舒服',
          '雲層很美'
        ];
      case '雪天':
        return [
          '下雪了，好美',
          '雪景真漂亮',
          '想堆雪人',
          '雪地好滑',
          '冬天來了',
          '下雪了',
          '雪景很美',
          '想堆雪人',
          '雪地好滑',
          '冬天來了'
        ];
      default:
        return [
          '今天天氣不錯',
          '適合出門走走',
          '天氣很舒服',
          '天氣不錯',
          '適合出門'
        ];
    }
  }

  // 根據季節獲取訊息
  List<String> _getSeasonBasedMessages(String season) {
    switch (season) {
      case '春天':
        return [
          '櫻花開了',
          '春天來了',
          '萬物復甦',
          '適合踏青',
          '春風很舒服',
          '櫻花開了',
          '春天來了',
          '萬物復甦',
          '適合踏青',
          '春風舒服'
        ];
      case '夏天':
        return [
          '好熱啊',
          '冷氣費要爆表了',
          '夏天到了',
          '想游泳',
          '冰飲料真好喝',
          '好熱啊',
          '夏天到了',
          '想游泳',
          '冰飲料好喝',
          '冷氣費高'
        ];
      case '秋天':
        return [
          '秋高氣爽',
          '落葉好美',
          '秋天來了',
          '適合郊遊',
          '秋風很涼爽',
          '秋高氣爽',
          '落葉很美',
          '秋天來了',
          '適合郊遊',
          '秋風涼爽'
        ];
      case '冬天':
        return [
          '好冷啊',
          '想窩在被窩',
          '冬天來了',
          '想喝熱湯',
          '雪景真美',
          '好冷啊',
          '冬天來了',
          '想喝熱湯',
          '雪景很美',
          '想窩被窩'
        ];
      default:
        return [];
    }
  }

  // 根據時間段獲取訊息
  List<String> _getTimeBasedMessages(String timeOfDay) {
    switch (timeOfDay) {
      case '早晨':
        return [
          '早安',
          '新的一天開始了',
          '早餐吃什麼',
          '晨跑好舒服',
          '早起精神好',
          '早安',
          '新的一天',
          '早餐吃什麼',
          '晨跑舒服',
          '早起精神好'
        ];
      case '中午':
        return [
          '午餐時間到了',
          '好餓啊',
          '想吃飯',
          '午休時間',
          '下午還要工作',
          '午餐時間',
          '好餓啊',
          '想吃飯',
          '午休時間',
          '下午工作'
        ];
      case '下午':
        return [
          '下午茶時間',
          '想喝咖啡',
          '下午好睏',
          '工作加油',
          '快下班了',
          '下午茶時間',
          '想喝咖啡',
          '下午好睏',
          '工作加油',
          '快下班'
        ];
      case '晚上':
        return [
          '晚餐吃什麼',
          '晚上好涼爽',
          '想散步',
          '夜生活開始',
          '夜景好美',
          '晚餐吃什麼',
          '晚上涼爽',
          '想散步',
          '夜生活開始',
          '夜景很美'
        ];
      case '深夜':
        return [
          '又熬夜了',
          '深夜emo時間',
          '失眠數羊',
          '明天要早起',
          '夜深人靜',
          '又熬夜了',
          '深夜emo',
          '失眠數羊',
          '明天早起',
          '夜深人靜'
        ];
      default:
        return [];
    }
  }

  // 通用訊息
  List<String> _getGeneralMessages() {
    return [
      '今天心情不錯',
      '想找人聊天',
      '這裡好美',
      '生活真美好',
      '想分享心情',
      '今天過得怎樣',
      '有什麼好玩的地方',
      '想認識新朋友',
      '這裡的風景真好',
      '想記錄美好時光',
      '心情不錯',
      '想聊天',
      '這裡很美',
      '生活美好',
      '想分享',
      '過得怎樣',
      '好玩的地方',
      '認識朋友',
      '風景真好',
      '記錄時光'
    ];
  }

  // 生成隨機字數的訊息
  String generateRandomLengthMessage({
    required String country,
    required String weather,
    required String season,
    required String timeOfDay,
    int minLength = 5,
    int maxLength = 30,
  }) {
    final targetLength = minLength + _random.nextInt(maxLength - minLength + 1);
    
    String message = generateSmartMessage(
      location: '未知',
      country: country,
      weather: weather,
      season: season,
      timeOfDay: timeOfDay,
    );
    
    // 調整到目標長度
    if (message.length > targetLength) {
      message = message.substring(0, targetLength);
    } else if (message.length < targetLength) {
      message = _expandToTargetLength(message, targetLength, weather, season, timeOfDay);
    }
    
    return message;
  }

  // 擴展到目標長度
  String _expandToTargetLength(String message, int targetLength, String weather, String season, String timeOfDay) {
    final currentLength = message.length;
    final neededLength = targetLength - currentLength;
    
    if (neededLength <= 0) return message;
    
    // 添加適當的內容來達到目標長度
    final additions = <String>[];
    
    if (neededLength >= 3) {
      switch (weather) {
        case '晴天':
          additions.add('天氣真好');
          break;
        case '雨天':
          additions.add('雨聲催眠');
          break;
        case '多雲':
          additions.add('雲朵很美');
          break;
        case '雪天':
          additions.add('雪景很美');
          break;
      }
    }
    
    if (neededLength >= 2 && additions.isEmpty) {
      additions.add('真美');
      additions.add('很好');
      additions.add('不錯');
    }
    
    if (additions.isNotEmpty) {
      final addition = additions[_random.nextInt(additions.length)];
      if (message.length + addition.length <= targetLength) {
        message += '，$addition';
      }
    }
    
    return message;
  }
}
