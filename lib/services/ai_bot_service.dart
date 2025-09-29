import 'dart:math';

class AIBotService {
  final Random _random = Random();
  
  /// 生成隨機訊息
  String generateRandomMessage() {
    final messages = [
      '今天天氣真不錯！',
      '這裡的風景很美',
      '有人來過這裡嗎？',
      '留下一個腳印',
      '美好的回憶',
      '探索新地方',
      '發現新事物',
      '記錄這個時刻',
      '分享美好時光',
      '留下痕跡',
    ];
    
    return messages[_random.nextInt(messages.length)];
  }
  
  /// 根據位置生成上下文相關訊息
  String generateLocationBasedMessage(String location) {
    final locationMessages = {
      '澳門': [
        '澳門的葡式建築真美',
        '大三巴牌坊值得一遊',
        '澳門塔的夜景很棒',
        '這裡有好多美食',
      ],
      '香港': [
        '維多利亞港的夜景',
        '太平山頂的風景',
        '中環的繁華',
        '尖沙咀的購物',
      ],
      '台灣': [
        '台北101的壯觀',
        '九份老街的懷舊',
        '阿里山的美景',
        '日月潭的寧靜',
      ],
    };
    
    final messages = locationMessages[location] ?? [
      '這個地方很有趣',
      '值得探索的地方',
      '美好的回憶',
      '留下足跡',
    ];
    
    return messages[_random.nextInt(messages.length)];
  }
  
  /// 生成指定長度的訊息
  String generateMessageWithLength(int minLength, int maxLength) {
    String message = generateRandomMessage();
    
    // 如果訊息太短，添加一些內容
    while (message.length < minLength) {
      message += ' ${generateRandomMessage()}';
    }
    
    // 如果訊息太長，截斷
    if (message.length > maxLength) {
      message = '${message.substring(0, maxLength - 3)}...';
    }
    
    return message;
  }
}

