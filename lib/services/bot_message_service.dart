import 'dart:math';
import '../models/message.dart';
import 'translation_service.dart';
import 'package:flutter/material.dart';

class BotMessageService {
  final TranslationService _translationService = TranslationService();
  final Random _random = Random();

  // 機器人訊息的固定屬性
  static const String botSenderId = 'miji_bot';
  static const double botRadius = 500.0; // 機器人訊息的範圍

  // 機器人訊息的顏色主題
  static const List<Color> botColors = [
    Color(0xFF6366F1), // 靛藍色
    Color(0xFF8B5CF6), // 紫色
    Color(0xFF06B6D4), // 青色
    Color(0xFF10B981), // 綠色
    Color(0xFFF59E0B), // 琥珀色
  ];

  // 生成本地化的機器人訊息
  Future<List<Message>> generateLocalizedBotMessages(
      double latitude, double longitude) async {
    try {
      // 獲取當地化的訊息內容
      List<String> localPhrases =
          await _translationService.generateLocalizedBotMessages();
      List<Message> botMessages = [];

      for (int i = 0; i < localPhrases.length; i++) {
        String content = localPhrases[i];

        // 檢測訊息語言
        String detectedLanguage =
            await _translationService.detectLanguage(content);

        // 創建機器人訊息
        Message botMessage = Message(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}_$i',
          content: content,
          latitude: _addRandomOffset(latitude),
          longitude: _addRandomOffset(longitude),
          radius: botRadius,
          createdAt:
              DateTime.now().subtract(Duration(minutes: _random.nextInt(30))),
          expiresAt:
              DateTime.now().add(const Duration(hours: 2)), // 機器人訊息2小時後過期
          isAnonymous: true,
          senderId: botSenderId,
          gender: Gender.unknown,
          bubbleColor: botColors[i % botColors.length],
          originalLanguage: detectedLanguage,
          isBotGenerated: true,
          isTranslated: false,
        );

        botMessages.add(botMessage);
      }

      return botMessages;
    } catch (e) {
      print('Error generating bot messages: $e');
      return [];
    }
  }

  // 為座標添加隨機偏移，讓機器人訊息分散在用戶周圍
  double _addRandomOffset(double coordinate) {
    // 添加 ±0.001 度的隨機偏移（約 ±100米）
    double offset = (_random.nextDouble() - 0.5) * 0.002;
    return coordinate + offset;
  }

  // 翻譯機器人訊息
  Future<Message> translateBotMessage(
      Message message, String targetLanguage) async {
    if (message.isTranslated || !message.isBotGenerated) {
      return message;
    }

    try {
      String translatedContent = await _translationService.translateText(
        message.content,
        targetLanguage,
        sourceLanguage: message.originalLanguage ?? 'auto',
      );

      return message.copyWith(
        translatedContent: translatedContent,
        isTranslated: true,
      );
    } catch (e) {
      print('Error translating bot message: $e');
      return message;
    }
  }

  // 生成特定主題的機器人訊息
  Future<List<Message>> generateThematicBotMessages(
      double latitude, double longitude, String theme) async {
    Map<String, Map<String, List<String>>> thematicMessages = {
      'food': {
        'KH': [
          'តើអ្នកធ្លាប់ញ៉ាំ Fish Amok ហើយឬនៅ?',
          'ខ្ញុំស្រលាញ់ Beef Lok Lak ណាស់!',
          'តើមានអ្នកណាដឹងរបៀបធ្វើ Nom Banh Chok ទេ?',
        ],
        'TH': [
          'ใครเคยกิน Tom Yum Goong แล้วบ้าง?',
          'Pad Thai ที่นี่อร่อยมาก!',
          'มีใครรู้วิธีทำ Som Tam บ้างไหม?',
        ],
        'VN': [
          'Ai đã thử Phở Bò chưa?',
          'Bánh Mì ở đây ngon lắm!',
          'Có ai biết cách làm Bún Chả không?',
        ],
      },
      'tourism': {
        'KH': [
          'តើអ្នកបានទៅលេងអង្គរវត្តហើយឬនៅ?',
          'ទីកន្លែងទេសចរណ៍ល្អបំផុតនៅភ្នំពេញ',
          'ខ្ញុំចង់ទៅកោះរ៉ុង',
        ],
        'TH': [
          'เคยไปวัดพระแก้วแล้วไหม?',
          'ตลาดน้ำดำเนินสะดวกสวยมาก',
          'อยากไปเกาะสมุย',
        ],
        'VN': [
          'Đã đi Vịnh Hạ Long chưa?',
          'Hội An đẹp lắm vào buổi tối',
          'Muốn đi Sapa xem ruộng bậc thang',
        ],
      },
    };

    try {
      String countryCode = await _translationService.getCurrentCountryCode();
      List<String> messages = thematicMessages[theme]?[countryCode] ??
          thematicMessages[theme]?['KH'] ??
          [];

      if (messages.isEmpty) {
        return [];
      }

      List<Message> botMessages = [];

      for (int i = 0; i < messages.length && i < 2; i++) {
        String content = messages[i];
        String detectedLanguage =
            await _translationService.detectLanguage(content);

        Message botMessage = Message(
          id: 'bot_${theme}_${DateTime.now().millisecondsSinceEpoch}_$i',
          content: content,
          latitude: _addRandomOffset(latitude),
          longitude: _addRandomOffset(longitude),
          radius: botRadius,
          createdAt:
              DateTime.now().subtract(Duration(minutes: _random.nextInt(30))),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
          isAnonymous: true,
          senderId: botSenderId,
          gender: Gender.unknown,
          bubbleColor: _getThemeColor(theme),
          originalLanguage: detectedLanguage,
          isBotGenerated: true,
          isTranslated: false,
        );

        botMessages.add(botMessage);
      }

      return botMessages;
    } catch (e) {
      print('Error generating thematic bot messages: $e');
      return [];
    }
  }

  // 根據主題獲取顏色
  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'food':
        return const Color(0xFFF59E0B); // 琥珀色 - 食物
      case 'tourism':
        return const Color(0xFF06B6D4); // 青色 - 旅遊
      case 'culture':
        return const Color(0xFF8B5CF6); // 紫色 - 文化
      case 'language':
        return const Color(0xFF10B981); // 綠色 - 語言
      default:
        return const Color(0xFF6366F1); // 靛藍色 - 默認
    }
  }

  // 生成首次啟動的機器人訊息（3-6個，剩餘時間1小時，80%當地語言）
  Future<List<Message>> generateFirstLaunchBotMessages(
      double latitude, double longitude) async {
    try {
      // 隨機生成3-6個訊息
      int messageCount = 3 + _random.nextInt(4); // 3-6個訊息
      List<Message> botMessages = [];

      // 獲取當地化的訊息內容
      List<String> localPhrases =
          await _translationService.generateLocalizedBotMessages();

      // 添加一些中文訊息（20%）
      List<String> chinesePhrases = [
        '歡迎來到秘跡！',
        '這裡有很多有趣的訊息',
        '試試看發送你的第一條訊息吧',
        '附近的人都在聊什麼呢？',
      ];

      // 混合當地語言（80%）和中文（20%）
      List<String> mixedPhrases = [];
      int localCount = (messageCount * 0.8).round();
      int chineseCount = messageCount - localCount;

      // 添加當地語言訊息
      for (int i = 0; i < localCount && i < localPhrases.length; i++) {
        mixedPhrases.add(localPhrases[i]);
      }

      // 添加中文訊息
      for (int i = 0; i < chineseCount && i < chinesePhrases.length; i++) {
        int randomIndex = _random.nextInt(chinesePhrases.length);
        mixedPhrases.add(chinesePhrases[randomIndex]);
      }

      // 手動打亂順序
      for (int i = mixedPhrases.length - 1; i > 0; i--) {
        int j = _random.nextInt(i + 1);
        String temp = mixedPhrases[i];
        mixedPhrases[i] = mixedPhrases[j];
        mixedPhrases[j] = temp;
      }

      for (int i = 0; i < messageCount && i < mixedPhrases.length; i++) {
        String content = mixedPhrases[i];
        String detectedLanguage =
            await _translationService.detectLanguage(content);

        // 創建機器人訊息，剩餘時間約1小時
        DateTime now = DateTime.now();
        DateTime createdTime = now.subtract(
            Duration(minutes: _random.nextInt(30) + 30)); // 30-60分鐘前創建
        DateTime expireTime =
            createdTime.add(const Duration(hours: 2)); // 2小時後過期，所以剩餘約1小時

        Message botMessage = Message(
          id: 'first_launch_bot_${DateTime.now().millisecondsSinceEpoch}_$i',
          content: content,
          latitude: _addRandomOffset(latitude),
          longitude: _addRandomOffset(longitude),
          radius: botRadius,
          createdAt: createdTime,
          expiresAt: expireTime,
          isAnonymous: true,
          senderId: botSenderId,
          gender: Gender.unknown,
          bubbleColor: botColors[i % botColors.length],
          originalLanguage: detectedLanguage,
          isBotGenerated: true,
          isTranslated: false,
        );

        botMessages.add(botMessage);
      }

      return botMessages;
    } catch (e) {
      print('Error generating first launch bot messages: $e');
      return [];
    }
  }

  // 檢查是否為機器人訊息
  bool isBotMessage(Message message) {
    return message.senderId == botSenderId || message.isBotGenerated;
  }

  // 獲取機器人訊息的顯示內容（優先顯示翻譯內容）
  String getBotMessageDisplayContent(Message message) {
    if (message.isTranslated && message.translatedContent != null) {
      return message.translatedContent!;
    }
    return message.content;
  }
}
