# Miji App 開發指南

## 項目概述

Miji App 是一個基於 Flutter 開發的匿名社交地圖應用，採用現代化的架構設計和最佳實踐。

## 技術棧

### 前端框架
- **Flutter**: 3.4.0+
- **Dart**: 3.4.0+
- **Material Design**: 3.0+

### 狀態管理
- **Provider**: 6.1.1+
- **ChangeNotifier**: 內建狀態管理

### 地圖服務
- **Google Maps Flutter**: 2.10.1+
- **Google Maps API**: 自定義樣式

### 本地存儲
- **Hive**: 2.2.3+
- **Hive Flutter**: 1.1.0+

### 其他依賴
- **Google Fonts**: 6.3.0+
- **Confetti**: 0.8.0+
- **Audio Players**: 5.2.1+
- **HTTP**: 1.1.0+

## 項目結構

```
lib/
├── config/                 # 配置文件
│   └── ai_bot_config.dart
├── main.dart              # 應用入口
├── main_simple.dart       # 簡化版入口
├── models/                # 數據模型
│   ├── app_theme.dart
│   ├── message.dart
│   └── task.dart
├── providers/             # 狀態管理
│   ├── app_state.dart
│   ├── auth_provider.dart
│   ├── location_provider.dart
│   ├── message_provider.dart
│   └── task_provider.dart
├── screens/               # 頁面組件
│   ├── ai_bot_control_screen.dart
│   ├── content_filter_settings_screen.dart
│   ├── intro_screen.dart
│   ├── login_screen.dart
│   ├── map_screen.dart
│   ├── settings_screen.dart
│   ├── task_screen.dart
│   └── theme_selection_screen.dart
├── services/              # 業務邏輯
│   ├── ai_bot_service.dart
│   ├── ai_geographic_bot_service.dart
│   ├── auth_service.dart
│   ├── bot_message_service.dart
│   ├── bot_service.dart
│   ├── content_moderation_service.dart
│   ├── enhanced_ai_service.dart
│   ├── supabase_service.dart
│   ├── location_service.dart
│   ├── message_service.dart
│   ├── smart_message_generator.dart
│   ├── task_service.dart
│   ├── theme_service.dart
│   └── translation_service.dart
├── utils/                 # 工具類
│   ├── app_colors.dart
│   ├── app_strings.dart
│   └── constants.dart
└── widgets/               # 自定義組件
    ├── countdown_overlay.dart
    ├── glassmorphism_message_bubble.dart
    ├── glassmorphism_range_circle.dart
    ├── miji_fab.dart
    ├── quick_send_widget.dart
    └── reward_claim_dialog.dart
```

## 開發環境設置

### 系統要求
- **macOS**: 10.14+
- **Windows**: 10+
- **Linux**: Ubuntu 18.04+
- **Flutter**: 3.4.0+
- **Dart**: 3.4.0+

### 安裝步驟

1. **安裝 Flutter**
   ```bash
   # 下載 Flutter SDK
   git clone https://github.com/flutter/flutter.git
   
   # 添加到 PATH
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # 驗證安裝
   flutter doctor
   ```

2. **安裝依賴**
   ```bash
   # 進入項目目錄
   cd miji_app
   
   # 安裝依賴
   flutter pub get
   
   # 生成代碼
   flutter packages pub run build_runner build
   ```

3. **配置 IDE**
   - **VS Code**: 安裝 Flutter 和 Dart 擴展
   - **Android Studio**: 安裝 Flutter 插件
   - **IntelliJ IDEA**: 安裝 Flutter 插件

## 代碼規範

### 命名規範

#### 文件命名
- **小寫字母** + **下劃線**
- 例如：`message_provider.dart`, `map_screen.dart`

#### 類命名
- **大寫字母開頭** + **駝峰命名**
- 例如：`MessageProvider`, `MapScreen`

#### 變量命名
- **小寫字母開頭** + **駝峰命名**
- 例如：`messageList`, `isLoading`

#### 常量命名
- **全大寫字母** + **下劃線**
- 例如：`MAX_MESSAGE_LENGTH`, `DEFAULT_RADIUS`

### 代碼結構

