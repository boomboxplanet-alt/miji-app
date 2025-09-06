import 'package:flutter/material.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  int _currentBytes = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateByteCount);
    _loadSampleMessages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateByteCount() {
    setState(() {
      _currentBytes = _messageController.text.length;
    });
  }

  void _loadSampleMessages() {
    _messages.addAll([
      ChatMessage('Hello there!', true, const Color(0xFFFFB6C1)),
      ChatMessage('Don\'t forget to have fun!', false, const Color(0xFF87CEEB)),
      ChatMessage('Have a great day!', true, const Color(0xFFDDA0DD)),
      ChatMessage(':)', true, const Color(0xFFF8E8F0)),
      ChatMessage('Have a great day!', false, const Color(0xFFFFE4B5)),
      ChatMessage('Hello there!\nSuggest a reply', true, const Color(0xFFF5DEB3)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8F0),
      body: Stack(
        children: [
          // 背景圖案
          _buildBackgroundPattern(),
          
          // 狀態欄
          _buildStatusBar(),
          
          // 聊天內容
          _buildChatContent(),
          
          // 錯誤提示（如果有）
          _buildErrorOverlay(),
          
          // 底部加號按鈕
          _buildBottomPlusButton(),
        ],
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
              '6:41',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                const Icon(Icons.wifi, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                const Icon(Icons.battery_full, size: 16, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      bottom: 120,
      child: Column(
        children: [
          // 聊天標題
          _buildChatHeader(),
          
          // 訊息列表
          Expanded(
            child: _buildMessageList(),
          ),
          
          // 輸入區域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
      child: Row(
        children: [
          // Miji 標題氣泡
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4B5), // 淺桃色
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Miji',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513), // 深棕色
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 笑臉圖標
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF8E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                ':)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isLeft) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF8E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  ':)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (message.content.contains('Suggest a reply')) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Suggest a reply',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!message.isLeft) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF8E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  ':)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 顯示名稱輸入
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '輸入您的顯示名稱',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B4D1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '匿名',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 訊息輸入
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '說點什麼...(最多200字節)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  '$_currentBytes/200 字節',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 按鈕區域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B4D1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '泡泡設置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '發送',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Something went wrong while listening for position updates',
          style: TextStyle(
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
          Navigator.pop(context);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          _messageController.text.trim(),
          false,
          const Color(0xFF4A90E2),
        ));
        _messageController.clear();
      });
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
      ..color = const Color(0xFFF0E6F0).withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 繪製網格線
    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 繪製波浪線
    final wavePaint = Paint()
      ..color = const Color(0xFFE8B4D1).withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    for (double x = 0; x < size.width; x += 10) {
      final y = size.height * 0.3 + 20 * sin(x / size.width * 2 * pi);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, wavePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    for (double x = 0; x < size.width; x += 10) {
      final y = size.height * 0.7 + 15 * cos(x / size.width * 2 * pi);
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, wavePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
