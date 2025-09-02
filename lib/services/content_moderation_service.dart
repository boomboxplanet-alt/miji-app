/// 內容審核服務
/// 提供多層內容過濾和審核機制
class ContentModerationService {
  static final ContentModerationService _instance =
      ContentModerationService._internal();
  factory ContentModerationService() => _instance;
  ContentModerationService._internal();

  // 敏感詞庫 - 可以從服務器動態更新
  final Set<String> _bannedWords = {
    // 暴力威脅相關
    '殺', '死', '打死', '暴力', '血腥', '殺人', '自殺', '傷害',
    '開槍', '槍殺', '射殺', '槍擊', '開火', '射擊', '槍支',
    '炸彈', '爆炸', '恐怖', '襲擊', '攻擊', '威脅', '報復',
    '刀殺', '砍死', '捅死', '勒死', '毒死', '燒死',
    '要去殺', '要去開槍', '要去炸', '要去攻擊', '要去報復',
    '我要殺', '我要開槍', '我要炸', '我要攻擊', '我要報復',
    '準備殺', '準備開槍', '準備炸', '準備攻擊', '準備報復',
    '計劃殺', '計劃開槍', '計劃炸', '計劃攻擊', '計劃報復',
    '武器', '刀具', '槍械', '彈藥', '手榴彈', '炸藥',
    '屠殺', '滅絕', '消滅', '幹掉', '解決掉', '弄死',
    // 色情相關
    '色情', '裸體', '性愛', '做愛', '性交', '淫穢', '黃色',
    // 政治敏感
    '政治', '革命', '推翻', '政府', '獨裁', '民主',
    // 歧視仇恨
    '歧視', '仇恨', '種族', '宗教', '性別歧視',
    // 詐騙相關
    '詐騙', '騙錢', '傳銷', '賭博', '洗錢', '非法',
    // 毒品相關
    '毒品', '大麻', '海洛因', '冰毒', '吸毒', '販毒',
  };

  // 可疑詞庫 - 需要人工審核
  final Set<String> _suspiciousWords = {
    '約會', '見面', '私聊', '加微信',
    '錢', '轉帳', '借錢', '投資', '賺錢', '兼職',
    // 潛在暴力相關（需要上下文判斷）
    '打', '揍', '教訓', '收拾', '對付', '搞定',
    '火', '幹', '弄', '整', '修理',
    // 個人信息相關
    '姓名', '真名', '全名', '本名', '叫什麼', '名字',
    '手機', '電話', '號碼', '聯繫', '聯絡',
    '住址', '地址', '家住', '住在', '位置',
    '身份證', 'ID', '證件', '學號', '工號',
  };

  // 個人信息檢測模式
  final List<String> _personalInfoPatterns = [
    r'我叫.{1,10}', // 我叫XXX
    r'名字是.{1,10}', // 名字是XXX
    r'真名.{1,10}', // 真名XXX
    r'\d{11}', // 11位手機號碼
    r'\d{3,4}-\d{7,8}', // 固定電話
    r'\d{15}|\d{18}', // 身份證號碼
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', // 電子郵件
    r'微信[：:]?[A-Za-z0-9_-]{5,20}', // 微信號
    r'QQ[：:]?\d{5,12}', // QQ號
    r'住在.{2,20}', // 住在XXX
    r'家住.{2,20}', // 家住XXX
    r'地址.{2,30}', // 地址XXX
  ];

  // 暴力威脅變體檢測
  final Map<String, List<String>> _violentVariants = {
    '開槍': ['開鎗', 'kai槍', 'k槍', '開q', '開*槍', '開.槍'],
    '殺': ['sha', 'kill', 'k掉', 'k了', '煞', '刹'],
    '炸': ['zha', 'boom', '轟'],
    '攻擊': ['攻ji', 'attack', '襲ji', '打ji'],
    '威脅': ['威xie', 'threat', '恐嚇', '嚇唬'],
  };

