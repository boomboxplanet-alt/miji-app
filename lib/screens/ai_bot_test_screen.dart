import 'package:flutter/material.dart';
import 'dart:async';
import '../services/ai_geographic_bot_service.dart';
import '../services/smart_message_generator.dart';
import '../utils/app_colors.dart';

class AIBotTestScreen extends StatefulWidget {
  const AIBotTestScreen({super.key});

  @override
  State<AIBotTestScreen> createState() => _AIBotTestScreenState();
}

class _AIBotTestScreenState extends State<AIBotTestScreen> {
  final AIGeographicBotService _botService = AIGeographicBotService();
  final SmartMessageGenerator _messageGenerator = SmartMessageGenerator();
  
  String _testLocation = '澳門';
  String _testWeather = '晴天';
  String _testSeason = '春天';
  String _testTimeOfDay = '中午';
  
  final List<String> _generatedMessages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateTestMessages();
  }

  void _generateTestMessages() {
    setState(() {
      _isGenerating = true;
      _generatedMessages.clear();
    });

    // 生成多條測試訊息
    for (int i = 0; i < 10; i++) {
      final message = _messageGenerator.generateRandomLengthMessage(
        country: _testLocation,
        weather: _testWeather,
        season: _testSeason,
        timeOfDay: _testTimeOfDay,
        minLength: 5,
        maxLength: 30,
      );
      
      _generatedMessages.add(message);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isGenerating = false;
      });
    });
  }

  void _updateTestParameters() {
    setState(() {
      // 隨機更新測試參數
      final locations = ['澳門', '香港', '台灣', '其他'];
      final weathers = ['晴天', '雨天', '多雲', '雪天'];
      final seasons = ['春天', '夏天', '秋天', '冬天'];
      final timeOfDays = ['早晨', '中午', '下午', '晚上', '深夜'];
      
      _testLocation = locations[DateTime.now().millisecond % locations.length];
      _testWeather = weathers[DateTime.now().millisecond % weathers.length];
      _testSeason = seasons[DateTime.now().millisecond % seasons.length];
      _testTimeOfDay = timeOfDays[DateTime.now().millisecond % timeOfDays.length];
    });
    
    _generateTestMessages();
  }

  void _testBotService() {
    // 測試機器人服務
    _botService.updateUserLocation(22.1667, 113.5500); // 澳門座標
    
    // 生成幾條訊息
    for (int i = 0; i < 3; i++) {
      Timer(Duration(milliseconds: i * 1000), () {
        _botService.generateMessageNow();
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤖 已測試機器人服務，請查看控制台輸出'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('AI 機器人測試'),
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
            // 測試參數設置
            _buildTestParameters(),
            const SizedBox(height: 20),
            
            // 測試按鈕
            _buildTestButtons(),
            const SizedBox(height: 20),
            
            // 生成的訊息列表
            _buildGeneratedMessages(),
            const SizedBox(height: 20),
            
            // 機器人服務狀態
            _buildBotServiceStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestParameters() {
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
                Icon(Icons.tune, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '測試參數設置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildParameterRow('📍 位置', _testLocation, Icons.location_on),
            _buildParameterRow('🌤️ 天氣', _testWeather, Icons.wb_sunny),
            _buildParameterRow('🌸 季節', _testSeason, Icons.local_florist),
            _buildParameterRow('⏰ 時間段', _testTimeOfDay, Icons.access_time),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateTestParameters,
                icon: const Icon(Icons.shuffle),
                label: const Text('隨機更新參數'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateTestMessages,
            icon: _isGenerating 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? '生成中...' : '生成測試訊息'),
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
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _testBotService,
            icon: const Icon(Icons.smart_toy),
            label: const Text('測試機器人'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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

  Widget _buildGeneratedMessages() {
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
                  '生成的測試訊息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${_generatedMessages.length} 條',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_generatedMessages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '點擊「生成測試訊息」按鈕開始測試',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _generatedMessages.length,
                itemBuilder: (context, index) {
                  final message = _generatedMessages[index];
                  return _buildMessageItem(message, index + 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(String message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '字數: ${message.length} 字',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLengthColor(message.length),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLengthLabel(message.length),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLengthColor(int length) {
    if (length < 10) return Colors.red;
    if (length < 20) return Colors.orange;
    if (length < 30) return Colors.green;
    return Colors.blue;
  }

  String _getLengthLabel(int length) {
    if (length < 10) return '短';
    if (length < 20) return '中';
    if (length < 30) return '長';
    return '超長';
  }

  Widget _buildBotServiceStatus() {
    final status = _botService.getCurrentStatus();
    
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
                Icon(Icons.smart_toy, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '機器人服務狀態',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatusRow('🤖 服務狀態', status['isEnabled'] == true ? '已啟用' : '已禁用'),
            _buildStatusRow('📍 當前位置', status['location'] ?? '未知'),
            _buildStatusRow('🌍 國家/地區', status['country'] ?? '未知'),
            _buildStatusRow('🌤️ 天氣', status['weather'] ?? '未知'),
            _buildStatusRow('🌡️ 溫度', status['temperature'] != null 
              ? '${status['temperature'].toStringAsFixed(1)}°C' 
              : '未知'),
            _buildStatusRow('🌸 季節', status['season'] ?? '未知'),
            _buildStatusRow('⏰ 時間段', status['timeOfDay'] ?? '未知'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}
