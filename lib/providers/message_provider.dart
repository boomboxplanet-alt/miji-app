import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../services/bot_service.dart';
import '../services/task_service.dart';
import '../services/translation_service.dart';
import '../services/bot_message_service.dart';
import '../utils/app_colors.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService();
  final BotService _botService = BotService();
  final TaskService _taskService = TaskService();
  final TranslationService _translationService = TranslationService();
  final BotMessageService _botMessageService = BotMessageService();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  
  double? _currentLatitude;
  double? _currentLongitude;
  
  // 用戶 ID，用於識別用戶自己發送的訊息
  final String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  
  // 翻譯相關狀態
  final Map<String, bool> _translatingMessages = {};
  String _userLanguage = 'zh-TW'; // 用戶語言，默認繁體中文

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBotEnabled => _botService.isEnabled;
  String get currentUserId => _currentUserId;
  String get userLanguage => _userLanguage;
  
  // 檢查訊息是否正在翻譯
  bool isTranslating(String messageId) => _translatingMessages[messageId] ?? false;

  MessageProvider() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _cleanExpiredMessages();
      if (_currentLatitude != null && _currentLongitude != null) {
        fetchNearbyMessages(_currentLatitude!, _currentLongitude!);
      }
    });
    
    // 初始化機器人服務
    _initializeBotService();
  }
  
  void _initializeBotService() {
    _botService.setOnBotMessageGenerated((content, lat, lng, radius, duration) {
      _addBotMessage(content, lat, lng, radius, duration);
    });
    // 確保機器人服務預設為啟用狀態
    _botService.setEnabled(true);
  }

  // 翻譯訊息
  Future<void> translateMessage(String messageId) async {
    if (_translatingMessages[messageId] == true) return;
    
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;
    
    final message = _messages[messageIndex];
    if (message.isTranslated) return;
    
    _translatingMessages[messageId] = true;
    notifyListeners();
    
    try {
      String translatedContent = await _translationService.translateText(
        message.content,
        _userLanguage,
        sourceLanguage: message.originalLanguage ?? 'auto',
      );
      
      _messages[messageIndex] = message.copyWith(
        translatedContent: translatedContent,
        isTranslated: true,
      );
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '翻譯失敗: $e';
    } finally {
      _translatingMessages[messageId] = false;
      notifyListeners();
    }
  }
  
  // 生成本地化機器人訊息
  Future<void> generateLocalizedBotMessages() async {
    if (_currentLatitude == null || _currentLongitude == null) return;
    
    try {
      List<Message> botMessages = await _botMessageService.generateLocalizedBotMessages(
        _currentLatitude!,
        _currentLongitude!,
      );
      
      for (Message botMessage in botMessages) {
        _messages.add(botMessage);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error generating localized bot messages: $e');
    }
  }
  
  // 生成首次啟動的機器人訊息
  Future<void> generateFirstLaunchBotMessages() async {
    if (_currentLatitude == null || _currentLongitude == null) return;
    
    try {
      List<Message> botMessages = await _botMessageService.generateFirstLaunchBotMessages(
        _currentLatitude!,
        _currentLongitude!,
      );
      
      for (Message botMessage in botMessages) {
        _messages.add(botMessage);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error generating first launch bot messages: $e');
    }
  }
  
  // 生成主題機器人訊息
  Future<void> generateThematicBotMessages(String theme) async {
    if (_currentLatitude == null || _currentLongitude == null) return;
    
    try {
      List<Message> botMessages = await _botMessageService.generateThematicBotMessages(
        _currentLatitude!,
        _currentLongitude!,
        theme,
      );
      
      for (Message botMessage in botMessages) {
        _messages.add(botMessage);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error generating thematic bot messages: $e');
    }
  }
  
  // 設置用戶語言
  void setUserLanguage(String languageCode) {
    _userLanguage = languageCode;
    notifyListeners();
  }
  
  // 獲取訊息顯示內容（優先顯示翻譯內容）
  String getMessageDisplayContent(Message message) {
    if (message.isTranslated && message.translatedContent != null) {
      return message.translatedContent!;
    }
    return message.content;
  }
  
  // 檢查是否為機器人訊息
  bool isBotMessage(Message message) {
    return _botMessageService.isBotMessage(message);
  }
  
  // 生成隨機發送者名字
  String _generateRandomName(Gender gender) {
    final random = math.Random();
    
    // 男性名字列表
    final maleNames = [
      '小明', '小華', '小強', '小偉', '小傑', '小宇', '小峰', '小龍',
      '阿志', '阿豪', '阿文', '阿成', '阿勇', '阿輝', '阿凱', '阿軒',
      '建宏', '志明', '家豪', '俊傑', '承翰', '宗翰', '冠宇', '柏翰'
    ];
    
    // 女性名字列表
    final femaleNames = [
      '小美', '小芳', '小雯', '小慧', '小玲', '小婷', '小君', '小萍',
      '雅婷', '怡君', '淑芬', '麗華', '佳穎', '筱雯', '詩涵', '欣怡',
      '思妤', '語彤', '心怡', '宜庭', '若涵', '芷若', '雨萱', '詩婷'
    ];
    
    // 中性名字列表
    final neutralNames = [
      '小安', '小樂', '小晴', '小星', '小雨', '小風', '小光', '小希',
      '阿德', '阿智', '阿正', '阿良', '阿新', '阿青', '阿亮', '阿祥'
    ];
    
    switch (gender) {
      case Gender.male:
        return maleNames[random.nextInt(maleNames.length)];
      case Gender.female:
        return femaleNames[random.nextInt(femaleNames.length)];
      case Gender.unknown:
      default:
        return neutralNames[random.nextInt(neutralNames.length)];
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _botService.stopBotService();
    super.dispose();
  }
  
  void updateUserLocation(double latitude, double longitude, {double? radius}) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    _botService.updateUserLocation(latitude, longitude);
    
    // 如果提供了範圍參數，更新機器人服務的用戶範圍
    if (radius != null) {
      _botService.updateUserRadius(radius);
    }
    
    // 計算範圍內的真實用戶數量（排除機器人訊息）
    final realUserMessages = _messages.where((message) => 
      !message.senderId.startsWith('bot') && 
      message.senderId != _currentUserId
    ).toList();
    
    // 更新真實用戶數量到機器人服務
    _botService.updateRealUserCount(realUserMessages.length);
    
    // 如果訊息列表為空且真實用戶少於3個，立即生成初始機器人訊息
    if (_messages.isEmpty && realUserMessages.length < 3) {
      // 立即生成初始訊息，不延遲
      _botService.generateMessageNow();
    }
    
    fetchNearbyMessages(latitude, longitude);
  }

  Future<Message> sendMessage({
    required String content,
    required double latitude,
    required double longitude,
    required double radius,
    required Duration duration,
    bool isAnonymous = true,
    String? customSenderName, // 添加自定義發送者名稱參數
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 隨機生成性別
      final random = math.Random();
      final gender = Gender.values[random.nextInt(Gender.values.length)];
      
      // 處理發送者名稱
      String? senderName;
      if (isAnonymous) {
        senderName = null; // 匿名訊息不顯示名稱
      } else if (customSenderName != null && customSenderName.trim().isNotEmpty) {
        senderName = customSenderName.trim(); // 使用自定義名稱
      } else {
        // 如果沒有自定義名稱，拋出異常提示用戶輸入
        throw Exception('請輸入您的顯示名稱或選擇匿名發送');
      }
      
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(duration),
        isAnonymous: isAnonymous,
        senderId: _currentUserId,
        senderName: senderName,
        gender: gender,
      );
      
      final sentMessage = await _messageService.sendMessage(message);
      _messages.add(sentMessage);
      
      // 更新任務進度
       _taskService.updateTaskProgress('daily_mystery_messenger');
       _taskService.updateTaskProgress('weekly_story_weaver');
       _taskService.updateTaskProgress('achievement_first_whisper');
      
      return sentMessage;
      
    } catch (e) {
      _errorMessage = '發送失敗: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNearbyMessages(double latitude, double longitude) async {
    try {
      final nearbyMessages = await _messageService.getNearbyMessages(
        latitude,
        longitude,
        2000, // Search radius set to 2 km
      );
      
      _updateMessageList(nearbyMessages);

    } catch (e) {
      _errorMessage = '無法獲取附近訊息: $e';
      notifyListeners();
    }
  }

  void _updateMessageList(List<Message> newMessages) {
    final now = DateTime.now();
    final messageMap = { for (var m in _messages) m.id: m };

    for (var newMessage in newMessages) {
      if (now.isBefore(newMessage.expiresAt)) {
        messageMap[newMessage.id] = newMessage;
      }
    }
    
    _messages.clear();
    _messages.addAll(messageMap.values.where((m) => now.isBefore(m.expiresAt)));
    
    notifyListeners();
  }

  void _cleanExpiredMessages() {
    final now = DateTime.now();
    final originalCount = _messages.length;
    _messages.removeWhere((message) => now.isAfter(message.expiresAt));
    
    if (_messages.length < originalCount) {
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  // 機器人相關方法
  void _addBotMessage(String content, double lat, double lng, double radius, Duration duration) {
    // 隨機生成性別（排除unknown，只在male和female中選擇）
    final random = math.Random();
    final gender = random.nextBool() ? Gender.male : Gender.female;
    final messageId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
    
    final botMessage = Message(
      id: messageId,
      content: content,
      latitude: lat,
      longitude: lng,
      radius: radius,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(duration),
      isAnonymous: true,
      senderId: 'bot',
      senderName: _generateRandomName(gender),
      gender: gender,
      bubbleColor: getRandomBubbleColor(), // 為機器人訊息分配固定顏色
    );
    
    _messages.add(botMessage);
    notifyListeners();
    
    // 為機器人訊息生成隨機統計數據
    _generateBotMessageStats(messageId);
  }
  
  void setBotEnabled(bool enabled) {
    _botService.setEnabled(enabled);
    notifyListeners();
  }
  
  void generateBotMessageNow() {
    _botService.generateMessageNow();
  }
  
  Map<String, dynamic> getBotStats() {
    return _botService.getStats();
  }
  
  void clearAllMessages() {
    _messages.clear();
    notifyListeners();
  }
  
  // 觀看訊息
  void viewMessage(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      if (!message.viewedBy.contains(_currentUserId)) {
        _messages[messageIndex] = message.copyWith(
          viewCount: message.viewCount + 1,
          viewedBy: [...message.viewedBy, _currentUserId],
        );
        
        // 更新任務進度
        _taskService.updateTaskProgress('daily_treasure_hunter');
        
        notifyListeners();
      }
    }
  }

  // 刪除已查看的訊息
  void deleteViewedMessage(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      // 只允許刪除用戶已經查看過的訊息
      if (message.viewedBy.contains(_currentUserId)) {
        _messages.removeAt(messageIndex);
        notifyListeners();
      }
    }
  }

  // 檢查訊息是否已被用戶查看
  bool isMessageViewedByUser(String messageId) {
    try {
      final message = _messages.firstWhere((m) => m.id == messageId);
      return message.viewedBy.contains(_currentUserId);
    } catch (e) {
      // 如果找不到訊息，返回false
      return false;
    }
  }
  
  // 點讚訊息
  void likeMessage(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      if (!message.likedBy.contains(_currentUserId)) {
        _messages[messageIndex] = message.copyWith(
          likeCount: message.likeCount + 1,
          likedBy: [...message.likedBy, _currentUserId],
        );
        
        // 更新任務進度
        _taskService.updateTaskProgress('daily_kindness_spreader');
        
        notifyListeners();
      }
    }
  }
  
  // 倒讚訊息（不顯示數量，但記錄）
  void dislikeMessage(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      if (!message.dislikedBy.contains(_currentUserId)) {
        _messages[messageIndex] = message.copyWith(
          dislikeCount: message.dislikeCount + 1,
          dislikedBy: [...message.dislikedBy, _currentUserId],
        );
        notifyListeners();
      }
    }
  }
  
  // 為機器人訊息生成隨機統計數據
  void _generateBotMessageStats(String messageId) {
    final random = math.Random();
    
    // 延遲生成初始觀看數和點讚數
    Timer(Duration(seconds: random.nextInt(5) + 1), () {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final initialViews = random.nextInt(8) + 2; // 2-9次觀看
        final initialLikes = random.nextInt(initialViews ~/ 2 + 1); // 點讚數不超過觀看數的一半
        
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          viewCount: initialViews,
          likeCount: initialLikes,
        );
        notifyListeners();
        
        // 開始隨機增長
        _startRandomGrowth(messageId);
      }
    });
  }
  
  // 開始隨機增長統計數據
  void _startRandomGrowth(String messageId) {
    final random = math.Random();
    
    // 每30-120秒隨機增長一次
    Timer.periodic(Duration(seconds: random.nextInt(90) + 30), (timer) {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) {
        timer.cancel();
        return;
      }
      
      final message = _messages[messageIndex];
      
      // 檢查訊息是否過期
      if (DateTime.now().isAfter(message.expiresAt)) {
        timer.cancel();
        return;
      }
      
      // 隨機決定是否增長（70%機率）
      if (random.nextDouble() < 0.7) {
        final viewIncrease = random.nextInt(3) + 1; // 增加1-3次觀看
        final likeIncrease = random.nextDouble() < 0.3 ? 1 : 0; // 30%機率增加1個讚
        
        _messages[messageIndex] = message.copyWith(
          viewCount: message.viewCount + viewIncrease,
          likeCount: message.likeCount + likeIncrease,
        );
        notifyListeners();
      }
      
      // 隨機決定是否停止增長（10%機率）
      if (random.nextDouble() < 0.1) {
        timer.cancel();
      }
    });
  }
  
  // 獲取隨機泡泡顏色
  Color getRandomBubbleColor() {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      AppColors.accentColor,
      const Color(0xFF9C27B0), // 紫色
      const Color(0xFFE91E63), // 粉紅色
      const Color(0xFF2196F3), // 藍色
      const Color(0xFF4CAF50), // 綠色
      const Color(0xFFF44336), // 紅色
      const Color(0xFF009688), // 青色
      const Color(0xFF3F51B5), // 靛色
      const Color(0xFFFF9800), // 橙色
      const Color(0xFF795548), // 棕色
    ];
    
    final random = math.Random();
    return colors[random.nextInt(colors.length)];
  }
}