  /// 檢查內容是否包含違禁詞
  ContentModerationResult moderateContent(String content) {
    if (content.trim().isEmpty) {
      return ContentModerationResult(
        isAllowed: false,
        reason: '內容不能為空',
        severity: ModerationSeverity.low,
      );
    }

    // 檢查長度限制
    if (content.length > 200) {
      return ContentModerationResult(
        isAllowed: false,
        reason: '內容超過200字符限制',
        severity: ModerationSeverity.low,
      );
    }

    // 檢查是否包含違禁詞
    final lowerContent = content.toLowerCase();

    // 首先檢查高風險短語模式
    final highRiskPatterns = [
      r'我要.*開槍',
      r'要去.*開槍',
      r'準備.*開槍',
      r'計劃.*開槍',
      r'我要.*殺',
      r'要去.*殺',
      r'準備.*殺',
      r'計劃.*殺',
      r'我要.*炸',
      r'要去.*炸',
      r'準備.*炸',
      r'計劃.*炸',
      r'我要.*攻擊',
      r'要去.*攻擊',
      r'準備.*攻擊',
      r'計劃.*攻擊',
    ];

    for (final pattern in highRiskPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(content)) {
        return ContentModerationResult(
          isAllowed: false,
          reason: '內容包含嚴重暴力威脅，已被系統攔截',
          severity: ModerationSeverity.high,
          flaggedWord: regex.firstMatch(content)?.group(0) ?? '暴力威脅',
        );
      }
    }

    // 檢查暴力威脅變體
    for (final entry in _violentVariants.entries) {
      final baseWord = entry.key;
      final variants = entry.value;

      // 檢查基礎詞
      if (lowerContent.contains(baseWord.toLowerCase())) {
        return ContentModerationResult(
          isAllowed: false,
          reason: '內容包含暴力威脅詞語：$baseWord',
          severity: ModerationSeverity.high,
          flaggedWord: baseWord,
        );
      }

      // 檢查變體
      for (final variant in variants) {
        if (lowerContent.contains(variant.toLowerCase())) {
          return ContentModerationResult(
            isAllowed: false,
            reason: '內容包含暴力威脅變體：$variant (對應：$baseWord)',
            severity: ModerationSeverity.high,
            flaggedWord: variant,
          );
        }
      }
    }

