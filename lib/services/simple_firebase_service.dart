import 'package:google_sign_in/google_sign_in.dart';

class SimpleFirebaseService {
  static SimpleFirebaseService? _instance;
  static SimpleFirebaseService get instance => _instance ??= SimpleFirebaseService._();
  
  SimpleFirebaseService._();
  
  bool _isInitialized = false;
  GoogleSignIn? _googleSignIn;
  
  /// 初始化服務
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        _googleSignIn = GoogleSignIn(
          clientId: '508695711441-r97p5ql81s4u77sirfc04dni20hu53u0.apps.googleusercontent.com',
        );
        _isInitialized = true;
        print('Google Sign-In 初始化成功');
      }
    } catch (e) {
      print('Google Sign-In 初始化失敗: $e');
      _isInitialized = false;
    }
  }
  
  /// Google 登入
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      if (_googleSignIn == null) {
        throw Exception('Google Sign-In 未初始化');
      }
      
      final GoogleSignInAccount? account = await _googleSignIn!.signIn();
      
      if (account != null) {
        return {
          'uid': account.id,
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
        };
      }
      
      return null;
    } catch (e) {
      print('Google 登入失敗: $e');
      throw e;
    }
  }
  
  /// 登出
  Future<void> signOut() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      print('登出失敗: $e');
      throw e;
    }
  }
  
  /// 獲取當前用戶
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      if (_googleSignIn != null) {
        final GoogleSignInAccount? account = await _googleSignIn!.signInSilently();
        if (account != null) {
          return {
            'uid': account.id,
            'email': account.email,
            'displayName': account.displayName,
            'photoUrl': account.photoUrl,
          };
        }
      }
      return null;
    } catch (e) {
      print('獲取當前用戶失敗: $e');
      return null;
    }
  }
  
  /// 監聽認證狀態變化
  Stream<Map<String, dynamic>?> get authStateChanges async* {
    while (true) {
      try {
        final user = await getCurrentUser();
        yield user;
        await Future.delayed(Duration(seconds: 1));
      } catch (e) {
        yield null;
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }
}