#### 類結構順序
```dart
class ExampleClass extends StatefulWidget {
  // 1. 構造函數
  const ExampleClass({Key? key}) : super(key: key);
  
  // 2. 重寫方法
  @override
  State<ExampleClass> createState() => _ExampleClassState();
}

class _ExampleClassState extends State<ExampleClass> {
  // 1. 靜態常量
  static const double _defaultRadius = 1000.0;
  
  // 2. 實例變量
  late GoogleMapController _mapController;
  bool _isLoading = false;
  
  // 3. 生命週期方法
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  
  // 4. 私有方法
  void _initializeMap() {
    // 實現邏輯
  }
  
  // 5. 公共方法
  void updateLocation() {
    // 實現邏輯
  }
  
  // 6. 構建方法
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI 實現
    );
  }
}
```

### 註釋規範

#### 類註釋
```dart
/// 訊息提供者類
/// 
/// 負責管理訊息相關的狀態和邏輯，包括：
/// - 訊息的增刪改查
/// - 附近訊息的獲取
/// - 訊息狀態的管理
class MessageProvider extends ChangeNotifier {
  // 實現
}
```

#### 方法註釋
```dart
/// 獲取附近的訊息
/// 
/// [latitude] 緯度
/// [longitude] 經度
/// [radius] 搜索半徑（米）
/// 
/// 返回 [Future<List<Message>>] 附近的訊息列表
Future<List<Message>> fetchNearbyMessages(
  double latitude,
  double longitude,
  double radius,
) async {
  // 實現
}
```

#### 行內註釋
```dart
// 初始化地圖控制器
_mapController = controller;

// TODO: 添加錯誤處理
// FIXME: 修復內存洩漏問題
// NOTE: 這裡需要優化性能
```

## 狀態管理

### Provider 模式

#### 創建 Provider
```dart
class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // 更新狀態
  void _updateState() {
    notifyListeners();
  }
  
  // 業務方法
  Future<void> fetchMessages() async {
    _isLoading = true;
    _errorMessage = null;
    _updateState();
    
    try {
      _messages = await MessageService.getMessages();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _updateState();
    }
  }
}
```

#### 使用 Provider
```dart
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (messageProvider.errorMessage != null) {
          return Text('Error: ${messageProvider.errorMessage}');
        }
        
        return ListView.builder(
          itemCount: messageProvider.messages.length,
          itemBuilder: (context, index) {
            final message = messageProvider.messages[index];
            return MessageWidget(message: message);
          },
        );
      },
    );
  }
}
```

## 組件開發

### 自定義 Widget

#### 基本結構
```dart
class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  
  const CustomWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 實現
      ),
    );
  }
}
```

#### 動畫 Widget
```dart
class AnimatedWidget extends StatefulWidget {
  final Widget child;
  
  const AnimatedWidget({Key? key, required this.child}) : super(key: key);
  
  @override
  _AnimatedWidgetState createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
```

## 測試

### 單元測試

#### 測試 Provider
```dart
void main() {
  group('MessageProvider Tests', () {
    late MessageProvider provider;
    
    setUp(() {
      provider = MessageProvider();
    });
    
    tearDown(() {
      provider.dispose();
    });
    
    test('should initialize with empty messages', () {
      expect(provider.messages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
    
    test('should fetch messages successfully', () async {
      await provider.fetchMessages();
      expect(provider.messages, isNotEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}
```

#### 測試 Widget
```dart
void main() {
  group('MessageWidget Tests', () {
    testWidgets('should display message content', (WidgetTester tester) async {
      final message = Message(
        id: '1',
        content: 'Test message',
        latitude: 25.0330,
        longitude: 121.5654,
        radius: 1000.0,
        duration: 60,
        isAnonymous: true,
        createdAt: DateTime.now(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: MessageWidget(message: message),
        ),
      );
      
      expect(find.text('Test message'), findsOneWidget);
    });
  });
}
```

### 集成測試

