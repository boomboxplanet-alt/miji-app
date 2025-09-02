import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class TranslationService {
  static const bool isMockApi = true;
  static const String baseUrl = 'https://api.translate.googleapis.com/translate/v2';
  static const String apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
  
  // 根據國家代碼獲取當地語言
  static const Map<String, String> countryToLanguage = {
    'KH': 'km', // 柬埔寨 -> 高棉語
    'TW': 'zh-TW', // 台灣 -> 繁體中文
    'CN': 'zh-CN', // 中國 -> 簡體中文
    'TH': 'th', // 泰國 -> 泰語
    'VN': 'vi', // 越南 -> 越南語
    'JP': 'ja', // 日本 -> 日語
    'KR': 'ko', // 韓國 -> 韓語
    'US': 'en', // 美國 -> 英語
    'GB': 'en', // 英國 -> 英語
    'FR': 'fr', // 法國 -> 法語
    'DE': 'de', // 德國 -> 德語
    'ES': 'es', // 西班牙 -> 西班牙語
    'IT': 'it', // 義大利 -> 義大利語
    'RU': 'ru', // 俄羅斯 -> 俄語
    'IN': 'hi', // 印度 -> 印地語
    'ID': 'id', // 印尼 -> 印尼語
    'MY': 'ms', // 馬來西亞 -> 馬來語
    'SG': 'en', // 新加坡 -> 英語
    'PH': 'tl', // 菲律賓 -> 他加祿語
    'AU': 'en', // 澳洲 -> 英語
    'NZ': 'en', // 紐西蘭 -> 英語
  };
  
  // 根據國家代碼獲取當地常用問候語和短語
  static const Map<String, List<String>> countryToLocalPhrases = {
    'KH': [
      'សួស្តី! តើអ្នកកំពុងធ្វើអ្វី?', // 你好！你在做什麼？
      'ថ្ងៃនេះអាកាសធាតុល្អណាស់!', // 今天天氣真好！
      'តើមានអ្នកណាចង់ទៅញ៉ាំបាយជាមួយគ្នាទេ?', // 有人想一起去吃飯嗎？
      'ខ្ញុំកំពុងស្វែងរកកន្លែងញ៉ាំបាយឆ្ងាញ់ៗ', // 我在找好吃的餐廳
      'តើអ្នកដឹងទីកន្លែងទេសចរណ៍ល្អៗទេ?', // 你知道好的旅遊景點嗎？
      'ខ្ញុំជាភ្ញៀវទេសចរ ចង់ស្វែងយល់អំពីវប្បធម៌ក្នុងស្រុក', // 我是遊客，想了解當地文化
      'តើមានកន្លែងទិញអីវ៉ាន់អ្វីល្អៗទេ?', // 有什麼好的購物地點嗎？
      'ខ្ញុំចង់រៀនភាសាខ្មែរ តើអ្នកអាចជួយបានទេ?', // 我想學高棉語，你能幫忙嗎？
    ],
    'TH': [
      'สวัสดีครับ! วันนี้ทำอะไรกัน?', // 你好！今天做什麼？
      'อากาศดีจังเลย!', // 天氣真好！
      'มีใครอยากไปกินข้าวด้วยกันบ้าง?', // 有人想一起去吃飯嗎？
      'กำลังหาร้านอาหารอร่อยๆ', // 在找好吃的餐廳
      'รู้จักสถานที่ท่องเที่ยวดีๆ บ้างไหม?', // 知道好的旅遊景點嗎？
      'เป็นนักท่องเที่ยว อยากเรียนรู้วัฒนธรรมท้องถิ่น', // 是遊客，想了解當地文化
      'มีที่ช้อปปิ้งดีๆ แนะนำบ้างไหม?', // 有好的購物地點推薦嗎？
      'อยากเรียนภาษาไทย ช่วยได้ไหม?', // 想學泰語，能幫忙嗎？
    ],
    'VN': [
      'Xin chào! Hôm nay làm gì vậy?', // 你好！今天做什麼？
      'Thời tiết hôm nay đẹp quá!', // 今天天氣真好！
      'Có ai muốn đi ăn cùng không?', // 有人想一起去吃飯嗎？
      'Đang tìm nhà hàng ngon', // 在找好吃的餐廳
      'Bạn có biết địa điểm du lịch nào hay không?', // 你知道好的旅遊景點嗎？
      'Tôi là khách du lịch, muốn tìm hiểu văn hóa địa phương', // 我是遊客，想了解當地文化
      'Có chỗ mua sắm nào tốt không?', // 有什麼好的購物地點嗎？
      'Tôi muốn học tiếng Việt, bạn có thể giúp không?', // 我想學越南語，你能幫忙嗎？
    ],
  };
  
  // 獲取當前位置的國家代碼
  Future<String> getCurrentCountryCode() async {
    if (isMockApi) {
      // 模擬：假設用戶在柬埔寨
      return 'KH';
    }
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      // 使用反向地理編碼獲取國家代碼
      // 這裡需要實際的地理編碼API
      return await _getCountryCodeFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      // 默認返回台灣
      return 'TW';
    }
  }
  
  // 根據座標獲取國家代碼
  Future<String> _getCountryCodeFromCoordinates(double lat, double lng) async {
    if (isMockApi) {
      // 模擬：根據座標判斷國家
      if (lat >= 10.0 && lat <= 14.7 && lng >= 102.3 && lng <= 107.6) {
        return 'KH'; // 柬埔寨範圍
      }
      return 'TW'; // 默認台灣
    }
    
    // 實際實現需要使用地理編碼API
    return 'TW';
  }
  
  // 根據當前位置獲取本地語言
  Future<String> getLocalLanguage() async {
    String countryCode = await getCurrentCountryCode();
    return countryToLanguage[countryCode] ?? 'en';
  }
  
  // 生成當地化的機器人訊息
  Future<List<String>> generateLocalizedBotMessages() async {
    String countryCode = await getCurrentCountryCode();
    List<String> localPhrases = countryToLocalPhrases[countryCode] ?? [
      'Hello! How are you today?',
      'Beautiful weather today!',
      'Anyone want to grab some food together?',
      'Looking for a good restaurant',
      'Do you know any good tourist spots?',
    ];
    
    // 隨機選擇一些短語
    List<String> selectedPhrases = [];
    Random random = Random();
    for (int i = 0; i < 3 && i < localPhrases.length; i++) {
      int randomIndex = random.nextInt(localPhrases.length);
      selectedPhrases.add(localPhrases[randomIndex]);
    }
    return selectedPhrases;
  }
  
  // 翻譯文本
  Future<String> translateText(String text, String targetLanguage, {String sourceLanguage = 'auto'}) async {
    if (isMockApi) {
      // 模擬翻譯結果
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 簡單的模擬翻譯邏輯
      if (targetLanguage == 'zh-TW' || targetLanguage == 'zh') {
        return _getMockTranslation(text);
      }
      return '[翻譯] $text';
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }
  
  // 模擬翻譯結果
  String _getMockTranslation(String text) {
    final Map<String, String> mockTranslations = {
      'សួស្តី! តើអ្នកកំពុងធ្វើអ្វី?': '你好！你在做什麼？',
      'ថ្ងៃនេះអាកាសធាតុល្អណាស់!': '今天天氣真好！',
      'តើមានអ្នកណាចង់ទៅញ៉ាំបាយជាមួយគ្នាទេ?': '有人想一起去吃飯嗎？',
      'ខ្ញុំកំពុងស្វែងរកកន្លែងញ៉ាំបាយឆ្ងាញ់ៗ': '我在找好吃的餐廳',
      'តើអ្នកដឹងទីកន្លែងទេសចរណ៍ល្អៗទេ?': '你知道好的旅遊景點嗎？',
      'ខ្ញុំជាភ្ញៀវទេសចរ ចង់ស្វែងយល់អំពីវប្បធម៌ក្នុងស្រុក': '我是遊客，想了解當地文化',
      'តើមានកន្លែងទិញអីវ៉ាន់អ្វីល្អៗទេ?': '有什麼好的購物地點嗎？',
      'ខ្ញុំចង់រៀនភាសាខ្មែរ តើអ្នកអាចជួយបានទេ?': '我想學高棉語，你能幫忙嗎？',
    };
    
    return mockTranslations[text] ?? '[翻譯] $text';
  }
  
  // 檢測文本語言
  Future<String> detectLanguage(String text) async {
    if (isMockApi) {
      // 簡單的語言檢測邏輯
      if (text.contains(RegExp(r'[\u1780-\u17FF]'))) {
        return 'km'; // 高棉語
      } else if (text.contains(RegExp(r'[\u4e00-\u9fff]'))) {
        return 'zh'; // 中文
      } else if (text.contains(RegExp(r'[\u0E00-\u0E7F]'))) {
        return 'th'; // 泰語
      }
      return 'en'; // 默認英語
    }
    
    // 實際實現需要使用語言檢測API
    return 'en';
  }
}