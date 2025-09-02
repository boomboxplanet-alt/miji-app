import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/enhanced_ai_service.dart';
import 'services/translation_service.dart';
import 'services/bot_service.dart';

void main() {
  runApp(LocationTestApp());
}

class LocationTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '地理位置檢測測試',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LocationTestPage(),
    );
  }
}

class LocationTestPage extends StatefulWidget {
  @override
  _LocationTestPageState createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  final EnhancedAIService _aiService = EnhancedAIService();
  final TranslationService _translationService = TranslationService();
  final BotService _botService = BotService();
  
  String _testResult = '';
  String _currentLocation = '';
  String _currentCountry = '';
  String _languagePreference = '';
  List<String> _generatedMessages = [];

  // 測試座標
  final Map<String, Map<String, double>> _testCoordinates = {
    '澳門': {'lat': 22.1667, 'lng': 113.5500},
    '香港': {'lat': 22.3193, 'lng': 114.1694},
    '台北': {'lat': 25.0330, 'lng': 121.5654},
    '柬埔寨': {'lat': 12.5657, 'lng': 104.9910},
    '泰國': {'lat': 13.7563, 'lng': 100.5018},
    '越南': {'lat': 21.0285, 'lng': 105.8542},
  };

  @override
  void initState() {
    super.initState();
    _runLocationTests();
  }

  void _runLocationTests() async {
    StringBuffer result = StringBuffer();
    result.writeln('🧪 地理位置檢測測試開始...\n');

    for (String location in _testCoordinates.keys) {
      final coords = _testCoordinates[location]!;
      final lat = coords['lat']!;
      final lng = coords['lng']!;

      result.writeln('📍 測試位置: $location');
      result.writeln('   座標: $lat, $lng');

      // 測試 AI 服務
      _aiService.updateUserLocation(lat, lng);
      final aiLocation = _aiService.currentLocation;
      final aiCountry = _aiService.currentCountry;
      
      result.writeln('   AI 服務檢測結果:');
      result.writeln('     位置: $aiLocation');
      result.writeln('     國家: $aiCountry');

      // 測試翻譯服務
      final countryCode = await _translationService.getCurrentCountryCode();
      final localLanguage = await _translationService.getLocalLanguage();
      
      result.writeln('   翻譯服務檢測結果:');
      result.writeln('     國家代碼: $countryCode');
      result.writeln('     本地語言: $localLanguage');

      // 測試機器人服務
      _botService.updateUserLocation(lat, lng);
      final botLanguage = _botService.languagePreference;
      
      result.writeln('   機器人服務檢測結果:');
      result.writeln('     語言偏好: $botLanguage');

      // 生成測試訊息
      final message = _aiService.generateSmartMessage();
      result.writeln('   生成的訊息: $message');
      
      result.writeln('');

      // 如果是澳門，保存結果用於顯示
      if (location == '澳門') {
        _currentLocation = aiLocation ?? '未知';
        _currentCountry = aiCountry ?? '未知';
        _languagePreference = botLanguage;
        _generatedMessages.add(message);
      }
    }

    result.writeln('✅ 測試完成！');
    setState(() {
      _testResult = result.toString();
    });
  }

  void _testMacauMessages() {
    setState(() {
      _generatedMessages.clear();
    });

    // 模擬澳門位置生成多條訊息
    _aiService.updateUserLocation(22.1667, 113.5500);
    _botService.updateUserLocation(22.1667, 113.5500);

    for (int i = 0; i < 5; i++) {
      final message = _aiService.generateSmartMessage();
      _generatedMessages.add(message);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地理位置檢測測試'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 澳門位置測試結果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('檢測位置: $_currentLocation'),
                    Text('檢測國家: $_currentCountry'),
                    Text('語言偏好: $_languagePreference'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _testMacauMessages,
                      child: Text('生成澳門本地訊息'),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_generatedMessages.isNotEmpty) ...[
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💬 生成的澳門本地訊息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...(_generatedMessages.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        );
                      })),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 完整測試結果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _testResult,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