#### 測試完整流程
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Miji App Integration Tests', () {
    testWidgets('Complete user flow test', (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pumpAndSettle();
      
      // 等待應用加載
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 驗證主界面元素
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // 測試發送訊息
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      expect(find.byType(BottomSheet), findsOneWidget);
      
      // 輸入訊息
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      
      // 發送訊息
      await tester.tap(find.text('發送'));
      await tester.pumpAndSettle();
      
      // 驗證發送成功
      expect(find.byType(BottomSheet), findsNothing);
    });
  });
}
```

## 性能優化

### 圖片優化

#### 使用 WebP 格式
```dart
Image.asset(
  'assets/images/logo.webp',
  width: 100,
  height: 100,
)
```

#### 實現圖片緩存
```dart
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  
  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
```

### 動畫優化

#### 使用 AnimatedBuilder
```dart
class OptimizedAnimatedWidget extends StatefulWidget {
  @override
  _OptimizedAnimatedWidgetState createState() => _OptimizedAnimatedWidgetState();
}

class _OptimizedAnimatedWidgetState extends State<OptimizedAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: ExpensiveWidget(), // 只構建一次
    );
  }
}
```

### 內存管理

#### 及時釋放資源
```dart
class ResourceManager {
  late StreamSubscription _subscription;
  late Timer _timer;
  
  void initialize() {
    _subscription = stream.listen((data) {
      // 處理數據
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // 定期任務
    });
  }
  
  void dispose() {
    _subscription.cancel();
    _timer.cancel();
  }
}
```

## 錯誤處理

### 異常處理策略

#### 網絡錯誤
```dart
Future<List<Message>> fetchMessages() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return parseMessages(response.body);
    } else {
      throw HttpException('HTTP ${response.statusCode}');
    }
  } on SocketException {
    throw NetworkException('網絡連接失敗');
  } on TimeoutException {
    throw NetworkException('請求超時');
  } catch (e) {
    throw UnknownException('未知錯誤: $e');
  }
}
```

#### 用戶界面錯誤
```dart
class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message;
    
    if (error is NetworkException) {
      message = '網絡連接失敗，請檢查網絡設置';
    } else if (error is TimeoutException) {
      message = '請求超時，請稍後重試';
    } else {
      message = '發生未知錯誤，請聯繫客服';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## 部署

### Web 部署

#### 構建 Web 版本
```bash
# 構建生產版本
flutter build web --release

# 構建開發版本
flutter build web --debug
```

#### 部署到服務器
```bash
# 複製構建文件到服務器
scp -r build/web/* user@server:/var/www/html/

# 或使用 rsync
rsync -av build/web/ user@server:/var/www/html/
```

### Android 部署

#### 構建 APK
```bash
# 構建發布版本
flutter build apk --release

# 構建調試版本
flutter build apk --debug
```

#### 構建 AAB
```bash
# 構建 Android App Bundle
flutter build appbundle --release
```

### iOS 部署

#### 構建 iOS 版本
```bash
# 構建 iOS 版本
flutter build ios --release

# 構建 iOS 版本（模擬器）
flutter build ios --simulator
```

## 版本管理

### 版本號規則
- **主版本號**：重大功能更新
- **次版本號**：新功能添加
- **修訂版本號**：錯誤修復

### 發布流程
1. **更新版本號**
2. **更新 CHANGELOG**
3. **創建 Git 標籤**
4. **構建發布版本**
5. **上傳到應用商店**

## 貢獻指南

### 提交代碼
1. **Fork 項目**
2. **創建功能分支**
3. **提交更改**
4. **推送到分支**
5. **創建 Pull Request**

### 代碼審查
- **功能完整性**
- **代碼質量**
- **測試覆蓋**
- **文檔更新**

## 常見問題

### Q: 如何調試地圖問題？
A: 檢查以下項目：
- Google Maps API 密鑰是否正確
- 網絡連接是否正常
- 位置權限是否已授予

### Q: 如何優化應用性能？
A: 建議：
- 使用 `flutter analyze` 檢查代碼
- 使用 `flutter build` 分析構建大小
- 使用性能分析工具

### Q: 如何處理內存洩漏？
A: 確保：
- 及時調用 `dispose()` 方法
- 取消訂閱和計時器
- 避免循環引用

---

**Miji App Development Team**  
*構建更好的匿名社交體驗*