    // 檢查個人信息洩露
    for (final pattern in _personalInfoPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(content)) {
        final match = regex.firstMatch(content)?.group(0) ?? '個人信息';
        return ContentModerationResult(
          isAllowed: false,
          reason: '為保護隱私安全，不允許發布個人信息：$match',
          severity: ModerationSeverity.high,
          flaggedWord: match,
        );
      }
    }

    // 然後檢查其他違禁詞
    for (final word in _bannedWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        return ContentModerationResult(
          isAllowed: false,
          reason: '內容包含不當詞語：$word',
          severity: ModerationSeverity.high,
          flaggedWord: word,
        );
      }
    }

    // 檢查可疑詞
    final suspiciousWordsFound = <String>[];
    for (final word in _suspiciousWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        suspiciousWordsFound.add(word);
      }
    }

    if (suspiciousWordsFound.isNotEmpty) {
      return ContentModerationResult(
        isAllowed: true, // 允許發送但標記審核
        reason: '內容包含可疑詞語，已標記人工審核',
        severity: ModerationSeverity.medium,
        flaggedWords: suspiciousWordsFound,
        requiresReview: true,
      );
    }

    // 檢查重複字符（防止刷屏）
    if (_hasExcessiveRepetition(content)) {
      return ContentModerationResult(
        isAllowed: false,
        reason: '內容包含過多重複字符',
        severity: ModerationSeverity.medium,
      );
    }

    // 檢查是否全為特殊字符
    if (_isOnlySpecialCharacters(content)) {
      return ContentModerationResult(
        isAllowed: false,
        reason: '內容不能只包含特殊字符',
        severity: ModerationSeverity.low,
      );
    }

    return ContentModerationResult(
      isAllowed: true,
      reason: '內容審核通過',
      severity: ModerationSeverity.none,
    );
  }

  /// 檢查是否有過多重複字符
  bool _hasExcessiveRepetition(String content) {
    if (content.length < 10) return false; // 短內容不檢查

    int maxRepeat = 0;
    int currentRepeat = 1;

    for (int i = 1; i < content.length; i++) {
      if (content[i] == content[i - 1]) {
        currentRepeat++;
      } else {
        maxRepeat = maxRepeat > currentRepeat ? maxRepeat : currentRepeat;
        currentRepeat = 1;
      }
    }
    maxRepeat = maxRepeat > currentRepeat ? maxRepeat : currentRepeat;

    // 檢查是否為純數字內容
    final isNumericOnly = RegExp(r'^\d+$').hasMatch(content);

    // 純數字內容允許更多重複（如電話號碼、ID等）
    if (isNumericOnly) {
      return maxRepeat > 15; // 數字允許15個重複
    }

    // 一般內容超過8個重複字符視為刷屏
    return maxRepeat > 8;
  }

  /// 檢查是否只包含特殊字符
  bool _isOnlySpecialCharacters(String content) {
    final alphanumericRegex = RegExp(r'[a-zA-Z0-9\u4e00-\u9fa5]');
    return !alphanumericRegex.hasMatch(content);
  }

  /// 舉報內容
  Future<bool> reportContent({
    required String messageId,
    required String reporterId,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      // 這裡應該調用後端API記錄舉報
      // 暫時返回成功
      print('內容舉報: messageId=$messageId, reason=$reason');
      return true;
    } catch (e) {
      print('舉報失敗: $e');
      return false;
    }
  }

  /// 更新敏感詞庫（從服務器獲取）
  Future<void> updateBannedWords() async {
    try {
      // 這裡應該從服務器獲取最新的敏感詞庫
      // final response = await http.get(Uri.parse('https://api.example.com/banned-words'));
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   _bannedWords.clear();
      //   _bannedWords.addAll(List<String>.from(data['banned_words']));
      // }
      print('敏感詞庫更新完成');
    } catch (e) {
      print('更新敏感詞庫失敗: $e');
    }
  }

  /// 獲取舉報原因選項
  List<String> getReportReasons() {
    return [
      '包含不當言論',
      '暴力威脅',
      '色情內容',
      '詐騙信息',
      '垃圾信息',
      '洩露個人信息',
      '發布他人姓名',
      '發布聯繫方式',
      '侵犯隱私',
      '仇恨言論',
      '其他違規內容',
    ];
  }

  /// 檢查用戶是否被限制發言
  Future<bool> isUserRestricted(String userId) async {
    // 這裡應該檢查用戶是否因為違規被限制
    // 暫時返回false
    return false;
  }

  /// 記錄用戶違規行為
  Future<void> recordViolation({
    required String userId,
    required String content,
    required String reason,
    required ModerationSeverity severity,
  }) async {
    try {
      // 記錄到數據庫或發送到服務器
      print('記錄違規: userId=$userId, reason=$reason, severity=$severity');

      // 根據嚴重程度決定處罰措施
      switch (severity) {
        case ModerationSeverity.high:
          // 嚴重違規：立即封禁
          await _banUser(userId, duration: const Duration(days: 7));
          break;
        case ModerationSeverity.medium:
          // 中等違規：警告或短期限制
          await _warnUser(userId);
          break;
        case ModerationSeverity.low:
          // 輕微違規：記錄警告
          await _logWarning(userId);
          break;
        case ModerationSeverity.none:
          break;
      }
    } catch (e) {
      print('記錄違規失敗: $e');
    }
  }

  Future<void> _banUser(String userId, {required Duration duration}) async {
    print('用戶 $userId 被封禁 ${duration.inDays} 天');
  }

  Future<void> _warnUser(String userId) async {
    print('用戶 $userId 收到警告');
  }

  Future<void> _logWarning(String userId) async {
    print('記錄用戶 $userId 的輕微違規');
  }
}

/// 內容審核結果
class ContentModerationResult {
  final bool isAllowed;
  final String reason;
  final ModerationSeverity severity;
  final String? flaggedWord;
  final List<String>? flaggedWords;
  final bool requiresReview;

  ContentModerationResult({
    required this.isAllowed,
    required this.reason,
    required this.severity,
    this.flaggedWord,
    this.flaggedWords,
    this.requiresReview = false,
  });
}

/// 審核嚴重程度
enum ModerationSeverity {
  none, // 無問題
  low, // 輕微問題
  medium, // 中等問題
  high, // 嚴重問題
}
