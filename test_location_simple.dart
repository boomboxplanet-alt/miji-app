import 'lib/services/enhanced_ai_service.dart';
import 'lib/services/translation_service.dart';
import 'lib/services/bot_service.dart';

void main() async {
  print('🧪 地理位置檢測測試開始...\n');

  final aiService = EnhancedAIService();
  final translationService = TranslationService();
  final botService = BotService();

  // 測試澳門座標
  final macauLat = 22.1667;
  final macauLng = 113.5500;

  print('📍 測試澳門位置: $macauLat, $macauLng');

  // 測試 AI 服務
  aiService.updateUserLocation(macauLat, macauLng);
  print('AI 服務檢測結果:');
  print('  位置: ${aiService.currentLocation}');
  print('  國家: ${aiService.currentCountry}');

  // 測試翻譯服務
  final countryCode = await translationService.getCurrentCountryCode();
  final localLanguage = await translationService.getLocalLanguage();
  print('翻譯服務檢測結果:');
  print('  國家代碼: $countryCode');
  print('  本地語言: $localLanguage');

  // 測試機器人服務
  botService.updateUserLocation(macauLat, macauLng);
  print('機器人服務檢測結果:');
  print('  語言偏好: ${botService.languagePreference}');

  // 生成測試訊息
  print('\n💬 生成的澳門本地訊息:');
  for (int i = 0; i < 5; i++) {
    final message = aiService.generateSmartMessage();
    print('  ${i + 1}. $message');
  }

  print('\n✅ 測試完成！');
}
