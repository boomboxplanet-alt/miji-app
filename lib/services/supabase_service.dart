import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late SupabaseClient _supabase;

  /// 初始化 Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://btmfruykvyncefdbaqyz.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0bWZydXlrdnluY2VmZGJhcXl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NzYyNzgsImV4cCI6MjA3NDM1MjI3OH0.lezj2jl5Hy-TEV-ZqxbN7VzRLJtcwohs5tOhzqAFuQs',
      );

      _supabase = Supabase.instance.client;
      print('Supabase 初始化成功');
    } catch (e) {
      print('Supabase 初始化失敗: $e');
      rethrow;
    }
  }

  /// 獲取 Supabase 客戶端
  SupabaseClient get client => _supabase;

  /// Google 登入
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // 使用 Supabase 的 Google OAuth 流程
      final bool response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:8089', // 重定向到當前應用
      );

      if (response) {
        // 返回一個模擬的 AuthResponse
        return AuthResponse(
          user: _supabase.auth.currentUser,
          session: _supabase.auth.currentSession,
        );
      }

      return null;
    } catch (e) {
      print('Google 登入失敗: $e');
      rethrow;
    }
  }

  /// 訪客登入
  Future<AuthResponse?> signInAnonymously() async {
    try {
      final AuthResponse response = await _supabase.auth.signInAnonymously();
      return response;
    } catch (e) {
      print('訪客登入失敗: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      // 登出 Supabase
      await _supabase.auth.signOut();
      print('登出成功');
    } catch (e) {
      print('登出失敗: $e');
      rethrow;
    }
  }

  /// 獲取當前用戶
  User? get currentUser => _supabase.auth.currentUser;

  /// 監聽認證狀態變化
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// 檢查是否已登入
  bool get isSignedIn => currentUser != null;

  /// 獲取用戶信息
  Map<String, dynamic>? getUserInfo() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.id,
      'email': user.email,
      'displayName':
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      'photoURL': user.userMetadata?['avatar_url'],
    };
  }

  /// 重新載入用戶信息
  Future<void> reloadUser() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      print('重新載入用戶信息失敗: $e');
    }
  }
}
