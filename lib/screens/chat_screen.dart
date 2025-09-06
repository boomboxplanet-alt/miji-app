import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/location_provider.dart';
import '../providers/message_provider.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage('Hello! How are you?', false, const Color(0xFF4A90E2)),
        ChatMessage('I\'m doing great, thanks!', true, const Color(0xFF50C878)),
        ChatMessage('What are you up to today?', false, const Color(0xFF4A90E2)),
        ChatMessage('Just exploring the city. It\'s beautiful here!', true, const Color(0xFF50C878)),
        ChatMessage('Have a great day!', false, const Color(0xFF4A90E2)),
        ChatMessage('Hello there!\nSuggest a reply', true, const Color(0xFFF5DEB3)),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8F0), // 淺粉色背景
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => MessageProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: Consumer2<MessageProvider, LocationProvider>(
          builder: (context, messageProvider, locationProvider, child) {
            return Stack(
              children: [
                // 背景圖案
                _buildBackgroundPattern(),
                
                // 狀態欄
                _buildStatusBar(),
                
                // 聊天標題
                _buildChatHeader(),
                
                // 訊息列表
                _buildMessageList(messageProvider),
                
                // 輸入區域
                _buildInputArea(),
                
                // 錯誤提示（如果有）
                if (locationProvider.errorMessage != null)
                  _buildErrorOverlay(locationProvider),
                
                // 底部加號按鈕
                _buildBottomPlusButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: BackgroundPatternPainter(),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '9:41',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
                const Icon(Icons.wifi, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
                const Icon(Icons.battery_full, size: 16, color: Colors.black87),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Miji 氣泡
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Miji',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 笑臉圖標
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF69B4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(MessageProvider messageProvider) {
    // 合併示例訊息和實際訊息
    final allMessages = [..._messages];
    if (messageProvider.messages.isNotEmpty) {
      for (final msg in messageProvider.messages) {
        allMessages.add(ChatMessage(
          msg.content,
          false, // 用戶發送的訊息
          const Color(0xFF4A90E2),
        ));
      }
    }
    
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      bottom: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: allMessages.length,
        itemBuilder: (context, index) {
          final message = allMessages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!message.isLeft) ...[
            const SizedBox(width: 50),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (message.isLeft) ...[
            const SizedBox(width: 50),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (text) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF69B4).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(LocationProvider locationProvider) {
    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          locationProvider.errorMessage!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomPlusButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFF69B4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF69B4).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final messageProvider = context.read<MessageProvider>();
      final locationProvider = context.read<LocationProvider>();
      
      if (locationProvider.currentPosition != null) {
        messageProvider.sendMessage(
          content: _messageController.text.trim(),
          latitude: locationProvider.currentPosition!.latitude,
          longitude: locationProvider.currentPosition!.longitude,
          radius: 1000.0,
          duration: const Duration(minutes: 30),
          isAnonymous: true,
        );
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('訊息已發送！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法獲取位置，請稍後再試')),
        );
      }
    }
  }
}

class ChatMessage {
  final String content;
  final bool isLeft;
  final Color color;

  ChatMessage(this.content, this.isLeft, this.color);
}

// 背景圖案繪製器
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 繪製網格圖案
    for (int i = 0; i < size.width; i += 40) {
      for (int j = 0; j < size.height; j += 40) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          2,
          paint,
        );
      }
    }

    // 繪製波浪圖案
    final wavePaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final y = size.height * 0.2 + i * size.height * 0.15;
      
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 5) {
        final waveY = y + sin(x * 0.01 + i) * 10;
        path.lineTo(x, waveY);
      }
      
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
