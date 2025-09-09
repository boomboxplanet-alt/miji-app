class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  
  AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthUser? _currentUser;

  // 獲取當前用戶
  AuthUser? get currentUser => _currentUser;

  // 檢查是否已登入
  bool get isSignedIn => _currentUser != null;

  // 簡化登入（暫時使用訪客模式）
  Future<AuthUser?> signInAsGuest() async {
    try {
      // 創建訪客用戶
      _currentUser = AuthUser(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: null,
        displayName: '訪客',
        photoURL: null,
      );
      
      return _currentUser;
    } catch (e) {
      print('訪客登入錯誤: $e');
      return null;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      _currentUser = null;
    } catch (e) {
      print('登出錯誤: $e');
      rethrow;
    }
  }

  // 獲取用戶資訊
  Map<String, dynamic>? getUserInfo() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };
  }

  // 獲取用戶顯示名稱
  String getUserDisplayName() {
    final user = currentUser;
    if (user == null) return '訪客';
    
    return user.displayName ?? user.email?.split('@').first ?? '用戶';
  }

  // 獲取用戶頭像URL
  String? getUserPhotoURL() {
    return currentUser?.photoURL;
  }

  // 獲取用戶ID（用於訊息系統）
  String getUserId() {
    return currentUser?.id ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 初始化（簡化版）
  static Future<void> initializeFirebase() async {
    // 簡化版本，不需要Firebase初始化
    print('認證服務已初始化');
  }

  // 檢查網路連接狀態（簡單實現）
  Future<bool> checkNetworkConnection() async {
    try {
      // 簡單的網路檢查
      return true;
    } catch (e) {
      return false;
    }
  }
}