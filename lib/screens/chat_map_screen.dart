import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../providers/message_provider.dart';
import '../providers/task_provider.dart';
import '../services/ai_geographic_bot_service.dart';
import 'dart:math';

class ChatMapScreen extends StatefulWidget {
  const ChatMapScreen({super.key});

  @override
  State<ChatMapScreen> createState() => _ChatMapScreenState();
}

class _ChatMapScreenState extends State<ChatMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final List<Widget> _bubbleOverlays = [];
  final AIGeographicBotService _aiBotService = AIGeographicBotService();
  double _currentRadius = 1000.0;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    final locationProvider = context.read<LocationProvider>();
    final messageProvider = context.read<MessageProvider>();
    final taskProvider = context.read<TaskProvider>();

    // 初始化時更新用戶的實際範圍權限
    _currentRadius = _getUserTotalRange();

    // 監聽TaskProvider變化，當用戶權限更新時重新計算範圍
    taskProvider.addListener(() {
      final newRadius = _getUserTotalRange();
      if (newRadius != _currentRadius) {
        _currentRadius = newRadius;
        if (locationProvider.currentPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateUserLocationAndRadius(locationProvider);
          });
        }
      }
    });

    // 監聽LocationProvider變化
    locationProvider.addListener(() {
      if (locationProvider.currentPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateUserLocationAndRadius(locationProvider);
        });
      }
    });

    // 監聽MessageProvider變化
    messageProvider.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _updateMarkers(messageProvider.messages, locationProvider);
      });
    });

    // 獲取位置
    locationProvider.getCurrentLocation().then((_) {
      if (locationProvider.currentPosition != null) {
        _goToCurrentLocation(locationProvider.currentPosition!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAIBotService(locationProvider.currentPosition!);
        });
      }
    });
  }

  void _startAIBotService(dynamic position) {
    try {
      _aiBotService.updateUserLocation(position.latitude, position.longitude);
      _aiBotService.updateUserRadius(_currentRadius);
      _aiBotService.setOnMessageGenerated((content, lat, lng, radius, duration) {
        final messageProvider = context.read<MessageProvider>();
        messageProvider.sendMessage(
          content: content,
          latitude: lat,
          longitude: lng,
          radius: radius,
          duration: duration,
          isAnonymous: true,
        );
      });
      _aiBotService.startService();
    } catch (e) {
      print('AI機器人服務啟動失敗: $e');
    }
  }

  double _getUserTotalRange() {
    final taskProvider = context.read<TaskProvider>();
    const baseRange = 1000.0;
    final bonusRange = taskProvider.bonusRangeMeters;
    return baseRange + bonusRange;
  }

  void _updateUserLocationAndRadius(LocationProvider locationProvider) {
    if (_mapController != null && locationProvider.currentPosition != null) {
      final position = locationProvider.currentPosition!;
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _updateMarkers(List<dynamic> messages, LocationProvider locationProvider) async {
    if (_mapController == null) return;

    final Set<Marker> newMarkers = {};
    final List<Widget> newBubbleOverlays = [];

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final position = LatLng(message.latitude, message.longitude);
      
      newMarkers.add(
        Marker(
          markerId: MarkerId('message_$i'),
          position: position,
          infoWindow: InfoWindow(
            title: message.content,
            snippet: '半徑: ${message.radius.toStringAsFixed(0)}m',
          ),
        ),
      );

      // 簡化版本，不使用 MessageBubbleOverlay
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
      _bubbleOverlays.clear();
      _bubbleOverlays.addAll(newBubbleOverlays);
    });
  }

  void _goToCurrentLocation(Position position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8F0), // 淺粉色背景，帶網格線效果
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Stack(
            children: [
              // 背景網格和波浪圖案
              _buildBackgroundPattern(),
              
              // 聊天界面
              _buildChatInterface(locationProvider),
              
              // 位置權限請求提示
              if (locationProvider.isLoading && locationProvider.currentPosition == null)
                _buildLocationPermissionPrompt(locationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8E8F0),
      ),
      child: CustomPaint(
        painter: BackgroundPatternPainter(),
      ),
    );
  }

  Widget _buildChatInterface(LocationProvider locationProvider) {
    return Stack(
      children: [
        Column(
          children: [
            // 狀態欄
            Container(
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
            
            // 聊天內容區域
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    
                    // 底部安全區域
                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // 底部加號按鈕
        Positioned(
          bottom: 20,
          right: 20,
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
      ],
    );
  }

  Widget _buildChatHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
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
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.messages.isEmpty) {
          return _buildSampleMessages();
        }
        
        return ListView.builder(
          itemCount: messageProvider.messages.length,
          itemBuilder: (context, index) {
            final message = messageProvider.messages[index];
            return _buildMessageBubble(message, index);
          },
        );
      },
    );
  }

  Widget _buildSampleMessages() {
    return ListView(
      children: [
        _buildSampleMessageBubble('Hello there!', true, const Color(0xFFFFB6C1)), // 粉色
        _buildSampleMessageBubble('Don\'t forget to have fun!', false, const Color(0xFF87CEEB)), // 藍色
        _buildSampleMessageBubble('Have a great day!', true, const Color(0xFFDDA0DD)), // 紫色
        _buildSampleMessageBubble(':)', true, const Color(0xFFF8E8F0)), // 淺粉色笑臉
        _buildSampleMessageBubble('Have a great day!', false, const Color(0xFFFFE4B5)), // 桃色
        _buildSampleMessageBubble('Hello there!\nSuggest a reply', true, const Color(0xFFF5DEB3)), // 米色
      ],
    );
  }

  Widget _buildSampleMessageBubble(String content, bool isLeft, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isLeft) ...[
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
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isLeft) ...[
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

  Widget _buildMessageBubble(dynamic message, int index) {
    final isFromAI = message.isFromAI ?? false;
    final colors = [
      const Color(0xFFFFB6C1), // 粉色
      const Color(0xFF87CEEB), // 藍色
      const Color(0xFFDDA0DD), // 紫色
      const Color(0xFFFFE4B5), // 桃色
      const Color(0xFFF5DEB3), // 米色
    ];
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isFromAI) ...[
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
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!isFromAI) ...[
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
      margin: const EdgeInsets.only(top: 20),
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
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '說點什麼...(最多200字節)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Text(
                  '0/200 字節',
                  style: TextStyle(
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
              Container(
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
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildLocationPermissionPrompt(LocationProvider locationProvider) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              '正在請求位置權限',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '請允許應用訪問您的位置，以便提供更好的服務',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (locationProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  locationProvider.errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }


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
