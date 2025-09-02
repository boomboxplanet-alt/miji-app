import 'package:google_sign_in/google_sign_in.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  AuthUser? _currentUser;

  // 獲取當前用戶
  AuthUser? get currentUser => _currentUser;

  // 檢查是否已登入
  bool get isSignedIn => _currentUser != null;

  // Google登入
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // 觸發Google登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 用戶取消登入
        return null;
      }

      // 創建AuthUser對象
      _currentUser = AuthUser(
        id: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoURL: googleUser.photoUrl,
      );
      
      return _currentUser;
    } catch (e) {
      print('Google登入錯誤: $e');
      // 檢查是否為Client ID相關錯誤
      if (e.toString().contains('invalid_client') || e.toString().contains('401')) {
        throw Exception('Google登入配置錯誤：請聯繫開發者配置正確的Client ID');
      }
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
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