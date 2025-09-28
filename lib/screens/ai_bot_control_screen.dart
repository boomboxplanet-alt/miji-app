import 'package:flutter/material.dart';
import '../services/ai_geographic_bot_service.dart';
import '../utils/app_colors.dart';

class AIBotControlScreen extends StatefulWidget {
  const AIBotControlScreen({super.key});

  @override
  State<AIBotControlScreen> createState() => _AIBotControlScreenState();
}

class _AIBotControlScreenState extends State<AIBotControlScreen> {
  final AIGeographicBotService _botService = AIGeographicBotService();
  bool _isBotEnabled = false;
  bool _isGenerating = false;
  String _lastGeneratedMessage = '';
  Map<String, dynamic> _botStatus = {};

  @override
  void initState() {
    super.initState();
    _loadBotStatus();
    _setupMessageCallback();
  }

  void _loadBotStatus() {
    _botStatus = _botService.getCurrentStatus();
    _isBotEnabled = _botService.isEnabled;
  }

  void _setupMessageCallback() {
    _botService.setOnMessageGenerated((content, lat, lng, radius, duration) {
      setState(() {
        _lastGeneratedMessage = content;
      });

      // 這裡可以將訊息添加到地圖上
      // 或者通過 Provider 通知其他組件
      print('🤖 AI 機器人生成訊息: $content');
      print('📍 位置: $lat, $lng');
      print('📏 範圍: ${radius.toStringAsFixed(0)}米');
      print('⏰ 持續時間: ${duration.inMinutes}分鐘');
    });
  }

  void _toggleBot() {
    setState(() {
      _isBotEnabled = !_isBotEnabled;
      _botService.setEnabled(_isBotEnabled);
    });
  }

  void _generateMessageNow() {
    setState(() {
      _isGenerating = true;
    });

    _botService.generateMessageNow();

    // 模擬生成過程
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isGenerating = false;
      });
    });
  }

  void _updateBotLocation() async {
    // 這裡應該從用戶的實際位置獲取
    // 目前使用澳門的座標作為示例
    const double lat = 22.1667;
    const double lng = 113.5500;

    _botService.updateUserLocation(lat, lng);
    _loadBotStatus();

    // 機器人位置已更新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('AI 地理機器人控制'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 機器人狀態卡片
            _buildStatusCard(),
            const SizedBox(height: 20),

            // 控制按鈕
            _buildControlButtons(),
            const SizedBox(height: 20),

            // 機器人設置
            _buildBotSettings(),
            const SizedBox(height: 20),

            // 最後生成的訊息
            _buildLastMessageCard(),
            const SizedBox(height: 20),

            // 機器人信息
            _buildBotInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _isBotEnabled ? Colors.green.shade100 : Colors.red.shade100,
              _isBotEnabled ? Colors.green.shade50 : Colors.red.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isBotEnabled ? Icons.smart_toy : Icons.smart_toy_outlined,
              size: 48,
              color: _isBotEnabled ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _isBotEnabled ? 'AI 機器人已啟動' : 'AI 機器人已停止',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    _isBotEnabled ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isBotEnabled ? '正在自動生成地理相關訊息' : '點擊啟動按鈕開始工作',
              style: TextStyle(
                fontSize: 14,
                color:
                    _isBotEnabled ? Colors.green.shade600 : Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleBot,
            icon: Icon(_isBotEnabled ? Icons.stop : Icons.play_arrow),
            label: Text(_isBotEnabled ? '停止機器人' : '啟動機器人'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBotEnabled ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isBotEnabled ? _generateMessageNow : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? '生成中...' : '立即生成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '機器人設置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 位置更新按鈕
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _updateBotLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('更新機器人位置'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 當前狀態顯示
            _buildStatusItem('📍 當前位置', _botStatus['location'] ?? '未知'),
            _buildStatusItem('🌍 國家/地區', _botStatus['country'] ?? '未知'),
            _buildStatusItem('🌤️ 天氣', _botStatus['weather'] ?? '未知'),
            _buildStatusItem(
                '🌡️ 溫度',
                _botStatus['temperature'] != null
                    ? '${_botStatus['temperature'].toStringAsFixed(1)}°C'
                    : '未知'),
            _buildStatusItem('🌸 季節', _botStatus['season'] ?? '未知'),
            _buildStatusItem('⏰ 時間段', _botStatus['timeOfDay'] ?? '未知'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastMessageCard() {
    if (_lastGeneratedMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '最新生成的訊息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy,
                          color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI 機器人',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '剛剛',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastGeneratedMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '字數: ${_lastGeneratedMessage.length} 字',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '機器人功能說明',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              '🌍 地理位置檢測',
              '自動檢測用戶當前地理位置，包括國家、城市等信息',
            ),
            _buildInfoItem(
              '🌤️ 天氣感知',
              '根據當前天氣狀況生成相關的訊息內容',
            ),
            _buildInfoItem(
              '🌸 季節適應',
              '根據當前季節調整訊息的主題和語氣',
            ),
            _buildInfoItem(
              '⏰ 時間智能',
              '根據一天中的不同時間段生成合適的訊息',
            ),
            _buildInfoItem(
              '📝 字數控制',
              '自動生成 5-30 字的自然語言訊息',
            ),
            _buildInfoItem(
              '🎯 隨機分布',
              '在用戶周圍隨機位置發布訊息，模擬真實用戶行為',
            ),
            _buildInfoItem(
              '🔄 自動更新',
              '每 2-5 分鐘自動生成新訊息，保持活躍度',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
