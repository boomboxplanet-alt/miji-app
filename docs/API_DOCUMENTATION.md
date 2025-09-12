# Miji App API 文檔

## 概述

Miji App 是一個基於 Flutter 開發的社交地圖應用，提供匿名訊息分享和地理位置互動功能。

## 核心架構

### 狀態管理 (Provider Pattern)

應用使用 Provider 模式進行狀態管理，主要包含以下 Provider：

#### MessageProvider
負責管理訊息相關的狀態和邏輯。

```dart
class MessageProvider extends ChangeNotifier {
  List<Message> messages = [];
  bool isLoading = false;
  String? errorMessage;
  
  // 主要方法
  void fetchNearbyMessages(double latitude, double longitude, double radius);
  void addMessage(String content, double latitude, double longitude, double radius, int duration, bool isAnonymous);
  void clearError();
}
```

#### LocationProvider
管理用戶位置相關功能。

```dart
class LocationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  
  // 主要方法
  Future<void> getCurrentLocation();
  void clearError();
}
```

#### TaskProvider
處理任務系統相關邏輯。

```dart
class TaskProvider extends ChangeNotifier {
  List<Task> claimableTasks = [];
  int bonusDurationMinutes = 0;
  int bonusRangeMeters = 0;
  
  // 主要方法
  void claimTask(String taskId);
  void addBonusDuration(int minutes);
  void addBonusRange(int meters);
}
```

#### AuthProvider
管理用戶認證狀態。

```dart
class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  User? currentUser;
  
  // 主要方法
  Future<void> signIn();
  Future<void> signOut();
}
```

## 服務層 (Services)

### MessageService
處理訊息的 CRUD 操作。

```dart
class MessageService {
  static Future<List<Message>> getNearbyMessages(double latitude, double longitude, double radius);
  static Future<void> sendMessage(Message message);
  static Future<void> deleteMessage(String messageId);
}
```

### LocationService
提供位置相關服務。

```dart
class LocationService {
  static Future<Position> getCurrentPosition();
  static Future<String> getAddressFromCoordinates(double latitude, double longitude);
  static Future<List<Place>> searchNearbyPlaces(double latitude, double longitude, double radius);
}
```

### AIGeographicBotService
AI 機器人服務，模擬真實用戶行為。

```dart
class AIGeographicBotService {
  void startService();
  void stopService();
  void updateUserLocation(double latitude, double longitude);
  void updateUserRadius(double radius);
  void setOnMessageGenerated(Function(Message) callback);
}
```

## 主要組件 (Widgets)

### MapScreen
主地圖界面，包含地圖顯示和訊息氣泡。

```dart
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  
  // 主要方法
  void _onMapCreated(GoogleMapController controller);
  void _openQuickSendSheet();
  void _showMessageDetail(Message message);
}
```

### GlassmorphismMessageBubble
玻璃態效果的訊息氣泡組件。

```dart
class GlassmorphismMessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 玻璃態效果實現
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(...),
          boxShadow: [...],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(...),
        ),
      ),
    );
  }
}
```

### MijiFAB
自定義的浮動操作按鈕。

```dart
class MijiFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  
  @override
  _MijiFABState createState() => _MijiFABState();
}

class _MijiFABState extends State<MijiFAB> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  
  // 動畫效果
  void _handleTapDown(TapDownDetails details);
  void _handleTapUp(TapUpDetails details);
  void _handleTapCancel();
}
```

## 數據模型 (Models)

### Message
訊息數據模型。

```dart
class Message {
  final String id;
  final String content;
  final double latitude;
  final double longitude;
  final double radius;
  final int duration;
  final bool isAnonymous;
  final DateTime createdAt;
  final String? nickname;
  final String? gender;
  final int likeCount;
  final int viewCount;
  
  Message({
    required this.id,
    required this.content,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.duration,
    required this.isAnonymous,
    required this.createdAt,
    this.nickname,
    this.gender,
    this.likeCount = 0,
    this.viewCount = 0,
  });
}
```

### Task
任務數據模型。

```dart
class Task {
  final String id;
  final String title;
  final String description;
  final String type;
  final int rewardDuration;
  final int rewardRange;
  final bool isCompleted;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rewardDuration,
    required this.rewardRange,
    this.isCompleted = false,
  });
}
```

## 配置和常數

### AppColors
應用顏色配置。

```dart
class AppColors {
  static const Color primary = Color(0xFFFF6B9D);
  static const Color secondary = Color(0xFF8E44AD);
  static const Color accent = Color(0xFF6C5CE7);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
}
```

### AppStrings
應用字符串配置。

```dart
class AppStrings {
  static const String appName = 'Miji';
  static const String appDescription = '匿名社交地圖應用';
  static const String sendMessage = '發送訊息';
  static const String cancel = '取消';
  static const String anonymous = '匿名';
  static const String settings = '設定';
  static const String taskCenter = '任務中心';
}
```

## 地圖配置

### 地圖樣式
應用使用自定義的地圖樣式，主要特點：
- 粉紫色漸變背景
- 隱藏商業地標
- 突出顯示街道名稱
- 玻璃態效果

```dart
class MapStyles {
  static const String pinkPurpleStyle = '''
  [
    {
      "featureType": "all",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#FFE4E1"
        }
      ]
    },
    // ... 更多樣式配置
  ]
  ''';
}
```

## 性能優化

### 圖片優化
- 使用 WebP 格式
- 實現圖片緩存
- 延遲加載

### 動畫優化
- 使用 `AnimatedBuilder` 減少重建
- 實現動畫控制器複用
- 優化動畫性能

### 內存管理
- 及時釋放資源
- 使用 `dispose()` 方法
- 避免內存洩漏

## 錯誤處理

### 異常處理策略
```dart
try {
  // 業務邏輯
} catch (e) {
  if (e is SocketException) {
    // 網絡錯誤處理
  } else if (e is TimeoutException) {
    // 超時錯誤處理
  } else {
    // 其他錯誤處理
  }
}
```

### 錯誤日誌
```dart
void logError(String message, dynamic error, StackTrace stackTrace) {
  // 記錄錯誤日誌
  print('Error: $message');
  print('Exception: $error');
  print('Stack trace: $stackTrace');
}
```

## 測試

### 單元測試
```dart
void main() {
  group('MessageProvider Tests', () {
    test('should initialize with empty messages', () {
      final provider = MessageProvider();
      expect(provider.messages, isEmpty);
    });
  });
}
```

### 集成測試
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete user flow test', (WidgetTester tester) async {
    // 測試完整用戶流程
  });
}
```

## 部署

### Web 部署
```bash
flutter build web --release
```

### Android 部署
```bash
flutter build apk --release
```

### iOS 部署
```bash
flutter build ios --release
```

## 版本歷史

### v1.3(9.13)
- 完成系統檢查和優化
- 修復所有編譯警告
- 添加測試覆蓋
- 完善文檔

### v1.3(9.12)
- 重新設計浮動按鈕
- 優化訊息氣泡UI
- 改進地圖樣式

### v1.2(9.11)
- 基礎功能實現
- 地圖集成
- 訊息系統

## 貢獻指南

1. Fork 項目
2. 創建功能分支
3. 提交更改
4. 推送到分支
5. 創建 Pull Request

## 許可證

本項目採用 MIT 許可證。
