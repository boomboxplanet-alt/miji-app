import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'chat_screen.dart';
import '../providers/location_provider.dart';
import '../providers/message_provider.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // 脈衝動畫
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 旋轉動畫
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8F0),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => MessageProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return Stack(
              children: [
                // 背景圖案
                _buildBackgroundPattern(),
                
                // 狀態欄
                _buildStatusBar(),
                
                // 頂部標題
                _buildTopHeader(),
                
                // 中央功能區域
                _buildCentralArea(),
                
                // 底部區域
                _buildBottomArea(),
                
                // 位置權限請求提示
                if (locationProvider.isLoading && locationProvider.currentPosition == null)
                  _buildLocationPermissionPrompt(locationProvider),
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

  Widget _buildTopHeader() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          // 笑臉圖標
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8E8F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                ':)',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralArea() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 中央笑臉按鈕
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: () {
                    // 點擊中央按鈕的動作
                    _showMessageDialog();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C1), // 粉色
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        ':)',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // 周圍功能按鈕
          _buildSurroundingButtons(),
        ],
      ),
    );
  }

  Widget _buildSurroundingButtons() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                // Message 按鈕 (上方)
                _buildFunctionButton(
                  'Message',
                  Icons.chat_bubble,
                  const Color(0xFFFFB6C1),
                  const Color(0xFFE91E63),
                  const Offset(0, -80),
                ),
                
                // AI suggestion 按鈕 (左中)
                _buildFunctionButton(
                  'AI suggestion',
                  Icons.auto_awesome,
                  const Color(0xFFDDA0DD),
                  const Color(0xFF9C27B0),
                  const Offset(-80, 0),
                ),
                
                // 30 min 按鈕 (右中)
                _buildFunctionButton(
                  '30 min',
                  Icons.access_time,
                  const Color(0xFFFFE4B5),
                  const Color(0xFFFF9800),
                  const Offset(80, 0),
                ),
                
                // Anonymous 按鈕 (左下)
                _buildFunctionButton(
                  'Anonymous',
                  Icons.visibility_off,
                  const Color(0xFFDDA0DD),
                  const Color(0xFF9C27B0),
                  const Offset(-60, 60),
                ),
                
                // Distance 按鈕 (右下)
                _buildFunctionButton(
                  'Distance',
                  Icons.location_on,
                  const Color(0xFFFFE4B5),
                  const Color(0xFFFF9800),
                  const Offset(60, 60),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionButton(String label, IconData icon, Color bgColor, Color iconColor, Offset offset) {
    return Positioned(
      left: 100 + offset.dx - 30,
      top: 100 + offset.dy - 30,
      child: GestureDetector(
        onTap: () {
          _showFunctionDialog(label);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Hello there 按鈕
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB6C1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'Hello there!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 加號按鈕
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog() {
    final messageProvider = context.read<MessageProvider>();
    final locationProvider = context.read<LocationProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('發送訊息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('您想要發送什麼訊息？'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: '輸入訊息內容',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty && locationProvider.currentPosition != null) {
                  messageProvider.sendMessage(
                    content: text.trim(),
                    latitude: locationProvider.currentPosition!.latitude,
                    longitude: locationProvider.currentPosition!.longitude,
                    radius: 1000.0,
                    duration: const Duration(minutes: 30),
                    isAnonymous: true,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('訊息已發送！')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showFunctionDialog(String function) {
    switch (function) {
      case 'Message':
        _showMessageDialog();
        break;
      case 'AI suggestion':
        _showAISuggestionDialog();
        break;
      case '30 min':
        _showTimeSettingsDialog();
        break;
      case 'Anonymous':
        _showAnonymousSettingsDialog();
        break;
      case 'Distance':
        _showDistanceSettingsDialog();
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(function),
            content: Text('$function 功能正在開發中...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('確定'),
              ),
            ],
          ),
        );
    }
  }

  void _showAISuggestionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 建議'),
        content: const Text('AI 會根據您的位置和時間提供個性化的訊息建議。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showTimeSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('時間設置'),
        content: const Text('設置訊息的存在時間，預設為30分鐘。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showAnonymousSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('匿名設置'),
        content: const Text('選擇是否以匿名方式發送訊息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showDistanceSettingsDialog() {
    final locationProvider = context.read<LocationProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('距離設置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('設置訊息的顯示範圍。'),
            const SizedBox(height: 16),
            if (locationProvider.currentPosition != null)
              Text('當前位置: ${locationProvider.currentPosition!.latitude.toStringAsFixed(4)}, ${locationProvider.currentPosition!.longitude.toStringAsFixed(4)}')
            else
              const Text('正在獲取位置...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
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
