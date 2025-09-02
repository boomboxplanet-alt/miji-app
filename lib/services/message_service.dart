import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageService {
  // 由於後端 API 尚未就绪，我们将会使用一个模拟的延迟和响应。
  // 当后端准备好后，我们可以轻易地将 isMockApi 设置为 false。
  static const bool isMockApi = true;
  static const String baseUrl = 'https://api.miji.app/v1'; // 实际的 API 网址

  Future<Message> sendMessage(Message message) async {
    if (isMockApi) {
      // 模拟 API 延迟和成功响应
      await Future.delayed(const Duration(milliseconds: 500));
      // 模擬API：訊息發送成功
      return message.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<Message>> getNearbyMessages(double latitude, double longitude, double maxDistance) async {
    if (isMockApi) {
      // 模拟 API 响应，返回模拟的附近訊息
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模擬API：獲取附近訊息
      // 為了測試多裝置互通，我們返回一些模擬訊息
      final mockMessages = [
        Message(
          id: 'mock_1',
          content: '今天天氣真好！',
          latitude: latitude + 0.001, // 稍微偏移的位置
          longitude: longitude + 0.001,
          radius: 1000.0,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          isAnonymous: true,
          senderId: 'mock_user_1',
          senderName: '匿名用戶',
          gender: Gender.unknown,
        ),
        Message(
          id: 'mock_2',
          content: '附近有什麼好吃的嗎？',
          latitude: latitude - 0.001, // 稍微偏移的位置
          longitude: longitude - 0.001,
          radius: 800.0,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          isAnonymous: false,
          senderId: 'mock_user_2',
          senderName: '美食探索者',
          gender: Gender.female,
        ),
      ];
      
      return mockMessages;
    }
    
    try {
      final uri = Uri.parse('$baseUrl/messages/nearby').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'maxDistance': maxDistance.toString(),
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch nearby messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby messages: $e');
    }
  }
}