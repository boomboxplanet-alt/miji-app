// 模擬 Firebase 服務，不依賴實際的 Firebase 包
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  bool _isInitialized = false;
  
  /// 初始化 Firebase（模擬）
  Future<void> initialize() async {
    try {
      // 模擬初始化過程
      await Future.delayed(Duration(milliseconds: 100));
      _isInitialized = true;
      print('Firebase 初始化成功 - 秘跡miji 項目（模擬模式）');
    } catch (e) {
      print('Firebase 初始化失敗: $e');
      _isInitialized = false;
    }
  }
  
  /// Google 登入（模擬）
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // 模擬登入過程
      await Future.delayed(Duration(milliseconds: 500));
      
      return {
        'uid': 'mock_user_123',
        'email': 'user@example.com',
        'displayName': '測試用戶',
        'photoURL': null,
      };
    } catch (e) {
      print('Google 登入失敗: $e');
      return null;
    }
  }
  
  /// 登出（模擬）
  Future<void> signOut() async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      print('登出成功（模擬）');
    } catch (e) {
      print('登出失敗: $e');
    }
  }
  
  /// 獲取當前用戶（模擬）
  dynamic get currentUser {
    return _isInitialized ? {
      'uid': 'mock_user_123',
      'email': 'user@example.com',
      'displayName': '測試用戶',
      'photoURL': null,
    } : null;
  }
  
  /// 監聽認證狀態變化（模擬）
  Stream<dynamic> get authStateChanges {
    return Stream.value(currentUser);
  }
}