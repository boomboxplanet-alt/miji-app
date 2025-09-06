import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/location_provider.dart';
import '../providers/message_provider.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

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
      backgroundColor: const Color(0xFFF8E8F0), // 淺粉色背景
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

  Widget _buildTopHeader() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Text(
          'Miji',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCentralArea() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      bottom: 200,
      child: Stack(
        children: [
          // 中央笑臉按鈕
          _buildCentralSmileyButton(),
          
          // 周圍功能按鈕
          _buildFunctionalButtons(),
        ],
      ),
    );
  }

  Widget _buildCentralSmileyButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: _showMessageDialog,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4), // 粉色
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF69B4).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sentiment_very_satisfied,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFunctionalButtons() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Message 按鈕 (上方)
            _buildRotatingButton(
              angle: _rotationAnimation.value,
              radius: 80,
              icon: Icons.message,
              label: 'Message',
              onTap: () => _showFunctionDialog('Message'),
            ),
            
            // AI suggestion 按鈕 (右上方)
            _buildRotatingButton(
              angle: _rotationAnimation.value + pi / 2.5,
              radius: 80,
              icon: Icons.psychology,
              label: 'AI suggestion',
              onTap: () => _showFunctionDialog('AI suggestion'),
            ),
            
            // 30 min 按鈕 (右下方)
            _buildRotatingButton(
              angle: _rotationAnimation.value + pi,
              radius: 80,
              icon: Icons.access_time,
              label: '30 min',
              onTap: () => _showFunctionDialog('30 min'),
            ),
            
            // Anonymous 按鈕 (左下方)
            _buildRotatingButton(
              angle: _rotationAnimation.value + pi * 1.5,
              radius: 80,
              icon: Icons.visibility_off,
              label: 'Anonymous',
              onTap: () => _showFunctionDialog('Anonymous'),
            ),
            
            // Distance 按鈕 (左上方)
            _buildRotatingButton(
              angle: _rotationAnimation.value + pi * 2,
              radius: 80,
              icon: Icons.location_on,
              label: 'Distance',
              onTap: () => _showFunctionDialog('Distance'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRotatingButton({
    required double angle,
    required double radius,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final centerX = MediaQuery.of(context).size.width / 2;
    final centerY = MediaQuery.of(context).size.height / 2 - 50;
    
    final x = centerX + radius * cos(angle);
    final y = centerY + radius * sin(angle);
    
    return Positioned(
      left: x - 25,
      top: y - 25,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFFFF69B4),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFFFF69B4),
                  fontWeight: FontWeight.w500,
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
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Hello there! 按鈕
          _buildHelloThereButton(),
          
          // 加號按鈕
          _buildPlusButton(),
        ],
      ),
    );
  }

  Widget _buildHelloThereButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: _showHelloDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFFF69B4),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Hello there!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
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

  void _showHelloDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hello there!'),
        content: const Text('歡迎使用 Miji！這是一個基於位置的匿名聊天應用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
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
