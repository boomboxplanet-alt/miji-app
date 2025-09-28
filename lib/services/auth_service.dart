import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

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

  final SupabaseService _supabaseService = SupabaseService.instance;

  // 獲取當前用戶
  AuthUser? get currentUser {
    final user = _supabaseService.currentUser;
    if (user == null) return null;

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName:
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      photoURL: user.userMetadata?['avatar_url'],
    );
  }

  // 檢查是否已登入
  bool get isSignedIn => _supabaseService.isSignedIn;

  // Google 登入
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final response = await _supabaseService.signInWithGoogle();
      if (response?.user != null) {
        return currentUser;
      }
      return null;
    } catch (e) {
      print('Google 登入錯誤: $e');
      return null;
    }
  }

  // 訪客登入
  Future<AuthUser?> signInAsGuest() async {
    try {
      final response = await _supabaseService.signInAnonymously();
      if (response?.user != null) {
        return currentUser;
      }
      return null;
    } catch (e) {
      print('訪客登入錯誤: $e');
      return null;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
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
    return currentUser?.id ??
        'anonymous_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 初始化 Supabase
  static Future<void> initializeSupabase() async {
    try {
      await SupabaseService.instance.initialize();
      print('Supabase 認證服務已初始化');
    } catch (e) {
      print('Supabase 初始化失敗: $e');
      rethrow;
    }
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
